# AIMD-DLM
Bash/Python scripts to implement the AIMD+DLM method in VASP, which is used to model the paramagnetic state of materials using first-principles methods.

First, you need to prepare an initial equilibration run. Do the following:
1) For the MAGMOM line in INCAR, write the zero-spin atoms first.
2) Include the zero-spin atoms first in POSCAR.
3) Run the system in the AFM state for a sufficient time.

Then, to initiate the disordered local moments simulations, do the following:
0) Open "DLMSequence.sh" and replace "pbs.sh" and "qsub pbs.sh" with the file/command suitable for your HPC.
1) Put all the input and output files of the equilibration run in a folder named 0. This is Run 0.
3) In the folder 0, include a job submission script suitable for very short runs.
4) In the parent folder of 0, include: "DLM.in", "ModifyINCAR.py", and "DLMSequence.sh".
5) Fill DLM.in with the parameters of your DLM run.
6) Finally, "bash ./DLMSequence.sh".
7) Kindly cite this work.
