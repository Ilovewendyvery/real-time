function Plot_residuals_of_CENTER_and_NEW() 
isupdata=false;
if isupdata%If there is no data, recalculate.
    % calculate_residuals('100','New')
    % calculate_residuals('100','ADMM') 
end
data='100err';
load(strcat('result/ADMM',data),'A');
A_ADMM=A; 
load(strcat('result/New',data),'A'); 
A_New_our=A;
 

figure;
kadmm=2;
knew=1;

subplot(1,3,1) 
hold on; 
box on 
plot(1:A_ADMM.new_s,A_ADMM.Oe(kadmm,:),'-','linewidth',1.5);
plot(1:150,A_New_our.Oe(knew,:),'-','linewidth',1.5);hold off; 
ydata=[A_ADMM.Oe(kadmm,:);A_New_our.Oe(knew,:)];
subplot(1,3,2) 
hold on;
box on 
plot(1:A_ADMM.new_s,A_ADMM.Ce(kadmm,:),'-','linewidth',1.5);
plot(1:150,A_New_our.Ce(knew,:),'-','linewidth',1.5);hold off;
ydata=[ydata;A_ADMM.Ce(kadmm,:);A_New_our.Ce(knew,:)];
subplot(1,3,3)
hold on;
box on 
plot(1:A_ADMM.new_s,A_ADMM.Fe(kadmm,:),'-','linewidth',1.5);
plot(1:150,A_New_our.Fe(knew,:),'-','linewidth',1.5);hold off;
ydata=[ydata;A_ADMM.Fe(kadmm,:);A_New_our.Fe(knew,:)];
subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend('CEN','DEN')
set(gca,'YScale', 'log');
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend('CEN','DEN') 
set(gca,'YScale', 'log');
subplot(1,3,3)
ylabel('Function value')
xlabel('iteration step')
legend('CEN','DEN')
set(gca,'YScale', 'log');
%caption('Comparison of convergence speeds of the three methods')
box on

xdata=1:A_ADMM.new_s;
data=[xdata',ydata'];
writematrix(data, 'residualcomparison.csv');
end