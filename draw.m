function draw(obj,k)
figure(k)
time=(1:48)/2;
hold on;
plot(time,obj.PevT(1,:),'r+')
plot(time,obj.PbuyT(1,:),'r-')
plot(time,obj.PevT(2,:),'bo')
plot(time,obj.PbuyT(2,:),'b-')
plot(time,obj.PevT(1,:)+obj.PbuyT(1,:),'r-','LineWidth',1.5)
plot(time,obj.PevT(2,:)+obj.PbuyT(2,:),'b-','LineWidth',1.5)
plot(time,obj.PevT(1,:)+obj.PbuyT(1,:)+obj.PevT(2,:)+obj.PbuyT(2,:),'g-','LineWidth',1.5)
hold off;
legend('Pev1','Pbuy1','Pev2','Pbuy2','Pev1+Pbuy1','Pev2+Pbuy2(feeder2)','Pev1+Pbuy1+Pev2+Pbuy2(feeder1)')
xlabel('time(h)');ylabel('power(kW)')
b1=num2str(obj.Data.minREP.B_feeder(1));
b2=num2str(obj.Data.minREP.B_feeder(2));
Pmax_ev=num2str(obj.Data.minEV.Pmax_ev);
title(strcat('  Pmax of ev=',Pmax_ev,'  \beta_1=',b1,'  \beta_2=',b2))
box on
end