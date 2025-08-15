function Plot_CEN5_all()
 
 
 TT='result/ADMM100.mat'; 
 
load(TT,'obj')
AA=obj.Data.U_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;

for i=1:1
    h1(i) = plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT]), ...
        'LineStyle', linestyle{1}, 'Color', colors{i}, 'LineWidth', 2);
end 


B=obj.Data.B_feeder; 
TT='result/ADMM100_noRestrain.mat';
load(TT,'obj') 
time=0.5:0.5:obj.Data.T/2;  
for i=1:1
    h2(i) = plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT]), ...
        'LineStyle', linestyle{2}, 'Color', colors{i}, 'LineWidth', 2);
end

% 只保留蓝色曲线的图例，且不带数字
% 蓝色曲线是 colors{1}，即 i=1 的曲线
legend([h1(1), h2(1)], {'With constraint', 'Without constraint'}, 'Location', 'best');

hold off;
xlabel('Time (h)')
ylabel('Total gird power(kW) ')
title('Powers of feeders with considering the capacity constraints for 5 feeders for Centralized optimization')
box on
