This directory contains CellProfiler projects to perform quantification of tau NFTs and amyloid plaques in 20x images from sections
stained with antibodies against tau (used with stainings with AT-100 antibody) and beta-amyloid respectively. 
This step is explained in manuscript Section 2.7.
CellProfiler allows processing and analysis of images using an automated and unified pipeline for the whole dataset.
One example image of each type is provided in the directory "ExampleImages".

CellProfiler can be installed for free here:
https://cellprofiler.org/releases

And information on available modules and functionalities can be found here:
https://tutorials.cellprofiler.org/

To use these projects, images should be added in the first module "Images", 
and the performance of each step can be evaluated using the "Test Mode". 
Batch analysis can be then initiated with "Analyze Images". 

---STEPS OF THE PROJECTS-------
Both NFT (TauQuantification) and amyloid plaque (BamyloidQuantification) projects include the same processing steps:

1- Module "UnmixColors" to segment images based on color 
("brown" for structures stained with the antibody of interest, "purple" for structures stained with hematoxylin). 
In addition, for amyloid stainings, "ImageMath" modules are used to optimize the separation between these two channels.

2- Modules "MeasureImageIntensity" and "ImageMath" to intensity normalize segmented images. 
This is done by substracting to each image (brown and purple channels) its mean intensity, 
to optimize the use of a single pipeline for images of sections with variable intensity of staining.
The higher the variability in the intensity across images, the stronger weight was given to the mean substraction. 
 
3- Module "IdentifyPrimaryObjects" to segment objects of interest based on size.
In amyloid quantification project, plaques are segmented from brown channel (antibody staining). 
In tau quantification projects, NFTs are segmented from brown channel (antibody staining), and the rest of neuronal nuclei 
are segmented from purple channel (hematoxylin). In addition, for tau quantification the module "CombineObjects" is used to 
fuse NFT and nuclei segmentations to obtain the total neuron count and avoid overlap of both measurements 
(e.g. NFT and nuclei from a same neuron being counted twice) 

4- Module "ExportToSpreadsheet" is used to export measurements from each image. 
Data to export can be selected in that module under "Press button to select measurements",
relevant measurements are normally under the category "Image". Before this step, in amyloid project, area covered by plaques 
segmented in step 3 is measured with the module "MeasureImageAreaOccupied".
------------------------------

-----TAU PROJECTS-------------

Since NFTs are intracellular and neurons have different size in hippocampal subfields CA1, CA2 and CA3 compared to the dentate gyrus, 
we employed two separate projects to quantify tau images from the hippocampus:
1. TauQuantification_CA: used for 20x images from CA1, CA2 and CA3
2. TauQuantification_DG: used for 20x images from dentate gyrus (medial (MDG) and lateral (LDG))
-------------------------------
