function B_val = sample_B( ss )
% Using M-H Sampling to resample the role-compatibility matrix B
% ss: the whole structure

B_sigma = ss.B_sigma;
B_val = ss.B_val;
datas = ss.datas;
feaNum = ss.feaNum;
z_val = ss.z_val;

B_val_candidate = randn(feaNum)*B_sigma;

% do the mask matrix
% maskMat = ss.maskMat;
%

for k= randperm(feaNum)
    for l = randperm(feaNum)
        % select the related rows
        kk = find(z_val(:, k) == 1);
        ll = find(z_val(:, l) == 1);
        
        if ~isempty(kk) || ~isempty(ll)
%             mask_val = maskMat(kk, ll);
%             mask_in = find(mask_val == 1);
            
            % old
            sigma1 = (z_val(kk, :)*B_val)*z_val(ll, :)';
            prob1 = 1./(1+exp(-sigma1));
            prob1 = (prob1.^datas(kk,ll)).*((1-prob1).^(1-datas(kk,ll)));
%             prob1(mask_in) = 1;
            logpr1 = sum(sum(log(prob1)));
            
            % new
            temp_kl = B_val(k, l);
            B_val(k, l) = B_val_candidate(k, l);
            sigma2 = (z_val(kk, :)*B_val)*z_val(ll, :)';
            prob2 = 1./(1+exp(-sigma2));
            prob2 = (prob2.^datas(kk,ll)).*((1-prob2).^(1-datas(kk,ll)));
%             prob2(mask_in) = 1;
            logpr2 = sum(sum(log(prob2)));
            
            % comparison
            if rand < (1+(1+exp(-(logpr1 - logpr2))))
                B_val(k, l) = temp_kl;
            end
        end
    end
end

end

