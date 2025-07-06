classdef getData2ev2house<A_data
    properties  
        Ne;Nr;T;

        BPVL;
        minREP;
        minEV;
        minResident;    

        % for EV
        beta=8;omega_e=1;thresholds=10; %kw

        % for Resident
        alpha=0.9;omega_r=20;

        % for REP
        a=0.003;b=0.03;c=0;

        % for battery
        Bat_cap=10;% kw*h

        numer_of_feed;

        GC; %Columns correspond to times, rows correspond to users 
        GG;
  
        A;
        B;
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
            obj.numer_of_feed=2;
            obj.GC=GC(1:nr*obj.numer_of_feed,:);% Load kw
            obj.GG=GG(1:nr*obj.numer_of_feed,:);% PV kw
            obj.Ne=ne*obj.numer_of_feed;
            [Nr,NT]=size(obj.GC);
            obj.Nr=Nr;obj.T=NT;

            [A,B]=LineCapacityConstraints_2(ne,nr);


            if is_constrain==0
                A=[];B=[];
            end
            obj.A = A;
            obj.B = B;    
            if isempty(B)
                Lmax=400;
            else
                Lmax=B(1);
            end
            obj.Lmax=Lmax;

            obj.BPVL = BatteryandPVandLoad(obj.GC,obj.GG,obj.Bat_cap);
            obj.minREP=argMIN_REP(obj.a,obj.b,obj.c,Lmax);
            obj.minEV=argMIN_EV(obj.beta,obj.omega_e,obj.thresholds);
            obj.minResident = argMIN_Resident(obj.BPVL,obj.GC,obj.alpha,obj.omega_r);  
        end

    end
end

function [A,B]=LineCapacityConstraints_2(ne,nr)
%5   
Ne=ne*2;Nr=nr*2;
A=zeros(2,Nr+Ne);
B=[22;11]*1;% (kw)

A(1,1:Ne)=1;                     
A(2,2:Ne)=1;              

A(1,Ne+(1:Nr))=1;
A(2,Ne+(2:Nr))=1; 
end
