function ploterr(data) 
load(strcat('New',data),'A'); 
A_new=A;
load(strcat('Prox',data),'A'); 
A_Prox=A;
load(strcat('Corr',data),'A'); 
A_Corr=A;

k=3;

figure;

subplot(1,3,1)
plot(1:A_new.new_s,A_new.Oe(k,:),'-','linewidth',1.5);hold on; 
plot(1:A_Prox.new_s,A_Corr.Oe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Oe(k,:),'-','linewidth',1.5);hold off; 
subplot(1,3,2)
plot(1:A_new.new_s,A_new.Ce(k,:),'-','linewidth',1.5);hold on;
plot(1:A_Prox.new_s,A_Corr.Ce(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Ce(k,:),'-','linewidth',1.5);hold off;
subplot(1,3,3)
plot(1:A_new.new_s,A_new.Fe(k,:),'-','linewidth',1.5);hold on;
plot(1:A_Prox.new_s,A_Corr.Fe(k,:),'-','linewidth',1.5);
plot(1:A_Prox.new_s,A_Prox.Fe(k,:),'-','linewidth',1.5);hold off;

subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend('New','Corr','Prox')
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend('New','Corr','Prox') 
subplot(1,3,3)
ylabel('Function value')
xlabel('iteration step')
legend('New','Corr','Prox') 
end