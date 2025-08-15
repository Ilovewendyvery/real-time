function Plot_Heterogeneous_Step()
steps=[1,3,8,30,40];
isupdata=false;
if isupdata
    for kk=1:length(steps)
        obj= Algorithms('100EG','New');
        obj.Method.iter_max=steps(kk);
        Solve_ALL(obj)
        save(strcat('result/100EG_S',num2str(steps(kk)),'.mat'),'obj')
    end
end


    linestyle = {'-', '--', ':', '-.','--',};
    colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
    figure;
    hold on;
    legend_str = cell(length(steps), 1);  % 创建图例字符串的单元格数组
for kk=1:length(steps)
    TT=strcat('result/100EG_S',num2str(steps(kk)),'.mat');
    load(TT,'obj')
    AA=obj.Data.U_feeder;
    time=0.5:0.5:obj.Data.T/2; 
   
    plot(time,(AA(1,:)*[obj.PevT;obj.PbuyT]) , 'LineStyle', linestyle{1},'Color', colors{kk},'LineWidth',2)
    legend_str{kk} = ['Step=', num2str(steps(kk))]; 
end
 
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
title('Aggregated behaviors with heterogeneous EV by applying Algorithm')
box on;
