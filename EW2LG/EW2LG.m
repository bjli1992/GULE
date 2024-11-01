function [criteria,idx,Y,U,idx_kmns,idx_kmds,A,B] = EW2LG(X,n_class,opts)

% Extract options from input structure
ab = opts.ab;
labels = opts.labels;
distmetric = opts.distmetric;
n_layer = opts.layers;
s_class = opts.classsize; 

% Set default parameters if not provided in opts
k_0 = 5; if isfield(opts,'k0'), k_0 = opts.k0; end
repa = 1; if isfield(opts,'repa'), repa = opts.repa; end
num_eig = n_class + 5; if isfield(opts,'num_eig'), num_eig = opts.num_eig; end

% Number of data points
n = size(X,2); 

% Determine alpha value for sigmoid function based on data size
alpha = 6; if n/n_class<=100, alpha = 9; end  
if isfield(opts,'alpha'), alpha = opts.alpha; end

% Step 1: First glimpse - Class-consistent neighborhood estimation in raw space
% 1.1 Estimate class-consistent neighborhoods for each data point
[nb_idx,nb_dist,nb_0] = nbhood_X(X,n_class,k_0,distmetric);  

% 1.2 Construct class-consistent credibility graph using sigmoid function
A = sigmoid_graph_X(nb_idx,nb_dist,alpha);  

% 1.3 Perform adaptive spectral projection to obtain low-dimensional representation
% Normalize adjacency matrix and compute Laplacian
% Apply spectral decomposition to extract eigenvectors

d = sqrt(sum(A,2));
D_inv_sqrt = spdiags(1./d,0,n,n);
G = speye(n)-D_inv_sqrt*A*D_inv_sqrt;
G = (G+G')/2;

if n<1000
  [U,~] = eigs(G, num_eig,'smallestabs','SubspaceDimension',min(n,1000)); 
else
  [U,~] = eigs(G, num_eig,'smallestabs');
end
clear G

% Select the appropriate number of eigenvectors based on class consistency
maxu = max(abs(U),[],1);

if all(maxu(1:n_class)<=0.5)
    U = U(:,1:n_class);
else
    ii = nnz(maxu>0.5);
    U = U(:,1: min(n_class + ii, num_eig));
end

% Step 2: Second glimpse - Refine neighborhoods in the projected space
% 2.1 Estimate neighborhoods in the projected space using class-consistent credibility
[I,J,nb_sdist,sigma] = nbhood_U(U,n_class,s_class,k_0); 

% Step 3: Perform Intelligent Spectral Clustering on refined neighborhoods
func = opts.func;
[idx,Y,phi,B,idx_kmns,idx_kmds] = ISC(ab,I,J,nb_sdist,sigma,nb_0,n_class,s_class,n_layer,func, repa);

% Step 4: Calculate clustering evaluation metrics (AC, MI, ARI)
acmiari = [calAC(idx,labels) calMI(idx,labels) calARI(idx,labels)];

% Output criteria including objective function value and evaluation metrics
criteria = [phi acmiari];
