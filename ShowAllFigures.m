%run
close all;
ploterr()
plotBESScharginganddischarging();
plotFeeder_capacity;

load('New100.mat','obj')  
drawSOC(obj,3,3)
draw2(obj)
draw3(obj)