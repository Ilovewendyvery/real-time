classdef argMIN_EV 
    properties
         beta_ev;
         omega_ev;
         Pmax_ev;

         debug=0;
    end
    
    methods
        function obj = argMIN_EV(beta_ev,omega_ev,Pmax_ev) 
            obj.beta_ev=beta_ev;
            obj.omega_ev=omega_ev;
            obj.Pmax_ev=Pmax_ev;
        end

        
        function U =Utility_fun(obj,Pev_i) 
            % Kw
            U=obj.beta_ev*log(obj.omega_ev*min(Pev_i,obj.Pmax_ev)+1)/log(3);
        end
        
 
        
        function Pev_i =Solve(obj,lambda_i,X1_i,beta,PevOld_i,mu)
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x)-lambda_i*x+0.5*beta*(x-X1_i).^2+0.5*mu*(x-PevOld_i).^2;

            options = optimset('Display', 'off');
            Pev_i = fminbnd(fun,0,obj.Pmax_ev,options);

            if obj.debug==1
                figure(1)
                hold on;
                plot(0:obj.Pmax_ev+10,-obj.Utility_fun(0:obj.Pmax_ev+10),'b-')
                plot(0:obj.Pmax_ev+10,-lambda_i*(0:obj.Pmax_ev+10),'g-')
                
                plot(0:obj.Pmax_ev+10,fun(0:obj.Pmax_ev+10),'r-');
                plot(Pev_i,fun(Pev_i),'b*');
                hold off;
            end
        end

        function Pev_i =Solve_T(obj,lambda_i,sumx_L,beta,PevOld_i,mu,UB)
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x)-lambda_i*x+0.5*beta*(x+sumx_L-PevOld_i).^2+0.5*mu*(x-PevOld_i).^2;

            options = optimset('Display', 'off');
            UB=min(UB,obj.Pmax_ev);
            Pev_i = fminbnd(fun,0,UB,options);

            if obj.debug==1
                plot(0:obj.Pmax_ev,fun(0:UB),'r-');hold on;
                plot(Pev_i,fun(Pev_i),'b*');
            end
        end
    end
end

