function stats = mask_sta_compute(ss)
% sta_compute: compute all the statistics such as train_error, test_error,
%              test loglikelihood,AUC
% dim3: the whole structure
% stats: structure includes the train_error, test error, test log likelihood, AUC

maskMat = ss.maskMat;
datas = ss.datas;
seLabel = ss.seLabel;
reLabel = ss.reLabel;
mask_data = datas(maskMat);
tau_kl = ss.tau_kl;
tau1_kl = ss.tau1_kl;
Nik = ss.Nik;
numClass = size(tau_kl, 1);

%%% Calculate the deviance of the estimated density
dev_den = 0;
for i = 1:ss.dataNum
    for j = 1:ss.dataNum
        if maskMat(i,j) == 0
            re_tau_kl = tau_kl;
            re_tau1_kl = tau1_kl;
            re_tau_kl(seLabel(i,j), reLabel(i,j)) = re_tau_kl(seLabel(i,j), reLabel(i,j)) - 1;
            re_tau1_kl(seLabel(i,j), reLabel(i,j)) = re_tau1_kl(seLabel(i,j), reLabel(i,j)) - datas(i,j);
            dev_pr = (re_tau1_kl + ss.alpha_B)./(re_tau_kl+ss.alpha_B + ss.beta_B);
            dev_den = dev_den + log(sum(sum((Nik(i,1:(end))'*Nik(j,1:(end))).*dev_pr)))-2*log(2*(ss.dataNum - 1));
        end
    end
end
%%%
std_dev = -2*dev_den;
pr = (tau1_kl+ss.alpha_B)./(tau_kl + ss.alpha_B + ss.beta_B);
la_in = (reLabel-1)*numClass + seLabel;
probs = pr(la_in);
% compute the training error and test error
err = (probs - datas).^2;
train_index = (maskMat == 0);
train_error = sum(sum(err(train_index)))/sum(train_index(:));

p_Nikt = Nik./repmat(sum(Nik, 2), 1, size(Nik, 2));
% p_Nikt(:, end) = [];
test_p = (p_Nikt*pr)*p_Nikt';  % here lies one problem
test_p = test_p(maskMat);
test_e = (test_p - mask_data).^2;
test_error = sum(sum(test_e))/sum(maskMat(:));

% compute the test log likelihood
%test_p = probs(maskMat);
test_prob = (test_p.^mask_data).*((1-test_p).^(1-mask_data));
test_loglike = sum(sum(log(test_prob)));

% compute the AUC value
n1 = sum(sum(mask_data == 1));
no = sum(sum(mask_data == 0));

test_p = reshape(test_p, 1, []);
test_data = reshape(mask_data, 1, []);
[ranked_bern, rank_indcs] = sort(test_p);
R_sorted = test_data(rank_indcs);
So = sum(find(R_sorted > 0));
auc = (So - (n1*(n1+1))/2)/(n1*no);

% return the values
stats.train_error = train_error;
stats.test_error = test_error;
stats.test_loglike = test_loglike;
stats.auc = auc;
stats.std_dev = std_dev;
stats.probs = probs;
end

