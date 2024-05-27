#!/bin/bash

# Check if an input file name was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_filename"
    exit 1
fi

input_file=$1
job_name=$(basename "$input_file" .i)  # Assumes the file extension is .i
echo "Input file: $input_file"

# Define the path to the file
file_path="../../../dikes-opt"

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "Error: The file $file_path does not exist."
    exit 1
fi

# Continue with the rest of your script if the file exists
echo "opt file exists, continuing..."
# Your script continues here...

# remove old files
find . -type f -name "${job_name}*.json*" -exec rm -f {} \;
find . -type f -name "${job_name}_*.out" -exec rm -f {} \;
find . -type f -name "${job_name}*.e*" -exec rm -f {} \;

# Create a batch script for the job
batch_file="${job_name}.sh"
cat > "$batch_file" <<EOF
#!/bin/bash
#SBATCH --job-name=$job_name
#SBATCH --output=%x_%j.out
#SBATCH --time=24:00:00  # Job time, e.g., 1 hour
#SBATCH --nodes=1        # Number of nodes
#SBATCH --ntasks=1       # Number of tasks (MPI processes)
#SBATCH --cpus-per-task=12  # Number of cores per task
#SBATCH --mem=4G         # Memory per node
#SBATCH --account=karlstrom
#SBATCH --partition=karlstrom

 # Load the appropriate MOOSE module
module load mpich/4.1.1
module load python3/3.11.4
module load cmake/3.26.3
export PYTHONPATH=$PYTHONPATH:/projects/karlstrom/shared/moose_projects/moose/python
export MOOSE_DIR=/projects/karlstrom/shared/moose_projects/moose

$file_path -i $input_file
EOF

# Submit the job
echo "submitting $batch_file"
sbatch "$batch_file"

