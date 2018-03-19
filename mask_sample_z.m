function ss = mask_sample_z( ss )

% Get the privious values from the whole structure
datas = ss.datas;
eta_val = ss.eta_val;
psi_v = ss.psi_v;
pi_val = ss.pi_val;
dataNum = ss.dataNum;
nums = ss.nums;
tau_kl = ss.tau_kl;
tau1_kl = ss.tau1_kl;
alpha_B = ss.alpha_B;
beta_B = ss.beta_B;
seLabel = ss.seLabel;
reLabel = ss.reLabel;
Nik = ss.Nik;
numClass = max(nums);

% set the mask value
masks = ss.masks;
% end here

%% sample \{s_{ij}, r_{ij}\}_{i,j}
for i=randperm(dataNum)
    for j=randperm(dataNum)
        if (sum(j==masks(i,:))==0)
            
            se_la = seLabel(i,j);
            re_la = reLabel(i,j);
            % edge(i,j,t)'s likelihood calculation
            Nik(i, se_la) = Nik(i, se_la) - 1;
            Nik(j, re_la) = Nik(j, re_la) - 1;
            tau_kl(se_la, re_la)=tau_kl(se_la, re_la)-1;
            tau1_kl(se_la, re_la)= tau1_kl(se_la, re_la)-datas(i,j);
            tau0_kl = tau_kl-tau1_kl;
            
            % calculating the likehood value
            if (datas(i,j)==1)
                like_wei = ([tau1_kl(1:nums(i),1:nums(j)) zeros(nums(i),1);zeros(1,(nums(j)+1))]+alpha_B)./([tau_kl(1:nums(i), 1:nums(j)) zeros(nums(i),1);zeros(1,(nums(j)+1))]+alpha_B+beta_B);  % change the denominator
            else
                like_wei = ([tau0_kl(1:nums(i),1:nums(j)) zeros(nums(i),1);zeros(1,(nums(j)+1))]+beta_B)./([tau_kl(1:nums(i), 1:nums(j)) zeros(nums(i),1);zeros(1,(nums(j)+1))]+alpha_B+beta_B);
            end

            % prob_can: the prior probability of s_{ij} = k, r_{ij} = l. 
            p_weight = diag([pi_val(i,1:nums(i)) 1-sum(pi_val(i,1:nums(i)))])*like_wei*diag([pi_val(j,1:nums(j)) 1-sum(pi_val(j,1:nums(j)))]);
            %
            p_weight = reshape(p_weight, 1, []);
            
            % sampling
            ath_value = 1+sum((rand*sum(p_weight)) > cumsum(p_weight));
            ath_col = ceil(ath_value/(nums(i)+1));
            ath_row = ath_value - (ath_col-1)*(nums(i)+1);
            
            seLabel(i,j) = (ath_row);
            reLabel(i,j) = (ath_col);
                      
            % consider the case (ath_col > numClass) or (ath_row > numClass)
            % Nikt's changing
            if max(ath_row, ath_col)>numClass
                
                % need to add new features \eta_{f, k+1}
                eta_val(:, (end+1))= gamrnd(ones(size(ss.attr, 2), 1)*ss.alpha_eta, ones(size(ss.attr, 2), 1)*(1/ss.beta_eta));
                psi_v(:, (end+1)) = betarnd(1, exp(ss.attr*log(eta_val(:, end)))); % here is the wrong problem
                pi_val(:, end:(end+1)) = bsxfun(@times, pi_val(:, end), [psi_v(:, end) 1-psi_v(:, end)]);
                % add operation ends here

                tau_kl = [tau_kl zeros(numClass, 1); zeros(1, (numClass+1))];
                tau1_kl = [tau1_kl zeros(numClass, 1); zeros(1, (numClass+1))];
                Nik(:, (end+1)) = zeros(dataNum, 1);
                numClass = numClass+1;
            end
            if ath_row > nums(i)  % here is something wrong
                nums(i) = nums(i)+1;
            end
            if  ath_col > nums(j)
                nums(j) = nums(j)+1;
            end
            Nik(i, ath_row) = Nik(i, ath_row) + 1;
            Nik(j, ath_col) = Nik(j, ath_col) + 1;
            tau_kl(ath_row, ath_col)=tau_kl(ath_row, ath_col)+1;
            tau1_kl(ath_row, ath_col)=tau1_kl(ath_row, ath_col)+datas(i,j);

        end
    end
end

% remove the empty cluster
empty_clu = find(sum(Nik)==0);


if ~isempty(empty_clu)  % clean the empty component
    
    tau_kl(:,empty_clu) = [];
    tau_kl(empty_clu,:) = [];
    tau1_kl(:,empty_clu) = [];
    tau1_kl(empty_clu,:) = [];
    % need to deal with eta_val, psi_v, pi_val
    eta_val(:, empty_clu) = [];
    psi_v(:,empty_clu) = [];
    Nik(:, empty_clu) = [];
    pi_val = [psi_v ones(dataNum, 1)].*[ones(dataNum, 1) cumprod(1-psi_v, 2)];
    % 
    
    for i = 1:dataNum
        if any(empty_clu <= nums(i))
            nums(i) = nums(i) - sum(empty_clu <= nums(i));
        end
    end
    
    for k = 1:numClass
        if ~any(empty_clu ==k)
            trans_k = k-sum(empty_clu < k);
            seLabel(seLabel==k) = trans_k;
            reLabel(reLabel==k) = trans_k;
        end
    end
end

ss.Nik = Nik;
ss.eta_val = eta_val;
ss.psi_v = psi_v;
ss.pi_val = pi_val;
ss.nums = nums;
ss.tau_kl = tau_kl;
ss.tau1_kl = tau1_kl;
ss.seLabel = seLabel;
ss.reLabel = reLabel;

end

