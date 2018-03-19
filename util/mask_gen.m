function [masks maskNum] = mask_gen(dataNum)
% generate the mask variables
% dataNum: the total number of data points
maskNum = ceil(dataNum/10);
masks = zeros(dataNum, maskNum);
for i = 1:dataNum
    masks(i, :) = randsample(1:dataNum, maskNum);
end

end

