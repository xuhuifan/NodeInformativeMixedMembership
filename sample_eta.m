function eta_val = sample_eta( ss )
% sample_eta: sampling the \eta value

% Get the privious values from the whole structure
alpha_eta = ss.alpha_eta;
beta_eta = ss.beta_eta;
attr = ss.attr;
psi_v = ss.psi_v;
eta_val = ss.eta_val;

% Start to \eta_val sampling
% here we sample different k for the same \eta at one time, which will not
% affect the inference and speed up computation at the same time
psi_v(psi_v < 1e-16) = 1e-16;
psi_v(psi_v > (1-1e-16)) = (1-1e-16);
pos_alpha_eta = alpha_eta + sum(attr);

val_2 = exp(attr*log(eta_val));


for f = randperm(size(attr, 2))
    val_2 = val_2./exp(attr(:, f)*(log(eta_val(f, :))));
    pos_beta_eta = beta_eta -sum(bsxfun(@times, attr(:, f), log(1-psi_v)).*val_2);
    eta_val(f, :) = gamrnd(pos_alpha_eta(f), 1./pos_beta_eta);
    val_2 = val_2.*exp(attr(:, f)*(log(eta_val(f, :))));
end

end

