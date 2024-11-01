addpath(genpath('Data')); % Add paths to the 'Data' directory and its subdirectories
addpath(genpath('EW2LG')); % Add paths to the 'EW2LG' directory and its subdirectories
addpath(genpath('Tool')); % Add paths to the 'Tool' directory and its subdirectories
load('Color4Figs.mat'); % Load predefined color schemes for visualizing figures
rng default; % Set random number generator to default state for reproducibility
warning off; % Suppress all warnings to avoid unnecessary console output

% Input: Select the dataset to be used for analysis
example_id = 2; % Specify the dataset index (1-based)

% Define the names of datasets and their normalization settings
Datasets = {'COIL20', 'UMist', 'Control'};
nmlzs = [2, 2, 0]; % Normalization settings for each dataset (0: no normalization)

% Define distance metrics used for clustering analysis
% 'nm_seuclidean': Normalized Euclidean distance
% 'cityblock': Manhattan distance
% 'spearman': Spearman rank correlation
% 'nm_euclidean': Another normalized Euclidean distance metric
dist_types = {'euclidean', 'nm_seuclidean', 'cityblock', 'spearman', 'nm_euclidean'};

% Select the dataset based on the example ID provided
data = Datasets{example_id}; % Get dataset name
isnormal = nmlzs(example_id); % Get normalization setting for selected dataset

% Load the selected dataset dynamically using the dataset name
eval(['load ' data]); % Load the data file (e.g., 'load COIL20')
X = double(fea'); % Convert the feature matrix to double precision and transpose it
gnd = double(gnd); % Convert ground truth labels to double precision
labels = gnd - min(gnd) + 1; % Adjust labels to start from 1 for clustering
n_class = max(labels); % Get the number of unique classes
m_ = ceil(length(labels) / n_class); % Estimate the approximate size of each class for clustering

% Display the name of the dataset being used
fprintf('Data: %s\n', data);

% Select the appropriate distance metric for the dataset based on normalization setting
dist_type = dist_types{isnormal + 1};

% Set options for running the USAN_Lite algorithm, including parameters for projection and clustering
opts = struct('ab', [2 * ones(2, 1), [1; 0]], ... % Parameters for adaptive spectral projection
              'labels', labels, ... % Ground truth labels for evaluating clustering performance
              'distmetric', dist_type, ... % Distance metric to be used for neighborhood calculation
              'layers', 2, ... % Number of layers in the hierarchical structure of the algorithm
              'MaxIter', 5, ... % Maximum number of iterations for convergence
              'classsize', m_, ... % Estimated size of each class for clustering
              'func', 'db/(sc*ch)', ... % Evaluation function used for clustering performance
              'repa', 1); % Reparameterization parameter for optimization

% Run the EW2LG algorithm to perform clustering on the selected dataset
[criteria, Idx] = EW2LG(X, n_class, opts);
idx = Idx(:, end); % Extract the final clustering results from the algorithm output

% Calculate performance metrics to evaluate the clustering results
elapsed_time = toc; % Measure the elapsed time for clustering
ACC = calAC(idx, labels); % Calculate clustering accuracy (ACC)
NMI = calMI(idx, labels); % Calculate normalized mutual information (NMI) for cluster quality
ARI = calARI(idx, labels); % Calculate adjusted Rand index (ARI) for comparing true vs predicted labels
[~, map] = calAC(idx, labels); % Calculate mapping of predicted labels to true labels for optimal ACC
idx = map(idx); % Remap the predicted labels based on the optimal mapping

% Display the clustering performance metrics in the console
fprintf('   ACC: %.4f, NMI: %.4f, ARI: %.4f, Time: %.4f\n', ACC, NMI, ARI, elapsed_time);

% Calculate and display the confusion matrix for clustering results
confusion_mat = confusionmat(labels, idx); % Compute the confusion matrix between true and predicted labels

% Create a visual representation of the confusion matrix for better understanding
figure;
confusionchart(confusion_mat); % Plot the confusion matrix as a confusion chart for visualization
title('Confusion Matrix'); % Set the title for the confusion matrix figure
