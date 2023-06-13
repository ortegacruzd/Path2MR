The three provided Matlab scripts (and required functions) allow registration of histology and generation of final pathology maps,
as part of steps 5 and 8 respectively from the histology mapping pipeline.
These steps are explained in Section 2.5 of the manuscript.

This is accomplished wit three scripts:

STEP 5 OF PIPELINE
5.1. histology_registration.m -> register each histology slide (2D image) to reconstructed hemisphere (output of reconstruction, step 2 of the pipeline).
5.2. generate_gaussian_distribution.m -> create a gaussian distribution around histology section position.

STEP 8 OF PIPELINE
get_pathology_map.m -> obtain pathology map from histology slides using gaussian distributions (PREVIOUSLY REGISTERED TO MNI!) and pathology values from each section.

Scripts 5.1 and 5.2 need to be run once per included histology section 
BEFORE RUNNING STEP 8 (get_pathology_map), gaussian distributions from script 5.2 need to be registered to a common space (such as MNI) 
using NiftyReg or similar software (step 6 of the pipeline), and pathology of interest needs to be quantified (step 7 of the pipeline).
Then, step 8 (get_pathology_map) only needs to be run once.