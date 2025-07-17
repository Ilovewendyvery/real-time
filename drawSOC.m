function drawSOC(obj,k)
figure(k)
time=(0:48)/2;
hold on;
plot(time,obj.Data.BPVL.SOC(1,:))
plot(time,obj.Data.BPVL.SOC_of_EV(1,:))
hold off;
legend('SOC of Bat','SOC of EV')
end