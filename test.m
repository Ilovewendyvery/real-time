%%Test
clear
clc 
close all;

if 1==1
    obj= Algorithms('2','Prox');
    Solve_ALL(obj)
    save('testdata.mat',"obj")
else
    load('testdata.mat',"obj")
end

time=(1:48)/2;
figure(1)
hold on;
plot(time,obj.PevT(1,:),'r+') 
plot(time,obj.PbuyT(1,:),'r-')
plot(time,obj.PevT(2,:),'bo') 
plot(time,obj.PbuyT(2,:),'b-')
plot(time,obj.PevT(1,:)+obj.PbuyT(1,:),'r-','LineWidth',1.5)
plot(time,obj.PevT(2,:)+obj.PbuyT(2,:),'b-','LineWidth',1.5)
plot(time,obj.PevT(1,:)+obj.PbuyT(1,:)+obj.PevT(2,:)+obj.PbuyT(2,:),'g-','LineWidth',1.5)

hold off;
legend('Pev1','Pbuy1','Pev2','Pbuy2','Ptotal1','Ptotal2')
xlabel('time(h)');ylabel('power(kW)') 
b1=num2str(obj.Data.B_feeder(1));b2=num2str(obj.Data.B_feeder(2));
title(strcat('beta1=',b1,'   beta2=',b2))



figure(2)
hold on;
plot(time,sum(obj.Data.BPVL.GG),'g')
plot(time,sum(obj.Data.BPVL.GC),'r')
hold off;
xlabel('time(h)');ylabel('power(kW)')
legend('PV','Load')


figure(3)
% Resident  
plot(time,obj.Data.BPVL.GC(1,:),'og')% demand
hold on;
plot(time,obj.PbuyT(1,:)+obj.Data.BPVL.GG2user(1,:)+obj.PbatT(1,:),'g')
% plot(obj.Data.BPVL.GG(1,:)+obj.PbuyT(1,:)...
%     +obj.PevT(1,:)-obj.PbatT(1,:)-...
%     obj.Data.BPVL.GC(1,:),'+')
grid on
hold off
xlabel('time(h)');ylabel('power(kW)')
legend('demand','supply')

 

