# EW2LG Clustering Demos

This repository provides three demo scripts to showcase the use of the **EW2LG** (Extracting the Whole from Twice Local Glimpses) clustering algorithm on various datasets, both simulated and real-world. The demos include data preprocessing, clustering with EW2LG, and visualization of clustering results. These scripts are designed to help users understand the application of EW2LG in different scenarios and visualize its performance.

## Contents

1. **Demo_simulation.m**: Demonstrates EW2LG clustering on synthetic data.
2. **Demo_RealWorld.m**: Applies EW2LG clustering to real-world datasets, including `COIL20`, `UMist`, `PIE`, and `MNIST`.
3. **Demo_Visualization.m**: Visualizes clustering results on both original and transformed data spaces, allowing comparisons between raw data and EW2LG clustering outputs.

## Requirements

The demos require the following:
- **MATLAB** R2020a or later
- Datasets for `COIL20`, `UMist`, `PIE`, `MNIST`, and other real-world data included in the `Data` folder
- Additional paths to the `EW2LG` and `Tool` folders, which contain necessary functions and dependencies

## Usage

### Running the Demos

Each demo can be run independently in MATLAB. Ensure all paths are set correctly to `Data`, `EW2LG`, and `Tool` folders.

1. **Demo_simulation.m**: 
   - **Purpose**: Runs EW2LG on a synthetic dataset with configurable parameters.
   - **Description**: Initializes parameters for synthetic data, applies EW2LG, and outputs clustering performance metrics.

   ```matlab
   % Run Demo_simulation
   Demo_simulation
   ```

2. **Demo_RealWorld.m**:
   - **Purpose**: Applies EW2LG on real-world datasets, showcasing its performance on high-dimensional data.
   - **Description**: Selects datasets like `COIL20`, `UMist`, etc., processes and normalizes them, and then applies the EW2LG algorithm. Performance metrics are displayed in the console.

   ```matlab
   % Run Demo_RealWorld
   Demo_RealWorld
   ```

3. **Demo_Visualization.m**:
   - **Purpose**: Provides visual comparisons of clustering results on raw data versus EW2LG results using t-SNE projections.
   - **Description**: Generates scatter plots to visualize clustering in both original and learned spaces, with silhouette scores included to evaluate cluster quality.

   ```matlab
   % Run Demo_Visualization
   Demo_Visualization
   ```

### Customizing the Demos

Each demo script includes customizable parameters such as `example_id` (for dataset selection), `n_layers` (number of clustering layers), and `dist_type` (distance metric for clustering). Adjust these parameters at the beginning of each script to suit your specific requirements.

## Output

- **Performance Metrics**: Each demo outputs clustering accuracy (ACC), normalized mutual information (NMI), and adjusted Rand index (ARI) in the MATLAB console.
- **Visualizations**: `Demo_Visualization.m` provides t-SNE visualizations of clustering results, comparing the raw data with the EW2LG-transformed space.

## Troubleshooting

- **Data Loading Errors**: Ensure all required datasets are placed in the `Data` folder and properly named.
- **Path Issues**: Verify that the `addpath` commands include all necessary folders (`Data`, `EW2LG`, and `Tool`).

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Contact

For questions or contributions, please contact bjlistat@nus.edu.sg.

Happy clustering!
