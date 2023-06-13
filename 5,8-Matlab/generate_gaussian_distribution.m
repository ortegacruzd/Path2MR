% Code to create a gaussian distribution around histology slide position
% obtained after histology_registration.m
% This gaussian distribution will smooth the final distribution result. The
% width (sigma) of the distribution can be modified based on the
% registration error (the lower the uncertainty of the registration, the
% lower the required sigma). All slide distributions used in the same analysis 
% should have the same sigma. 
% This code should be run once per histology slide to be included in
% analyses. 

% This code corresponds to SECOND step from section 2.5 within: (link to paper)
% Author: Juan Eugenio Iglesias
% Date: May 2023

%%%%%%%INPUTS AND PARAMETERS%%%%%%%
cd 'path\to\output\directory\' %output directory
atlas.nonlinear = 'path\to\MNI_atlas_registered_to_synthetic_MRI.nii'; %MNI atlas in subject-specific space (registered to synthetic MRI obtained from 3D SynthSR) in nifti format.
slice=72; %coronal coordinate of 'slide.regfakeMRI.nii' with respect to MNI atlas in subject-specific space (atlas.nonlinear). Can be derived by opening both in freeview or a similar 3D viewer. 
sigma=10; %Sigma of gaussian distribution around slide position. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%
%In principle, no need to edit beyond this point
%%%%%%%%%%%%

%Create output volume
MRI1 = myMRIread(atlas.nonlinear, 0, tempdir);
%Modify coordinate to Matlab indexing (starts at 1 instead of 0)
slice=slice + 1; 

%Create gaussian distribution around slide position in output volume
for i=1:size(MRI1.vol,1)
    MRI1.vol(i,:,:)=exp(-0.5*(i-slice)^2/(sigma^2)); 
end

%Save result to output directory
myMRIwrite(MRI1,'slide.regfakeMRI.gauss10.nii');

disp('Done!');


