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
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            L=0;
            Lambda=0.1;

            for iter=1:obj.iter_max
                Lambdaold=Lambda;
                PevPbuyold=[Pev;Pbuy];

                % Solve each x_j-subproblem
                L=D.minREP.Solve(Lambda,sum([Pev;Pbuy]),obj.beta,L,obj.mu);
                for i=1:D.Ne
                    if isempty(D.B)
                        UB=400;
                    else
                        Bool=logical(D.A(:,i));
                        UB= D.B- (D.A*PevPbuyold-D.A(:,i).*PevPbuyold(i));
                        UB=min(UB(Bool));
                    end
                    xx=D.minEV.Solve(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pev(i),obj.mu,UB);
                    if isempty(xx)
                        xx=0;
                    end
                    Pev(i)=xx;
                end

                for j=1:D.Nr
                    if isempty(D.B)
                        UB=400;
                    else
                        Bool=logical(D.A(:,D.Ne+j));
                        UB= D.B- (D.A*PevPbuyold-D.A(:,D.Ne+j).*PevPbuyold(D.Ne+j));
                        UB=min(UB(Bool));
                    end
                    [x,y]=D.minResident.Solve(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k,UB);
                    Pbuy(j)=x;Pbat(j)=y;
                end

                % Update dual variable
                Lambda=Lambda-obj.beta*(sum([Pev;Pbuy])-L);

                if norm(Lambda-Lambdaold)/norm(Lambda)<=1e-3 && iter>3
                    break
                end
            end
        end


        function [Originale,Consistente,f,Pbat]=Solve_convergence(obj,D,GG2Bat,SOC,k,new_iter)
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);
            L=0;
            Lambda=0.1;

            f=zeros(1,new_iter);
            Originale=zeros(1,new_iter);
            Consistente=zeros(1,new_iter);
            for iter=1:new_iter
                fvalue=0;
                PevPbuyold=[Pev;Pbuy];

                % Solve each x_j-subproblem
                L=D.minREP.Solve(Lambda,sum([Pev;Pbuy]),obj.beta,L,obj.mu);

                fvalue=fvalue+D.minREP.Cost_fun(L);

                for i=1:D.Ne
                    if isempty(D.B)
                        UB=400;
                    else
                        Bool=logical(D.A(:,i));
                        UB= D.B- (D.A*PevPbuyold-D.A(:,i).*PevPbuyold(i));
                        UB=min(UB(Bool));
                    end
                    xx=D.minEV.Solve(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pev(i),obj.mu,UB);
                    if isempty(xx)
                        xx=0;
                    end
                    Pev(i)=xx;

                    fvalue=fvalue-D.minEV.Utility_fun(Pev(i));
                end

                for j=1:D.Nr
                    if isempty(D.B)
                        UB=400;
                    else
                        Bool=logical(D.A(:,D.Ne+j));
                        UB= D.B- (D.A*PevPbuyold-D.A(:,D.Ne+j).*PevPbuyold(D.Ne+j));
                        UB=min(UB(Bool));
                    end
                    [x,y]=D.minResident.Solve(Lambda,sum([Pev;Pbuy])-L,obj.beta,Pbuy(j),Pbat(j),SOC(j),GG2Bat(j),obj.mu,j,k,UB);
                    Pbuy(j)=x;Pbat(j)=y;

                    fvalue=fvalue-D.minResident.Utility_fun(x,y,j,k)+D.minResident.Cost_func(y,GG2Bat(j),SOC(j));
                end

                % Update dual variable
                Lambda=Lambda-obj.beta*(sum([Pev;Pbuy])-L);

                f(iter)=fvalue;
                Originale(iter)=norm(sum([Pev;Pbuy])-L);
                Consistente(iter)=norm([Pev;Pbuy]-PevPbuyold);
            end
        end

    end
end