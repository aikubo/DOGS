import pandas as pd
import glob
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import re

# Define the path to the directory containing the CSV files
csv_directory = '/home/akh/myprojects/moose_projects/dikes/sims/simple/permTests/csv/'

# Get a list of all CSV files in the directory
csv_files = glob.glob(csv_directory + 'ConstantPermSampler_out_results*.csv.0')

# Create an empty DataFrame to store the combined data
df = pd.DataFrame()
#old columns
#results:AreaAboveBackgroundSum:value,results:T_dike_avg:value,results:T_dike_max:value,
# results:T_host_avg:value,results:T_host_max:value,results:converged,results:perm:value,
# results:q_dike:value,results:q_top:value
new_columns= ["Area Above Background","Average Dike Temperature (K)",
              "Max Dike Temperature (K)", "Average Host Rock Temperature (K)",
              "Max Host Rock Temperature (K)","converged","Permeability (m^2)",
              "Heat Flow from Dike (W/m^2)", "Heat Flow from Top (W/m^2)", 'Time (years)']

# Read each CSV file and append its data to the combined DataFrame
for file in csv_files:
  df_t = pd.read_csv(file)
  # Extract the time step name from the file name
  time_step = file.split('_')[-1].split('.')[0]
  # Convert time_step to number
  time_step = int(time_step)
  # Add a new column called 'time' with the extracted time step name
  df_t['Time (years)'] = (time_step*2e6)/3.154e7 # timestep is 2e6, seconds in year is 3.154e7
  df = df._append(df_t, ignore_index=True)


df.columns = new_columns

#take log of permeability
df['Permeability (log(k) m^2)'] = df['Permeability (m^2)'].apply(lambda x: np.log10(x))
#convert to string for plotting and cut off decimals
df['Permeability (log(k) m^2)'] = df['Permeability (log(k) m^2)'].apply(lambda x: str(round(x,2)))


# Calculate the maximum value of 'Area Above Background' over time for each value of 'Permeability (log(k) m^2)'
max_area = df.groupby('Permeability (log(k) m^2)')['Area Above Background'].max()

# Normalize 'Area Above Background' by dividing it by the corresponding maximum value
df['Normalized Area Above Background'] = df['Area Above Background'] / df['Permeability (log(k) m^2)'].map(max_area)

# Calculate the maximum value of heat flow over time for each value of 'Permeability (log(k) m^2)'
max_qdike = df.groupby('Permeability (log(k) m^2)')["Heat Flow from Dike (W/m^2)"].max()

df['Normalized Heat Flow from Dike'] = df["Heat Flow from Dike (W/m^2)"] / df['Permeability (log(k) m^2)'].map(max_qdike)

#Calculate the maximum value of heat flow from the top for each permeability value
max_qtop = df.groupby('Permeability (log(k) m^2)')["Heat Flow from Top (W/m^2)"].max()

# Normalize 'Heat Flow from Top' by dividing it by the corresponding maximum value
df['Normalized Heat Flow from Top'] = df["Heat Flow from Top (W/m^2)"] / df['Permeability (log(k) m^2)'].map(max_qtop)

# Loop through each column (except 'Time (years)', 'Permeability (m^2)', 'Permeability (log(k) m^2)', and 'Area Above Background')
for column in df.columns:
  if column not in ['Time (years)', 'Permeability (m^2)', 'Permeability (log(k) m^2)', 'Area Above Background']:
    # Normalize the column by dividing it by the corresponding maximum value over time for each permeability value
    max_value = df.groupby('Permeability (log(k) m^2)')[column].max()
    # Plot the normalized column against permeability
    sns.lineplot(data=df, x='Time (years)', y=column, hue='Permeability (log(k) m^2)')

    # Remove anything inside parentheses including the parentheses themselves
    new_column_name = re.sub(r'\(.*?\)', '', column).replace(' ', '')

    plt.savefig(new_column_name + "plot" + '.png')
    # Clear the plot for the next iteration
    plt.clf()


df.to_csv('PermTestsDataResults.csv', index=False)
