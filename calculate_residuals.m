function calculate_residuals(data,method)
close all; 
A=struct();A.Oe=[];A.Ce=[];A.Fe=[]; 

A.new_s=150;

switch method
    case 'New'
        mu=[1,10,20];
        beta=[1,1,1];
   case 'Prox'
        beta=[0.5,0.6,0.7];
        mu=[0.01,0.02,1]*50;
    case 'Corr' 
        beta=[0.5,0.6,0.7];
        gamma=[0.1,0.2,0.3]*5;
    case 'ADMM'
        beta=[0.5,1,2]; 
        gamma=[1,1,1];

end
A.TTprimal=cell(length(beta),1);

for k=1:length(beta)
    obj=Algorithms(data,method);  
    switch method
        case 'New'
            obj.Method.beta=beta(k);
            obj.Method.mu=mu(k);
            A.TTprimal{k}=strcat('\beta=',num2str(beta(k)),'\mu=',num2str(mu(k)));
        case 'Prox'
            obj.Method.beta=beta(k);
            obj.Method.mu=mu(k);
            A.TTprimal{k}=strcat('\beta=',num2str(beta(k)),'mu=',num2str(mu(k)));
        case 'Corr'
            obj.Method.beta=beta(k); 
            obj.Method.gamma=gamma(k);
            A.TTprimal{k}=strcat('\beta=',num2str(beta(k)),'gamma=',num2str(gamma(k)));
        case 'ADMM'
            obj.Method.beta=beta(k);  
            A.TTprimal{k}=strcat('\rho=',num2str(beta(k)),'gamma=',num2str(gamma(k)));
    end

    [Oe,Ce,Fe]=Solve_All_convergence(obj,A.new_s);
    A.Oe=[A.Oe;Oe];A.Ce=[A.Ce;Ce];A.Fe=[A.Fe;Fe]; 

    figure(4)
    subplot(1,3,1)
    plot(1:A.new_s,A.Oe(k,:),'-','linewidth',1.5);hold on;
    set(gca,'YScale', 'log');
    subplot(1,3,2)
    plot(1:A.new_s,A.Ce(k,:),'-','linewidth',1.5);hold on;
    set(gca,'YScale', 'log');
    subplot(1,3,3)
    plot(1:A.new_s,A.Fe(k,:),'-','linewidth',1.5);hold on;
    set(gca,'YScale', 'log');

end
subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend(A.TTprimal)
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend(A.TTprimal)
subplot(1,3,3)
ylabel('function value')
xlabel('iteration step')
legend(A.TTprimal)

TT='err.mat';
TT=strcat('result/',method,data,TT); 
save(TT,'A')
end
