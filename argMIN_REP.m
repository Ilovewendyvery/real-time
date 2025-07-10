classdef argMIN_REP    
    properties
        a_rep;b_rep;c_rep;
        Lmax; %Maximum production capacity 

        U_feeder;  B_feeder;
        lb; ub;
    end
    
    methods
        function obj = argMIN_REP(U_feeder,B_feeder,a_rep,b_rep,c_rep,N)           
            obj.U_feeder=U_feeder;
            obj.B_feeder=B_feeder;
            if isempty(B_feeder)
                obj.Lmax=400;
            else 
                obj.Lmax=B_feeder(1); %Maximum production is equal to the maximum capacity of the feeder
            end

            obj.a_rep=a_rep;obj.b_rep=b_rep;obj.c_rep=c_rep; 
            obj.lb=zeros(N,1);
            obj.ub=zeros(N,1)+obj.Lmax;
        end 

        function C =Cost_fun(obj,L) 
            %C=a*sum(L)*sum(L)+b*sum(L)+c
            N=length(L); 
            C=obj.a_rep*L'*ones(N,N)*L+obj.b_rep*ones(1,N)*L+obj.c_rep;
        end

        function L =Solve_quadprog(obj,lambda,PevPbuy_old,beta,L_old,mu,x0)
            %  L=argmin\Big\{L^T(aE)L+b^TL+c-\lambda^T([Pev_{old};Pbat_{old}]-L)+\frac{\beta}{2}\|[Pev_{old};Pbat_{old}]-L\|^2+\frac{\mu}{2}\|L-L_{old}\|^2\Big\}\\
            %   =argmin\Big\{\frac{1}{2}L^T[(2aE)+(\beta+\mu) I]L+(b^T+\lambda^T-\beta [Pev_{old};Pbat_{old}]-\mu L_{old})L\Big\}
            % fmin=0.5 L^T*H*L+f^T*L 
                          
            N=length(lambda);
            H=2*obj.a_rep*ones(N,N)+(beta+mu)*eye(N);
            f=obj.b_rep*ones(N,1)+lambda-beta*PevPbuy_old-mu*L_old;
            options = optimset('Display', 'off');
            L=quadprog(H,f,obj.U_feeder,obj.B_feeder,[],[],obj.lb,obj.ub,x0,options);
        end

        function C =Cost_fun_T(obj,L)  
            C=obj.a_rep*L^2+obj.b_rep*L+obj.c_rep;
        end
 
        function L =Solve_T(obj,lambda,sumx,beta,Lold,mu) 
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(L) obj.Cost_fun(L)-lambda*(-L)+0.5*beta*(sumx-L).^2+0.5*mu*(L-Lold).^2;

            options = optimset('Display', 'off'); 
            L = fminbnd(fun,0,obj.Lmax,options); 
        end
    end
end

