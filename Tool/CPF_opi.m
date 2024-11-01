function [X,Q,fs,df_norms,flag] = CPF_opi(W,options)

% CPF_opi computes the CP facorization based on the outer-point mathod
% min f(W) = 0.25\|XX^T-I\|_F^2 +0.5*lambda*\|(WX)_-\|_F^2

[lambda,rho,sigma,maxiter,ac,kappa,nu] = getopts(options);
ac_dfnorm = ac(1);
ac_f = ac(2);
ac_steplength = ac(3);

r = size(W,2);
eta = 0.5*sigma/(sigma-rho);

% Compute f and gradient at the initial X
if isfield(options,'init')
    X = options.init;
    OX = X*X'-eye(r);
    WX = W*X;
else
    X = diag(sign(sum(W)));
    WX = W;
end
WX_ = min(WX,0);
df = lambda*(W'*WX_);
f = 0.5*lambda*norm(WX_,'fro')^2; f2 = f;

if isfield(options,'init')
    f1 = 0.25*norm(OX,'fro')^2;
    f = f1 + f2;
    df = df + OX*X;
end
if f<1.e-26
    fs = f; Q = X;
    return
end

fs = ones(maxiter,1);
df_norms = zeros(maxiter,1);

df_norm = norm(df,'fro'); df_norm2 = df_norm^2;
D = -df;   D_norm = df_norm;
df_d = -df_norm2; % = <D, df>

% NCG itaration
flag = -1;
for iter = 1:maxiter
    fs(iter) = f;
    df_norms(iter) = df_norm;
    
    % 1. Choose a suitable step length c for the linear search
    rho_dfd = rho*df_d; sigma_dfd = sigma*df_d;
    a = 0; fa = f; dfa_d = df_d;
    
    % 1.1) Choose [a,b] with b not satisfying Wolfe condition (1)
    b = eta; WD = W*D;
    while 1
        Xb = X + b*D;
        OXb = Xb*Xb' - eye(r);
        WXb_ = min(WX+b*WD,0);
        fb1 = 0.25*norm(OXb,'fro')^2;
        fb2 = 0.5*lambda*norm(WXb_,'fro')^2;
        fb = fb1 + fb2;
        if fb > f + b*rho_dfd
            break;
        else
            b = 2*b;
        end
    end
    
    % 1.2) Determine c via shrinking the interval [a b]
    while 1
        % Choose c
        delta = b-a;
        c = a - 0.5*delta^2*dfa_d/(fb-fa-delta*dfa_d);
        c = max(c,eta*a+(1-eta)*b);
        Xc = X + c*D;
        OXc = Xc*Xc' - eye(r);
        WXc = WX+c*WD; WXc_ = min(WXc,0);
        fc1 = 0.25*norm(OXc,'fro')^2;
        fc2 = 0.5*lambda*norm(WXc_,'fro')^2;
        fc = fc1 + fc2;
        
        % Shrink the interval [a b] to [a c] or [c b]
        if fc > f + c*rho_dfd      % c does not satisfy Wolfe condition (1)
            b = c; fb = fc;
        else                       % c satisfy Wolfe conditions (1)
            dfc = OXc*Xc + lambda*(W'*WXc_);
            dfc_d = sum(dfc(:).*D(:)); % = <D,dfc>
            if dfc_d < sigma_dfd   % c does not satisfy Wolfe condition (2)
                a = c; fa = fc; dfa_d = dfc_d;
            else                   % c satisfy Wolfe conditions (1, 2)
                break
            end
        end
        
        % Check the convergece of interval updating
        if (b-a)/b<ac_steplength
            break
        end
    end
    var_f = f-fc;
    var_df = dfc-df;
    df_norm2_ = df_norm2;
    
    X = Xc; f = fc; WX = WXc; df = dfc;
    df_norm = norm(df,'fro'); df_norm2 = df_norm^2;
    
    % Check convergence of NCG
    %if (df_norm<1.e-5 && f>df_norm) ||(df_norm < ac_dfnorm && var_f<ac_f)
    if df_norm < ac_dfnorm && var_f<ac_f
        flag = 0;
        fs(iter+1:end) = [];
        df_norms(iter+1:end) = [];
        break
    else
        % Update the conjugated gradient D
        temp = var_df; 
        t = nu*norm(var_df,'fro')^2/df_norm2_;
        temp = temp-t*D;
        temp = max(0, sum(dfc(:).*temp(:)));
        temp = min(temp/df_norm2_,kappa*df_norm/D_norm);
        beta = temp;
        
        D = beta*D-df;
        D_norm = norm(D,'fro');
        
        
        % Reset the direction if necessary
        df_d = sum(df(:).*D(:));
    end
end

if nargout >= 2
    [U,~,V] = svd(X,'econ');
    Q = U*V';
end

end

function [lambda,rho,sigma,maxiter,ac,kappa,nu] = getopts(options)

lambda = 1.e-3; rho = 0.1; sigma = 0.4;  maxiter = 1000;
ac = [1.e-8,1.e-32, 1.e-15];  kappa = 1000; nu = 1;

if isfield(options,'lambda'),   lambda = options.lambda;           end
if isfield(options,'rho'),      rho = options.rho;                 end
if isfield(options,'sigma'),    sigma = options.sigma;             end
if isfield(options,'maxiter_NCG'),  maxiter = options.maxiter_NCG; end
if isfield(options,'ac'),       ac = options.ac;                   end
if isfield(options,'kappa'),    kappa = options.kappa;             end
if isfield(options,'nu'),       nu = options.nu;                   end
end
