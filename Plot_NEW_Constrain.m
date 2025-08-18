function Plot_NEW_Constrain()
%Updata
isupdata=false;
if isupdata
    obj= Algorithms('100','New');
    obj.Method.iter_max=40;
    Solve_ALL(obj)
    save('result/New100_S40.mat','obj')
end
 
 TT='result/New100_S40.mat';
 
load(TT,'obj')
AA=obj.Data.U_feeder;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;

ydata=zeros(5,48);
for i=1:obj.Data.number_of_feeder
    plot(time,(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i), ...
        'LineStyle', linestyle{1}, 'Color', colors{i}, 'LineWidth', 2);
    ydata(i,:)=(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i);
end 


legend('feeder1','feeder2','feeder3','feeder4','feeder5')
hold off;
xlabel('Time (h)')
ylabel('Percentage')
title('Powers percentage of feeders with  considering the capacity constraints for 5 feeders in Summer')
box on

xdata=time;
data=[xdata',ydata'];
writematrix(data, '5overleadingCWinter.csv');
end

