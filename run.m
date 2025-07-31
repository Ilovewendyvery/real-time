%%Test
clear;
clc;
close all;

% obj= Algorithms('12f','New');
% Solve_ALL(obj)
% save('result/New12f.mat','obj')
% 
% obj= Algorithms('12f','New');
% obj.Data.minREP.B_feeder=obj.Data.minREP.B_feeder*1000;
% Solve_ALL(obj)
% save('result/New12f_noRestrain.mat','obj')


% obj= Algorithms('100','New');
% Solve_ALL(obj)
% save('result/New100.mat','obj')


calculate_residuals('100','New')
% calculate_residuals('100','Corr')
% calculate_residuals('100','Prox')
% calculate_residuals('100','ADMM')








