function PlotFigure8()
isupdata=false;
if isupdata
    obj= Algorithms('12f','New');
    obj.Method.iter_max=20;
    Solve_ALL(obj)
    save('result/New12f1_S20.mat','obj')

    obj= Algorithms('12f','New');
    obj.Data.minREP.B_feeder=100000*ones(12,1);
    Solve_ALL(obj)
    save('result/New12f_noRestrain.mat','obj')
end
 
 TT='result/New12f1_S20.mat';
 
load(TT,'obj')
AA=obj.Data.U_feeder;
B=obj.Data.minREP.B_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k','b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;
legend_str = cell(2*obj.Data.number_of_feeder, 1);  % 创建图例字符串的单元格数组
for i=1:obj.Data.number_of_feeder
    plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i), 'LineStyle', linestyle{1},'Color', colors{i},'LineWidth',2)
    legend_str{i} = ['\beta=', num2str(floor(B(i)))];
end 
 

TT='result/New12f_noRestrain.mat';
 
load(TT,'obj')  
time=0.5:0.5:obj.Data.T/2;  
for i=1:obj.Data.number_of_feeder
    plot(time,(obj.Data.U_feeder(i,:)*[obj.PevT;obj.PbuyT])/B(i), 'LineStyle', linestyle{2},'Color', colors{i},'LineWidth',2)
    legend_str{i+obj.Data.number_of_feeder} = 'Unlimited';
end
hold off;
legend(legend_str, 'Location', 'best');  % 添加图例
xlabel('Time(h)')
ylabel('Percentage')
title('Powers percentage of  feeders with or without considering the capacity constraints')

