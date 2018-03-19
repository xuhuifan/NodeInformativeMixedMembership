function stats = sta_compute(ss)
% % sta_compute: compute all the statistics such as train_error, test_error,
% %              test loglikelihood,AUC 
% % ss: the whole structure
% % stats: structure includes the train_error, test error, test log likelihood, AUC
% 
% maskMat = ss.maskMat;
seLabel = ss.seLabel;
reLabel = ss.reLabel;
feaNum = max(ss.nums);
datas= ss.datas;
tau_kl = ss.tau_kl;
tau1_kl = ss.tau1_kl;
alpha_B = ss.alpha_B;
beta_B = ss.beta_B;
% mask_data = datas_ori(maskMat);
% 
probs_1 = (tau1_kl+alpha_B)./(tau_kl + alpha_B + beta_B);

indexs = (reLabel -1)*feaNum + seLabel;
probs = probs_1(indexs);
% % compute the training error and test error
err = (probs - datas).^2;

stats.err = sum(err(:))/numel(datas);
stats.probs = probs;
% train_index = (maskMat == 0);
% test_index = (maskMat == 1);
% train_error = sum(sum(err(train_index)))/sum(train_index(:));
% test_error = sum(sum(err(test_index)))/sum(test_index(:));
% 
% % compute the test log likelihood
% test_p = probs(maskMat);
% test_prob = (test_p.^mask_data).*((1-test_p).^(1-mask_data));
% test_loglike = sum(sum(log(test_prob)));
% 
% % compute the AUC value
% n1 = sum(sum(mask_data == 1));
% no = sum(sum(mask_data == 0));
% 
% test_p = reshape(test_p, 1, []);
% test_data = reshape(mask_data, 1, []);
% [ranked_bern rank_indcs] = sort(test_p);
% R_sorted = test_data(rank_indcs);
% So = sum(find(R_sorted > 0));
% auc = (So - (n1*(n1+1))/2)/(n1*no);
% 
% % return the values
% stats.train_error = train_error;
% stats.test_error = test_error;
% stats.test_loglike = test_loglike;
% stats.auc = auc;

end

