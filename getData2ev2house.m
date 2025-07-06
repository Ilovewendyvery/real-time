classdef getData2ev2house<A_data
    properties  
        Ne;Nr;T;

        BPVL;
        minREP;
        minEV;
        minResident;

        % for EV
        beta_ev=8;omega_ev=1;thresholds_ev=10; %kw

        % for Resident
        alpha_re=0.9;omega_re=20;

        % for REP
        a_rep=0.003;b_rep=0.03;c_rep=0; 

        % for battery
        Capacity_bat=10% kw*h

        numer_of_feeder;

        GC; %Columns correspond to times, rows correspond to users 
        GG;
  
        U_feeder;
        B_feeder;
        Lmax;
    end
    methods  
        function obj=getData2ev2house()
            %ConNet = ConstraintsNetwork(0,1,0);
            is_summer=1;
            is_constrain=1;

            load('data.mat'); 
            if is_summer==1
                GC=GC1221*0.001;GG=GG1221*0.001;
            else
                GC=GC621*0.001;GG=GG621*0.001;
            end 
            ne=1;nr=1;
            obj.numer_of_feeder=2;
            obj.GC=GC(1:nr*obj.numer_of_feeder,:);% kw
            obj.GG=GG(1:nr*obj.numer_of_feeder,:);% kw
            obj.Ne=ne*obj.numer_of_feeder;
            [Nr,NT]=size(obj.GC);
            obj.Nr=Nr;obj.T=NT;

            [A,B]=LineCapacityConstraints_2(ne,nr);


            if is_constrain==0
                A=[];B=[];
            end
            obj.U_feeder = A;
            obj.B_feeder = B;    
            if isempty(B)
                Lmax=400;
            else
                Lmax=B(1);
            end
            obj.Lmax=Lmax;

            obj.BPVL = BatteryandPVandLoad(obj.GC,obj.GG,obj.Capacity_bat);
            obj.minREP=argMIN_REP(obj.U_feeder,obj.B_feeder,obj.a_rep,obj.b_rep,obj.c_rep,obj.Ne+obj.Nr);
            obj.minEV=argMIN_EV(obj.beta_ev,obj.omega_ev,obj.thresholds_ev);
            obj.minResident = argMIN_Resident(obj.BPVL,obj.GC,obj.alpha_re,obj.omega_re); 
        end

    end
end
 
function [A,B]=LineCapacityConstraints_2(ne,nr)
%5   
Ne=ne*2;Nr=nr*2;
A=zeros(2,Nr+Ne);
B=[3;0.5]*1;% (kw)

A(1,1:Ne)=1;                     
A(2,2:Ne)=1;              

A(1,Ne+(1:Nr))=1;
A(2,Ne+(2:Nr))=1; 
end
