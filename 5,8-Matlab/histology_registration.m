% Code to register histology slide (2D image) to reconstructed hemisphere
% (3D volume) obtained from specimen photos from the same subject (photo_reconstruction code).
% Manual initialization is performed by selecting two points with approximately 
% the same anatomical position in both the reconstructed hemisphere and in
% the histology image. Coordinates from points selected in the reconstructed 
% hemisphere are copied here as input, and corresponding points in the histology 
% slide are then selected while running the code. 
% This code should be run once per histology slide to be included in
% analyses.

% This code corresponds to the FIRST step from section 2.5 within: (link to paper)
% Author: Juan Eugenio Iglesias
% Date: May 2023

clear

%%%%%%%%%%%%
%%%INPUTS%%%
inputimage = 'path\to\hitology\file.tif'; %scanned histology slide image
photo_recon = 'path\to\photo_reconstruction_volume.nii'; %reconstructed hemisphere from photos (output from photo_reconstruction) in nifti format
fakeMRI =  'path\to\MNI_atlas_registered_to_synthetic_MRI.nii'; %MNI atlas in subject-specific space (registered to synthetic MRI obtained from 3D SynthSR) in nifti format. Alternatively, the synthetic MRI from 3D SynthSR can be used. 
cd 'path\to\output\directory\' %output directory
point1ras = []'; %Insert here RAS coordinates of selected point 1 in reconstructed hemisphere from photos
point2ras = []'; %Insert here RAS coordinates of selected point 2 in reconstructed hemisphere from photos
%%%PARAMETERS%%%
pixsize = 1 / 160; %pixel size of histology slide image
approximate_depth = -2.5; %Assumed depth (mm) of histology slide with respect to the surface of the slice. Positive value indicates moving in the anterior direction, negative in posterior direction.   
workingRes = 1; %Resolution of "fakeMRI" in the coronal plane (mm)
priorSigma = 1; %Sigma of gaussian distribution for registration to fake MRI 
%%%%%%%%%%%%

%%%%%%%%%%%%
%In principle, no need to edit beyond this point
%%%%%%%%%%%%

%1.Point selection%
%Selection of reference points 1 and 2 in histology slide,
%which will be aligned with "point1ras" and "point2ras" coordinates, respectively.
A=imread(inputimage);

close all
figure(1)
imshow(A);
disp('Please click on first point');
p1 = ginput(1);
hold on, plot(p1(1),p1(2),'b.','markersize',16), hold off
disp('Please click on second point');
p2 = ginput(1);
hold on, plot(p2(1),p2(2),'b.','markersize',16), hold off
pause(2)
close(1);

%2. Generate a 3D volume for the histology slide and register it to photo_recon% 
mri =[];
mri.vol = reshape(A, [size(A,1) size(A,2) 1 3]);
mri.vox2ras0 =[-pixsize 0 0 0; 0 0 pixsize 0; 0 -pixsize 0 0; 0 0 0 1];
mri.volres = [pixsize pixsize pixsize];

cim = (p1+p2)/2;
cimras = mri.vox2ras0 * [cim(1); cim(2); 0; 1];
shift = (point1ras + point2ras) /2 - cimras(1:3);
mri.vox2ras0(1:3,4) = shift;

point1vox = inv(mri.vox2ras0) * [point1ras; 1];
point2vox = inv(mri.vox2ras0) * [point2ras; 1];
targetdirvox = point2vox(1:2) - point1vox(1:2);
targetdirvox = targetdirvox / norm(targetdirvox);
inputdirvox = p2-p1;
inputdirvox = inputdirvox / norm(inputdirvox);
targetangle = atan2(targetdirvox(2), targetdirvox(1));
inputangle = atan2(inputdirvox(2), inputdirvox(1));
angle = targetangle - inputangle;

C1 = [1 0 0 -cim(1); 0 1 0 -cim(2); 0 0 1 0; 0 0 0 1];
R = [cos(angle) -sin(angle) 0 0; sin(angle) cos(angle) 0 0; 0 0 1 0; 0 0 0 1];
invC1 = inv(C1);
mri.vox2ras0 = mri.vox2ras0 * invC1 * R * C1;
mri.vox2ras0(2,4)  = mri.vox2ras0(2,4) + approximate_depth;

pr = myMRIread(photo_recon, 0, tempdir);
targetdir = pr.vox2ras * [0 0 1 0]';
targetdir = targetdir(1:3);
targetdir = targetdir / norm(targetdir);
if targetdir(2)<0, targetdir = -targetdir; end
inputdir =[0; 1; 0];
inputdir = inputdir(1:3);
inputdir = inputdir / norm(inputdir);
if inputdir(2)<0, inputdir = -inputdir; end

cimras = mri.vox2ras0 * [cim(1); cim(2); 0; 1];
C1 = eye(4); C1(1:3,4) = -cimras(1:3);
el = asin(targetdir(3));
az = atan2(targetdir(2), targetdir(1)) - pi/2;
R1 = [1 0 0 0; 0 cos(el) -sin(el) 0; 0 sin(el) cos(el) 0; 0 0 0 1];
R2 = [cos(az) -sin(az) 0 0; sin(az) cos(az) 0 0; 0 0 1 0; 0 0 0 1];
invC1 = inv(C1);
mri.vox2ras0 = invC1 * R2 * R1 * C1 * mri.vox2ras0;

%Save histology slide registered to photo_recon in output directory
myMRIwrite(mri,'slide.nii'); 

%3. Bring the registered histology slide to the same resolution as the fakeMRI (working resolution)%
mri2 = mri;
factor = pixsize/workingRes;
Ar = imresize(rgb2gray(A),factor);
mri2.vol = Ar;
mri2.vox2ras0(:,1:2) = mri2.vox2ras0(:,1:2) / factor;
mri2.volres(1:2)  = mri2.volres(1:2)  / factor;
mri2.vox2ras0(1:3,4) = mri2.vox2ras0(1:3,4) + mri2.vox2ras0(1:3,1:3) * [.5; .5; 0];

%Save the registered slide at working resolution to output directory
myMRIwrite(mri2,'slide.workingRes.nii'); 

%4. Optimize registration to fakeMRI based on gradient magnitude correlation%
V = mri2.vol;
GV = grad2d(V);
sV = size(mri2.vol);
sV(end+1) = 1;
N = 10;
[II,JJ,KK] = ndgrid(-N:sV(1)-1+N, -N:sV(2)-1+N, -N:sV(3)-1+N);
KK = KK / factor;
RAS = mri2.vox2ras0 * [JJ(:)'; II(:)'; KK(:)'; ones(1, numel(II))];
mrifake = myMRIread(fakeMRI,0,tempdir);
IJK = inv(mrifake.vox2ras0) * RAS;
I = IJK(2,:)+1; J = IJK(1,:)+1; K = IJK(3,:)+1;
FMR = reshape(interpn(mrifake.vol,I(:),J(:),K(:)), size(II));
for z = 1 : size(FMR,3)
    FMR(:,:,z) = grad2d(FMR(:,:,z));
end
FIT = zeros(2*N+1,2*N+1,2*N+1);
y = GV(:);
for i = -N : N
    for j = -N:N
        for k=-N:N
            
            x = FMR(i+N+1:i+N+sV(1), j+N+1:j+N+sV(2), k+N+1:k+N+sV(3)); 
            x = x(:);
            rho = corrcoef(x,y);
            FIT(i+N+1,j+N+1,k+N+1) = rho(1,2);
        end
    end
end
gauss = fspecial('gaussian',[size(FIT,1), size(FIT,2)], priorSigma);
gauss = gauss / max(gauss(:));
for k = 1 : size(FIT,3)
    FIT(:,:,k) = FIT(:,:,k) .* gauss;
end
for i = 1 : size(FIT,1)
    for j = 1 : size(FIT,2)
        FIT(i,j,:) =  FIT(i,j,:) .* reshape(gauss(N+1,:),[1 1 2*N+1]);
    end
end
[maxi, idx] = max(FIT(:));
[i,j,k] = ind2sub(size(FIT), idx);
i = i - N -1;
j = j - N -1;
k = k - N -1;

mri4 = mri2;
T = eye(4); T(1:3,4) = [j,i,k/factor]';
mri4.vox2ras0 = mri2.vox2ras0 * T;
%Save slide with optimized registration to fakeMRI to output directory at working resolution
myMRIwrite(mri4,'slide.workingRes.regfakeMRI.nii'); 

mri5 = mri;
T = eye(4); T(1:3,4) = [j/factor,i/factor,k/factor]';
mri5.vox2ras0 = mri5.vox2ras0 * T;
%Save slide with optimized registration to fakeMRI to output directory at
%original resolution (final output)
myMRIwrite(mri5,'slide.regfakeMRI.nii'); 

disp('Done!');