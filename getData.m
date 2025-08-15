classdef getData<handle
    properties 
        Ne;% number of total EV
        Nr;% number of total residents
        T; % The number of portions that are divided in a day

        BPVL;% A class about Battery and PV and Load
        minREP;% A class that minimizes the objective function of ERP 
        minEV;% A class that minimizes the objective function of EV
        minResident;% A class that minimizes the objective function of Resident 

        % Parameters about EV
        beta_ev=8;
        omega_ev=1;
        Pmax_ev=10; %kw
        Capacity_EV=60;
        

        % Parameters about Resident
        alpha_re=0.9;
        omega_re=20;

        % Parameters about REP
        a_rep=0.003;b_rep=0.03;c_rep=0; 

        % Parameters about battery
        Capacity_bat=10;% kw*h
        
        % Parameters about PV
        GC;  %A matrix of power regarding the needs of residents
        GG;  %A matrix regarding the power of PV generation        
        %（Columns correspond to times, rows correspond to users）
        
        % Parameters about feeder
        number_of_feeder; % Total number of feeders      
        U_feeder;%A matrix containing feeder connectivity and user distribution information
        B_feeder;%A vector of feeder capacity
          
        Lmax;
    end
    methods  
        function obj=getData(data) 
           
            switch data
                case '1' 
                    is_summer=1;
                    ne=1;nr=1;
                    obj.number_of_feeder=1;
                    obj.U_feeder=[];obj.B_feeder=[];
                    Ne=ne*obj.number_of_feeder;
                    Nr=nr*obj.number_of_feeder;
                    dt=1;
                case '2'
                    is_summer=1;
                    ne=1;nr=1;
                    obj.number_of_feeder=2;
                    obj.U_feeder=LineCapacityConstraints_2(ne,nr);
                    obj.B_feeder=[3;2];

                    Ne=ne*obj.number_of_feeder;
                    Nr=nr*obj.number_of_feeder;
                    dt=1;
                case '100'
                    is_summer=1;
                    ne=20;nr=20;
                    obj.number_of_feeder=5;
                    obj.U_feeder=LineCapacityConstraints_5(ne,nr);
                    obj.B_feeder=[310; 100; 90; 50; 85];% (kw)

                    Ne=ne*obj.number_of_feeder;
                    Nr=nr*obj.number_of_feeder;
                    dt=1;
                case '100winter'
                    is_summer=0;
                    ne=20;nr=20;
                    obj.number_of_feeder=5;
                    obj.U_feeder=LineCapacityConstraints_5(ne,nr);
                    obj.B_feeder=[310; 100; 90; 50; 85];% (kw)

                    Ne=ne*obj.number_of_feeder;
                    Nr=nr*obj.number_of_feeder;
                    dt=1;
                case '12f'
                    is_summer=1;
                    ne=30;nr=10;
                    obj.number_of_feeder=12;
                    obj.U_feeder=LineCapacityConstraints_12(ne,nr);
                    obj.B_feeder=[500;120;40;120;40;350;120;40;120;40;120;40];% (kw)

                    Ne=ne*obj.number_of_feeder;
                    Nr=nr*obj.number_of_feeder;
                    dt=1;

                case '100EG' 
                    is_summer=1; 
                    obj.number_of_feeder=5;
                    obj.U_feeder=LineCapacityConstraints_5EG();
                    obj.B_feeder=[310; 80; 90; 50; 85];% (kw)

                    Ne=100;
                    Nr=80;
                    dt=2;
            end
 
            load('data.mat'); 
            if is_summer==1
                GC=GC1221*0.001;GG=GG1221*0.001;
            else
                GC=GC621*0.001;GG=GG621*0.001;
            end  
            obj.GC=GC(2:Nr+1,1:dt:end);% kw
            obj.GG=GG(2:Nr+1,1:dt:end);% kw
            obj.Ne=Ne;
            [~,NT]=size(obj.GC);
            obj.Nr=Nr;obj.T=NT; 


              
            if isempty(obj.B_feeder)
                obj.Lmax=400;
            else
                obj.Lmax=obj.B_feeder(1);
            end 

            obj.BPVL = BatteryandPVandLoad(obj.GC,obj.GG,obj.Capacity_bat,obj.Capacity_EV,obj.Ne);
            obj.minREP=argMIN_REP(obj.U_feeder,obj.B_feeder,obj.a_rep,obj.b_rep,obj.c_rep,obj.Ne+obj.Nr);
            obj.minEV=argMIN_EV(obj.beta_ev,obj.omega_ev,obj.Pmax_ev);
            obj.minResident = argMIN_Resident(obj.BPVL,obj.GC,obj.alpha_re,obj.omega_re); 

            if strcmp(data, '100EG')
               obj.BPVL.Time_int=1;
               obj.minResident.Time_int=1; 
            end
        
        
        end

    end
end
 
function [A]=LineCapacityConstraints_2(ne,nr)
%2
Ne=ne*2;Nr=nr*2;
A=zeros(2,Nr+Ne);

A(1,1:Ne)=1;
A(2,2:Ne)=1;

A(1,Ne+(1:Nr))=1;
A(2,Ne+(2:Nr))=1;
end

function [A]=LineCapacityConstraints_5(ne,nr)
%5
Ne=ne*5;Nr=nr*5;
A=zeros(5,Nr+Ne);


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
function [A]=LineCapacityConstraints_12(ne,nr)
%13 bus 
Ne=ne*12;Nr=nr*12; 
A=zeros(12,Nr+Ne);B=zeros(12,1);

A(1,1:Ne)=1;          
A(2,1:ne)=1;          
A(3,1:2*ne)=1;        
A(4,3*ne+1:5*ne)=1;    
A(5,4*ne+1:5*ne)=1;    
A(6,5*ne+1:Ne)=1;      
A(7,5*ne+1:6*ne)=1;    
A(8,5*ne+1:6*ne)=1;A(8,10*ne+1:11*ne)=1;  
A(9,8*ne+1:10*ne)=1;   
A(10,9*ne+1:10*ne)=1;  
A(11,10*ne+1:11*ne)=1; 
A(12,11*ne+1:12*ne)=1; 



         
A(2,Ne+(1:nr))=1;          
A(3,Ne+(1:2*nr))=1;        
A(4,Ne+(3*nr+1:5*nr))=1;    
A(5,Ne+(4*nr+1:5*nr))=1;    
A(6,Ne+(5*nr+1:Nr))=1;      
A(7,Ne+(5*nr+1:6*nr))=1;    
A(8,Ne+(5*nr+1:6*nr))=1;A(8,Ne+(10*nr+1:11*nr))=1;  
A(9,Ne+(8*nr+1:10*nr))=1;   
A(10,Ne+(9*nr+1:10*nr))=1;  
A(11,Ne+(10*nr+1:11*nr))=1; 
A(12,Ne+(11*nr+1:12*nr))=1; 
end 

function [A]=LineCapacityConstraints_5EG()
%5
Ne=100;Nr=80;
A=zeros(5,Nr+Ne);


A(1,1:100)=1;
A(2,[31:50,66:80])=1;
A(3,51:65)=1;
A(4,66:80)=1;
A(5,81:100)=1;

A(1,101:180)=1;
A(2,[121:140,151:180])=1;
A(3,141:150)=1;
A(4,151:160)=1;
A(5,161:180)=1;
end