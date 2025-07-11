classdef chooseCorrADMM<A_OptMethod
    properties
        iter_max=200;
        beta=1;

        gamma=1;

        debug=1;
    end
    methods
        function obj=chooseCorrADMM()
        end

        function [Pev,Pbuy,Pbat,Lambda] = Solve(obj,D,GG2Bat,SOC,SOCV_of_EV,k)
           Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            L=0;
            Lambda=0.1;

            alpha=obj.gamma*(1-sqrt((D.Ne+D.Nr+1)/(D.Ne+D.Nr+2))); 
            for iter=1:obj.iter_max 
                PevPbuyold=[Pev;Pbuy];
                Lold=L;
                Pevold=Pev;
                Pbuyold=Pbuy;
                Pbatold=Pbat;
                Lambdaold=Lambda;

                % Solve each x_j-subproblem
                L=D.minREP.Solve_T(Lambda,sum([Pev;Pbuy]),obj.beta,L,0); 
                for i=1:D.Ne                    
                    if SOCV_of_EV(i)>=1
                        Pev(i)=0;
                    else
                        if isempty(D.B_feeder)
                            UB=400;
                        else
                            Bool=logical(D.U_feeder(:,i));
                            UB= D.B_feeder- (D.U_feeder*PevPbuyold-D.U_feeder(:,i).*PevPbuyold(i));
                            UB=min(UB(Bool));
                        end
                        xx=D.minEV.Solve_T(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pev(i),0,UB);
                        if isempty(xx)
                            xx=0;
                        end
                        Pev(i)=xx;
                    end
                end

                for j=1:D.Nr
                    if isempty(D.B_feeder)
                        UB=400;
                    else
                        Bool=logical(D.U_feeder(:,D.Ne+j));
                        UB= D.B_feeder- (D.U_feeder*PevPbuyold-D.U_feeder(:,D.Ne+j).*PevPbuyold(D.Ne+j));
                        UB=min(UB(Bool));
                    end
                    [x,y]=D.minResident.Solve_T(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),0,j,k,UB);
                    Pbuy(j)=x;Pbat(j)=y; 
                end 

                % Update dual variable
                Lambda=Lambda-obj.beta*(sum([Pev;Pbuy])-L);

                L=L-alpha*(L-Lold);
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

        function [Originale,Consistente,f,Pbat]=Solve_convergence(obj,D,GG2Bat,SOC,SOCV_of_EV,k,new_iter)
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            L=0;
            Lambda=0.1;

            alpha=obj.gamma*(1-sqrt((D.Ne+D.Nr+1)/(D.Ne+D.Nr+2)));

            f=zeros(1,new_iter);
            Originale=zeros(1,new_iter);
            Consistente=zeros(1,new_iter);
            for iter=1:new_iter
                fvalue=0;
                PevPbuyold=[Pev;Pbuy];
                Lold=L;
                Pevold=Pev;
                Pbuyold=Pbuy;
                Pbatold=Pbat;
                Lambdaold=Lambda;

                % Solve each x_j-subproblem
                L=D.minREP.Solve_T(Lambda,sum([Pev;Pbuy]),obj.beta,L,0);

                fvalue=fvalue+D.minREP.Cost_fun(L);
                for i=1:D.Ne 
                    if SOCV_of_EV(i)>=1
                        Pev(i)=0;
                        fvalue=fvalue-D.minEV.Utility_fun(D.minEV.Pmax_ev);
                    else
                        if isempty(D.B_feeder)
                            UB=400;
                        else
                            Bool=logical(D.U_feeder(:,i));
                            UB= D.B_feeder- (D.U_feeder*PevPbuyold-D.U_feeder(:,i).*PevPbuyold(i));
                            UB=min(UB(Bool));
                        end
                        xx=D.minEV.Solve_T(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pev(i),0,UB);
                        if isempty(xx)
                            xx=0;
                        end
                        Pev(i)=xx;
                        
                        fvalue=fvalue-D.minEV.Utility_fun(Pev(i));
                    end
                end
                
                
                for j=1:D.Nr
                    if isempty(D.B_feeder)
                        UB=400;
                    else
                        Bool=logical(D.U_feeder(:,D.Ne+j));
                        UB= D.B_feeder- (D.U_feeder*PevPbuyold-D.U_feeder(:,D.Ne+j).*PevPbuyold(D.Ne+j));
                        UB=min(UB(Bool));
                    end
                    [x,y]=D.minResident.Solve_T(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),0,j,k,UB);
                    Pbuy(j)=x;Pbat(j)=y;

                    fvalue=fvalue-D.minResident.Utility_fun(x,y,j,k)+D.minResident.Cost_func(y,GG2Bat(j),SOC(j));
                end 
                % Update dual variable
                Lambda=Lambda-obj.beta*(sum([Pev;Pbuy])-L);

                L=L-alpha*(L-Lold);
                Pev=Pev-alpha*(Pev-Pevold);
                Pbuy=Pbuy-alpha*(Pbuy-Pbuyold);
                Pbat=Pbat-alpha*(Pbat-Pbatold);
                Lambda=Lambda-alpha*(Lambda-Lambdaold);



                f(iter)=fvalue;
                Originale(iter)=norm(sum([Pev;Pbuy])-L);
                Consistente(iter)=norm([Pev;Pbuy]-PevPbuyold);
            end
        end

    end
end