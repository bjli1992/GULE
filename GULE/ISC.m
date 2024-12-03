function [idx,Y,phi,A,idx_kmns,idx_kmds] = ISC(ab,I,J,nb_sdist,sigma,nb_0,n_class,s_class,n_layer,func, repa)

% Iteligent spectral clustering 

k_0 = 5; 
n = length(sigma);
for t=2:n_layer
  % Construct a sigmoid graph for the first yaler
  A = sigmoid_graph_Y(ab(t,1),I,J,nb_sdist,sigma,nb_0, repa);

  % Take the intelligent spectral projection in the first layer
  d = sum(A,2); d_ = d.^(-ab(t,2)/2);
  D_inv_pow = spdiags(d_,0,n,n); % Create a sparse diagonal matrix with d_ on the diagonal
  G = D_inv_pow * A * D_inv_pow; 
  G = (G + G')/2;

  if n<1000
     [U,~] = eigs(G,n_class,'largestreal','SubspaceDimension',min(n,1000));      
  else
     [U,~] = eigs(G,n_class,'largestreal'); 
  end


  % estimate the calss-consistent neighbor sets
  if t<n_layer
    [I,J,nb_sdist,sigma] = nbhood_U(U,n_class,s_class,k_0);
  end
end


% CP clustering
[idx,UQ] = cp_clustering(U); Y = UQ';

% kmeans clustering
idx_kmns = kmeans(U,n_class);

% kmedian clustering
idx_kmds = kmedoids(U,n_class);


if nargout==2
  return
end

% Compute opjective function
P = Y'; P = bsxfun(@ldivide,sqrt(sum(P.^2,2)) + eps,P);

switch func
  
  case 'db/(sc*ch)'
    eva = evalclusters(P,idx,'DaviesBouldin');
    db = eva.CriterionValues;
    eva = evalclusters(P,idx,'silhouette');
    sc = eva.CriterionValues;
    eva = evalclusters(P,idx,'CalinskiHarabasz');
    ch = eva.CriterionValues;
    phi = db/(sc*ch);

  case 'db/sc'
    eva = evalclusters(P,idx,'DaviesBouldin');
    db = eva.CriterionValues;
    eva = evalclusters(P,idx,'silhouette');
    sc = eva.CriterionValues;
    phi = db/(sc);

  case 'db'
    eva = evalclusters(P,idx,'DaviesBouldin');
    phi = eva.CriterionValues;

  case '1/ch'
    eva = evalclusters(P,idx,'CalinskiHarabasz');
    ch = eva.CriterionValues;
    phi =1/ch;
end

