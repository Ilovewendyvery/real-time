function Plot_12feedre()
isupdata=false;
if isupdata
    obj= Algorithms('12f','New');
    obj.Method.iter_max=40;
    Solve_ALL(obj)
    save('result/New12f1_S40.mat','obj')

    % obj= Algorithms('12f','New');
    % obj.Data.minREP.B_feeder=100000*ones(12,1);
    % Solve_ALL(obj)
    % save('result/New12f_noRestrain.mat','obj')
end
 
 TT='result/New12f_S40.mat';
 
load(TT,'obj')
AA=obj.Data.U_feeder;
B=obj.Data.minREP.B_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k','b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;
% 保存句柄以控制 legend
h_constrained = gobjects(obj.Data.number_of_feeder,1);
ydata=zeros(12,48);
for i = 1:obj.Data.number_of_feeder
h_constrained(i) = plot(time, ...
(AA(i,:) * [obj.PevT; obj.PbuyT]) / obj.Data.B_feeder(i), ...
'LineStyle', linestyle{1}, ...
'Color', colors{i}, ...
'LineWidth', 2);

ydata(i,:)=(AA(i,:) * [obj.PevT; obj.PbuyT]) / obj.Data.B_feeder(i);
end
% % ======= Load unconstrained result =======
% TT = 'result/New12f_noRestrain.mat';
% load(TT, 'obj')
% for i = 1:obj.Data.number_of_feeder
% h_unconstrained(i) = plot(time, ...
% (obj.Data.U_feeder(i,:) * [obj.PevT; obj.PbuyT]) / B(i), ...
% 'LineStyle', linestyle{2}, ...
% 'Color', colors{i}, ...
% 'LineWidth', 2);
% end
% ======= Add legend: only for blue lines =======
% 蓝色是 colors{1} = 'b'，即 i=1 和 i=8（你有重复的 'b'）
% legend([h_constrained(1), h_unconstrained(1)], ...
% {'With constraint', 'Without constraint'}, ...
% 'Location', 'best');
legend('feeder1','feeder2','feeder3','feeder4','feeder5','feeder6','feeder7','feeder8','feeder9','feeder10','feeder11','feeder12')
hold off;
xlabel('Time (h)')
ylabel('Percentage')
title('Powers percentage of feeders with or without considering the capacity constraints')
box on


data=[time',ydata'];
writematrix(data, '12feeder.csv');