function PlotFigure3() 
isupdata=false;
if isupdata%If there is no data, recalculate.
    calculate_residuals('100','Prox')
    calculate_residuals('100','Corr')
    calculate_residuals('100','New')
end
data='100err';
load(strcat('result/Prox',data),'A'); 
A_Prox=A;
load(strcat('result/Corr',data),'A'); 
A_Corr=A;
load(strcat('result/New',data),'A'); 
A_New_our=A;

k=3;

figure;

subplot(1,3,1) 
hold on; 
box on
plot(1:A_Prox.new_s,A_Corr.Oe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Oe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_New_our.Oe(k,:),'-','linewidth',1.5);hold off; 
subplot(1,3,2) 
hold on;
box on
plot(1:A_Prox.new_s,A_Corr.Ce(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Ce(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_New_our.Ce(k,:),'-','linewidth',1.5);hold off;
subplot(1,3,3)
hold on;
box on
plot(1:A_Prox.new_s,A_Corr.Fe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Fe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_New_our.Fe(k,:),'-','linewidth',1.5);hold off;

subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend('Corr','Prox','Our')
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend('Corr','Prox','Our') 
subplot(1,3,3)
ylabel('Function value')
xlabel('iteration step')
legend('Corr','Prox','Our')
%caption('Comparison of convergence speeds of the three methods')
box on
end