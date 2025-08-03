function PlotFigure2()
isupdata=false;
if isupdata%If there is no data, recalculate.
    data='100';
    method='New';

    % different parameters
    mu=[1,1,1,1,0.1,10];
    beta=[0.1,0.5,1,10,1,1];

    A=struct();A.Oe=[];A.Ce=[];A.Fe=[];
    A.TTprimal=cell(length(beta),1);
    A.new_s=100;
    for k=1:length(beta)
        obj=Algorithms(data,method);
        obj.Method.beta=beta(k);
        obj.Method.mu=mu(k);
        A.TTprimal{k}=strcat('\beta=',num2str(beta(k)),'\mu=',num2str(mu(k)));

        [Oe,Ce,Fe]=Solve_All_convergence(obj,A.new_s);
        A.Oe=[A.Oe;Oe];A.Ce=[A.Ce;Ce];A.Fe=[A.Fe;Fe];
    end

    save('result/Figure2.mat','A')
end

load('result/Figure2.mat','A')
linestyle = {'-', '--', ':', '-.','--','-'};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
figure;
for k=1:length(A.TTprimal)
    subplot(1,3,1)
    plot(1:A.new_s,A.Oe(k,:),'-','linewidth',1.5,'LineStyle', linestyle{k}, 'Color', colors{k});hold on;
    subplot(1,3,2)
    plot(1:A.new_s,A.Ce(k,:),'-','linewidth',1.5,'LineStyle', linestyle{k}, 'Color', colors{k});hold on;
    subplot(1,3,3)
    plot(1:A.new_s,A.Fe(k,:),'-','linewidth',1,'LineStyle', linestyle{k}, 'Color', colors{k});hold on;

end
subplot(1,3,1)
ylabel('Primal error value')
xlabel('iteration step')
legend(A.TTprimal)
set(gca,'YScale', 'log');
subplot(1,3,2)
ylabel('Dual error value')
xlabel('iteration step')
legend(A.TTprimal)
set(gca,'YScale', 'log');
subplot(1,3,3)
ylabel('function value')
xlabel('iteration step')
legend(A.TTprimal)
%set(gca,'YScale', 'log');
end
