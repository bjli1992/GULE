function A = sigmoid_graph_Y(alpha, I, J, nb_sdist, sigma, nb_init, repa)

% Construct a sparse sigmoid graph A
n = length(sigma);
A_temp = cell(n, 1);

parfor i = 1:n
    bi = exp(nb_sdist{i}/(2*(sigma(i)/alpha)^2+eps));
    A_temp{i} = 2./(1+bi);
end

% Concatenate A_temp cell array into a single column vector
A_ = vertcat(A_temp{:});

% Construct the sparse matrix A
A = sparse(I,J,A_);
A = max(A,A');

if repa == 1
    [k_c, n] = size(nb_init);
    A_ = sparse(nb_init(:),kron((1:n)',ones(k_c,1)),ones(k_c*n,1),n,n);
    A_ = logical(max(A_,A_'));
    A = max(A,A_);
end
