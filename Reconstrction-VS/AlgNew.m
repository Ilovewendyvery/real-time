classdef AlgNew<handle

    properties
        Data;%（class）
        Method;%（class）

        PevT;PbuyT;PbatT;LambdaT; 
    end

    methods
        function obj = AlgNew(data,method)
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
                case 'Prox'
                    obj.Method=chooseProxADMM();
                case 'Corr'
                    obj.Method=chooseCorrADMM();
            end 

            obj.PevT=zeros(obj.Data.Ne,obj.Data.T);
            obj.PbuyT=zeros(obj.Data.Nr,obj.Data.T);
            obj.PbatT=zeros(obj.Data.Nr,obj.Data.T);
            obj.LambdaT=zeros(obj.Data.Nr+obj.Data.Ne,obj.Data.T);
        end

        function Solve_ALL(obj)
            for k=1:obj.Data.T
                obj.Data.BPVL.UndateGG2Bat(k);
                GG2BatV=obj.Data.BPVL.GG2Bat(:,k);
                SOCV=obj.Data.BPVL.SOC(:,k);
                [Pev,Pbuy,Pbat,Lambda]=obj.Method.Solve(obj.Data,GG2BatV,SOCV,k);
                obj.Data.BPVL.UndateSOC(Pbat,k);

                obj.PevT(:,k)=Pev;
                obj.PbuyT(:,k)=Pbuy;
                obj.PbatT(:,k)=Pbat;
                obj.LambdaT(:,k)=Lambda;

                disp([Lambda(1),obj.Data.BPVL.SOC(1,k)])
            end
        end


        function [Originale,Consistente,f]=Solve_All_convergence(obj,new_s)
            GG2Batv=obj.Data.BPVL.GG2Bat(:,1);
            SOCv=obj.Data.BPVL.SOC(:,1);
            [Originale,Consistente,f]=obj.Method.Solve_convergence(obj.Data,GG2Batv,SOCv,1,new_s); 
        end
    end

end
