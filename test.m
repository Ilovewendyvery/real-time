clear;close all;
figure(1)
load("D:\WorkSpace\Code\real-time\result\ADMM100_noRestrain.mat",'obj');
draw(obj,'-s')
load("D:\WorkSpace\Code\real-time\result\ADMM100.mat",'obj');
draw(obj,'-^')
load("D:\WorkSpace\Code\real-time\result\New100.mat",'obj');
draw(obj,'-o') 
% legend('EV','Resident','REP','bat','total','New-EV','New-Resident','New-REP','New-bat','New-total')
legend('C-no','C','New')
function draw(obj,TT)
time=0.5:0.5:obj.Data.T/2;
U_EV=zeros(1,48);
U_RE=zeros(1,48);
U_REP=zeros(1,48);
U_Bat=zeros(1,48); 
U_EV(1,:)=sum(-Utility_fun_EV(obj.PevT),1);
U_RE(1,:)=sum(-Utility_fun_Resident(obj.PbuyT,obj.PbatT,obj.Data.BPVL.GG2user,obj.Data.BPVL.GC),1);
AA=[obj.PevT;obj.PbuyT];
for t=1:48 
U_REP(1,t)=sum(obj.Data.minREP.Cost_fun(AA(:,t)),1);
end
U_Bat(1,:)=sum(Cost_func(obj.PbatT,obj.Data.BPVL.GG2Bat,obj.Data.BPVL.SOC(:,1:end-1)),1); 

hold on;
% plot(time,U_EV,TT); 
% plot(time,U_RE,TT); 
% plot(time,U_REP,TT); 
% plot(time,U_Bat,TT); 
% plot(time,obj.Data.BPVL.SOC(3,1:end-1))
plot(time,U_EV+U_RE+U_REP+U_Bat,TT,'linewidth',2)
% time=0.5:0.5:obj.Data.T/2;
%  plot(time,(obj.Data.U_feeder(1,:)*[obj.PevT;obj.PbuyT])/obj.Data.B_feeder(1))

end


 



function U =Utility_fun_EV(Pev_i)
beta_ev=8;
omega_ev=1;
Pmax_ev=10; %kw
% Kw
U=beta_ev*log(omega_ev*min(Pev_i,Pmax_ev)+1)/log(3);
end


function U =Utility_fun_Resident(Pbuy_j,Pbat_j,GG2user_j_k,GC_j_k)
alpha_re=0.9;
omega_re=20;
U=omega_re*(Pbuy_j+Pbat_j+GG2user_j_k).^alpha_re;

idx=Pbuy_j+Pbat_j+GG2user_j_k > GC_j_k;
U(idx)= omega_re*GC_j_k(idx).^alpha_re; 
end

function C=Cost_func(Pbat_j,GG2Bat_j,SOC)
Capacity_bat=10;% kw*h
bat_beta=1;
eta=0.95;
Time_int=0.5;

C=bat_beta*(Capacity_bat./(Capacity_bat+SOC*Capacity_bat+eta*GG2Bat_j*Time_int-Pbat_j*Time_int/eta));
end