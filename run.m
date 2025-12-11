%%Test
clear;
clc;
close all;

%%
% 12馈线
% obj= Algorithms('12f','New');
% Solve_ALL(obj)
% save('result/New12f.mat','obj')
%% 
%12馈线无约束
% obj= Algorithms('12f','New');
% obj.Data.minREP.B_feeder=obj.Data.minREP.B_feeder*1000;
% Solve_ALL(obj)
% save('result/New12f_noRestrain.mat','obj')
%%
% % % %5馈线 
% obj= Algorithms('100','New');
% Solve_ALL(obj)
% save('result/New100.mat','obj')
% obj= Algorithms('100winter','New');
% Solve_ALL(obj)
% save('result/New100winter.mat','obj')

% % 5馈线无约束
% obj= Algorithms('100','New');
% obj.Data.minREP.B_feeder=100000*ones(5,1);
% Solve_ALL(obj)
% save('result/New100_noRestrain.mat','obj')

%%
% %5馈线集中求解 
% obj= Algorithms('100','ADMM');
% obj.Method.iter_max=100;
% Solve_ALL(obj)
% save('result/ADMM100.mat','obj')
% %



% calculate_residuals('100','New')
% calculate_residuals('100','Corr')
% calculate_residuals('100','Prox')
% calculate_residuals('100','ADMM')

% %异构
% obj= Algorithms('100EG','New');
% obj.Method.iter_max=40;
% mu = 0.5;      % 均值
% sigma = 0.1;   % 标准差
% Initial_power_percentage = mu + sigma * randn(obj.Data.Ne, 1);  % 1000个N(2,9)的随机数
% obj.Data.BPVL.SOC_of_EV(:,1)=Initial_power_percentage;
% Solve_ALL(obj)
% save('result/New100EG.mat','obj')








