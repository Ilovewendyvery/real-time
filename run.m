%%Test
clear;
clc;
close all;

obj= Algorithms('100','New');
Solve_ALL(obj)
save('result/New100.mat','obj')


 
calculate_residuals('100','New')
calculate_residuals('100','Corr')
calculate_residuals('100','Prox')








