function err()
data='2';
method='Corr';


close all; 
A=struct();A.Oe=[];A.Ce=[];A.Fe=[];
A.kk=3;
A.TTprimal=cell(A.kk,1);
A.new_s=100;

switch method
    case 'New'
        mu=[1,1,1];
        beta=[0.5,0.6,0.7];
   case 'Prox'
        beta=[0.5,0.6,0.7]*1;
        mu=[0.01,0.02,1]*50;
    case 'Corr' 
        beta=[0.5,0.6,0.7]*1;
        gamma=[0.1,0.2,0.3]*5;
end


for k=1:A.kk
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
    end

    [Oe,Ce,Fe]=Solve_All_convergence(obj,A.new_s);
    A.Oe=[A.Oe;Oe];A.Ce=[A.Ce;Ce];A.Fe=[A.Fe;Fe]; 

    figure(4)
    subplot(1,3,1)
    plot(1:A.new_s,A.Oe(k,:),'-','linewidth',1.5);hold on;
    subplot(1,3,2)
    plot(1:A.new_s,A.Ce(k,:),'-','linewidth',1.5);hold on;
    subplot(1,3,3)
    plot(1:A.new_s,A.Fe(k,:),'-','linewidth',1.5);hold on;

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
TT=strcat(method,data,TT);
save(TT,'A')
end
