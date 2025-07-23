#!/bin/bash

HOME=$(pwd)

# Source the variables from DLM.in
source DLM.in

line_number1=$((10 + tot_num_atoms)) # Number of line that contains the 1st occurance of the FFT grid dimensions.
num_spin_flips=$((simulation_time/(spin_flip_time/time_step))) # Number of spin flips - to be used to define the for loop.

for j in $(seq 1 $num_spin_flips); do
    i=$(($j-1)) # i refers to the previous completed run whereas j refers to the current run.
    cd $HOME/$i
    until [ -f PROCAR ]
    do
        sleep 5 
    done
    echo "Run $i finished."
    mkdir $HOME/$j
    cp $HOME/$i/CONTCAR      $HOME/$j/POSCAR
    cp $HOME/$i/INCAR        $HOME/$j
    cp $HOME/$i/KPOINTS      $HOME/$j
    cp $HOME/$i/POTCAR       $HOME/$j
    # ==========================================================================
    # EDIT THIS:
    cp $HOME/$i/pbs.sh       $HOME/$j # This is the job submission script. Replace this with a script suitable for the HPC your are using.
    # ==========================================================================
    cp $HOME/ModifyINCAR.py  $HOME/$j
    cp $HOME/$i/WAVECAR      $HOME/$j
    cp $HOME/$i/CHGCAR       $HOME/$j    
    rm $HOME/$i/CHG
    echo "Files copied."
    cd $HOME/$j
    # Extract the line that contains the FFT grid dimensions:
    line_content=$(sed -n "${line_number1}p" CHGCAR)
    # Check if the line is repeated and get the line number of the 2nd occurrence:
    line_number2=$(awk -v target="$line_content" '{
        if ($0 == target) {
            count++;
            if (count == 2) {
                print NR;
                exit;
            }
        }
    }' CHGCAR)
    if [ -n "$line_number2" ]; then
        echo "FFT grid dimensions line number: $line_number2"
    else
        echo "The FFT grid dimensions do not occur twice in CHGCAR."
    fi
    # Remove the magnetization part of the CHGCAR file
    sed -i "${line_number2},\$d" $HOME/$j/CHGCAR 
    echo "CHGCAR edited."
    # Run the Python script to get random magnetic moments for U atoms
    python ModifyINCAR.py $num_spin_atoms $spin_flip_time $time_step 
    mv $HOME/$j/NewINCAR $HOME/$j/INCAR
    echo "New INCAR written."
    rm $HOME/$j/ModifyINCAR.py
    # ==========================================================================
    # EDIT THIS:
    qsub pbs.sh # This is the job submission command for PBS, which is a workload manager and job scheduler. Replace this with a command suitable for the job scheduler your HPC is using.
    # ==========================================================================
    echo "Job submitted."
done
