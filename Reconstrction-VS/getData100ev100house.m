classdef getData100ev100house<A_data
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
        Bat_cap=0.002;% kw*h

        numer_of_feed;

        GC; %Columns correspond to times, rows correspond to users 
        GG;
  
        A;
        B;
    end
    methods  
        function obj=getData100ev100house()
            %ConNet = ConstraintsNetwork(0,1,0);
            is_summer=1;
            is_constrain=1;

            load('data.mat'); 
            if is_summer==1
                GC=GC1221*0.001;GG=GG1221*0.001;
            else
                GC=GC621*0.001;GG=GG621*0.001;
            end 
            ne=20;nr=20;
            obj.numer_of_feed=5;
            obj.GC=GC(1:nr*obj.numer_of_feed,:);% kw
            obj.GG=GG(1:nr*obj.numer_of_feed,:);% kw
            obj.Ne=ne*obj.numer_of_feed;
            [Nr,NT]=size(obj.GC);
            obj.Nr=Nr;obj.T=NT;

            [A,B]=LineCapacityConstraints_5(ne,nr);


            if is_constrain==0
                A=[];B=[];
            end
            obj.A = A;
            obj.B = B;    

            obj.BPVL = BatteryandPVandLoad(obj.GC,obj.GG,obj.Bat_cap);
            obj.minREP=argMIN_REP(obj.A,obj.B,obj.a,obj.b,obj.c,obj.Ne+obj.Nr);
            obj.minEV=argMIN_EV(obj.beta,obj.omega_e,obj.thresholds);
            obj.minResident = argMIN_Resident(obj.BPVL,obj.GC,obj.alpha,obj.omega_r); 
        end

    end
end

function [A,B]=LineCapacityConstraints_5(ne,nr)
%5   
Ne=ne*5;Nr=nr*5;
A=zeros(5,Nr+Ne);
B=[9300;4800;1200;880;720]/25;% (kw)

A(1,1:Ne)=1;                     
A(2,[ne+1:2*ne,3*ne+1:Ne])=1;   
A(3,2*ne+1:3*ne)=1;
A(4,3*ne+1:4*ne)=1;
A(5,4*ne+1:5*ne)=1;            

A(1,Ne+(1:Nr))=1;
A(2,Ne+[nr+1:2*nr,3*nr+1:Nr])=1;
A(3,Ne+(2*nr+1:3*nr))=1;
A(4,Ne+(3*nr+1:4*nr))=1;
A(5,Ne+(4*nr+1:5*nr))=1; 
end