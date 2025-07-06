%%Test
clear all
clc
obj= AlgNew('2','New');
Solve_ALL(obj)
close all;

figure(1)
plot(obj.PbuyT(1,:),'r')
hold on;
plot(obj.PevT(1,:),'y')
plot(obj.PbatT(1,:),'-b')
%hold off;


%figure(2)
plot(obj.Data.BPVL.GG(1,:),'g')
%hold on;
plot(obj.Data.BPVL.GC(1,:),'*r')
%legend('PV','Load')
plot(obj.Data.BPVL.GG(1,:)+obj.PbuyT(1,:)...
    -obj.PevT(1,:)-obj.PbatT(1,:)-...
    obj.Data.BPVL.GC(1,:),'+')
grid on
hold off
legend('Pbuy','Pev','Pbat','PV','Load')

%figure(3)
%plot(obj.Data.BPVL.SOC(1,:),'b')

