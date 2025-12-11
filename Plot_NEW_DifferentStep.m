function Plot_NEW_DifferentStep()
steps=[1,3,5,8,20];
isupdata=true;
if isupdata
    for kk=1:length(steps)
        obj= Algorithms('100','New');
        obj.Method.iter_max=steps(kk);
        Solve_ALL(obj)
        save(strcat('result/New100_S',num2str(steps(kk)),'.mat'),'obj')
    end
end


    linestyle = {'-', '--', ':', '-.','--',};
    colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
    figure;
    hold on;
    legend_str = cell(length(steps), 1);  % 创建图例字符串的单元格数组
ydata=zeros(length(steps),48);   
for kk=1:length(steps)
    TT=strcat('result/New100_S',num2str(steps(kk)),'.mat');
    load(TT,'obj')
    AA=obj.Data.U_feeder;
    time=0.5:0.5:obj.Data.T/2; 
    
    plot(time,(AA(1,:)*[obj.PevT;obj.PbuyT]) , 'LineStyle', linestyle{1},'Color', colors{kk},'LineWidth',2)
    legend_str{kk} = ['Step=', num2str(steps(kk))]; 
    ydata(kk,:)=(AA(1,:)*[obj.PevT;obj.PbuyT]);
end
xdata=time;
    % time=0.5:0.5:obj.Data.T/2; 
    % 
    % plot(time, sum(obj.Data.BPVL.GC,1), 'LineStyle', linestyle{2},'Color', colors{7},'LineWidth',2)
    % legend_str{kk+1} = ['Resident']; 
    % plot(time, sum(obj.Data.BPVL.GG,1), 'LineStyle', linestyle{3},'Color', colors{7},'LineWidth',2)
    % legend_str{kk+2} = ['Photovoltaic']; 
    % %plot(time,(AA(1,1:100)*[obj.PevT]) , 'LineStyle', linestyle{4},'Color', colors{7},'LineWidth',2)

hold off;
legend(legend_str, 'Location', 'best');  % 添加图例
xlabel('Time(h)')
ylabel('Power(kW)')
title('Aggregated behaviors by applying Algorithm')

data=[xdata',ydata'];
writematrix(data, 'Diff_Step.csv');