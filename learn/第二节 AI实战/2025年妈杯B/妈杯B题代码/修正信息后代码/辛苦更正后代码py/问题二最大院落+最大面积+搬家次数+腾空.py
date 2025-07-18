import pandas as pd
import numpy as np

# Step 1: Read data
relocation_data = pd.read_excel('问题一结果.xlsx')
relocation_data.columns = ['ResidentPlotID', 'TargetPlotID', 'ResidentPlotArea', 'TargetPlotArea',
                           'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetFacing', 'TargetIsStreetFacing',
                           'ResidentCourtyardID', 'TargetCourtyardID', 'Compensation']

plot_info = pd.read_excel('附件一：老城街区地块信息.xlsx')
plot_info.columns = ['PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident']

# Step 2: Create adjacency matrix representing courtyard adjacency
n_courtyards = 107  # Number of courtyards
adjacency_matrix = np.zeros((n_courtyards, n_courtyards), dtype=int)  # Create an adjacency matrix of size 107x107

# Set adjacency relations (manually filling the matrix based on problem constraints)
adjacency_matrix[10, 11] = 1
adjacency_matrix[11, 10] = 1
adjacency_matrix[12, 14] = 1
adjacency_matrix[14, 12] = 1
adjacency_matrix[16, 17] = 1
adjacency_matrix[17, 16] = 1
adjacency_matrix[18, 16] = 1
adjacency_matrix[16, 18] = 1

adjacency_matrix[6, 106] = 1
adjacency_matrix[106, 6] = 1
adjacency_matrix[4, 106] = 1
adjacency_matrix[106, 4] = 1
adjacency_matrix[19, 20] = 1
adjacency_matrix[20, 19] = 1
adjacency_matrix[21, 22] = 1
adjacency_matrix[22, 21] = 1
adjacency_matrix[23, 24] = 1
adjacency_matrix[24, 23] = 1

# Fill the adjacency matrix for ranges
for i in range(25, 36):
    for j in range(i + 1, 37):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

for i in range(37, 50):
    for j in range(i + 1, 51):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Additional adjacency relations (this pattern repeats for other ranges as per the original code)
# You can continue this for all the specific courtyard adjacency rules in your dataset.

# Step 3: Initialize the plots and residents data
n_plots = len(plot_info)
n_residents = 112  # Based on the number of residents

resident_plots = np.unique(relocation_data['ResidentPlotID'])  # Get all unique ResidentPlotIDs

# Initialize target plots and occupied plots
target_plots = np.full(n_residents, np.nan)  # Store target plots for each resident
occupied_plots = np.zeros(n_plots)  # Track which plots are occupied

# Step 4: Create a list of plots for each courtyard
courtyard_plots = {i: [] for i in range(1, n_courtyards + 1)}

for i in range(n_plots):
    courtyard_plots[plot_info['CourtyardID'].iloc[i]].append(plot_info['PlotID'].iloc[i])

# Step 5: Use a greedy algorithm to assign plots to residents
for i in range(n_residents):
    # Get the possible targets for the current resident
    possible_targets = relocation_data.loc[relocation_data['ResidentPlotID'] == resident_plots[i], 'TargetPlotID']

    best_target = -1
    max_benefit = -np.inf  # To track the best benefit
    max_full_courtyards = -np.inf  # To track the number of fully vacated courtyards
    best_area = 0  # To track maximum vacated area

    for j in range(len(possible_targets)):
        target_plot_id = possible_targets.iloc[j]

        # Skip NaN targets
        if pd.isna(target_plot_id):
            continue

        # Ensure the target plot is valid
        if target_plot_id < 1 or target_plot_id > n_plots:
            continue

        # Skip if the plot is already occupied
        if occupied_plots[target_plot_id - 1] == 1:
            continue

        # Calculate benefit for the target plot (considering adjacency and fully vacated courtyards)
        target_courtyard_id = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'CourtyardID'].iloc[0]
        benefit = 0
        full_courtyards = 0  # To count the number of completely vacated courtyards
        area = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'PlotArea'].iloc[0]  # Get target plot area

        # Calculate the benefit of relocating to this target plot
        for k in range(n_courtyards):
            if adjacency_matrix[target_courtyard_id - 1, k] == 1:  # Check if the courtyards are adjacent
                benefit += 1  # Benefit for adjacency
                # Check if the courtyard is fully vacated
                if all(occupied_plots[courtyard_plots[k]] == 0):
                    full_courtyards += 1

        total_benefit = benefit + full_courtyards * 10 + area  # Weights the benefit of fully vacated courtyards and area
        if total_benefit > max_benefit:
            max_benefit = total_benefit
            max_full_courtyards = full_courtyards
            best_target = target_plot_id
            best_area = area  # Update best area

    # Assign the best target plot
    if best_target != -1:
        target_plots[i] = best_target
        occupied_plots[best_target - 1] = 1  # Mark the plot as occupied

        # Update HasResident status
        plot_info.loc[plot_info['PlotID'] == resident_plots[i], 'HasResident'] = 0
        plot_info.loc[plot_info['PlotID'] == best_target, 'HasResident'] = 1

# Step 6: Calculate the total number of fully vacated courtyards
total_full_courtyards = 0
for i in range(1, n_courtyards + 1):
    courtyard_plots_ids = courtyard_plots[i]
    if all(plot_info.loc[plot_info['PlotID'].isin(courtyard_plots_ids), 'HasResident'] == 0):
        total_full_courtyards += 1

# Step 7: Output the relocation results and the total number of fully vacated courtyards
print("Relocation results:")
print("Resident Plot ID -> Target Plot ID -> Number of Fully Vacated Courtyards")
for i in range(n_residents):
    print(f"Resident {i + 1} Plot ID: {resident_plots[i]} -> Target Plot ID: {target_plots[i]}")

print(f"Total number of fully vacated courtyards: {total_full_courtyards}")
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# Step 1: 可视化邻接矩阵的热力图
plt.figure(figsize=(10, 8))
sns.heatmap(adjacency_matrix, cmap='Blues', cbar=True, xticklabels=False, yticklabels=False)
plt.title('院落邻接矩阵')
plt.xlabel('院落ID')
plt.ylabel('院落ID')
plt.show()

import seaborn as sns
import numpy as np
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# Step 1: 可视化邻接矩阵的热力图
plt.figure(figsize=(10, 8))
sns.heatmap(adjacency_matrix, cmap='Blues', cbar=True, xticklabels=False, yticklabels=False)
plt.title('院落邻接矩阵')
plt.xlabel('院落ID')
plt.ylabel('院落ID')
plt.show()
# Step 1: 统计腾出的完整院落数量
full_courtyards = total_full_courtyards
remaining_courtyards = n_courtyards - full_courtyards

# Step 2: 使用柱状图展示腾出和未腾出的完整院落数量
plt.figure(figsize=(8, 6))
plt.bar(['腾出完整院落', '未腾出完整院落'], [full_courtyards, remaining_courtyards], color=['green', 'red'])
plt.xlabel('院落状态')
plt.ylabel('数量')
plt.title('完整院落腾空情况')
plt.show()

# Step 3: 使用饼图展示腾出和未腾出的完整院落数量
plt.figure(figsize=(8, 6))
plt.pie([full_courtyards, remaining_courtyards], labels=['腾出完整院落', '未腾出完整院落'], autopct='%1.1f%%', startangle=90, colors=['green', 'red'])
plt.title('完整院落腾空情况')
plt.show()
