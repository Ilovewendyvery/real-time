%%Test
clear;
clc;
close all;

obj= Algorithms('2','New');
obj.Data.minREP.B_feeder=[3;2]*10;
obj.Data.minEV.Pmax_ev=10;
obj.Data.BPVL.Capacity_EV=60;

obj.Data.minResident.omega_re=2;

Solve_ALL(obj)
save('test2.mat','obj')

k=1;








