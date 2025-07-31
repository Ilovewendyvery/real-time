classdef argMIN_Resident 
    
    properties
         alpha_re; 
         omega_re; 


         GG2user;GC;
         eta;
         Time_int;
         Capacity_bat;

         debug=0;

         bat_beta=1;% 0 or 1
    end
    
    methods
        function obj = argMIN_Resident(BPVL,GC,alpha_re,omega_re)
            obj.alpha_re=alpha_re;obj.omega_re=omega_re; 
            obj.GG2user=BPVL.GG2user;
            obj.GC=GC;
            obj.eta=BPVL.eta;
            obj.Time_int=BPVL.Time_int;
            obj.Capacity_bat=BPVL.Capacity_bat;
        end
        
        function U =Utility_fun(obj,Pbuy_j,Pbat_j,j,k) 
            U=obj.omega_re*(Pbuy_j+Pbat_j+obj.GG2user(j,k)).^obj.alpha_re;

            idx=Pbuy_j+Pbat_j+obj.GG2user(j,k) > obj.GC(j,k);
            U(idx)= obj.omega_re*(obj.GC(j,k)).^obj.alpha_re; 
        end

        function C=Cost_func(obj,Pbat_j,GG2Bat_j,SOC) 
            C=obj.bat_beta*(obj.Capacity_bat./(obj.Capacity_bat+SOC*obj.Capacity_bat+obj.eta*GG2Bat_j*obj.Time_int-Pbat_j*obj.Time_int/obj.eta));
        end 
 

        function [Pbuy_j,Pbat_j] =Solve_T(obj,tilde_Lambda,X1_j,beta,PbuyOld,PbatOld,SOC,GG2Bat,mu,j,k,UB) 
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x(:,1),x(:,2),j,k)+obj.bat_beta*obj.Cost_func(x(:,2),GG2Bat,SOC)...
                       -tilde_Lambda*x(:,1)+0.5*beta*(x(:,1)-X1_j).^2+0.5*mu*(x(:,1)-PbuyOld).^2;%+0.5*mu*(x(:,2)-PbatOld).^2;  

            ub=obj.bat_beta*(SOC*obj.Capacity_bat+obj.eta*GG2Bat*obj.Time_int)*obj.eta/obj.Time_int;
            x0=[PbuyOld,PbatOld];

            options = optimset('Display', 'off');
            UB=min(obj.GC(j,k),UB);
            [x] = fmincon(fun,x0,[],[],[],[],[0,0],[UB,ub],[],options);
            Pbuy_j=x(1);
            Pbat_j=x(2); 

            if obj.debug==1
                draw0(fun,100,ub-2,x(1),x(2),z0)
            end 
        end


        function [Pbuy_j,Pbat_j] =Solve(obj,tilde_Lambda,X1_j,beta,PbuyOld,PbatOld,SOC,GG2Bat,mu,j,k)
            % lambda;Augmented;Augmented_coefficient;Proximity;Proximity_coefficient
            fun = @(x) -obj.Utility_fun(x(:,1),x(:,2),j,k)+obj.Cost_func(x(:,2),GG2Bat,SOC)...
                       -tilde_Lambda*x(:,1)+0.5*beta*(x(:,1)-X1_j).^2+0.5*mu*(x(:,1)-PbuyOld).^2;%+0.5*mu*(x(:,2)-PbatOld).^2;  

            ub=obj.bat_beta*(SOC*obj.Capacity_bat+obj.eta*GG2Bat*obj.Time_int)*obj.eta/obj.Time_int;
            x0=[PbuyOld,PbatOld];

            options = optimset('Display', 'off');
            [x] = fmincon(fun,x0,[],[],[],[],[0,0],[obj.GC(j,k),ub],[],options);
            Pbuy_j=x(1);
            Pbat_j=x(2); 

            if obj.debug==1
                draw0(fun,100,ub-2,x(1),x(2),z0)
            end 
        end
    end
end

function draw0(fun,maxx,maxy,x0,y0,z0)
x=linspace(0,maxx,10);
y=linspace(0,maxy,10);
[xx,yy]=meshgrid(x,y);z=zeros(10,10);
for i=1:10
    for j=1:10
        z(i,j)=fun([xx(i,j),yy(i,j)]);
    end
end
surf(xx,yy,z);hold on
plot3(x0,y0,z0,'r*')
end
