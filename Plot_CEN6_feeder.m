function Plot_CEN6_feeder()
isupdata=false;
if isupdata
    % obj= Algorithms('100','ADMM');
    % obj.Method.iter_max=30;
    % Solve_ALL(obj)
    % save('result/ADMM100.mat','obj')

    obj= Algorithms('100','ADMM');
    obj.Method.iter_max=50;
    obj.Data.B_feeder=100000*ones(5,1);
    Solve_ALL(obj)
    save('result/ADMM100_noRestrain.mat','obj')
end
 
 TT='result/ADMM100.mat'; 
 
load(TT,'obj')
AA=obj.Data.U_feeder; 
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;
xdata=time;
ydata=zeros(10,48);idx=0;

for i=1:obj.Data.number_of_feeder
    h1(i) = plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i), ...
        '-o', 'Color', colors{i}, 'LineWidth', 0.5);
    ydata(idx+i,:)=(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i);
end 


B=obj.Data.B_feeder; 
TT='result/ADMM100_noRestrain.mat';
load(TT,'obj') 
time=0.5:0.5:obj.Data.T/2;  
idx=5;
for i=1:obj.Data.number_of_feeder
    h2(i) = plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT])/B(i), ...
        '--', 'Color', colors{i}, 'LineWidth', 0.5);
    ydata(idx+i,:)=(AA(i,:)*[obj.PevT;obj.PbuyT])/B(i);
end

% 只保留蓝色曲线的图例，且不带数字
% 蓝色曲线是 colors{1}，即 i=1 的曲线
legend('feeder1','feeder2','feeder3','feeder4','feeder5', 'Location', 'best');

hold off;
xlabel('Time (h)')
ylabel('Percentage')
%title('Powers percentage of feeders with  considering the capacity constraints for 5 feeders for Centralized optimization')
box on
data=[xdata',ydata'];
writematrix(data, 'CENfeeder.csv');