function Percentage_of_Photovoltaic_Utilization_winter()
% %updata
% isupdata=false;
% if isupdata
%     obj= Algorithms('100winter','New');
%     obj.Method.iter_max=40;
%     Solve_ALL(obj)
%     save('result/New100winter.mat','obj')
% end

%plot
TT='result/New100winter.mat';
load(TT,'obj')
linestyle = {'-', '--', ':', '-.','--',}; 
time=0.5:0.5:obj.Data.T/2;
figure;
hold on;

% ydata=zeros(5,48);
[r,l]=size(obj.Data.GG);
pgene=obj.Data.GG;
pload=obj.Data.GC;
idx=(pgene<=pload);
Percentage=zeros(r,l);
Percentage(idx)=1;
SOC=obj.Data.BPVL.SOC(:,1:end-1);
pv2bat=(1-SOC)*obj.Data.Capacity_bat*obj.Data.BPVL.eta;
nidx=logical(1-idx);
Percentage(nidx)=min(pv2bat(nidx)./pgene(nidx),1);
plot(time, mean(Percentage,1), ...
    'LineStyle', linestyle{1}, 'Color', 'b', 'LineWidth', 2);
% ydata(i,:)=(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i);


TT='result/New100.mat';
load(TT,'obj')
[r,l]=size(obj.Data.GG);
pgene=obj.Data.GG;
pload=obj.Data.GC;
idx=(pgene<=pload);
Percentage=zeros(r,l);
Percentage(idx)=1;
SOC=obj.Data.BPVL.SOC(:,1:end-1);
pv2bat=(1-SOC)*obj.Data.Capacity_bat*obj.Data.BPVL.eta;
nidx=logical(1-idx);
Percentage(nidx)=min(pv2bat(nidx)./pgene(nidx),1);
plot(time, mean(Percentage,1), ...
    'LineStyle', linestyle{2}, 'Color', 'r', 'LineWidth', 2);
% ydata(i,:)=(AA(i,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(i);

hold off;
legend('winter','summer')
xlabel('Time (h)')
ylabel('Percentage')
title('Percentage of Photovoltaic Utilization in winter')
box on


% xdata=time;
% data=[xdata',ydata'];
% writematrix(data, '5overleadingCWinter.csv');
end

