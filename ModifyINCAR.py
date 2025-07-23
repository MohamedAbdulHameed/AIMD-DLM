import os
import random
from math import ceil
import argparse

def modify_INCAR(num_spin_atoms, spin_flip_time, time_step):
    file_in = "INCAR"
    file_out = "NewINCAR"
    with open(file_in, 'r') as file:
        lines = file.readlines()
    processed_lines = []
    sum_magnetization = 0
    for line_number, line in enumerate(lines, start=1):
        line = line.rstrip()  # Remove trailing spaces.
        fields = line.split()
        if line.startswith('ISTART'):
            processed_lines.append("ISTART = 1\n")
        elif line.startswith('ICHARG'):
            processed_lines.append("ICHARG = 1\n")
        elif line.startswith('MAGMOM'):
            # Modify the MAGMOM line
            processed_lines.append(f"{fields[0]} {fields[1]} {fields[2]}")
            for i in range(num_spin_atoms):
                if i < 70:
                    mag = ceil(2 * random.random())
                    mag = -5 if mag == 1 else 5
                    sum_magnetization += mag
                else:
                    mag = 5 if sum_magnetization < 0 else -5
                    sum_magnetization += mag
                processed_lines.append(f" {mag}")  # Write the magnetization of U atoms one-by-one.
            processed_lines.append("\n")
        elif line.startswith('NSW'):
            # Modify the NSW line
            run_time = int(spin_flip_time / time_step)
            processed_lines.append(f"NSW = {run_time}\n")
        else:
            # Leave other lines unchanged
            processed_lines.append(f"{line}\n")
    # Write the updated content to the new file
    with open(file_out, 'w') as file:
        file.writelines(processed_lines)

# Main execution
if __name__ == "__main__":
    # Setup argument parser for num_spin_atoms, spin_flip_time, and time_step
    parser = argparse.ArgumentParser(description="Generate INCAR file for a DLM simulation")
    parser.add_argument("num_spin_atoms", type=int, help="Number of spin polarized atoms")
    parser.add_argument("spin_flip_time", type=float, help="Spin flip time")
    parser.add_argument("time_step", type=float, help="Time step")
    args = parser.parse_args()
    if not os.path.isfile("INCAR"):
        print("The INCAR file could not be found.")
        exit(1)
    modify_INCAR(args.num_spin_atoms, args.spin_flip_time, args.time_step)
