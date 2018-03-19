function     ss = sample_hyper(ss);
% % we need to sample the hyper-parameters here to be precisely defined

eta_val = ss.eta_val;
feaNum = ss.feaNum;
f_sigma = ss.f_sigma;
dataNum = ss.dataNum;
attr = ss.attr;
v_val = ss.v_val;
B_val = ss.B_val;

% Sampling \mu_f
f_mu = randn(size(eta_val, 1), 1)*(1+feaNum/(f_sigma^2))^(0.5) + sum(eta_val, 2)/(f_sigma^2+feaNum);
ss.f_mu = f_mu;

% Sampling f_sigma
a_f = 1;
b_f = 1;
com_af = a_f + feaNum*size(eta_val, 1)/2;
com_bf = b_f + sum(sum((bsxfun(@minus, eta_val, f_mu)).^2))/2;
inv_f = gamrnd(com_af, 1/com_bf);
ss.f_sigma = inv_f^(-0.5);

% Sampling v_sigma
a_v = 1;
b_v = 1;
com_av = a_v + feaNum * dataNum /2;
com_bv = b_v + sum(sum((v_val - attr*eta_val).^2))/2;
inv_v = gamrnd(com_av, 1/com_bv);
ss.v_sigma = inv_v^(-0.5);

% Sampling B_sigma
a_B = 1;
b_B = 1;
com_aB = a_B + (feaNum^2)/2;
com_bB = b_B + sum(sum(B_val.^2))/2;
inv_B = gamrnd(com_aB, 1/com_bB);
ss.B_sigma = inv_B^(-0.5);

end

