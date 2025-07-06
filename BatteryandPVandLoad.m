classdef BatteryandPVandLoad < handle
    properties
        Nr;
        GC;%(Nr,T)User demanded power
        GG;%(Nr,T)PV Power generation
        GG2user;%(Nr,T)PV power transmitted to the user

        eta=0.95;     %Charging efficiency
        Capacity_bat; %battery capacity
        Initial_power_percentage=0.1;
        Time_int=0.5; %time interval 0.5h
        
        %Variables that need to be updated in real time
        SOC; 
        GG2Bat;%The matrix of power information transmitted by PV to the battery
    end

    methods
        function obj = BatteryandPVandLoad(GC,GG,Capacity_bat) 
            obj.Capacity_bat=Capacity_bat;
            obj.Nr=size(GC,1);
            obj.GC=GC;
            obj.GG=GG;
            obj.GG2user=min(GC,GG);

            %SOC(2) indicates the percentage of power at the end of the k=1 time period 
            obj.SOC=zeros(obj.Nr,size(GC,2)+1);
            obj.SOC(:,1)=obj.Initial_power_percentage;   

            obj.GG2Bat=zeros(obj.Nr,size(GC,2));
        end

        function UndateGG2Bat(obj,k)
            %The capacity that PV can provide to the battery
            a=obj.GG(:,k)-obj.GC(:,k);
            a=max(a,0); 
            %Capacity acceptable to the battery
            b=(1-obj.SOC(:,k))*obj.Capacity_bat/(obj.eta*obj.Time_int);
            obj.GG2Bat(:,k)=min(a,b); 
        end

        function UndateSOC(obj,Bat2user,k) 
            %Battery capacity equals initial capacity plus charge less discharge
                obj.SOC(:,k+1)=obj.SOC(:,k)+obj.eta*obj.GG2Bat(:,k)*obj.Time_int/obj.Capacity_bat...
                    -Bat2user*obj.Time_int/(obj.eta*obj.Capacity_bat); 
        end
    end
end