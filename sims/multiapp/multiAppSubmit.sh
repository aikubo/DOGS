#!/bin/bash

main_file=pflowMain.i

sub_file=nsdikeChild.i

initial_conditions_file=pflowInitial.i

# Define the path to the file
file_path="../../dikes-opt"

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "Error: The file $file_path does not exist."
    exit 1
fi

# Continue with the rest of your script if the file exists
echo "opt file exists, continuing..."
# Your script continues here...

if [ -f "pflowInitial_out.e" ]; then
    echo "Initial conditions file exists, continuing..."
else
    echo "Initial conditions file does not exist, running pflowInitial.i to generate it..."
    mpiexec -n 4 $file_path -i $initial_conditions_file
fi

if [ -f "pflowMain_out.e" ]; then
    echo "Main file exists, remove it to run the simulation again"
    rm pflowMain_out.e
    rm nsdikeChild_out.e
fi

if [ -f "multAppBatch.sh" ]; then
    sbatch multAppBatch.sh
  else
    echo "Batch file does not exist, creating it..."
    cat > "multiAppBatch.sh" <<EOF
    #!/bin/bash
    #SBATCH --job-name=MultiApp
    #SBATCH --output=%x_%j.out
    #SBATCH --time=24:00:00  # Job time, e.g., 1 hour
    #SBATCH --nodes=1        # Number of nodes
    #SBATCH --ntasks=8       # Number of tasks (MPI processes)
    #SBATCH --cpus-per-task=1  # Number of cores per task
    #SBATCH --mem=4G         # Memory per node
    #SBATCH --account=karlstrom
    #SBATCH --partition=karlstrom

    # Load the appropriate MOOSE module
    module load mpich/4.1.1
    module load python3/3.11.4
    module load cmake/3.26.3
    export PYTHONPATH=$PYTHONPATH:/projects/karlstrom/shared/moose_projects/moose/python
    export MOOSE_DIR=/projects/karlstrom/shared/moose_projects/moose

    mpiexec -n 8 $file_path -i pflowMain.i
EOF

    # Submit the job
    echo "submitting batch file"
    sbatch multAppBatch.sh

fi

