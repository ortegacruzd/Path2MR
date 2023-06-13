"""This script enables to launch predictions with SynthSeg from the terminal."""

# print information
print('\n')
print('SynthSR prediction')
print('\n')

# python imports
import os
import sys
import numpy as np
from argparse import ArgumentParser

# add main folder to python path and import SynthSR packages
from ext.neuron import models as nrn_models
from ext.lab2im import utils
from ext.lab2im import edit_volumes
import tensorflow as tf





parser = ArgumentParser()
parser.add_argument("path_image", type=str, help="3D photo recon to super-resolve / synthesize.")
parser.add_argument("path_prediction", type=str,
                    help="path where to save the synthetic 1mm MP-RAGE")
parser.add_argument("path_model", type=str,
                    help="path where the DL model is")

args = vars(parser.parse_args())


# enforce CPU processing
print('using CPU, hiding all CUDA_VISIBLE_DEVICES')
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
tf.config.threading.set_intra_op_parallelism_threads(8)

# Build Unet and load weights
unet_model = nrn_models.unet(nb_features=24,
                             input_shape=[None,None,None,1],
                             nb_levels=5,
                             conv_size=[3, 3, 3],
                             nb_labels=1,
                             feat_mult=2,
                             nb_conv_per_level=2,
                             conv_dropout=0,
                             final_pred_activation='linear',
                             batch_norm=-1,
                             activation='elu',
                             input_model=None)

unet_model.load_weights(args['path_model'], by_name=True)

im, aff, hdr = utils.load_volume(args['path_image'],im_only=False,dtype='float')
while len(im.shape)>3:
    im = np.mean(im, axis=-1)
mask = (im>10).astype(float)
tmp = aff
im, aff = edit_volumes.rescale_voxel_size(im, aff, [1.0, 1.0, 1.0])
mask, _ = edit_volumes.rescale_voxel_size(mask, tmp, [1.0, 1.0, 1.0])
aff_ref = np.eye(4)
im, aff2 = edit_volumes.align_volume_to_ref(im, aff, aff_ref=aff_ref, return_aff=True, n_dims=3)
mask, _ = edit_volumes.align_volume_to_ref(mask, aff, aff_ref=aff_ref, return_aff=True, n_dims=3)
from scipy.ndimage import gaussian_filter
mask = gaussian_filter(mask, 1.0 * np.ones(3))
im = im - np.min(im)
im = im / np.max(im)
I = im[np.newaxis,..., np.newaxis]
W = (np.ceil(np.array(I.shape[1:-1]) / 32.0) * 32).astype('int')
idx = np.floor((W-I.shape[1:-1])/2).astype('int')
S = np.zeros([1, *W, 1])
S[0, idx[0]:idx[0]+I.shape[1], idx[1]:idx[1]+I.shape[2], idx[2]:idx[2]+I.shape[3], :] = I
output = unet_model.predict(S)
pred = np.squeeze(output)
pred = 255 * pred
pred[pred<0] = 0
pred[pred>255] = 255
pred = pred[idx[0]:idx[0]+I.shape[1], idx[1]:idx[1]+I.shape[2], idx[2]:idx[2]+I.shape[3]]
utils.save_volume(pred*mask,aff2,None,args['path_prediction'])

print('freeview ' + args['path_image'] + ' ' + args['path_prediction'])
