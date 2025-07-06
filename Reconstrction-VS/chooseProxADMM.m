classdef chooseProxADMM<A_OptMethod
    properties   
        iter_max=20;
        beta=1;
        mu=1;

        debug=1;
    end
    methods  
        function obj=chooseProxADMM() 
        end
 
        function [Pev,Pbuy,Pbat,Lambda] = Solve(obj,D,GG2Bat,SOC,k)
            % Initialization
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            X1=[Pev;Pbuy];
            Lambda=zeros(D.Nr+D.Ne,1)+0.1; 

            % Main iteration
            for iter=1:obj.iter_max 

                % Solve each x_j-subproblem
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,obj.mu,X1); 

                for i=1:D.Ne 
                    Pev(i)=D.minEV.Solve(Lambda(i),X1(i),obj.beta,Pev(i),obj.mu); 
                end 

                for j=1:D.Nr
                    [x,y]=D.minResident.Solve(Lambda(j+D.Ne),X1(D.Ne+j),obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k);
                    Pbuy(j)=x;Pbat(j)=y;
                end   
                 
                % Update dual variable
                Lambdaold=Lambda;
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1); 

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

            f=zeros(1,new_iter);
            Originale=zeros(1,new_iter);
            Consistente=zeros(1,new_iter); 
             for iter=1:new_iter 
                fvalue=0;
                PevPbuyold=[Pev;Pbuy]; 

                % Solve each x_j-subproblem
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,obj.mu,X1);

                fvalue=fvalue+D.minREP.Cost_fun(X1); 

                for i=1:D.Ne 
                    Pev(i)=D.minEV.Solve(Lambda(i),X1(i),obj.beta,Pev(i),obj.mu);

                    fvalue=fvalue-D.minEV.Utility_fun(Pev(i));
                end 

                for j=1:D.Nr                    
                    [x,y]=D.minResident.Solve(Lambda(j+D.Ne),X1(D.Ne+j),obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k);
                    Pbuy(j)=x;Pbat(j)=y;

                    fvalue=fvalue-D.minResident.Utility_fun(x,y,j,k)+D.minResident.Cost_func(y,GG2Bat(j),SOC(j));
                end  
                 
                % Update dual variable 
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1); 

                f(iter)=fvalue;
                Originale(iter)=norm([Pev;Pbuy]-X1);
                Consistente(iter)=norm([Pev;Pbuy]-PevPbuyold); 
            end
        end

    end
end