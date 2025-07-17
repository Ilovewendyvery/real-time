function plotFeeder_capacity(TT) 
if nargin==0
    TT='New100.mat';
end
load(TT,'obj')
AA=obj.Data.U_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;  
legend_str = cell(obj.Data.number_of_feeder, 1);  % 创建图例字符串的单元格数组 
for i=1:obj.Data.number_of_feeder
    plot(time,AA(i,:)*[obj.PevT;obj.PbuyT], 'LineStyle', linestyle{1},'Color', colors{i},'LineWidth',2)
    legend_str{i} = ['\beta=', num2str(obj.Data.minREP.B_feeder(i))];
end
hold off;
legend(legend_str, 'Location', 'best');  % 添加图例  
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
legend(legend_str, 'Location', 'best');  % 添加图例  
xlabel('Time(h)')
ylabel('Power(kW)')
title('Total load after centralization on 5 feeders (EVs and Pbuy)')
end