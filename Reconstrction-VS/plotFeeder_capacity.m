function plotFeeder_capacity(TT)
load('New.mat','obj');
AA=obj.Data.A;
if nargin==0
    TT='New.mat';
end
load(TT,'obj')
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on; numer_of_line=5;
for k=1:numer_of_line
    plot(time,AA(k,:)*[obj.PevT;obj.PbuyT] , 'LineStyle', linestyle{1},'Color', colors{k},'LineWidth',2)
    %plot(time,obj.B(k)*ones(1,obj.T), 'LineStyle', linestyle{2},'Color', colors{k},'LineWidth',1)
end
hold off;
LEGTT={'feeder1','feeder2','feeder3','feeder4','feeder5',};
legend(LEGTT);
xlabel('Time(h)')
ylabel('Power(kW)')
title('Total load on 5 feeders (EVs and Pbuy)')

figure;
hold on; numer_of_line=5;
for k=1:numer_of_line
    plot(time,AA(k,:)*[obj.PevT;obj.PbuyT]-mean(AA(k,:)*[obj.PevT;obj.PbuyT]), 'LineStyle', linestyle{1},'Color', colors{k},'LineWidth',2)
    %plot(time,obj.B(k)*ones(1,obj.T), 'LineStyle', linestyle{2},'Color', colors{k},'LineWidth',1)
end
hold off;
LEGTT={'feeder1','feeder2','feeder3','feeder4','feeder5',};
legend(LEGTT);
xlabel('Time(h)')
ylabel('Power(kW)')
title('Total load after centralization on 5 feeders (EVs and Pbuy)')
end