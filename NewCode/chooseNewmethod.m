classdef chooseNewmethod 
    properties   
        iter_max=50;

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
            
            Lambda=zeros(D.Nr+D.Ne,1)+0.0;

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
    end
end