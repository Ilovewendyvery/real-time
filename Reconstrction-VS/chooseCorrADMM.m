classdef chooseCorrADMM<A_OptMethod
    properties   
        iter_max=20;
        beta=1;  

        gamma=1;
 
        debug=1;
    end
    methods  
        function obj=chooseCorrADMM()
        end
 
        function [Pev,Pbuy,Pbat,Lambda] = Solve(obj,D,GG2Bat,SOC,k)
            % Initialization
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            X1=[Pev;Pbuy];
            Lambda=zeros(D.Nr+D.Ne,1)+0.1;  

            alpha=obj.gamma*(1-sqrt((D.Ne+D.Nr+1)/(D.Ne+D.Nr+2)));

            % Main iteration
            for iter=1:obj.iter_max 
                X1old=X1;
                Pevold=Pev;
                Pbuyold=Pbuy;
                Pbatold=Pbat;
                Lambdaold=Lambda;

                % Solve each x_j-subproblem
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,0,X1); 

                for i=1:D.Ne 
                    Pev(i)=D.minEV.Solve(Lambda(i),X1(i),obj.beta,Pev(i),0);
                end 

                for j=1:D.Nr                    
                    [x,y]=D.minResident.Solve(Lambda(j+D.Ne),X1(D.Ne+j),obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),0,j,k);
                    Pbuy(j)=x;Pbat(j)=y;
                end  
                 
                % Update dual variable 
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1); 

                X1=X1-alpha*(X1-X1old);
                Pev=Pev-alpha*(Pev-Pevold);
                Pbuy=Pbuy-alpha*(Pbuy-Pbuyold);
                Pbat=Pbat-alpha*(Pbat-Pbatold);
                Lambda=Lambda-alpha*(Lambda-Lambdaold); 

                % Stopping criterion
                if norm(Lambda-Lambdaold)/norm(Lambda)<=1e-3 && iter>3
                    break
                end 
            end
        end

        function [Originale,Consistente,f,Pbat]=Solve_convergence(obj,D,GG2Bat,SOC,k,new_iter)  
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            X1=[Pev;Pbuy];
            Lambda=zeros(D.Nr+D.Ne,1)+0.1;

            alpha=obj.gamma*(1-sqrt((D.Ne+D.Nr+1)/(D.Ne+D.Nr+2)));

            f=zeros(1,new_iter);
            Originale=zeros(1,new_iter);
            Consistente=zeros(1,new_iter); 
             for iter=1:new_iter 
                fvalue=0;
                PevPbuyold=[Pev;Pbuy]; 
                X1old=X1;
                Pevold=Pev;
                Pbuyold=Pbuy;
                Pbatold=Pbat;
                Lambdaold=Lambda;

                % Solve each x_j-subproblem
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,0,X1);

                fvalue=fvalue+D.minREP.Cost_fun(X1); 

                for i=1:D.Ne 
                    Pev(i)=D.minEV.Solve(Lambda(i),X1(i),obj.beta,Pev(i),0);

                    fvalue=fvalue-D.minEV.Utility_fun(Pev(i));
                end 

                for j=1:D.Nr                    
                    [x,y]=D.minResident.Solve(Lambda(j+D.Ne),X1(D.Ne+j),obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),0,j,k);
                    Pbuy(j)=x;Pbat(j)=y;

                    fvalue=fvalue-D.minResident.Utility_fun(x,y,j,k)+D.minResident.Cost_func(y,GG2Bat(j),SOC(j));
                end    

                
                % Update dual variable 
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1); 

                X1=X1-alpha*(X1-X1old);
                Pev=Pev-alpha*(Pev-Pevold);
                Pbuy=Pbuy-alpha*(Pbuy-Pbuyold);
                Pbat=Pbat-alpha*(Pbat-Pbatold);
                Lambda=Lambda-alpha*(Lambda-Lambdaold); 

                f(iter)=fvalue;
                Originale(iter)=norm([Pev;Pbuy]-X1);
                Consistente(iter)=norm([Pev;Pbuy]-PevPbuyold); 
            end
        end

    end
end