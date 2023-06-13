"""This script enables to launch predictions with SynthSeg from the terminal."""

# print information
print('\n')
print('SynthSR prediction')
print('\n')

# python imports
import os
import sys
import numpy as np
import cv2
from argparse import ArgumentParser

# add main folder to python path and import SynthSR packages
synthSR_home = os.path.dirname(os.path.dirname(os.path.abspath(sys.argv[0])))
print(synthSR_home)
sys.path.append(synthSR_home)
from ext.neuron import models as nrn_models
from ext.lab2im import utils
from ext.lab2im import edit_volumes

# parse arguments
parser = ArgumentParser()
parser.add_argument("path_images", type=str, help="images to super-resolve / synthesize. Can be the path to a single image or to a folder")
parser.add_argument("path_predictions", type=str,
                    help="path where to save the synthetic 1mm MP-RAGEs. Must be the same type "
                         "as path_images (path to a single image or to a folder)")
parser.add_argument("--cpu", action="store_true", help="enforce running with CPU rather than GPU.")
parser.add_argument("--threads", type=int, default=1, dest="threads",
                    help="number of threads to be used by tensorflow when running on CPU.")
parser.add_argument("--model", type=str, help="path_to_model")

args = vars(parser.parse_args())

# enforce CPU processing if necessary
if args['cpu']:
    print('using CPU, hiding all CUDA_VISIBLE_DEVICES')
    os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

# limit the number of threads to be used if running on CPU
import tensorflow as tf
tf.config.threading.set_intra_op_parallelism_threads(args['threads'])

# Build Unet and load weights
conv_size = [3, 1, 3]
batch_norm_dim = None

unet_model = nrn_models.unet(nb_features=24,
                             input_shape=[None,None,None,1],
                             nb_levels=5,
                             conv_size=conv_size,
                             nb_labels=1,
                             feat_mult=2,
                             nb_conv_per_level=2,
                             conv_dropout=0,
                             final_pred_activation='linear',
                             batch_norm=batch_norm_dim,
                             activation='elu',
                             input_model=None)

weight_file = args['model']
unet_model.load_weights(weight_file, by_name=True)

# Prepare list of images to process
path_images = os.path.abspath(args['path_images'])
basename = os.path.basename(path_images)
path_predictions = os.path.abspath(args['path_predictions'])

# prepare input/output volumes
# First case: you're providing directories
if ('.jpg' not in basename) & ('.tif' not in basename) & ('.png' not in basename) & ('.npz' not in basename) & ('.npy' not in basename):
    if os.path.isfile(path_images):
        raise Exception('extension not supported for %s, only use: nii.gz, .nii, .mgz, or .npz' % path_images)
    images_to_segment = utils.list_images_in_folder(path_images)
    utils.mkdir(path_predictions)
    path_predictions = [os.path.join(path_predictions, os.path.basename(image)).replace('.jpg', '_SynthSR.jpg') for image in
                   images_to_segment]
    path_predictions = [seg_path.replace('.tif', '_SynthSR.tif') for seg_path in path_predictions]
    path_predictions = [seg_path.replace('.png', '_SynthSR.png') for seg_path in path_predictions]
    path_predictions = [seg_path.replace('.npy', '_SynthSR.npy') for seg_path in path_predictions]
    path_predictions = [seg_path.replace('.npz', '_SynthSR.npz') for seg_path in path_predictions]

else:
    assert os.path.isfile(path_images), "files does not exist: %s " \
                                        "\nplease make sure the path and the extension are correct" % path_images
    images_to_segment = [path_images]
    path_predictions = [path_predictions]


# Do the actual work
print('Found %d images' % len(images_to_segment))
for idx, (path_image, path_prediction) in enumerate(zip(images_to_segment, path_predictions)):
    print('  Working on image %d ' % (idx+1))
    print('  ' + path_image)

    I = cv2.imread(path_image)
    if len(I.shape)==3:
        I = cv2.cvtColor(I, cv2.COLOR_BGR2GRAY)
    I = I.astype(float)
    M = I>0
    I = I - np.min(I)
    I = I / np.max(I)

    # Change shape from photo to RAS
    I = np.fliplr(I)
    I = np.transpose(I)
    I = np.flip(I,axis=1)
    I = I[np.newaxis, :, np.newaxis, :, np.newaxis]

    W = (np.ceil(np.array(I.shape[1:-1]) / 32.0) * 32).astype('int')
    W[1] = 1
    idx = np.floor((W-I.shape[1:-1])/2).astype('int')
    S = np.zeros([1, *W, 1])
    S[0, idx[0]:idx[0]+I.shape[1], idx[1]:idx[1]+I.shape[2], idx[2]:idx[2]+I.shape[3], :] = I
    output = unet_model.predict(S)
    pred = np.squeeze(output)
    pred = 255 * pred
    pred[pred<0] = 0
    # pred[pred>128] = 128
    pred = pred[idx[0]:idx[0]+I.shape[1], idx[2]:idx[2]+I.shape[3]]
    pred = pred.astype('uint8')

    # Change shape from RAS to photo
    pred = np.flip(pred, axis=1)
    pred = np.transpose(pred)
    pred = np.fliplr(pred)
    pred[M==0] = 0
    cv2.imwrite(path_prediction, pred)

print(' ')
print('All done!')
print(' ')

