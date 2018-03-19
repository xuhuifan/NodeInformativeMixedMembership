
%main_function: the main function of metadata Latent feature relational model
clear;
% data loading
addpath('./util')
load('LazegaLawyers/ELwork.dat');  % the work relationship matrix
load('LazegaLawyers/ELattr.dat');  % each nodes' attributes
% ELwork = datas;
%  attr = zeros(size(ELwork, 1), 4);
attr = lazega_post(ELattr);
% attr = ones(size(attr));
% attrites = ELattr;
% datas = ELwork;
ss = mask_ss_initialization(ELwork, attr);

iteration_time = 1000;
train_auc = zeros(1, iteration_time);
probs = zeros(size(ss.datas));
tic;
for ttime = 1:iteration_time
    
    % sampling \eta
    ss.eta_val = sample_eta(ss);
    
    % sampling \pi
    [ss.psi_v, ss.pi_val] = mask_sample_psi(ss);
    
    %     % sampling B
    %     [ss.B_val] = sample_B(ss);
    
    % sampling z
    ss = mask_sample_z(ss);
    
    results = mask_sta_compute(ss);
    train_auc(ttime) = results.auc;
    if ttime > (iteration_time / 2)
        probs = probs + results.probs;
    end
    if mod(ttime, 100)==0
        toc;
        fprintf('iteration time is %d\n', ttime);
        tic;
    end
    % sampling hyper parameters
    % ss = sample_hyper(ss);
end

tr_probs = probs/(iteration_time/2);
figure(1);
imshow(~ss.datas);
figure(2);
imshow(1-tr_probs);
figure(3);
plot(train_auc);


%

