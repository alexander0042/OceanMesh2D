function [idx, dst] = WrapperForKsearch(dataset,testset,k)
% This wrapper is used because we cannot pass an ANN class object to
% parfeval in MATLAB R2017A.
% See reference (https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ANNmanual_1.1.pdf) returns the squared distances
% ANN: A Library for
% Approximate Nearest Neighbor Searching
% David M. Mount and Sunil Arya
% Version 1.1.2
% Release Date: Jan 27, 2010

% Modified by William to automatically do a projection and get the meters
% distance on a sphere
[dataset(:,1),dataset(:,2)] = m_ll2xy(dataset(:,1),dataset(:,2));
[testset(:,1),testset(:,2)] = m_ll2xy(testset(:,1),testset(:,2));
dataset(isnan(dataset(:,1)),:) = [];
% Find the nearest neighbors
anno = ann(dataset');
idx = ksearch(anno, testset',k,0);
idx = idx';
close(anno);

% The vector of long lat pairs
dst = zeros(length(testset),k);
for kk = 1:k
    long = zeros(length(testset)*2,1);
    lat  = zeros(length(testset)*2,1);
    long(1:2:end) = testset(:,1); long(2:2:end) = dataset(idx(:,kk),1);
    lat(1:2:end) = testset(:,2); lat(2:2:end) = dataset(idx(:,kk),2);
    % Get spherical earth distances
    dt = m_xydist(long,lat);
    dst(:,kk) = dt(1:2:end)*1e3;
end

end