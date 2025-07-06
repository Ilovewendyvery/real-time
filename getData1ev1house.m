classdef getData1ev1house<A_data
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
        Capacity_bat=0.1;% kw*h

        numer_of_feeder;

        GC;  
        GG;
  
        U_feeder;
        B_feeder;
        Lmax;
    end
    methods  
        function obj=getData1ev1house()
            %ConNet = ConstraintsNetwork(0,1,0);
            is_summer=1;
            is_constrain=0;

            load('data.mat'); 
            if is_summer==1
                GC=GC1221*0.001;GG=GG1221*0.001;
            else
                GC=GC621*0.001;GG=GG621*0.001;
            end 
            ne=1;nr=1;
            obj.numer_of_feeder=1;
            obj.GC=GC(1+5:nr*obj.numer_of_feeder+5,:);% kw
            obj.GG=GG(1+5:nr*obj.numer_of_feeder+5,:);% kw
            obj.Ne=ne*obj.numer_of_feeder;
            [Nr,NT]=size(obj.GC);
            obj.Nr=Nr;obj.T=NT;
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