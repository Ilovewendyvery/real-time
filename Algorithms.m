classdef Algorithms<handle

    properties
        Data;%Get the data class
        Method;%Get the method class

        PevT;PbuyT;PbatT;%Decision variables
        LambdaT; %Dual variables
    end

    methods
        function obj = Algorithms(data,method)
            switch data
                case '1'
                    obj.Data=getData1ev1house();
                case '2'
                    obj.Data=getData2ev2house();
                case '100'
                    obj.Data=getData100ev100house();
            end  
            switch method
                case 'New'
                    obj.Method=chooseNewmethod();
                    obj.LambdaT=zeros(obj.Data.Nr+obj.Data.Ne,obj.Data.T);
                case 'Prox'
                    obj.Method=chooseProxADMM();
                    obj.LambdaT=zeros(1,obj.Data.T);
                case 'Corr'
                    obj.Method=chooseCorrADMM();
                    obj.LambdaT=zeros(1,obj.Data.T);
            end 
            obj.PevT=zeros(obj.Data.Ne,obj.Data.T);
            obj.PbuyT=zeros(obj.Data.Nr,obj.Data.T);
            obj.PbatT=zeros(obj.Data.Nr,obj.Data.T);
        end

        function Solve_ALL(obj)
            for k=1:obj.Data.T
                obj.Data.BPVL.UpdateGG2Bat(k);
                GG2BatV=obj.Data.BPVL.GG2Bat(:,k);
                SOCV=obj.Data.BPVL.SOC(:,k);
                SOCV_of_EV=obj.Data.BPVL.SOC_of_EV(:,k);
                [Pev,Pbuy,Pbat,Lambda]=obj.Method.Solve(obj.Data,GG2BatV,SOCV,SOCV_of_EV,k);
                obj.Data.BPVL.UpdateSOC(Pbat,k);
                obj.Data.BPVL.UpdateSOC_of_EV(Pev,k)

                obj.PevT(:,k)=Pev;
                obj.PbuyT(:,k)=Pbuy;
                obj.PbatT(:,k)=Pbat;
                obj.LambdaT(:,k)=Lambda;

                %Shadow price and SOC 
                disp(['price is: ', num2str(-Lambda(1)), '  bat SOC is: ', num2str(obj.Data.BPVL.SOC(1,k))]);
            end
        end


        function [Originale,Consistente,f]=Solve_All_convergence(obj,new_s)
            GG2Batv=obj.Data.BPVL.GG2Bat(:,1);
            SOCv=obj.Data.BPVL.SOC(:,1);
            SOCV_of_EV=obj.Data.BPVL.SOC_of_EV(:,1);
            [Originale,Consistente,f]=obj.Method.Solve_convergence(obj.Data,GG2Batv,SOCv,SOCV_of_EV,1,new_s); 
        end
    end

end
