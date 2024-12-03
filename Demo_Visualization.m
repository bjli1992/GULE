% Add required paths
addpath(genpath('Data'));          % Add Data directory and its subdirectories to path
addpath(genpath('GULE'));        % Add GULE algorithm directory
addpath(genpath('Tool'));         % Add Tools directory
rng default;                      % Set random number generator for reproducibility
warning off;                      % Suppress warnings

% Select dataset and initialize parameters
example_id = 3;                   % Choose which dataset to analyze (3 = Entangled)
Datasets = {'Compounded'; 'Rounded'; 'Entangled';'COIL20';'PIE';'MNIST'};  % Available datasets
nmlzs = [2,2,2,2,1,4];           % Normalization type for each dataset
nmlzs_v = [3,3,3,3,2,2];         % Visualization normalization type
n_datasets = size(Datasets,1);    % Total number of datasets
dist_types = {'euclidean','cosine','cityblock','spearman'};  % Available distance metrics

% Load and prepare the selected dataset
data = Datasets{example_id};      % Get dataset name
isnormal = nmlzs(example_id);     % Get normalization type
eval(['load ' data])              % Load the dataset
X = fea';                         % Transform features matrix
labels = gnd-min(gnd)+1;          % Normalize labels to start from 1
n_class = max(gnd)-min(gnd)+1;    % Calculate number of classes
m_ = ceil(length(labels)/n_class); % Calculate approximate class size

% Select distance metric based on normalization type
if isnormal == 0
    dist_type = 'euclidean';
elseif isnormal == 1
    dist_type = 'nm_seuclidean';
elseif isnormal == 2
    dist_type = 'cityblock';
elseif isnormal == 3
    dist_type = 'spearman';
elseif isnormal == 4
    dist_type = 'nm_euclidean';
end

% Set up GULE parameters
n_layers = 2;                     % Number of layers in the graph
fprintf('n_layer: %2d\n',n_layers)
ab = [2*ones(n_layers,1),[1;zeros(n_layers-1,1)]];  % Layer weights

% Configure options for GULE algorithm
opts.ab = ab;                     % Set layer weights
opts.labels = labels;             % Provide ground truth labels
opts.distmetric = dist_type;      % Set distance metric
opts.layers = n_layers;           % Set number of layers
opts.MaxIter = 1;                 % Maximum iterations
opts.classsize = m_;              % Expected class size
opts.func = 'db/(sc*ch)';         % Objective function
opts.repa = 1;                    % Repeat parameter

% Run GULE algorithm
[criteria,idx,Y,U] = GULE(X,n_class,opts);
pred_groups = idx;                % Store predicted groups

% Visualization: Original Data (Left subplot)
subplot(1,2,1);
Z0 = tsne(X','Distance', dist_types{nmlzs_v(example_id)},'Perplexity',30);  % t-SNE on raw data
gscatter(Z0(:,1),Z0(:,2),gnd);   % Scatter plot colored by ground truth
legend off;
si_v = silhouette(Z0,gnd);       % Calculate silhouette score
title([data,', Raw, SI = ',num2str(mean(si_v),2)]);  % Title with silhouette score
title([data,', Raw']);           % Simple title
box off;
xlabel('t-SNE 1');
ylabel('t-SNE 2');
ax = gca;
ax.LineWidth = 1.5;

% Visualization: GULE Results (Right subplot)
subplot(1,2,2);
% Combine original and learned distances
Dx = pdist2(X',X',dist_types{nmlzs_v(example_id)});  % Original distance matrix
Dy = pdist2(Y',Y','cosine');     % Distance matrix in learned space
D = Dx/max(Dx(:)) + Dy/max(Dy(:));  % Normalized combined distance

% Visualize using t-SNE with custom distance matrix
Z = tsne_d(D);                    % Apply t-SNE
gscatter(Z(:,1),Z(:,2),gnd);     % Scatter plot colored by ground truth
legend off;
si_v = silhouette(Z,gnd);        % Calculate silhouette score
title([data,', GULE, SI = ',num2str(mean(si_v),2)]);  % Title with silhouette score
title([data,', GULE']);         % Simple title
box off;
xlabel('t-SNE 1');
ylabel('t-SNE 2');
ax = gca;
ax.LineWidth = 1.5;