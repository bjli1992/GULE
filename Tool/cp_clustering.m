function [idx,P,mean_smallgaps] = cp_clustering(U)

% CP clustering that gives
%   P       - orthogonally transformed matrix of U
%   idx     - index set of the largest component in each row
%   idx_sg  - index of the rows with small gap of its first two largest components


[n,dim] = size(U);
options_OPI.kappa = 1000;
options_OPI.nu = 1;
options_OPI.init = eye(dim);

P = U*diag(sign(sum(U)));
[~,Q] = CPF_opi(P,options_OPI);
P = P*Q;

if nargout <=2
  [~,idx] = max(P,[],2);
else
  [P_,idx] = maxk(P,2,2); idx = idx(:,1);
  mean_smallgaps = mean(mink(P_(:,1)-P_(:,2),rougn(n/10)));
end
