function PlotFigureEG()
isupdata=false;
if isupdata
    obj= Algorithms('100EG','New');
    obj.Method.iter_max=40;
    Solve_ALL(obj)
    save('result/New100EG_S40.mat','obj')

    obj= Algorithms('100EG','New');
    obj.Data.minREP.B_feeder=100000*ones(5,1);
    Solve_ALL(obj)
    save('result/New100EG_noRestrain.mat','obj')
end
  
  TT='result/New100EG.mat';
 
load(TT,'obj')
AA=obj.Data.U_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;

for i=1:obj.Data.number_of_feeder
    h1(i) = plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i), ...
        'LineStyle', linestyle{1}, 'Color', colors{i}, 'LineWidth', 2);
end 

 

% 只保留蓝色曲线的图例，且不带数字
% 蓝色曲线是 colors{1}，即 i=1 的曲线
% legend([h1(1)], {'With constraint', 'Without constraint'}, 'Location', 'best');

hold off;
xlabel('Time (h)')
ylabel('Percentage')
title('Powers percentage under heterogeneous EV with or without considering the capacity constraints')