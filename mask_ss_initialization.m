function ss = mask_ss_initialization(ELwork, attr)
% ss_initialization: initialize the structure: ss

ss.datas = ELwork;
ss.attr = attr;

% Define the basic values
ss.dataNum = size(ELwork, 1);
dataNum = ss.dataNum;
feaNum = 4;
ss.nums = ones(ss.dataNum, 1)*feaNum;
% define the maskMat value
load('maskIndex.mat');
masks_index = (masks - 1)*dataNum + (1:dataNum)'*ones(1, maskNum);
maskMat = zeros(dataNum, dataNum);
maskMat(masks_index) = 1;
ss.maskMat = logical(maskMat);
ss.masks = masks;
% define the variable's sigma value
ss.alpha_B = 1;
ss.beta_B = 1;
ss.alpha_eta = 1;
ss.beta_eta = 1;
characters = size(attr, 2);

% Initialize the Main variables
B_val = betarnd(ones(feaNum, feaNum)*ss.alpha_B, ones(feaNum, feaNum)*ss.beta_B);
ss.eta_val = gamrnd(ones(characters, feaNum)*ss.alpha_eta, ones(characters, feaNum)*(1/ss.beta_eta));

prod_eta = exp(ss.attr*log(ss.eta_val));

ss.psi_v = betarnd(prod_eta, 1);
ss.pi_val = [ss.psi_v ones(ss.dataNum, 1)].*[ones(ss.dataNum, 1) cumprod(1-ss.psi_v, 2)];

seLabel = zeros(ss.dataNum);
reLabel = zeros(ss.dataNum);
% initialize the ss.seLabel, ss.reLabel's values
for i = randperm(ss.dataNum)
    for j = randperm(ss.dataNum)
        sample_table = (diag(ss.pi_val(i,1:(end-1)))*(ss.datas(i,j)*B_val+(1-ss.datas(i,j))*(1-B_val)))*diag(ss.pi_val(j,1:(end-1)));
        
        p_weight = reshape(sample_table, 1, []);
            
        % sampling
        ath_value = 1+sum((rand*sum(p_weight)) > cumsum(p_weight));
        ath_col = ceil(ath_value/(feaNum));
        ath_row = ath_value - (ath_col-1)*(feaNum);
        
        seLabel(i,j) = ath_row;
        reLabel(i,j) = ath_col;
    end
end

ss.seLabel = seLabel;
ss.reLabel = reLabel;

% calculate the values of Nik
Nik = zeros(ss.dataNum, feaNum);
for i = 1:ss.dataNum
    [Nik(i,:), unsee] = hist([seLabel(i,:) reLabel(:,i)'], 1:feaNum);
end
for i_sli = 1:dataNum
    for k = 1:maskNum
        Nik(i_sli, seLabel(i_sli, masks(i_sli, k))) = Nik(i_sli, seLabel(i_sli, masks(i_sli, k))) - 1;
        Nik(masks(i_sli, k), reLabel(i_sli, masks(i_sli, k))) = Nik(masks(i_sli, k), reLabel(i_sli, masks(i_sli, k))) - 1; 
    end
end
ss.Nik = Nik;
%

tau_kl = zeros(feaNum, feaNum);  % pre_define the matrix n_{k,l}
tau1_kl = zeros(feaNum, feaNum); % pre_define the matrix n_{k,l}^1

for k = 1:feaNum    % this is to calculate the matrix n_{k,l}'s value
    for l=1:feaNum
        
        xy_loc=((seLabel==(k))&(reLabel==(l)));
        tau1_kl(k,l)=sum(row_sum(ss.datas(xy_loc)));
        tau_kl(k,l) =sum(row_sum(xy_loc));
    end
end
for i = 1:dataNum
    for k = 1:maskNum
        tau_kl(seLabel(i, masks(i, k)), reLabel(i, masks(i, k))) = tau_kl(seLabel(i, masks(i, k)), reLabel(i, masks(i, k))) - 1;
        tau1_kl(seLabel(i, masks(i, k)), reLabel(i, masks(i, k))) = tau1_kl(seLabel(i, masks(i, k)), reLabel(i, masks(i, k))) - ss.datas(i, masks(i, k));
    end
end
ss.tau_kl = tau_kl;
ss.tau1_kl = tau1_kl;

end
