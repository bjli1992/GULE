function [I,J,nb_sdist,sigma] = nbhood_U(U,n_class,s_class,k_0)

% Neighborhoods of Y whose columns are unit

if nargin<4, k_0 = 5; end

n = size(U,1);
m = n/n_class; %s_class = ceil(m);
k_c = k_0+floor(log2(m));

I = zeros(n.*s_class,1);
J = zeros(n.*s_class,1);
Nb = cell(1,n);
nb_sdist = cell(1,n);
sigma = zeros(1,n);

parfor i = 1:n
    warning off;
    di2 = pdist2(U, U(i,:),'cosine');
    [sort_i,idx_i] = sort(sqrt(di2));
    diff_dic = diff(sort_i(k_c:end));
    [~,ki] = max(diff_dic);
    ki = ki+k_c-1; ki = min(ki,s_class);

    sigma(i) = sort_i(ki+1);

    if ismember(i,idx_i(1:ki))
        Nb{i} = idx_i(1:ki);
    else
        Nb{i} = union(i,idx_i(1:ki-1));
    end
    nb_sdist{i} = di2(Nb{i});
end

ie = 0;

for i=1:n
    ni = length(Nb{i});
    is = ie+1; ie = ie+ni;
    I(is:ie) = Nb{i};
    J(is:ie) = i;
end

I(ie+1:end) = [];
J(ie+1:end) = [];
