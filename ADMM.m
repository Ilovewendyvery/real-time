classdef ADMM<A_OptMethod
    properties
        iter_max=30;
        beta=1;

        gamma=1;

        debug=1;
    end
    methods
        function obj=ADMM()
        end

        function [Pev,Pbuy,Pbat,Lambda] = Solve(obj,D,GG2Bat,SOC,SOCV_of_EV,k)
            rho=obj.beta;
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);

            Pold=[Pev;Pbuy;Pbat]; L=0;Lambda=0;

            for iter=1:obj.iter_max
                Lambdaold=Lambda;


                GG2user_j_k=D.BPVL.GG2user(:,k);
                GC_j_k=D.BPVL.GC(:,k);
                GG2Bat_j=GG2Bat;
                fun  = @(P) sum(-Utility_fun_EV(P(1:D.Ne,:)),1)...
                    +sum(-Utility_fun_Resident(P(1+D.Ne:D.Nr+D.Ne,:),P(1+D.Ne+D.Nr:end,:),GG2user_j_k,GC_j_k),1)...
                    +sum(Cost_func(P(1+D.Ne+D.Nr:end),GG2Bat_j,SOC),1)...
                    +rho/2*(sum(P(1:D.Ne+D.Nr,:))-L+Lambda)*(sum(P(1:D.Ne+D.Nr,:))-L+Lambda);

                % 初始�?
                x0 = Pold;

                % 线�?�不等式约束 A*x �? b
                b=D.B_feeder;
                A=[D.U_feeder,zeros(length(b),D.Nr)];

                % 线�?�等式约�? Aeq*x = beq
                Aeq = [];
                beq = [];

                % 变量下界和上�?
                lb = zeros(1,D.Ne+D.Nr+D.Nr);
                ub = zeros(1,D.Ne+D.Nr+D.Nr);
                Pmax_ev=10;
                ub(1:D.Ne)=Pmax_ev.*(SOCV_of_EV<=1);

                Capacity_bat=10;% kw*h
                bat_beta=1;
                eta=0.95;
                Time_int=0.5;
                ub(1+D.Ne:D.Ne+D.Nr)=D.BPVL.GC(:,k);
                ubat=bat_beta*(SOC*Capacity_bat+eta*GG2Bat*Time_int)*eta/Time_int;
                ubat=max(ubat,0.01*ones(D.Nr,1));
                ub(1+D.Ne+D.Nr:end)=ubat;

                % 求解
                options = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'interior-point');
                [P] = fmincon(fun, x0, A, b, Aeq, beq, lb, ub, [], options);
                %%

                % Solve each x_j-subproblem
                L=D.minREP.Solve_T(-Lambda,sum(P(1:D.Ne+D.Nr)),obj.beta,L,0);
                % Update dual variable
                Lambda=Lambda+obj.gamma*(sum(P(1:D.Ne+D.Nr))-L); 

                Pold=P;

                % Stopping criterion
                if norm(Lambda-Lambdaold)/norm(Lambda)<=1e-3 && iter>3
                    break
                end
            end
            Pev=P(1:D.Ne,1);
            Pbuy=P(1+D.Ne:D.Nr+D.Ne);
            Pbat=P(1+D.Ne+D.Nr:end,1); 
        end

        function [Originale,Consistente,f,Pbat]=Solve_convergence(obj,D,GG2Bat,SOC,SOCV_of_EV,k,new_iter)
            rho=obj.beta;
            Pev=zeros(D.Ne,1);
            Pbuy=zeros(D.Nr,1);
            Pbat=zeros(D.Nr,1);

            
            Pold=[Pev;Pbuy;Pbat]; L=0;Lambda=0;
            
            f=zeros(1,new_iter);
            Originale=zeros(1,new_iter);
            Consistente=zeros(1,new_iter);

            for iter=1:new_iter
                % 定义目标函数（非线�?�凸函数�?
                GG2user_j_k=D.BPVL.GG2user(:,k);
                GC_j_k=D.BPVL.GC(:,k);
                GG2Bat_j=GG2Bat;
                fun  = @(P) sum(-Utility_fun_EV(P(1:D.Ne,:)),1)...
                    +sum(-Utility_fun_Resident(P(1+D.Ne:D.Nr+D.Ne,:),P(1+D.Ne+D.Nr:end,:),GG2user_j_k,GC_j_k),1)...
                    +sum(Cost_func(P(1+D.Ne+D.Nr:end),GG2Bat_j,SOC),1)...
                    +rho/2*(sum(P(1:D.Ne+D.Nr,:))-L+Lambda)*(sum(P(1:D.Ne+D.Nr,:))-L+Lambda);
                fun2 = @(P) sum(-Utility_fun_EV(P(1:D.Ne,:)),1)...
                    +sum(-Utility_fun_Resident(P(1+D.Ne:D.Nr+D.Ne,:),P(1+D.Ne+D.Nr:end,:),GG2user_j_k,GC_j_k),1)...
                    +sum(Cost_func(P(1+D.Ne+D.Nr:end),GG2Bat_j,SOC),1);

                % 初始�?
                x0 = Pold;

                % 线�?�不等式约束 A*x �? b
                b=D.B_feeder;
                A=[D.U_feeder,zeros(length(b),D.Nr)];

                % 线�?�等式约�? Aeq*x = beq
                Aeq = [];
                beq = [];

                % 变量下界和上�?
                lb = zeros(1,D.Ne+D.Nr+D.Nr);
                ub = zeros(1,D.Ne+D.Nr+D.Nr);
                Pmax_ev=10;
                ub(1:D.Ne)=Pmax_ev.*(SOCV_of_EV<=1);

                Capacity_bat=10;% kw*h
                bat_beta=1;
                eta=0.95;
                Time_int=0.5;
                ub(1+D.Ne:D.Ne+D.Nr)=D.BPVL.GC(:,k);
                ubat=bat_beta*(SOC*Capacity_bat+eta*GG2Bat*Time_int)*eta/Time_int;
                ubat=max(ubat,0.01*ones(D.Nr,1));
                ub(1+D.Ne+D.Nr:end)=ubat;


                % 求解
                options = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'interior-point');
                [P] = fmincon(fun, x0, A, b, Aeq, beq, lb, ub, [], options);
                %%

                % Solve each x_j-subproblem
                L=D.minREP.Solve_T(-Lambda,sum(P(1:D.Ne+D.Nr)),obj.beta,L,0);
                % Update dual variable
                Lambda=Lambda+obj.gamma*(sum(P(1:D.Ne+D.Nr))-L);

                PPev=Pmax_ev.*(SOCV_of_EV>=1);PP=P;PP(1:D.Ne)=max(PPev,P(1:D.Ne));
                f(iter)=fun2(PP)+D.minREP.Cost_fun(L);
                Originale(iter)=norm(sum(P(1:D.Ne+D.Nr))-L);
                Consistente(iter)=norm(P(1:D.Ne+D.Nr)-Pold(1:D.Ne+D.Nr));
                Pold=P;
            end
        end


    end
end

function U =Utility_fun_EV(Pev_i)
beta_ev=8;
omega_ev=1;
Pmax_ev=10; %kw
% Kw
U=beta_ev*log(omega_ev*min(Pev_i,Pmax_ev)+1)/log(3);
end


function U =Utility_fun_Resident(Pbuy_j,Pbat_j,GG2user_j_k,GC_j_k)
alpha_re=0.9;
omega_re=20;
U=omega_re*(Pbuy_j+Pbat_j+GG2user_j_k).^alpha_re;

idx=Pbuy_j+Pbat_j+GG2user_j_k > GC_j_k;
U(idx)= omega_re*GC_j_k(idx).^alpha_re;
end

function C=Cost_func(Pbat_j,GG2Bat_j,SOC)
Capacity_bat=10;% kw*h
bat_beta=1;
eta=0.95;
Time_int=0.5;

C=bat_beta*(Capacity_bat./(Capacity_bat+SOC*Capacity_bat+eta*GG2Bat_j*Time_int-Pbat_j*Time_int/eta));
end
