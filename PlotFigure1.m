function PlotFigure1() 
isupdata=false;
if isupdata%If there is no data, recalculate.
    calculate_residuals('100','ADMM') 
    calculate_residuals('100','New')
end
data='100err';
load(strcat('result/ADMM',data),'A'); 
A_ADMM=A; 
load(strcat('result/New',data),'A'); 
A_New_our=A;

k=2;

figure;

subplot(1,3,1) 
hold on; 
box on 
plot(1:A_ADMM.new_s,A_ADMM.Oe(k,:),'-','linewidth',1.5);
plot(1:A_ADMM.new_s,A_New_our.Oe(k,:),'-','linewidth',1.5);hold off; 
subplot(1,3,2) 
hold on;
box on 
plot(1:A_ADMM.new_s,A_ADMM.Ce(k,:),'-','linewidth',1.5);
plot(1:A_ADMM.new_s,A_New_our.Ce(k,:),'-','linewidth',1.5);hold off;
subplot(1,3,3)
hold on;
box on 
plot(1:A_ADMM.new_s,A_ADMM.Fe(k,:),'-','linewidth',1.5);
plot(1:A_ADMM.new_s,A_New_our.Fe(k,:),'-','linewidth',1.5);hold off;

subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend('Prox','Our')
set(gca,'YScale', 'log');
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend('Prox','Our') 
set(gca,'YScale', 'log');
subplot(1,3,3)
ylabel('Function value')
xlabel('iteration step')
legend('Prox','Our')
set(gca,'YScale', 'log');
%caption('Comparison of convergence speeds of the three methods')
box on
end