function U =Utility_fun(Pev_i)
beta_ev=8;
omega_ev=1;
Pmax_ev=10; %kw
% Kw
U=beta_ev*log(omega_ev*min(Pev_i,Pmax_ev)+1)/log(3);
end