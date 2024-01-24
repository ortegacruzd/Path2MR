This is a 3D histology reconstruction pipeline that can be implemented with sparse histological sampling 
and in absence of an MRI reference. The pipeline is described in the following manuscript: "Three-dimensional histology reveals dissociable human hippocampal long axis gradients of Alzheimer’s pathology" by Ortega-Cruz et al., 
to be published soonin Alzheimer's and Dementia (doi: 10.1002/alz.13695)

HERE WE OUTLINE THE STEPS OF THE RECONSTRUCTION PIPELINE AND SPECIFY WHERE TO ACCESS THE CODE FOR EACH STEP.

This repository provides codes to steps 3-8. Steps 1 and 2 can be implemented in FreeSurfer 7.4.
Detailed instructions in: https://surfer.nmr.mgh.harvard.edu/fswiki/PhotoTools

1. Photo processing (FreeSurfer). Explained in manuscript Section 2.1. 

2. 3D photo reconstruction (Freesurfer).Explained in manuscript Section 2.2.

3. 3D SynthSR (3-SynthSR-main in this repository). Explained in manuscript Section 2.3.

4. Registration of MNI atlas to 3D SynthSR (4,6-Niftyreg in this repository). Explained in manuscript Section 2.4.

5. Registration of histology and generation of gaussian distributions around section position (5,8-Matlab in this repository, scripts 1 and 2). 
   Explained in manuscript Section 2.5.

6. Registration of gaussian distributions to MNI (4,6-Niftyreg in this repository). Explained in manuscript Section 2.5.

7. Pathology quantification with software of choice. CellProfiler projects to quantify tau NFTs and B-amyloid plaques
   in 20x images are provided (7-CellProfiler in this repository). Explained in manuscript Section 2.7.

8. Computation of final pathology map (5,8-Matlab in this repository, script 3). Explained in manuscript Section 2.5.



For questions, you can contact: diana.ortega@upm.es

If you use this tool, please cite: (link pending)

