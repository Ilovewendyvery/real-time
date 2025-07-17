close all;

obj= Algorithms('1','New');
Solve_ALL(obj)
save('NEW1house.mat',"obj")

load('NEW1house.mat','obj')
figure(1)
time=0.5:0.5:48/2;
plot(time,obj.PevT, 'b-');   % 蓝色线条
hold on;
plot(time,obj.PbuyT, 'r--','LineWidth',1.5); % 红色虚线
hold on;
plot(time,obj.PevT+obj.PbuyT, 'g-','LineWidth', 1.5); % 红色虚线
hold off;
legend('P_{EV}', 'P_{buy}','P_{grid}');
xlabel('Time Slot(h)');
ylabel('Power (kW)');
title('1EV Charging Power and 1House buy electricity Power');
grid on;




obj= Algorithms('2','New');
Solve_ALL(obj)
save('NEW2house.mat',"obj")
load('NEW2house.mat','obj')
figure(2)
time=0.5:0.5:48/2;
hold on;
plot(time,obj.PevT(1,:), 'b-*', 'LineWidth', 1.5);   % 蓝色线条
plot(time,obj.PbuyT(1,:), 'r-*', 'LineWidth', 1.5); % 红色虚线

plot(time,obj.PevT(2,:), 'b-o', 'LineWidth', 1.5);   % 蓝色线条
plot(time,obj.PbuyT(2,:), 'r-o', 'LineWidth', 1.5); % 红色虚线

hold on;
plot(time,sum(obj.PevT(1:2,:),1)+sum(obj.PbuyT(1:2,:),1), 'g-', 'LineWidth', 1.5); % 红色虚线
plot(time,sum(obj.PevT(2,:),1)+sum(obj.PbuyT(2,:),1), 'g--', 'LineWidth', 1.5); % 红色虚线
hold off;
legend('P_{EV}1', 'P_{buy}1','P_{EV}2', 'P_{buy}2','P_{grid}1','P_{grid}2');
xlabel('Time Slot(h)');
ylabel('Power (kW)');
title('2EV Charging Power and 2House buy electricity Power');
grid on;
box on
