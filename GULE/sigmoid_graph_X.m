function A = sigmoid_graph_X(nb_idx,nb_dist,alpha)

[k,n] = size(nb_idx);
sigma_A = nb_dist(k,:);
A = exp(bsxfun(@rdivide,nb_dist.^2,2*(sigma_A/alpha).^2+eps));
A = 2./(1+A);
A = A.*(nb_dist<sigma_A+eps);
A = sparse(nb_idx(:),kron((1:n)',ones(k,1)),A(:),n,n);
A = max(A,A');