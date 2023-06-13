We provide the NiftyReg package (niftyreg-master directory) for installation, version from November 18th 2022.
The latest version of NiftyReg is available here: https://github.com/KCL-BMEIS/niftyreg

Registration commands used for implementation of this pipeline are specified below:

4. Registration of MNI atlas to 3D SynthSR. Explained in manuscript Section 2.4.

	4.1 Linear registration command:

./reg_aladin -ref <SynthSR-output> -flo <MNI-atlas> -aff <output-linear-transform> -res <output-registration>

<SynthSR-output>: MRI-like volume of reconstructed hemisphere obtained from SynthSR (step 3)
<MNI-atlas>: an atlas of the left hemisphere in MNI is provided in "atlas" directory from this repository
<output-linear-transform>: output linear transform that will  be used in later steps, in .txt format
<output-registration>: output atlas registered to SynthSR output (linearly), in .nii or .nii.gz format

	4.2 Non-linear registration command:

./reg_f3d -ref <SynthSR-output> -flo <MNI-atlas> -aff <linear-transform> -res <output-nl-registration> -cpp <output-nl-transform> -omp 4 -sx -15 -vel --lncc 4.0

<SynthSR-output>: same as above
<MNI-atlas>: same as above
<linear-transform>: obtained as output from previous step (<output-linear-transform>) 
<output-nl-registration>: output atlas registered to SynthSR output (nonlinearly), in .nii or .nii.gz format
<output-nl-transform>: output non-linear transform that will be used in step 6, in .nii or .nii.gz format. 
A backward non-linear transform with the same name (output-nl-transform.backward.nii.gz) will be saved in the same directory after running this command.


6. Registration of gaussian distribution of each histological section to MNI. Explained in manuscript Section 2.5.

./reg_f3d -ref <MNI-atlas> -flo <gaussian-distribution> -aff <linear-transform> -incpp <nl-transform-backward> -res <output> -omp 4 -sx -15 -vel --lncc 4.0

<MNI-atlas>: same as above
<gaussian-distribution>: obtained for every section as output from step 5 (generate_gaussian_distribution.m)
<linear-transform>: obtained as output from step 4.1 (<output-linear-transform>) 
<nl-transform-backward>: obtained as output from step 4.2 (output-nl-transform.backward.nii.gz) 
<output>: output gaussian distribution registered to MNI space (nonlinearly)