addpath(genpath('Data')); % Add paths to the 'Data' directory and its subdirectories
addpath(genpath('GULE')); % Add paths to the 'GULE' directory and its subdirectories
addpath(genpath('Tool')); % Add paths to the 'Tool' directory and its subdirectories
load('Color4Figs.mat'); % Load color information for figures
rng default; % Set the random number generator to the default state for reproducibility
warning off; % Suppress all warnings

% Input: Select the dataset to use by specifying the example ID
example_id = 3; % Dataset index (1-based)

% Define dataset names and their corresponding normalization settings
Datasets = {'Compounded', 'Rounded', 'Entangled'};
nmlzs = [2, 2, 2]; % Normalization settings for each dataset

% Define distance metrics for clustering
% 'nm_seuclidean': Normalized Euclidean distance
% 'cityblock': Manhattan distance
% 'spearman': Spearman rank correlation
% 'nm_euclidean': Another normalized Euclidean metric
dist_types = {'euclidean', 'nm_seuclidean', 'cityblock', 'spearman', 'nm_euclidean'};

% Load the selected dataset and apply normalization settings
data = Datasets{example_id}; % Get the dataset name based on the example ID
isnormal = nmlzs(example_id); % Get the normalization setting for the selected dataset

% Load the dataset dynamically based on the dataset name
eval(['load ' data]); % Load the data file (e.g., 'load Compounded')
X = double(fea'); % Convert feature matrix to double and transpose it
gnd = double(gnd); % Convert ground truth labels to double
labels = gnd - min(gnd) + 1; % Adjust labels to start from 1
n_class = max(labels); % Get the number of unique classes
m_ = ceil(length(labels) / n_class); % Calculate the approximate size of each class

% Display the name of the dataset being used
fprintf('Data: %s\n', data);

% Select the appropriate distance metric for clustering based on normalization setting
dist_type = dist_types{isnormal + 1};

% Set options for the GULE algorithm, including various parameters for projection and clustering
opts = struct('ab', [2 * ones(2, 1), [1; 0]], ... % Parameters for adaptive spectral projection
              'labels', labels, ... % Ground truth labels
              'distmetric', dist_type, ... % Distance metric to use
              'layers', 2, ... % Number of layers for hierarchical clustering
              'MaxIter', 5, ... % Maximum number of iterations for clustering
              'classsize', m_, ... % Approximate size of each class
              'func', 'db/(sc*ch)', ... % Function used for evaluating clustering performance
              'repa', 1); % Parameter for reparameterization

% Run the GULE algorithm to perform clustering on the dataset
[criteria, Idx] = GULE(X, n_class, opts);
idx = Idx(:, end); % Get the final clustering result from the GULE output

% Calculate performance metrics for the clustering result
tic; % Start timer to measure elapsed time
elapsed_time = toc; % Stop timer to get the elapsed time
ACC = calAC(idx, labels); % Calculate clustering accuracy
NMI = calMI(idx, labels); % Calculate normalized mutual information (NMI)
ARI = calARI(idx, labels); % Calculate adjusted Rand index (ARI)
[~, map] = calAC(idx, labels); % Calculate label mapping for optimal accuracy
idx = map(idx); % Map predicted labels based on calculated mapping

% Display clustering performance metrics in the console
fprintf('   ACC: %.4f, NMI: %.4f, ARI: %.4f, Time: %.4f\n', ACC, NMI, ARI, elapsed_time);

% Plot the true class labels for visualization
subplot(1, 2, 1); hold on;
gscatter(fea(:, 1), fea(:, 2), labels, colors, '', 10); % Scatter plot with true class labels
set(gca, 'linewidth', 1.5, 'FontSize', 10, 'box', 'off'); % Customize plot appearance
legend off; % Turn off legend for the plot
xticklabels({}); % Remove x-axis tick labels
yticklabels({}); % Remove y-axis tick labels

% Set axis limits for the true class labels plot based on the dataset
xlim_values = {[25, 45], [0, 40], [0, 35]};
ylim_values = {[5, 25], [0, 35], [-2, 35]};
xlim(xlim_values{example_id}); % Set x-axis limits for the plot
ylim(ylim_values{example_id}); % Set y-axis limits for the plot
title('True Class'); % Set title for the plot of true class labels

% Plot the predicted class labels after clustering
subplot(1, 2, 2); hold on;
gscatter(fea(:, 1), fea(:, 2), idx, colors, '', 10); % Scatter plot with predicted class labels
set(gca, 'linewidth', 1.5, 'FontSize', 10, 'box', 'off'); % Customize plot appearance
legend off; % Turn off legend for the plot
xticklabels({}); % Remove x-axis tick labels
yticklabels({}); % Remove y-axis tick labels

% Set axis limits for the predicted class labels plot based on the dataset
xlim(xlim_values{example_id}); % Set x-axis limits for the plot
ylim(ylim_values{example_id}); % Set y-axis limits for the plot
title('GULE'); % Set title for the plot of predicted class labels
