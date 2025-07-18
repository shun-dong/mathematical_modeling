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

# Fill 26-37 as neighbors
for i in range(25, 36):
    for j in range(i + 1, 37):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 38-51 as neighbors
for i in range(37, 50):
    for j in range(i + 1, 51):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 52, 53, 54 as neighbors
adjacency_matrix[51, 52] = 1
adjacency_matrix[52, 51] = 1
adjacency_matrix[52, 53] = 1
adjacency_matrix[53, 52] = 1
adjacency_matrix[53, 54] = 1
adjacency_matrix[54, 53] = 1

# Fill 56 and 57 as neighbors
adjacency_matrix[55, 56] = 1
adjacency_matrix[56, 55] = 1

# Fill 58-62 as neighbors
for i in range(57, 61):
    for j in range(i + 1, 62):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 63 and 64 as neighbors
adjacency_matrix[62, 63] = 1
adjacency_matrix[63, 62] = 1

# Fill 66-70 as neighbors
for i in range(65, 69):
    for j in range(i + 1, 71):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 71, 72, 74 as neighbors
adjacency_matrix[70, 71] = 1
adjacency_matrix[71, 70] = 1
adjacency_matrix[71, 73] = 1
adjacency_matrix[73, 71] = 1

# Fill 75 and 76 as neighbors
adjacency_matrix[74, 75] = 1
adjacency_matrix[75, 74] = 1

# Fill 77 and 78 as neighbors
adjacency_matrix[76, 77] = 1
adjacency_matrix[77, 76] = 1

# Fill 81, 82, 83 as neighbors
adjacency_matrix[80, 81] = 1
adjacency_matrix[81, 80] = 1
adjacency_matrix[81, 82] = 1
adjacency_matrix[82, 81] = 1
adjacency_matrix[82, 83] = 1
adjacency_matrix[83, 82] = 1

# Fill 85-91 as neighbors
for i in range(84, 90):
    for j in range(i + 1, 92):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 98-104 as neighbors
for i in range(97, 103):
    for j in range(i + 1, 105):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 92-95 as neighbors
for i in range(91, 94):
    for j in range(i + 1, 95):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# Fill 96 and 97 as neighbors
adjacency_matrix[95, 96] = 1
adjacency_matrix[96, 95] = 1


# Step 3: Initialize the plots and residents data
n_plots = len(plot_info)  # Total number of plots
n_residents = 112  # Based on the number of residents

resident_plots = np.unique(relocation_data['ResidentPlotID'])  # Get all unique ResidentPlotIDs

# Initialize target plots and occupied plots
target_plots = np.full(n_residents, np.nan)  # Store target plots for each resident
occupied_plots = np.zeros(n_plots)  # Track which plots are occupied

# Step 4: Create a dictionary to store plots of each courtyard
courtyard_plots = {i: [] for i in range(1, n_courtyards + 1)}

for i in range(n_plots):
    courtyard_plots[plot_info['CourtyardID'].iloc[i]].append(plot_info['PlotID'].iloc[i])

# Step 5: Initialize cost and income variables
total_cost = 0  # Initialize total cost
total_income = 0  # Initialize total income
total_full_courtyards = 0  # Total number of vacated courtyards
total_full_courtyards_area = 0  # Total area of vacated courtyards
communication_cost = 30000 * n_residents  # Total communication cost, 30k per household
total_profit = 0  # Total profit

# Step 6: Greedy algorithm for relocation decision
for i in range(n_residents):
    # Get all possible target plots for the current resident
    possible_targets = relocation_data.loc[relocation_data['ResidentPlotID'] == resident_plots[i], 'TargetPlotID']

    best_target = -1
    max_benefit = -np.inf  # To track the best target plot benefit
    best_area = 0  # To track the maximum vacated area

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

        # Calculate benefit for the target plot (considering adjacency and vacated courtyards)
        target_courtyard_id = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'CourtyardID'].iloc[0]
        benefit = 0
        area = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'PlotArea'].iloc[0]  # Get target plot area

        # Calculate the benefit of relocating to this target plot
        for k in range(n_courtyards):
            if adjacency_matrix[target_courtyard_id - 1, k] == 1:  # Check if the courtyards are adjacent
                benefit += 1  # Benefit for adjacency

        total_benefit = benefit + area  # Weight the benefit and area
        if total_benefit > max_benefit:
            max_benefit = total_benefit
            best_target = target_plot_id
            best_area = area  # Update the best target plot area

    # Assign the best target plot
    if best_target != -1:
        target_plots[i] = best_target
        occupied_plots[best_target - 1] = 1  # Mark the plot as occupied

        # Update HasResident status
        plot_info.loc[plot_info['PlotID'] == resident_plots[i], 'HasResident'] = 0
        plot_info.loc[plot_info['PlotID'] == best_target, 'HasResident'] = 1

        # Update cost
        relocation_row = relocation_data.loc[(relocation_data['ResidentPlotID'] == resident_plots[i]) &
                                             (relocation_data['TargetPlotID'] == best_target), :]
        total_cost += relocation_row['Compensation'].iloc[
                          0] + 30000  # Add relocation compensation and communication cost

# Step 7: Calculate fully vacated courtyards and their area
full_courtyards_list = []

for i in range(1, n_courtyards + 1):
    courtyard_plots_ids = courtyard_plots[i]
    if all(plot_info.loc[
               plot_info['PlotID'].isin(courtyard_plots_ids), 'HasResident'] == 0):  # Check if all plots are vacated
        total_full_courtyards += 1  # If yes, count this courtyard as vacated
        total_full_courtyards_area += plot_info.loc[plot_info['CourtyardID'] == i, 'CourtyardArea'].iloc[
            0]  # Add the area of this vacated courtyard
        full_courtyards_list.append(i)  # Add vacated courtyard ID to list

# Step 8: Calculate income and losses
total_income = 0  # Initialize income
days_in_10_years = 10 * 365  # 10 years of rental days

for i in range(1, n_courtyards + 1):
    courtyard_plots_ids = courtyard_plots[i]
    if all(plot_info.loc[plot_info['PlotID'].isin(courtyard_plots_ids), 'HasResident'] == 0):  # Unoccupied courtyards
        total_income += plot_info.loc[plot_info['CourtyardID'] == i, 'CourtyardArea'].iloc[
                            0] * 30 * days_in_10_years  # Rent at 30 per square meter per day
    else:
        for j in range(len(courtyard_plots_ids)):
            plot_id = courtyard_plots_ids[j]
            if plot_info.loc[plot_info['PlotID'] == plot_id, 'HasResident'].iloc[0] == 0:  # Vacant plots
                if plot_info.loc[plot_info['PlotID'] == plot_id, 'Orientation'].iloc[0] in ['东', '西']:
                    total_income += plot_info.loc[plot_info['PlotID'] == plot_id, 'PlotArea'].iloc[
                                        0] * 8 * days_in_10_years  # East/West facing
                elif plot_info.loc[plot_info['PlotID'] == plot_id, 'Orientation'].iloc[0] in ['南', '北']:
                    total_income += plot_info.loc[plot_info['PlotID'] == plot_id, 'PlotArea'].iloc[
                                        0] * 15 * days_in_10_years  # North/South facing

# Step 9: Calculate time loss (4 months of rental loss) and consider adjacency benefits
time_loss_income = 0  # Time loss income
time_loss_income_with_neighbour = 0  # Time loss income with adjacency benefits

for i in range(1, n_courtyards + 1):
    if all(plot_info.loc[plot_info['PlotID'].isin(courtyard_plots[i]), 'HasResident'] == 0):
        for j in range(1, n_courtyards + 1):
            if adjacency_matrix[i - 1, j - 1] == 1 and all(
                    plot_info.loc[plot_info['PlotID'].isin(courtyard_plots[j]), 'HasResident'] == 0):
                time_loss_income_with_neighbour += plot_info.loc[plot_info['CourtyardID'] == i, 'CourtyardArea'].iloc[
                                                       0] * 30 * 0.2 * days_in_10_years  # Adjacency benefit

# Step 10: Calculate final income and profit
total_income -= time_loss_income  # Subtract time loss income
total_income -= time_loss_income_with_neighbour  # Subtract time loss income with adjacency benefits

# Step 11: Calculate total profit (total income minus total cost)
total_profit = total_income - total_cost  # Total income minus total cost

# Output results
print(f"Total cost (relocation compensation + communication cost): {total_cost}")
print(f"Total income: {total_income}")  # Output total income
print(f"Total profit: {total_profit}")  # Output total profit
