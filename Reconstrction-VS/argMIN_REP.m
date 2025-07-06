classdef argMIN_REP    
    properties
        a;b;c;
        Lmax; %Maximum production capacity 

        A;  bb;
        lb; ub;
    end
    
    methods
        function obj = argMIN_REP(A,B,a,b,c,N)           
            obj.A=A;
            obj.bb=B;
            if isempty(B)
                obj.Lmax=400;
            else 
                obj.Lmax=B(1); %Maximum production is equal to the maximum capacity of the feeder
            end

            obj.a=a;obj.b=b;obj.c=c; 
            obj.lb=zeros(N,1);
            obj.ub=zeros(N,1)+obj.Lmax;
        end 

        function C =Cost_fun(obj,L) 
            %C=a*sum(L)*sum(L)+b*sum(L)+c
            N=length(L); 
            C=obj.a*L'*ones(N,N)*L+obj.b*ones(1,N)*L+obj.c;
        end

        function L =Solve_quadprog(obj,lambda,PevPbuy_old,beta,L_old,mu,x0)
            %  L=argmin\Big\{L^T(aE)L+b^TL+c-\lambda^T([Pev_{old};Pbat_{old}]-L)+\frac{\beta}{2}\|[Pev_{old};Pbat_{old}]-L\|^2+\frac{\mu}{2}\|L-L_{old}\|^2\Big\}\\
            %   =argmin\Big\{\frac{1}{2}L^T[(2aE)+(\beta+\mu) I]L+(b^T+\lambda^T-\beta [Pev_{old};Pbat_{old}]-\mu L_{old})L\Big\}
            % fmin=0.5 L^T*H*L+f^T*L 
                          
            N=length(lambda);
            H=2*obj.a*ones(N,N)+(beta+mu)*eye(N);
            f=obj.b*ones(N,1)+lambda-beta*PevPbuy_old-mu*L_old;
            options = optimset('Display', 'off');
            L=quadprog(H,f,obj.A,obj.bb,[],[],obj.lb,obj.ub,x0,options);
        end
    end
end

