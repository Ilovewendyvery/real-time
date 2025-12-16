function plot_16Dec() 
close all;
%plot
TT='result/New100.mat';
load(TT,'obj') 
time=0.5:0.5:obj.Data.T/2;

%% 图1：光伏利用率堆叠图
figure(1);
set(gcf, 'Position', [100, 100, 800, 500]); % 设置图形大小

hold on;

% 第一条线：总PV发电量（保持为折线）
plot(time, sum(obj.Data.BPVL.GG, 1), '-', 'Color', [0.2, 0.6, 0.2], 'LineWidth', 2.5);

% 计算堆叠数据
pv2user = sum(obj.Data.BPVL.GG2user, 1);
pv2bat = sum(obj.Data.BPVL.GG2Bat, 1);
pcurt = sum(obj.Data.BPVL.GG, 1) - pv2user - pv2bat;

% 创建堆叠区域图
h_area = area(time, [pv2user; pv2bat; pcurt]', 'LineStyle', 'none');

% 设置堆叠区域的颜色和透明度
colors = [0.2, 0.4, 0.8;      % PV to user - 深蓝色
          0.9, 0.3, 0.3;      % PV to bat - 红色
          0.3, 0.3, 0.3];     % PV curt - 灰色

for i = 1:3
    h_area(i).FaceColor = colors(i, :);
    h_area(i).FaceAlpha = 0.7;
    h_area(i).EdgeColor = colors(i, :);
    h_area(i).LineWidth = 0.5;
end

hold off;

% 设置图例
legend('PV Generation', 'PV to User', 'PV to Battery', 'PV Curtailed', ...
       'Location', 'best', 'FontSize', 10, 'Box', 'off');

% 美化坐标轴
xlabel('Time (h)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Power (kW)', 'FontSize', 12, 'FontWeight', 'bold');
title('Photovoltaic Utilization Profile in Summer', 'FontSize', 14, 'FontWeight', 'bold');

% 设置网格和边框
grid on;

box on;

% 设置坐标轴范围
xlim([min(time) max(time)]);
ylim([0 max(sum(obj.Data.BPVL.GG, 1))*1.1]);

% 设置坐标轴字体
set(gca, 'FontSize', 11, 'LineWidth', 1.5, 'TickDir', 'out');

%% 图2：单个EV充电功率
figure(2);
set(gcf, 'Position', [150, 150, 700, 400]);

kk = 10;
hold on; 
plot(time, obj.PevT(kk,:),  '-', 'Color', [0.1, 0.5, 0.1], 'LineWidth', 2.5);  
hold off;  

xlabel('Time (h)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Power (kW)', 'FontSize', 12, 'FontWeight', 'bold');
title('Individual EV Charging Power Profile', 'FontSize', 14, 'FontWeight', 'bold');

grid on;

box on;
set(gca, 'FontSize', 11, 'LineWidth', 1.5, 'TickDir', 'out');
xlim([min(time) max(time)]);
% ylim([0 max(obj.PevT(kk,:))*1.1]);

%% 图3：单个电车SOC
figure(3);
set(gcf, 'Position', [200, 200, 700, 400]);

kk = 10;
hold on; 
plot([0,time], obj.Data.BPVL.SOC_of_EV(kk,:)*100,  '--', 'Color', [0.8, 0.2, 0.2], 'LineWidth', 2.5); 
hold off;  

xlabel('Time (h)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('SOC (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Individual EV State of Charge (SOC)', 'FontSize', 14, 'FontWeight', 'bold');

grid on;

box on;
set(gca, 'FontSize', 11, 'LineWidth', 1.5, 'TickDir', 'out');
xlim([0 max(time)]);
ylim([min(obj.Data.BPVL.SOC_of_EV(kk,:))*0.95 100]);

%% 图4：EV聚合负荷对比
figure(4);
set(gcf, 'Position', [250, 250, 800, 450]);

hold on; 

% 第一种情况
plot(time, sum(obj.PevT),  '-', 'Color', [0.2, 0.6, 0.2], 'LineWidth', 2.5);  

% 加载第二种情况数据
TT='result/New100_noRestrain.mat';
load(TT,'obj'); 
plot(time, sum(obj.PevT),  '-', 'Color', [0.1, 0.1, 0.1], 'LineWidth', 2.5);  

hold off;

xlabel('Time (h)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Aggregated Power (kW)', 'FontSize', 12, 'FontWeight', 'bold');
%title('EV Aggregated Load Comparison', 'FontSize', 14, 'FontWeight', 'bold');

% 添加图例
legend('With Constraints', 'Without Constraints', 'Location', 'best', ...
       'FontSize', 10, 'Box', 'off');

grid on;

box on;
set(gca, 'FontSize', 11, 'LineWidth', 1.5, 'TickDir', 'out');
xlim([min(time) max(time)]);

% 添加整体标题
sgtitle('EV and PV System Analysis Results', 'FontSize', 16, 'FontWeight', 'bold');

end