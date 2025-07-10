classdef chooseNewmethod<A_OptMethod
    properties   
        iter_max=200;

        beta=1;
        mu=1; 

        debug=1;
    end
    methods  
        function obj=chooseNewmethod() 
        end
 
        function [Pev,Pbuy,Pbat,Lambda] = Solve(obj,D,GG2Bat,SOC,SOCV_of_EV,k)
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);

            X1=[Pev;Pbuy];
            
            Lambda=zeros(D.Nr+D.Ne,1)+0.1;

            % Main iteration
            for iter=1:obj.iter_max 
                %%
                % Update X1 (Ne+Nr,1) )
                                          %lambda,PevPbuy_old,beta,L_old,mu,x0
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,0,X1);
                %%
                % Update tilde_Lambda
                tilde_Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1);
                %%
                % Update Pev
                for i=1:D.Ne 
                    if SOCV_of_EV(i)>=1
                        Pev(i)=0;
                    else                        
                        Pev(i)=D.minEV.Solve(tilde_Lambda(i),0,0,Pev(i),obj.mu);
                    end
                end 
                %%
                % Update Pbuy and Pbat
                for j=1:D.Nr             
                    [x,y]=D.minResident.Solve(tilde_Lambda(j+D.Ne),0,0,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k);
                    Pbuy(j)=x;Pbat(j)=y;
                end 
                %%
                % Update Lambda
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1);


                %val=norm(Lambda-Lambdaold)/norm(Lambda);
                if norm([Pev;Pbuy]-X1)<=1e-5 && iter>3
                    %disp('non-convergence')
                    %pause
                    disp([Lambda(1),iter])
                    break;
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
                X1=D.minREP.Solve_quadprog(Lambda,[Pev;Pbuy],obj.beta,X1,0,X1);

                fvalue=fvalue+D.minREP.Cost_fun(X1);
                %%
                tilde_Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1); 
                %%
                for i=1:D.Ne 
                    Pev(i)=D.minEV.Solve(tilde_Lambda(i),0,0,Pev(i),obj.mu);

                    fvalue=fvalue-D.minEV.Utility_fun(Pev(i));
                end  
                %%
                for j=1:D.Nr 
                    [x,y]=D.minResident.Solve(tilde_Lambda(j+D.Ne),0,0,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k);
                    Pbuy(j)=x;Pbat(j)=y;

                    fvalue=fvalue-D.minResident.Utility_fun(x,y,j,k)+D.minResident.Cost_func(y,GG2Bat(j),SOC(j));
                end                 
                %%
                Lambda=Lambda-obj.beta*([Pev;Pbuy]-X1);
                %%
                f(iter)=fvalue;
                Originale(iter)=norm([Pev;Pbuy]-X1);
                Consistente(iter)=norm([Pev;Pbuy]-PevPbuyold);
            end
        end
    end
end