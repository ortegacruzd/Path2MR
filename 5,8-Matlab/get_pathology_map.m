% Code to obtain pathology map from histology slides, using:
% - Gaussian distributions from each slide (obtained from generate_gaussian_distribution.m,
% then REGISTERED TO MNI using deformations from pipeline section 2.4).
% - Pathology values obtained from each slide, quantified with software of choice.
% - Mask of structure of interest from which histology slides are obtained.

% A Hippocampal MNI mask is provided in this repository, in the folder "atlas".
% If more than one histology slide per subject is considered, the total number of slides
% included in these analyses for each subject should also be provided (in
% variable "SlidesPerSubj") to normalize the pathology map by repeated measures.
% All gaussian distributions should have equal dimensions (equal sigma).

% This code only needs to be run once per analysis, including all slides.

% This code corresponds to the THIRD step from section 2.5 within: (link to paper)
% Authors: Juan Eugenio Iglesias and Diana Ortega-Cruz
% Date: May 2023

%%%%%%%INPUTS AND PARAMETERS%%%%%%%
Pathology=[]; %input quantified pathology burdens per slide into a horizontal vector, or import it from another variable
SlidesPerSubj=[]; %input or import the total number of slides included for that subject into a horizontal vector
num_slides=length(Pathology); %Doesn't need to be changed, total number of slides to be included
gaussians=repmat({''}, num_slides, 1); %Doesn't need to be changed, string vector to input paths to gaussian distributions of included slides
gaussians(1,1)= {'path\to\slide.regfakeMRI.gauss10.nii'}; %gaussian distribution for each slide to be included. 
%Insert paths for each slide in each consecutive position:
%gaussians(2,1)...gausians(num_slides,1), or import from a spreadsheet/variable
mask_file='path\to\mask_of_structure_of_interest.nii'; %MNI mask of brain structure of interest. 
cd 'path\to\output\directory\' %output directory
eps=1e-12; %epsilon for result normalization 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%
%In principle, no need to edit beyond this point
%%%%%%%%%%%%

G=[];
%Read volume files for gaussian distributions of all included slides and
%concatenate them in "G"
for i=1:num_slides
    gauss=myMRIread(char(gaussians(i,1)), 0, tempdir);
    G=cat(4,G,gauss.vol);
end

%Create accumulator to sum pathology measures per slide distribution
accum=zeros(size(gauss.vol));
for i=1:length(Pathology)
    accum=accum+Pathology(i)*G(:,:,:,i)/SlidesPerSubj(i);

end;

%Normalize result
normalizer=sum(G,4) + eps;
map=accum./normalizer;

%Mask results to structure of interest
mask = myMRIread(mask_file, 0, tempdir);
map_masked=map.*mask.vol;

%Save results
writemap=gauss;
writemap.vol=map;
myMRIwrite(writemap,'PathologyMap.nii');

writemap_masked=gauss;
writemap_masked.vol=map_masked;
myMRIwrite(writemap_masked,'MaskedPathologyMap.nii');

disp('Done!');