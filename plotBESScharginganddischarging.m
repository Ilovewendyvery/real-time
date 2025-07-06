function plotBESScharginganddischarging(TT)
if nargin==0
    TT='New100.mat';
end

load(TT,"obj")
time=0.5:0.5:obj.Data.T/2;
linestyle = {'-', '--', ':', '-.','--',};
colors = {'b', 'g', 'r', 'c', 'm', 'y', 'k','b', 'g', 'r', 'c', 'm'};
figure;
hold on;
mm=obj.Data.Nr/obj.Data.numer_of_feeder;
for k=1:obj.Data.numer_of_feeder
    mb=k*mm;ma=1+(k-1)*mm;
    plot(time, sum(obj.PbatT(ma:mb,:)) , 'LineStyle', linestyle{1},'Color', colors{k},'LineWidth',1.5)
    plot(time, sum(obj.Data.BPVL.GG2Bat(ma:mb,:)) , 'LineStyle', linestyle{2},'Color', colors{k},'LineWidth',1.5)
end
hold off;
box on
xlabel('Time(h)')
ylabel('Power(KW)')
LEGTT=cell(1,2*obj.Data.numer_of_feeder);
for kkk=1:obj.Data.numer_of_feeder
    LEGTT{2*kkk-1}=strcat('B2R-',num2str(kkk));
    LEGTT{2*kkk}=strcat('PVB-',num2str(kkk));
end
legend(LEGTT,'Location','west');
title('charging (PVB) and discharging (B2R) at different feeders')
end