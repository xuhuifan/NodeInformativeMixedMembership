function [psi_v, pi_val] = sample_psi(ss)
% sample_psi: sample \psi value
% \psi's posterior distribution is a beta distribution

% Get the privious values from the whole structure

eta_val = ss.eta_val;
attr = ss.attr;
Nik = ss.Nik;
dataNum = ss.dataNum;
% Start to generate the new value 
pos_alpha_psi = Nik + 1;
pos_beta_psi = 2*dataNum - cumsum(Nik, 2) + exp(attr*log(eta_val));

psi_v = betarnd(pos_alpha_psi, pos_beta_psi);
pi_val = [psi_v ones(dataNum, 1)].*[ones(dataNum, 1) cumprod(1-psi_v, 2)];

end
