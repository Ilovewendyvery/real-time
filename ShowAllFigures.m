%run
close all; 
plotBESScharginganddischarging(); 

load('result/New100.mat','obj')  
drawSOC(obj,30,30)
draw2(obj)
draw3(obj)