classdef argMIN_EV 
    properties
         beta;
         omega_e;
         thresholds;

         debug=0;
    end
    
    methods
        function obj = argMIN_EV(beta,omega_e,thresholds) 
            obj.beta=beta;
            obj.omega_e=omega_e;
            obj.thresholds=thresholds;
        end

        
        function U =Utility_fun(obj,Pev_i) 
            % Kw
            U=obj.beta*log(obj.omega_e*min(Pev_i,obj.thresholds)+1)/log(3);
        end
        
        function Pev_i =Solve(obj,lambda_i,X1_i,beta,PevOld_i,mu)
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x)-lambda_i*x+0.5*beta*(x-X1_i).^2+0.5*mu*(x-PevOld_i).^2;

            options = optimset('Display', 'off');
            Pev_i = fminbnd(fun,0,obj.thresholds,options);

            if obj.debug==1
                plot(0:obj.thresholds,fun(0:obj.thresholds),'r-');hold on;
                plot(Pev_i,fun(Pev_i),'b*');
            end
        end

        function Pev_i =Solve_T(obj,lambda_i,sumx_L,beta,PevOld_i,mu,UB)
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x)-lambda_i*x+0.5*beta*(x+sumx_L-PevOld_i).^2+0.5*mu*(x-PevOld_i).^2;

            options = optimset('Display', 'off');
            UB=min(UB,obj.thresholds);
            Pev_i = fminbnd(fun,0,UB,options);

            if obj.debug==1
                plot(0:obj.thresholds,fun(0:UB),'r-');hold on;
                plot(Pev_i,fun(Pev_i),'b*');
            end
        end
    end
end

