function a = ex_parallel(M, N)
% --------
% EX_PARALLEL performs N trials of
%  computing the largest eigenvalue 
% for an M-by-M random matrix
%
% Inputs:
% M     number of rows and columns
%       of each matrix
% N     number of trials
%
% Output:
% a     vector of largest eigenvalues
%
% Example:
% >> a = ex_parallel(50,4000);
rng(1);
a = zeros(N,1); 
parfor I = 1:N 
    a(I) = max(eig(rand(M)));
end

% Copyright 2010 - 2014 The MathWorks, Inc.

