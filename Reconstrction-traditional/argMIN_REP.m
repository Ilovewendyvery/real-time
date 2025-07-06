classdef argMIN_REP    
    properties
        a;b;c;
        Lmax; %Maximum production capacity  
    end
    
    methods
        function obj = argMIN_REP(a,b,c,Lmax)  
            obj.Lmax=Lmax;

            obj.a=a;obj.b=b;obj.c=c;  
        end 

        function C =Cost_fun(obj,L)  
            C=obj.a*L^2+obj.b*L+obj.c;
        end
 
        function L =Solve(obj,lambda,sumx,beta,Lold,mu) 
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(L) obj.Cost_fun(L)-lambda*(-L)+0.5*beta*(sumx-L).^2+0.5*mu*(L-Lold).^2;

            options = optimset('Display', 'off'); 
            L = fminbnd(fun,0,obj.Lmax,options); 
        end
    end
end

