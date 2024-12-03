function [nb_idx,nb_dist,nb_init]=nbhood_X(X,n_class,k_0,distype)

n = size(X,2); 
m = n/n_class; 
m_ = ceil(m);
k_c = floor(log2(m));

k = k_0+k_c+1;
nb_dist = zeros(k,n);
nb_idx = zeros(k,n);
pe = 0;
switch distype
  case 'euclidean'
    for p=1:n_class
      ps = pe+1; pe = min(n,pe+m_);
      Dk = pdist2(X',X(:,ps:pe)');  
      [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
    end
    case 'nm_euclidean'
    X = bsxfun(@rdivide,X,sqrt(sum(X.^2,1)));
    for p=1:n_class
      ps = pe+1; pe = min(n,pe+m_);
      Dk = pdist2(X',X(:,ps:pe)');  
      [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
    end
  case 'cityblock'
    X = X';
    for p=1:n_class
      ps = pe+1; pe = min(n,pe+m_);
      Dk = pdist2(X,X(ps:pe,:),'cityblock');  
      [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
    end
  case 'spearman'
    X = X';
    for p=1:n_class
      ps = pe+1; pe = min(n,pe+m_);
      Dk = pdist2(X,X(ps:pe,:),"spearman");
      [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
    end    
    case 'nm_seuclidean'
    X = bsxfun(@rdivide,X,sqrt(sum(X.^2,1)));
    for p=1:n_class
      ps = pe+1; pe = min(n,pe+m_);
      Dk = pdist2(X',X(:,ps:pe)','seuclidean');  
      [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
    end  
    case 'correlation'
        X = X';
        for p=1:n_class
            ps = pe+1; pe = min(n,pe+m_);
            Dk = pdist2(X,X(ps:pe,:),'correlation');
            [nb_dist(:,ps:pe),nb_idx(:,ps:pe)] = mink(Dk,k,1);
        end
end

% more pure and smaller neighborhood for recalibrating later estimation
nb_init = nb_idx(1:k_c+1,:);
