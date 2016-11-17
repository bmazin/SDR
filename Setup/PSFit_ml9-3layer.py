''' 
90'%' accuracy sometimes and 50'%' exact attenuation choice

4 hidden layers. 2 pools
3 classes (like the original)

To do:
Could try just overpower and normal seeing as that's all you care about and then use the 2nd max to find optimal
Have it plot missed resonators to dientify why it's missing them
Read up on CNN if you have to
Make it do loop test automatically without having to do 2012 2012 in command line

Author Rupert Dodkins

A script to automate the identification of resonator attenuations normally performed by PSFit.py. This is accomplished 
using Google's Tensor Flow machine learning package which implements a pattern recognition algorithm on the IQ velocity
spectrum. The code implements a 2D image classification algorithm similar to the MNIST test. This code creates a 2D 
image from a 1D variable by populating a matrix of zeros with ones at the y location of each datapoint

Usage:  python PSFit_ml.py 20160712/ps_r115_FL1_1_20160712-225809.h5 20160720/ps_r118_FL1_b_pos_20160720-231653.h5

Inputs:
20160712/ps_r115_FL1_1.txt:                    list of resonator frequencies and correct attenuations
20160712/ps_r115_FL1_1_20160712-225809.h5:     corresponding powersweep file
20160720/ps_r118_FL1_b_pos_20160720-231653.h5: powersweep file the user wishes to infer attenuations for

Intermediaries:
SDR/Setup/ps_peaks_train_w<x>_s<y>.pkl:        images and corresponding labels used to train the algorithm

Outputs: 
20160712/ps_r115_FL1_1.pkl:                        frequencies, IQ velocities, Is, Qs, attenuations formatted for quick use
20160720/ps_r118_FL1_b_pos_20160720-231653-ml.txt: to be used with PSFit.py (temporary)
20160720/ps_r118_FL1_b_pos.txt:                    final list of frequencies and attenuations

How it works:
For each resonator and attenuation the script first assesses if the IQ loop appears saturated. If the unstaurated IQ 
velocity spectrum for that attenuation is compared with the pattern recognition machine. A list of attenuations for each 
resonator, where the loop is not saturated and the IQ velocity peak looks the correct shape, and the attenuation value 
is chosen which has the highest 2nd largest IQ velocity. This identifier was chosen because the optimum attenuation 
value has a high max IQ velocity and a low ratio of max IQ velocity to 2nd max IQ velocity which is equivalent to 
choosing the highest 2nd max IQ velocity.

This list of attenuation values and frequencies are either fed PSFit.py to checked manually or dumped to 
ps_r118_FL1_b_pos.txt

The machine learning algorithm requires a series of images to train and test the algorithm with. If they exist the image 
data will be loaded from a train pkl file

Alternatively, if the user does not have a train pkl file but does have a powersweep file and corresponding list of 
resonator attenuations this should be used as the initial file and training data will be made. The 3 classes are an 
overpowered peak (saturated), peak with the correct amount of power, or an underpowered peak. 

These new image data will be saved as pkl files (or appened to existing pkl files) and reloaded

The machine is then trained and its ability to predict the type of image is validated

The weights used to make predictions for each class can be displayed using the plotWeights function

to do:
change training txt file freq comparison function so its able to match all frequencies

'''
import os,sys,inspect
from PSFit import *
from lib.iqsweep import *
import numpy as np
import sys, os
import matplotlib.pyplot as plt
import tensorflow as tf
import pickle
import random
import time
import math
from scipy import interpolate
np.set_printoptions(threshold=np.inf)

#removes visible depreciation warnings from lib.iqsweep
import warnings
warnings.filterwarnings("ignore")

class PSFitting():
    '''Class has been lifted from PSFit.py and modified to incorporate the machine learning algorithms from 
    WideAna_ml.py  
    '''
    def __init__(self, initialFile=None):
        self.initialFile = initialFile
        self.resnum = 0

    def loadres(self):
        '''
        Outputs
        Freqs:          the span of frequencies for a given resonator
        iq_vels:        the IQ velocities for all attenuations for a given resonator
        Is:             the I component of the frequencies for a given resonator
        Qs:             the Q component of the frequencies for a given resonator
        attens:         the span of attenuations. The same for all resonators
        '''
        
        self.Res1=IQsweep()
        self.Res1.LoadPowers(self.initialFile, 'r0', self.freq[self.resnum])
        self.resfreq = self.freq[self.resnum]
        self.NAttens = len(self.Res1.atten1s)
        self.res1_iq_vels=numpy.zeros((self.NAttens,self.Res1.fsteps-1))
        self.res1_iq_amps=numpy.zeros((self.NAttens,self.Res1.fsteps))
        for iAtt in range(self.NAttens):
            for i in range(1,self.Res1.fsteps-1):
                self.res1_iq_vels[iAtt,i]=sqrt((self.Res1.Qs[iAtt][i]-self.Res1.Qs[iAtt][i-1])**2+(self.Res1.Is[iAtt][i]-self.Res1.Is[iAtt][i-1])**2)
                self.res1_iq_amps[iAtt,:]=sqrt((self.Res1.Qs[iAtt])**2+(self.Res1.Is[iAtt])**2)
        #Sort the IQ velocities for each attenuation, to pick out the maximums
        
        sorted_vels = numpy.sort(self.res1_iq_vels,axis=1)
        #Last column is maximum values for each atten (row)
        self.res1_max_vels = sorted_vels[:,-1]
        #Second to last column has second highest value
        self.res1_max2_vels = sorted_vels[:,-2]
        #Also get indices for maximum of each atten, and second highest
        sort_indices = numpy.argsort(self.res1_iq_vels,axis=1)
        max_indices = sort_indices[:,-1]
        max2_indices = sort_indices[:,-2]
        max_neighbor = max_indices.copy()
        
        #for each attenuation find the ratio of the maximum velocity to the second highest velocity
        self.res1_max_ratio = self.res1_max_vels.copy()
        max_neighbors = zeros(self.NAttens)
        max2_neighbors = zeros(self.NAttens)
        self.res1_max2_ratio = self.res1_max2_vels.copy()
        for iAtt in range(self.NAttens):
            if max_indices[iAtt] == 0:
                max_neighbor = self.res1_iq_vels[iAtt,max_indices[iAtt]+1]
            elif max_indices[iAtt] == len(self.res1_iq_vels[iAtt,:])-1:
                max_neighbor = self.res1_iq_vels[iAtt,max_indices[iAtt]-1]
            else:
                max_neighbor = maximum(self.res1_iq_vels[iAtt,max_indices[iAtt]-1],
                                       self.res1_iq_vels[iAtt,max_indices[iAtt]+1])
            max_neighbors[iAtt]=max_neighbor
            self.res1_max_ratio[iAtt] = self.res1_max_vels[iAtt]/max_neighbor
            if max2_indices[iAtt] == 0:
                max2_neighbor = self.res1_iq_vels[iAtt,max2_indices[iAtt]+1]
            elif max2_indices[iAtt] == len(self.res1_iq_vels[iAtt,:])-1:
                max2_neighbor = self.res1_iq_vels[iAtt,max2_indices[iAtt]-1]
            else:
                max2_neighbor = maximum(self.res1_iq_vels[iAtt,max2_indices[iAtt]-1],
                                        self.res1_iq_vels[iAtt,max2_indices[iAtt]+1])
            max2_neighbors[iAtt]=max2_neighbor
            self.res1_max2_ratio[iAtt] = self.res1_max2_vels[iAtt]/max2_neighbor
        #normalize the new arrays
        self.res1_max_vels /= numpy.max(self.res1_max_vels)
        self.res1_max_vels *= numpy.max(self.res1_max_ratio)
        self.res1_max2_vels /= numpy.max(self.res1_max2_vels)

        
        max_ratio_threshold = 2.5#1.5
        rule_of_thumb_offset = 1#2

        # require ROTO adjacent elements to be all below the MRT
        bool_remove = np.ones(len(self.res1_max_ratio))
        for ri in range(len(self.res1_max_ratio)-rule_of_thumb_offset-2):
            bool_remove[ri] = bool((self.res1_max_ratio[ri:ri+rule_of_thumb_offset+1]< max_ratio_threshold).all())
        guess_atten_idx = np.extract(bool_remove,np.arange(len(self.res1_max_ratio)))

        # require the attenuation value to be past the initial peak in MRT
        guess_atten_idx = guess_atten_idx[where(guess_atten_idx > argmax(self.res1_max_ratio) )[0]]

        if size(guess_atten_idx) >= 1:
            if guess_atten_idx[0]+rule_of_thumb_offset < len(self.Res1.atten1s):
                guess_atten_idx[0] += rule_of_thumb_offset
                guess_atten_idx =  int(guess_atten_idx[0])
        else:
            guess_atten_idx = self.NAttens/2

        return {'freq': self.Res1.freq, 
                'iq_vels': self.res1_iq_vels, 
                'Is': self.Res1.Is,     
                'Qs': self.Res1.Qs, 
                'attens':self.Res1.atten1s}

    
    def loadps(self):
        hd5file=openFile(self.initialFile,mode='r')
        group = hd5file.getNode('/','r0')
        self.freq=empty(0,dtype='float32')
        
        for sweep in group._f_walkNodes('Leaf'):
            k=sweep.read()
            self.scale = k['scale'][0]
            #print "Scale factor is ", self.scale
            self.freq=append(self.freq,[k['f0'][0]])
        hd5file.close()

class mlClassification():
    def __init__(self,  initialFile=None):
        '''
        Implements the machine learning pattern recognition algorithm on IQ velocity data as well as other tests to 
        choose the optimum attenuation for each resonator
        '''
        self.nClass = 3
        self.xWidth = 40#np.shape(res1_freqs[1])
        self.scalexWidth = 1
        self.oAttDist = -1 # rule of thumb attenuation steps to reach the overpowered peak
        #self.uAttDist = +2 # rule of thumb attenuation steps to reach the underpowed peak

        self.initialFile = initialFile
        self.baseFile = ('.').join(initialFile.split('.')[:-1])
        self.PSFile = self.baseFile[:-16] + '.txt'#os.environ['MKID_DATA_DIR']+'20160712/ps_FL1_1.txt' # power sweep fit, .txt 
        self.mldir = './machine_learning_metadata/' 

        self.trainFile = 'ps_peaks_train_iqv_mag_c%i.pkl' % (self.nClass) 
        print self.trainFile
        self.trainFrac = 0.9
        self.testFrac=1 - self.trainFrac

    def makeResImage(self, res_num, iAtten, angle=0,  phase_normalise=False, showFrames=False, test_if_noisy=False):
        '''Creates a table with 2 rows, I and Q for makeTrainData(mag_data=True)

        inputs 
        res_num: index of resonator in question
        iAtten: index of attenuation in question
        self.scalexWidth: typical values: 1/2, 1/4, 1/8
                          uses interpolation to put data from an xWidth x xWidth grid to a 
                          (xWidth/scalexWidth) x (xWidth/scalexWidth) grid. This allows the 
                          user to probe the spectrum using a smaller window while utilizing 
                          the higher resolution training data
        angle: angle of rotation about the origin (radians)
        showFrames: pops up a window of the frame plotted using matplotlib.plot
        '''     
        xWidth= self.xWidth 
        scalexWidth = self.scalexWidth

        xCenter = self.get_peak_idx(res_num,iAtten)
        start = int(xCenter - xWidth/2)
        end = int(xCenter + xWidth/2)

        # plt.plot(self.Is[res_num,iAtten], self.Qs[res_num,iAtten])
        # plt.show()
        # for spectra where the peak is close enough to the edge that some points falls across the bounadry, pad zeros
        if start < 0:
            start_diff = abs(start)
            start = 0
            iq_vels = self.iq_vels[res_num, iAtten, start:end]
            iq_vels = np.lib.pad(iq_vels, (start_diff,0), 'constant', constant_values=(0))
            Is = self.Is[res_num,iAtten,start:end]
            Is = np.lib.pad(Is, (start_diff,0), 'constant', constant_values=(Is[0]))
            Qs = self.Qs[res_num,iAtten,start:end]
            Qs = np.lib.pad(Qs, (start_diff,0), 'constant', constant_values=(Qs[0]))
        elif end >= np.shape(self.freqs)[1]:
            iq_vels = self.iq_vels[res_num, iAtten, start:end]
            iq_vels = np.lib.pad(iq_vels, (0,end-np.shape(self.freqs)[1]+1), 'constant', constant_values=(0))
            Is = self.Is[res_num,iAtten,start:end]
            Is = np.lib.pad(Is, (0,end-np.shape(self.freqs)[1]), 'constant', constant_values=(Is[-1]))
            Qs = self.Qs[res_num,iAtten,start:end]
            Qs = np.lib.pad(Qs, (0,end-np.shape(self.freqs)[1]), 'constant', constant_values=(Qs[-1]))
        else:
            iq_vels = self.iq_vels[res_num, iAtten, start:end]
            Is = self.Is[res_num,iAtten,start:end]
            Qs = self.Qs[res_num,iAtten,start:end]
        #iq_vels = np.round(iq_vels * xWidth / max(self.iq_vels[res_num, iAtten, :]) )
        iq_vels = iq_vels / np.amax(self.iq_vels[res_num, :, :])


                # interpolate iq_vels onto a finer grid
        if scalexWidth!=None:
            x = np.arange(0, xWidth+1)
            iq_vels = np.append(iq_vels, iq_vels[-1])
            f = interpolate.interp1d(x, iq_vels)
            xnew = np.arange(0, xWidth, scalexWidth)
            iq_vels = f(xnew)/ scalexWidth

            Is = np.append(Is, Is[-1])
            f = interpolate.interp1d(x, Is)
            Is = f(xnew)/ scalexWidth
            
            Qs = np.append(Qs, Qs[-1])
            f = interpolate.interp1d(x, Qs)
            Qs = f(xnew)/ scalexWidth

        xWidth = int(xWidth/scalexWidth)

        # if test_if_noisy:
        #     peak_iqv = mean(iq_vels[int(xWidth/4): int(3*xWidth/4)])
        #     nonpeak_indicies=np.delete(np.arange(xWidth),np.arange(int(xWidth/4),int(3*xWidth/4)))
        #     nonpeak_iqv = iq_vels[nonpeak_indicies]
        #     nonpeak_iqv = mean(nonpeak_iqv[np.where(nonpeak_iqv!=0)]) # since it spans a larger area
        #     noise_condition = 1.5#0.7 

        #     if (peak_iqv/nonpeak_iqv < noise_condition):
        #         return None 

        res_mag = math.sqrt(np.amax(self.Is[res_num, :, :]**2 + self.Qs[res_num, :, :]**2))
        Is = Is / res_mag
        Qs = Qs / res_mag

        # Is = Is /np.amax(self.iq_vels[res_num, :, :])
        # Qs = Qs /np.amax(self.iq_vels[res_num, :, :])

        # Is = Is /np.amax(self.Is[res_num, :, :])
        # Qs = Qs /np.amax(self.Qs[res_num, :, :])

        # print Is[::5]
        # print Qs[::5]

        if phase_normalise:
            #mags = Qs**2 + Is**2
            #mags = map(lambda x: math.sqrt(x), mags)#map(lambda x,y:x+y, a,b)

            #peak_idx = self.get_peak_idx(res_num,iAtten)
            peak_idx =argmax(iq_vels)
            #min_idx = argmin(mags)

            phase_orig = math.atan2(Qs[peak_idx],Is[peak_idx])
            #phase_orig = math.atan2(Qs[min_idx],Is[min_idx])

            angle = -phase_orig

        rotMatrix = numpy.array([[numpy.cos(angle), -numpy.sin(angle)], 
                                 [numpy.sin(angle),  numpy.cos(angle)]])

        Is,Qs = np.dot(rotMatrix,[Is,Qs])

        if showFrames:
            fig = plt.figure(frameon=False,figsize=(15.0, 5.0))
            fig.add_subplot(131)
            plt.plot(iq_vels)
            plt.ylim(0,1)
            fig.add_subplot(132)
            plt.plot(Is)
            plt.plot(Qs)
            fig.add_subplot(133)
            plt.plot(Is,Qs)
            plt.show()
            plt.close()

        image = np.zeros((3,len(Is)))
        image[0,:] = Is
        image[1,:] = Qs
        image[2,:] = iq_vels

        image = image.flatten()
        # image = np.append(Is,Qs,axis=0)

        #print np.shape(image)

        return image

    def get_peak_idx(self,res_num,iAtten):
        return argmax(self.iq_vels[res_num,iAtten,:])

    def makeTrainData(self):                
        '''creates 1d arrays using makeWindowImage of each class with associated labels and saves to pkl file

        0: saturated peak, too much power
        1: goldilocks, not too narrow or short
        2: underpowered peak, too little power
        
        or if plotting IQ mags (mag_data==True)

        outputs
        train file.pkl. contains...
            trainImages: table of size- xWidth * xCenters*trainFrac
            trainLabels: 1d array of size- xCenters*trainFrac
            testImages: table of size- xWidth * xCenters*testFrac
            testLabels: 1d array of size- xCenters*testFrac

        creates the training data to be passed to function mlClass. For each resonator and attenuation a 2 x num_freqs table is created 
        with associated labels and saves to pkl file

        -3              :
        -2:             :
        -1: slightly saturated too much power  
        0:  goldilocks, not too narrow or short
        1:  underpowered peak, too little power
        2:              :
        3:              :

        '''

        self.freqs, self.iq_vels,self.Is,self.Qs, self.attens = get_PS_data(h5File=initialFile)
        self.res_nums = np.shape(self.freqs)[0]
        
        # if mag_data==True:
        #     #self.trainFile = self.trainFile.split('.')[0]+'_mag.pkl'
        #     print self.trainFile, 'self.trainFile'
        #     self.nClass =3

        if os.path.isfile(self.PSFile):
            print 'loading peak location data from %s' % self.PSFile
            PSFile = np.loadtxt(self.PSFile, skiprows=1)[:self.res_nums]
            opt_freqs = PSFile[:,0]
            opt_attens = PSFile[:,3]
            self.opt_iAttens = opt_attens -min(self.attens)
        else: 
            print 'no PS.txt file found' 
            exit()

        print len(opt_freqs)
        all_freqs = np.around(self.freqs, decimals=-4)
        opt_freqs = np.around(opt_freqs, decimals=-4)
        good_res = np.arange(self.res_nums)

        a=0 # index to remove values from all_freqs
        b = 0  # backtrack on g when good freqs can't be used
            # g index for the good freqs
        bad_opt_res = []

        for g in range(len(opt_freqs)-2):
            #print r, i, opt_freqs[r], round_freqs[i,:]# map(lambda x,y:x+y, a,b)
            while opt_freqs[g] not in all_freqs[a,:]:
                if opt_freqs[g] not in all_freqs[a:a+5,:]: # if in the next 5 rows of all_freqs then ignore good_freqs
                    #print 'ignoring frequency value from optimum file'
                    a -= 1 # cancels the index incrementing
                    b -= 1 # g is used to remove from good_res but g has incremented and i is stationary
                    bad_opt_res.append(g)
                    break

                good_res = np.delete(good_res,g+b) # identify this value of all_freqs as bad by removing from list
                a += 1  # keep incrementing until opt_freqs matches good_freqs
                #print g,a,a-g, len(good_res), b # see how well the two data match
            a += 1 # as g increments so does a

        # attDist = np.arange(-2,3,2)
        attDist = np.arange(-2,1,2)
        print attDist

        bad_opt_res.append(len(opt_freqs)-2)
        bad_opt_res.append(len(opt_freqs)-1)
        bad_opt_res.append(len(opt_freqs))

        print 'bad_opt_res', np.shape(bad_opt_res)

        iAttens = np.zeros((len(good_res),self.nClass))
        # for i in range(self.nClass-1):
        #     iAttens[:,i] = np.delete(self.opt_iAttens,bad_opt_res) + attDist[i]        
        # print len(self.attens)

        # iAttens[:,2] = np.ones((len(good_res)))*len(self.attens)-1#self.opt_iAttens[:self.res_nums] + self.uAttDist

        self.opt_iAttens = np.delete(self.opt_iAttens,bad_opt_res)
        for ia in range(len(self.opt_iAttens)):
            attDist = int(np.random.normal(2, 1, 1))
            if attDist <1: attDist = 2
            iAttens[ia,0] = self.opt_iAttens[ia] - attDist
            iAttens[ia,1] = self.opt_iAttens[ia] + attDist
            
        iAttens[:,1] = self.opt_iAttens  

        # print np.where(self.opt_iAttens==0)
        print np.shape(iAttens)
        print iAttens[:10]

        self.res_nums = len(good_res)

        lb_rej = np.where(iAttens[:,0]<0)[0]
        if len(lb_rej) != 0:
            iAttens = np.delete(iAttens,lb_rej,axis=0) # when index is below zero
            print len(iAttens)
            good_res = np.delete(good_res,lb_rej)
            self.res_nums = self.res_nums-len(lb_rej)
        
        ub_rej = np.where(iAttens[:,2]>len(self.attens))[0]
        if len(ub_rej) != 0:
            iAttens = np.delete(iAttens,ub_rej,axis=0) 
            print len(iAttens)
            good_res = np.delete(good_res,ub_rej)
            self.res_nums = self.res_nums-len(ub_rej)

        # self.res_indicies = np.zeros((self.res_nums,self.nClass))
        # for c in range(self.nClass):
        #     for i, rn in enumerate(good_res):
        #         self.res_indicies[i,c] = self.get_peak_idx(rn,iAttens[i,c])

        self.iq_vels=self.iq_vels[good_res]
        self.freqs=self.freqs[good_res]
        self.Is = self.Is[good_res]
        self.Qs = self.Qs[good_res]

        #class_steps = 300

        trainImages, trainLabels, testImages, testLabels = [], [], [], []

        # num_rotations = 3
        # angle = np.arange(0,2*math.pi,2*math.pi/num_rotations)
        train_ind = np.array(map(int,np.linspace(0,self.res_nums-1,self.res_nums*self.trainFrac)))
        print type(train_ind), len(train_ind)
        test_ind=[]
        np.array([test_ind.append(el) for el in range(self.res_nums) if el not in train_ind])
        print type(test_ind), len(test_ind)
        
        print train_ind[:10], test_ind[:10]

        test_if_noisy = False
        for c in range(self.nClass):
            if c ==2:
                test_if_noisy = False
            for rn in train_ind:#range(int(self.trainFrac*self.res_nums)):
                # for t in range(num_rotations):
                #     image = self.makeResImage(res_num = rn, iAtten= iAttens[rn,c], angle=angle[t],showFrames=False, 
                #                                 test_if_noisy=test_if_noisy, xCenter=self.res_indicies[rn,c])
                image = self.makeResImage(res_num = rn, iAtten= iAttens[rn,c], phase_normalise=True ,showFrames=False) 
                if image!=None:
                    trainImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[c] = 1
                    trainLabels.append(one_hot)

        print self.res_nums

        test_if_noisy = False
        for c in range(self.nClass):
            if c ==2:
                test_if_noisy = False
            for rn in test_ind:#range(int(self.trainFrac*self.res_nums), int(self.trainFrac*self.res_nums + self.testFrac*self.res_nums)):
                image = self.makeResImage(res_num = rn, iAtten= iAttens[rn,c], phase_normalise=True)
                if image!=None:
                    testImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[c] = 1
                    testLabels.append(one_hot)
        


        append = None
        if os.path.isfile(self.trainFile): 
            append = raw_input('Do you want to append this training data to previous data [y/n]')
        if (append  == 'n'):
            self.trainFile = self.trainFile.split('-')[0]+time.strftime("-%Y-%m-%d-%H-%M-%S")
        if (append  == 'y') or (os.path.isfile(self.trainFile)== False):
            print 'saving %s to %s' % (self.trainFile, os.path.dirname(os.path.abspath(self.trainFile)) )
            with open(self.trainFile, 'ab') as tf:
                pickle.dump([trainImages, trainLabels], tf)
                pickle.dump([testImages, testLabels], tf)

    def mlClass(self):       
        '''Code adapted from the tensor flow MNIST tutorial 1.
        
        Using training images and labels the machine learning class (mlClass) "learns" how to classify IQ velocity peaks. 
        Using similar data the ability of mlClass to classify peaks is tested

        The training and test matricies are loaded from file (those made earlier if chosen to not be appended to file 
        will not be used)
        '''
        print self.trainFile
        if not os.path.isfile(self.trainFile):
            self.makeTrainData()

        trainImages, trainLabels, testImages, testLabels = loadPkl(self.trainFile)
        
        print np.sum(trainLabels,axis=0), np.sum(testLabels,axis=0)
      
        print np.sum(trainLabels,axis=0)[0]

        print np.sum(trainLabels,axis=0), np.sum(testLabels,axis=0)
        print 'Number of training images:', np.shape(trainImages), ' Number of test images:', np.shape(testImages)

        print np.shape(trainLabels)
        print np.sum(trainLabels,axis=0)

        # print len(trainImages)
        # for i in range(len(trainImages)):
        #     if i % 50 ==0:
        #         print trainLabels[i]
        #         print np.shape(trainImages[i][:])
        #         plt.plot(trainImages[i][:40])
        #         plt.plot(trainImages[i][40:])
        #         plt.show()
      
        if self.scalexWidth != 1:
            self.xWidth = int(self.xWidth/self.scalexWidth)
        if np.shape(trainImages)[1]/3!=self.xWidth:
            print 'Please make new training images of the correct size'
            exit()
        
        #self.nClass = np.shape(trainLabels)[1]

        #self.x = tf.placeholder(tf.float32, [None, self.xWidth]) # correspond to the images
        
        self.x = tf.placeholder(tf.float32, [None, self.xWidth*3])
        #print type(self.x[0][0])
        #print self.x[0][0]
        #print self.xWidth
        #exit()

        #x_image = tf.reshape(self.x, [-1,1,self.xWidth,1])
        x_image = tf.reshape(self.x, [-1,3,self.xWidth,1])

        def weight_variable(shape):
            #initial = tf.Variable(tf.zeros(shape))
            initial = tf.truncated_normal(shape, stddev=0.1)
            return tf.Variable(initial)

        def bias_variable(shape):
            initial = tf.constant(0.1, shape=shape)
            return tf.Variable(initial)

        def conv2d(x, W):
            return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')

        def max_pool_2x2(x):
            return tf.nn.max_pool(x, ksize=[1, 3, 2, 1], strides=[1, 1, 2, 1], padding='SAME')

        num_filt1 = 32
        self.num_filt1 = num_filt1
        W_conv1 = weight_variable([1, 3, 1, num_filt1])
        b_conv1 = bias_variable([num_filt1])
        h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)

        h_pool1 = max_pool_2x2(h_conv1)

        num_filt2 = 4
        W_conv2 = weight_variable([1, 3, num_filt1, num_filt2])
        b_conv2 = bias_variable([num_filt2])
        h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)        

        h_pool6 = max_pool_2x2(h_conv2)



        self.fc_filters = 5**2
        num_fc_filt = int(math.ceil(self.xWidth*1./8) * num_filt2*6) #18*4

        W_fc1 = weight_variable([num_fc_filt, self.fc_filters]) 
        b_fc1 = bias_variable([self.fc_filters])
        h_pool6_flat = tf.reshape(h_pool6, [-1, num_fc_filt])
        h_fc1 = tf.nn.relu(tf.matmul(h_pool6_flat, W_fc1) + b_fc1)

        keep_prob = tf.placeholder(tf.float32)
        h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

        self.W_fc2 = weight_variable([self.fc_filters, self.nClass])
        b_fc2 = bias_variable([self.nClass])    

        self.y=tf.nn.softmax(tf.matmul(h_fc1, self.W_fc2) + b_fc2) #h_fc1_drop   

        y_ = tf.placeholder(tf.float32, [None, self.nClass]) # true class lables identified by user 
        cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(self.y+ 1e-10), reduction_indices=[1])) # find optimum solution by minimizing error

        train_step = tf.train.AdamOptimizer(10**-3).minimize(cross_entropy) # the best result is when the wrongness is minimal

        init = tf.initialize_all_variables()

        saver = tf.train.Saver()
        
        correct_prediction = tf.equal(tf.argmax(self.y,1), tf.argmax(y_,1)) #which ones did it get right?
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

        modelName = ('.').join(self.trainFile.split('.')[:-1]) + '.ckpt'
        print modelName
        if os.path.isfile("%s%s" % (self.mldir,modelName)):
            #with tf.Session() as sess:
            self.sess = tf.Session()
            self.sess.run(init)           #do I need this? 
            # Restore variables from disk.
            saver.restore(self.sess, "%s%s" % (self.mldir,modelName) )
        else:
            self.sess = tf.Session()
            self.sess.run(init) # need to do this everytime you want to access a tf variable (for example the true class labels calculation or plotweights)

            # for i in range(len(trainImages)):
            #     if i % 30 ==0:
            #         print trainLabels[i]
            #         print np.shape(trainImages[i][:])
            #         plt.plot(self.sess.run(self.x)[i][0],feed_dict={self.x: trainImages})
            #         plt.plot(self.sess.run(self.x)[i][1],feed_dict={self.x: trainImages})
            #         plt.show()
            
            start_time = time.time()
            trainReps = 10000
            batches = 50
            if np.shape(trainLabels)[0]< batches:
                batches = np.shape(trainLabels)[0]/2
            


            # print self.sess.run(tf.shape(W_conv1), feed_dict={self.x: testImages, y_: testLabels})    
            # print self.sess.run(tf.shape(h_conv1), feed_dict={self.x: testImages})    
            # #print self.sess.run(tf.shape(h_pool1), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_conv2))    
            # print self.sess.run(tf.shape(h_conv2), feed_dict={self.x: testImages})    
            # print self.sess.run(tf.shape(h_pool2), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_conv3))    
            # print self.sess.run(tf.shape(h_conv3), feed_dict={self.x: testImages})    
            # #print self.sess.run(tf.shape(h_pool3), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_conv4))    
            # print self.sess.run(tf.shape(h_conv4), feed_dict={self.x: testImages})    
            # print self.sess.run(tf.shape(h_pool4), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_conv5))    
            # print self.sess.run(tf.shape(h_conv5), feed_dict={self.x: testImages})    
            # #print self.sess.run(tf.shape(h_pool3), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_conv6))    
            # print self.sess.run(tf.shape(h_conv6), feed_dict={self.x: testImages})    
            # print self.sess.run(tf.shape(h_pool6), feed_dict={self.x: testImages})
            # print '\n'
            # print self.sess.run(tf.shape(W_fc1))    
            # print self.sess.run(tf.shape(h_pool6_flat), feed_dict={self.x: testImages})    
            # print self.sess.run(tf.shape(h_fc1), feed_dict={self.x: testImages})
            # print '\n'

            # print '\n'
            # print self.sess.run(tf.shape(self.W_fc2)) 



            ce_log = []
            acc_log=[]
            print 'Performing', trainReps, 'training repeats, using batches of', batches
            for i in range(trainReps):  #perform the training step using random batches of images and according labels
                batch_xs, batch_ys = next_batch(trainImages, trainLabels, batches) 
                
                #print np.shape(batch_xs), np.shape(batch_ys)

                if i % 100 == 0:
                    #self.plotW_fc2(self.sess.run(self.W_fc2))
                    #self.plotActivations(self.sess.run(h_conv1, feed_dict={self.x: batch_xs}), 'h_conv1', i)
                    #self.plotWeights(self.sess.run(W_conv2))
                    #self.plotActivations(self.sess.run(h_conv2, feed_dict={self.x: testImages}), 'h_conv2', i)
                    #print self.sess.run(W_conv1, feed_dict={self.x: testImages, y_: testLabels})
                    #print "max W vales: %g %g %g %g"%(self.sess.run(tf.reduce_max(tf.abs(W_conv1))),self.sess.run(tf.reduce_max(tf.abs(W_conv2))),self.sess.run(tf.reduce_max(tf.abs(W_fc1))),self.sess.run(tf.reduce_max(tf.abs(self.W_fc2))))
                    #print "max b vales: %g %g %g %g"%(self.sess.run(tf.reduce_max(tf.abs(b_conv1))),self.sess.run(tf.reduce_max(tf.abs(b_conv2))),self.sess.run(tf.reduce_max(tf.abs(b_fc1))),self.sess.run(tf.reduce_max(tf.abs(b_fc2))))
                    ce_log.append(self.sess.run(cross_entropy, feed_dict={self.x: batch_xs, y_: batch_ys}))
                    # print batch_ys[10],#, feed_dict={y_: batch_ys}),
                    # print self.sess.run(self.y, feed_dict={self.x: batch_xs})[10]
                    acc_log.append(self.sess.run(accuracy, feed_dict={self.x: testImages, y_: testLabels}) * 100)

                # if i % 1000 ==0:
                    # saver.save(self.sess, "/tmp/model.ckpt",global_step=i)#self.plotWeights(self.sess.run(W_fc2))
                    print i, self.sess.run(cross_entropy, feed_dict={self.x: batch_xs, y_: batch_ys}),
                    # print batch_ys[10],#, feed_dict={y_: batch_ys}),
                    # print self.sess.run(self.y, feed_dict={self.x: batch_xs})[10]
                    print self.sess.run(accuracy, feed_dict={self.x: testImages, y_: testLabels}) * 100
                self.sess.run(train_step, feed_dict={self.x: batch_xs, y_: batch_ys, keep_prob:0.5}) #calculate train_step using feed_dict
        
            print "--- %s seconds ---" % (time.time() - start_time)
            #print ce_log, acc_log
            fig = plt.figure(frameon=False,figsize=(15.0, 5.0))
            fig.add_subplot(121)
            plt.plot(ce_log)
            fig.add_subplot(122)
            plt.plot(acc_log)
            plt.show()

            print "%s%s" % (self.mldir,modelName)
            save_path = saver.save(self.sess, "%s%s" % (self.mldir,modelName))
        print 'true class labels: ', self.sess.run(tf.argmax(y_,1), 
                                                   feed_dict={self.x: testImages, y_: testLabels})
        print 'class estimates:   ', self.sess.run(tf.argmax(self.y,1), 
                                                   feed_dict={self.x: testImages, y_: testLabels}) #1st 25 printed
        #print self.sess.run(self.y, feed_dict={self.x: testImages, y_: testLabels})[:100]  # print the scores for each class
        ys_true = self.sess.run(tf.argmax(y_,1), feed_dict={self.x: testImages, y_: testLabels})
        ys_guess = self.sess.run(tf.argmax(self.y,1), feed_dict={self.x: testImages, y_: testLabels})
        print np.sum(self.sess.run(self.y, feed_dict={self.x: testImages, y_: testLabels}),axis=0)
        right = []
        for i,y in enumerate(ys_true):
            #print i, y, ys_guess[i] 
            if ys_guess[i] == y or ys_guess[i] == y-1 or ys_guess[i] == y+1:
                #print i, 'guessed right'
                right.append(i)

        print len(right), len(ys_true), float(len(right))/len(ys_true)

        score = self.sess.run(accuracy, feed_dict={self.x: testImages, y_: testLabels, keep_prob:1}) * 100
        print 'Accuracy of model in testing: ', score, '%'
        if score < 85: print 'Consider making more training images'

        del trainImages, trainLabels, testImages, testLabels

    def plotW_fc2(self, weights):
        s = np.shape(weights)
        print s
        fig2 = plt.figure(figsize=(8.0, 5.0))
        #for f in range(s[0]):
        for nc in range(self.nClass):
            fig2.add_subplot(2,2,nc+1)
            plt.plot(weights[:,nc])
            plt.title('class %i' % nc)
        plt.show()
        plt.close()

    # def plotWeights(self):
    #     '''creates a 2d map showing the positive and negative weights for each class'''
    #     weights = self.sess.run(self.W)
    #     weights = np.reshape(weights,(self.xWidth,self.xWidth,self.nClass))
    #     weights = np.flipud(weights)
    #     for nc in range(self.nClass):
    #         plt.imshow(weights[:,:, nc])
    #         plt.title('class %i' % nc)
    #         plt.show()
    #         plt.close()

    def plotActivations(self, layer, layername='lol', step=0):
        '''creates a 2d map showing the positive and negative weights for each class'''
        #weights = self.sess.run(self.W_fc2)
        #weights = np.reshape(weights,(math.sqrt(self.fc_filters),math.sqrt(self.fc_filters),self.nClass))
        #weights = np.flipud(weights)
        shape = np.shape(layer)
        print 'layer shape', shape
        
        fig2 = plt.figure(figsize=(8.0, 5.0))
        for nc in range(self.num_filt1):
            fig2.add_subplot(4,self.num_filt1/4,nc+1)
            plt.imshow(layer[:,0,:, nc]**2)#i*int(shape[0]/3)
            #fig2.title('class %i' % nc)
        #plt.savefig('actv_layer_%s_%i_s%i'%(layername,i,step))
        plt.show()
        #plt.close()



    def plotWeights(self, weights):
        '''creates a 2d map showing the positive and negative weights for each class'''
        import math
        #weights = self.sess.run(self.W_fc2)
        #weights = np.reshape(weights,(math.sqrt(self.fc_filters),math.sqrt(self.fc_filters),self.nClass))
        #weights = np.flipud(weights)
        print np.shape(weights)
        for nc in range(self.num_filt1):
            plt.subplot(2,self.num_filt1/2,nc+1)
            #plt.imshow(weights[:,0,:, nc])
            plt.plot(weights[0,:,0, nc])
            #plt.title('class %i' % nc)
        plt.show()
        plt.close()
    
    def checkLoopAtten(self, res_num, iAtten, showLoop=False, min_theta = 135, max_theta = 200, max_ratio_threshold = 1.5):
        '''function to check if the IQ loop at a certain attenuation is saturated. 3 checks are made.
        if the angle on either side of the sides connected to the longest edge is < min_theta or > max_theta
        the loop is saturated. Or if the ratio between the 1st and 2nd largest edge is > max_ratio_threshold.

        A True result means that the loop is unsaturated.

        Inputs:
        res_num: index of resonator in question
        iAtten: index of attenuation in question
        showLoop: pops up a window of the frame plotted using matplotlib.plot
        min/max_theta: limits outside of which the loop is considered saturated
        max_ratio_threshold: maximum largest/ 2nd largest IQ velocity allowed before loop is considered saturated

        Output:
        Boolean. True if unsaturated
        '''
        vindx = (-self.iq_vels[res_num,iAtten,:]).argsort()[:3]
        max_theta_vel  = math.atan2(self.Qs[res_num,iAtten,vindx[0]-1] - self.Qs[res_num,iAtten,vindx[0]], 
                                    self.Is[res_num,iAtten,vindx[0]-1] - self.Is[res_num,iAtten,vindx[0]])
        low_theta_vel = math.atan2(self.Qs[res_num,iAtten,vindx[0]-2] - self.Qs[res_num,iAtten,vindx[0]-1], 
                                   self.Is[res_num,iAtten,vindx[0]-2] - self.Is[res_num,iAtten,vindx[0]-1])
        upp_theta_vel = math.atan2(self.Qs[res_num,iAtten,vindx[0]] - self.Qs[res_num,iAtten,vindx[0]+1], 
                                   self.Is[res_num,iAtten,vindx[0]] - self.Is[res_num,iAtten,vindx[0]+1])

        theta1 = (math.pi + max_theta_vel - low_theta_vel)/math.pi * 180
        theta2 = (math.pi + upp_theta_vel - max_theta_vel)/math.pi * 180

        theta1 = abs(theta1)
        if theta1 > 360:
            theta1 = theta1-360
        theta2= abs(theta2)
        if theta2 > 360:
            theta2 = theta2-360

        max_ratio = self.iq_vels[res_num,iAtten,vindx[0]]/ self.iq_vels[res_num,iAtten,vindx[1]]
        
        if showLoop:
            plt.plot(self.Is[res_num,iAtten,:],self.Qs[res_num,iAtten,:])
            plt.show()
        

        # return True
        # return bool(max_ratio < max_ratio_threshold)
        # if max_ratio < max_ratio_threshold == True:
        #     return True
        # if (max_theta >theta1 > min_theta) * (max_theta > theta2 > min_theta) == True:
        #     return 'noisy'
        # else:
        #     return False

        # return [(max_theta >theta1 > min_theta)*(max_theta > theta2 > min_theta) , max_ratio < max_ratio_threshold]
        return bool((max_theta >theta1 > min_theta) * 
                    (max_theta > theta2 > min_theta) * 
                    (max_ratio < max_ratio_threshold))
        # if res_num==6:
        #     print res_num, max_ratio, self.iq_vels[res_num,iAtten,vindx[0]], self.iq_vels[res_num,iAtten,vindx[1]]
        #     plt.plot(self.Is[res_num,iAtten,:],self.Qs[res_num,iAtten,:])
        #     plt.show()


    def findAtten(self, inferenceFile, res_nums =20, searchAllRes=True, showFrames = True, usePSFit=True):
        '''The trained machine learning class (mlClass) finds the optimum attenuation for each resonator using peak shapes in IQ velocity

        Inputs
        inferenceFile: widesweep data file to be used
        searchAllRes: if only a few resonator attenuations need to be identified set to False
        res_nums: if searchAllRes is False, the number of resonators the atteunation value will be estimated for
        usePSFit: if true once all the resonator attenuations have been estimated these values are fed into PSFit which opens
                  the window where the user can manually check all the peaks have been found and make corrections if neccessary

        Outputs
        Goodfile: either immediately after the peaks have been located or through WideAna if useWideAna =True
        mlFile: temporary file read in to PSFit.py containing an attenuation estimate for each resonator
        '''

        try:
            self.sess
        except AttributeError:
            print 'You have to train the model first'
            exit()

        if self.scalexWidth!= 1:
            self.xWidth=self.xWidth*self.scalexWidth #reset ready for get_PS_data
        self.freqs, self.iq_vels, self.Is, self.Qs, self.attens = get_PS_data(h5File=inferenceFile, 
                                                                              searchAllRes=searchAllRes, 
                                                                              res_nums=res_nums)

        total_res_nums = np.shape(self.freqs)[0]
        if searchAllRes:
            res_nums = total_res_nums
        span = range(res_nums)

        self.inferenceLabels = np.zeros((res_nums,len(self.attens),self.nClass))
        print 'Using trained algorithm on images on each resonator'
        skip = []
        for i,rn in enumerate(span): 
            sys.stdout.write("\r%d of %i" % (i+1,res_nums) )
            sys.stdout.flush()
            noisy_res = 0
            for ia in range(len(self.attens)):                
                # first check the loop for saturation           
                nonsaturated_loop = self.checkLoopAtten(res_num=rn, iAtten= ia)
                # if nonsaturated_loop[0] == True:
                #     noisy_res += 1
                # nonsaturated_loop= bool(nonsaturated_loop[0]*nonsaturated_loop[1])
                if nonsaturated_loop:
                    # each image is formatted into a single element of a list so sess.run can receive a single values dictionary 
                    image = self.makeResImage(res_num = rn, iAtten= ia, phase_normalise=True,showFrames=False)
                    inferenceImage=[]
                    inferenceImage.append(image)            # inferenceImage is just reformatted image
                    self.inferenceLabels[rn,ia,:] = self.sess.run(self.y, feed_dict={self.x: inferenceImage} )
                    del inferenceImage
                    del image
                else:
                    self.inferenceLabels[rn,ia,:] = [1,0,0] # would just skip these if certain 

            if np.all(self.inferenceLabels[rn,:,1] ==0): # if all loops appear saturated for resonator then set attenuation to highest
                #best_guess = argmax(self.inferenceLabels[rn,:,1])
                #print best_guess
                best_guess = int(np.random.normal(len(self.attens)*2/5, 3, 1))
                if best_guess > len(self.attens): best_guess = len(self.attens)
                self.inferenceLabels[rn,best_guess,:] = [0,1,0]  # or omit from list

            # if noisy_res >= 15:#len(self.attens):
            #     self.inferenceLabels[rn,:] = [0,0,0]
            #     self.inferenceLabels[rn,5] = [0,1,0]
            #     skip.append(rn)

        print '\n'

        max_2nd_vels = np.zeros((res_nums,len(self.attens)))
        for r in range(res_nums):
            for iAtten in range(len(self.attens)):
                vindx = (-self.iq_vels[r,iAtten,:]).argsort()[:2]
                max_2nd_vels[r,iAtten] = self.iq_vels[r,iAtten,vindx[1]]

            # plt.plot(self.inferenceLabels[r,:,0], label='sat')
            # plt.plot(self.inferenceLabels[r,:,1], label='spot-on')
            # plt.plot(self.inferenceLabels[r,:,2], label='under')
            # plt.plot(max_2nd_vels[r,:]/max(max_2nd_vels[r,:]),label='2nd vel')
            # plt.legend()
            # plt.show()

        self.atten_guess=numpy.zeros((res_nums))
        # choose attenuation where there is the maximum in the 2nd highest IQ velocity
        for r in range(res_nums):
            class_guess = np.argmax(self.inferenceLabels[r,:,:], 1)
            if np.any(class_guess==1):
                #atten_guess[r] = np.where(class_guess==1)[0][argmax(max_2nd_vels[r,:][np.where(class_guess==1)[0]] )]
                self.atten_guess[r] = np.where(class_guess==1)[0][argmax(max_2nd_vels[r,:][np.where(class_guess==1)[0]] * self.inferenceLabels[r,:,1][np.where(class_guess==1)[0]] )]
            else:
                self.atten_guess[r] = argmax(self.inferenceLabels[r,:,1])        

    def loopTrain(self, showFrames =True, retrain=True):
        self.baseFile = ('.').join(initialFile.split('.')[:-1])
        self.PSFile = self.baseFile[:-16] + '.txt'
        print 'loading peak location data from %s' % self.PSFile
        self.res_nums = np.shape(self.freqs)[0]
        PSFile = np.loadtxt(self.PSFile, skiprows=1)#[:self.res_nums-20]
        opt_freqs = PSFile[:,0]
        opt_attens = PSFile[:,3]
        self.opt_iAttens = opt_attens -min(self.attens)

        print len(opt_freqs)
        all_freqs = np.around(self.freqs, decimals=-4)
        opt_freqs = np.around(opt_freqs, decimals=-4)
        good_res = np.arange(self.res_nums)

        a=0 # index to remove values from all_freqs
        b=0  # backtrack on g when good freqs can't be used
            # g index for the good freqs
        bad_opt_res = []

        for g in range(len(opt_freqs)-2):
            #print r, i, opt_freqs[r], round_freqs[i,:]# map(lambda x,y:x+y, a,b)
            while opt_freqs[g] not in all_freqs[a,:]:
                if opt_freqs[g] not in all_freqs[a:a+5,:]: # if in the next 5 rows of all_freqs then ignore good_freqs
                    #print 'ignoring frequency value from optimum file'
                    a -= 1 # cancels the index incrementing
                    b -= 1 # g is used to remove from good_res but g has incremented and i is stationary
                    bad_opt_res.append(g)
                    print g
                    break

                good_res = np.delete(good_res,g+b) # identify this value of all_freqs as bad by removing from list
                a += 1  # keep incrementing until opt_freqs matches good_freqs
                #print g,a,a-g, len(good_res), b # see how well the two data match
            a += 1 # as g increments so does a

        bad_opt_res.append(len(opt_freqs)-2)
        bad_opt_res.append(len(opt_freqs)-1)
        bad_opt_res.append(len(opt_freqs))

        print bad_opt_res

        self.opt_iAttens =np.delete(self.opt_iAttens,bad_opt_res)

        self.inferenceLabels = self.inferenceLabels[good_res]
        atten_guess = self.atten_guess[good_res]
        self.freqs = self.freqs[good_res]
        for i in range(40):
            print i, '\t', atten_guess[i], self.opt_iAttens[i]
        print len(atten_guess), len(self.opt_iAttens)

        correct_guesses = []
        wrong_guesses=[]
        within_5=np.zeros((len(atten_guess)))
        within_3=np.zeros((len(atten_guess)))
        within_1=np.zeros((len(atten_guess)))
        within_0=np.zeros((len(atten_guess)))
        for ig, ag in enumerate(atten_guess):
            if abs(atten_guess[ig]-self.opt_iAttens[ig]) <=5: within_5[ig] = 1
            if abs(atten_guess[ig]-self.opt_iAttens[ig]) <=3: within_3[ig] = 1
            if abs(atten_guess[ig]-self.opt_iAttens[ig]) <=1: within_1[ig] = 1
            if abs(atten_guess[ig]-self.opt_iAttens[ig]) ==0: 
                within_0[ig] = 1
                correct_guesses.append(ig)
            if abs(atten_guess[ig]-self.opt_iAttens[ig]) >0: 
                wrong_guesses.append(ig)
      
        print 'within 5', sum(within_5)/len(atten_guess)
        print 'within 3', sum(within_3)/len(atten_guess)
        print 'within 1', sum(within_1)/len(atten_guess)
        print 'within 0', sum(within_0)/len(atten_guess)


        #print correct_guesses
        # for i,wg in enumerate(wrong_guesses[:50]):
        #     print wg, atten_guess[wg], self.opt_iAttens[wg]

        # for i, wg in enumerate(wrong_guesses):
        #     print wg,good_res[wg],self.atten_guess[good_res[wg]], '\t', self.opt_iAttens[wg] 
        #     #fig = plt.figure(frameon=False,figsize=(10.0, 5.0))
            
        #     #fig.add_subplot(121)
        #     plt.plot(self.Is[good_res[wg],self.atten_guess[good_res[wg]],:],self.Qs[good_res[wg],self.atten_guess[good_res[wg]],:],label='guess')
            
        #     #fig.add_subplot(122)
        #     plt.plot(self.Is[good_res[wg],self.opt_iAttens[wg],:],self.Qs[good_res[wg],self.opt_iAttens[wg],:],label='true')
        #     #self.checkLoopAtten(good_res[wg],self.opt_iAttens[wg],showLoop=True)
        #     plt.legend()
        #     plt.show()

#def checkLoopAtten(self, res_num, iAtten, showLoop=False, min_theta = 135, max_theta = 200, max_ratio_threshold = 1.5):
        cs_5 = np.cumsum(within_5/len(atten_guess))
        cs_3 = np.cumsum(within_3/len(atten_guess))
        cs_1 = np.cumsum(within_1/len(atten_guess))
        cs_0 = np.cumsum(within_0/len(atten_guess))

        guesses_map = np.zeros((len(self.attens),len(self.attens)))
        for ia,ao in enumerate(self.opt_iAttens):
            ag = atten_guess[ia]
            guesses_map[ag,ao] += 1

        from matplotlib import cm
        plt.imshow(guesses_map,interpolation='none',cmap=cm.coolwarm)
        plt.xlabel('actual')
        plt.ylabel('estimate')

        plt.colorbar(cmap=cm.afmhot)
        plt.show()

        plt.plot(np.sum(guesses_map, axis=0))
        plt.plot(np.sum(guesses_map, axis=1))
        plt.show()

        showFrames=True
        if showFrames:
            plt.plot(np.arange(len(atten_guess))/float(len(atten_guess)), 'r--', label='max')
            plt.fill_between(range(len(cs_0)), cs_5, alpha=0.15, label='within 5')
            plt.fill_between(range(len(cs_0)), cs_3, alpha=0.15,label='within 3')
            plt.fill_between(range(len(cs_0)), cs_1, alpha=0.15,label='within 1')
            plt.fill_between(range(len(cs_0)), cs_0, alpha=0.15, facecolor='blue', label='within 0')
            plt.legend(loc="upper left")
            plt.show()

        if retrain:
            attDist = np.arange(-2,1,2)

            # for r,g in enumerate(wrong_guesses[:10]):
            #     for a,_ in enumerate(self.attens[:10]):
            #         print g[0], a, self.inferenceLabels[g[0],a,:], np.argmax(self.inferenceLabels[g[0],a,:], axis=0), g#doesn't work self.freqs[g[0], self.get_peak_idx(g[0], atten_guess[g[0]])]#, self.opt_iAttens[g[0]]

            self.opt_iAttens = self.opt_iAttens[wrong_guesses]

            self.res_nums = len(self.opt_iAttens)

            iAttens = np.zeros((self.res_nums,self.nClass))
            for i in range(self.nClass-1):
                iAttens[:,i] = self.opt_iAttens + attDist[i]        
            iAttens[:,2] = np.ones((self.res_nums))*len(self.attens)-1#self.opt_iAttens[:self.res_nums] + self.uAttDist
           
            print len(iAttens)
            lb_rej = np.where(iAttens[:,0]<0)[0]
            if len(lb_rej) != 0:
                iAttens = np.delete(iAttens,lb_rej,axis=0) # when index is below zero
                print len(iAttens)
                wrong_guesses = np.delete(wrong_guesses,lb_rej)
                self.res_nums = self.res_nums-len(lb_rej)
            
            ub_rej = np.where(iAttens[:,2]>len(self.attens))[0]
            if len(ub_rej) != 0:
                iAttens = np.delete(iAttens,ub_rej,axis=0) 
                print len(iAttens)
                wrong_guesses = np.delete(wrong_guesses,ub_rej)
                self.res_nums = self.res_nums-len(ub_rej)

            self.iq_vels=self.iq_vels[wrong_guesses]
            self.freqs=self.freqs[wrong_guesses]
            self.Is = self.Is[wrong_guesses]
            self.Qs = self.Qs[wrong_guesses]


            trainImages, trainLabels, testImages, testLabels = [], [], [], []

            # num_rotations = 3
            # angle = np.arange(0,2*math.pi,2*math.pi/num_rotations)
            train_ind = np.array(map(int,np.linspace(0,self.res_nums-1,self.res_nums*self.trainFrac)))
            print type(train_ind), len(train_ind)
            test_ind=[]
            np.array([test_ind.append(el) for el in range(self.res_nums) if el not in train_ind])
            print type(test_ind), len(test_ind)
            
            print train_ind[:10], test_ind[:10]

            for c in range(self.nClass):
                for rn in train_ind:#range(int(self.trainFrac*self.res_nums)):
                    image = self.makeResImage(res_num = rn, iAtten= iAttens[rn,c], phase_normalise=True, showFrames=False) 
                    if image!=None:
                        trainImages.append(image)
                        one_hot = np.zeros(self.nClass)
                        one_hot[c] = 1
                        trainLabels.append(one_hot)

            print self.res_nums

            for c in range(self.nClass):
                for rn in test_ind:#range(int(self.trainFrac*self.res_nums), int(self.trainFrac*self.res_nums + self.testFrac*self.res_nums)):
                    image = self.makeResImage(res_num = rn, iAtten= iAttens[rn,c], phase_normalise=True)
                    if image!=None:
                        testImages.append(image)
                        one_hot = np.zeros(self.nClass)
                        one_hot[c] = 1
                        testLabels.append(one_hot)

            # self.trainFile = ('.').join(self.trainFile.split('.')[:-1]) + '-retrain.pkl'
            retrainFile = ('.').join(self.trainFile.split('.')[:-1]) + '-retrain.pkl'
            if os.path.exists(self.trainFile):
                import shutil
                shutil.copy(self.trainFile,retrainFile)
            
            print self.trainFile

            append = None
            # if os.path.isfile(retrainFile): 
            #     append = raw_input('Do you want to append this training data to previous data %s [y/n]' % retrainFile)
            # if (append  == 'n'):
            #     retrainFile = retrainFile.split('-')[0]+time.strftime("-%Y-%m-%d-%H-%M-%S")
            # if (append  == 'y') or (os.path.isfile(self.trainFile)== False):
            print 'saving %s to %s' % (retrainFile, os.path.dirname(os.path.abspath(self.trainFile)) )
            with open(retrainFile, 'ab') as rtf:
                pickle.dump([trainImages, trainLabels], rtf)
                pickle.dump([testImages, testLabels], rtf)

            self.trainFile = retrainFile

            self.mlClass()
            self.findAtten(inferenceFile=inferenceFile, searchAllRes=True, usePSFit=True, showFrames=False, res_nums=50)
            self.i += 1
            if self.i<3:
                self.loopTrain(retrain=True)
            else:
                self.loopTrain(retrain=False)
    
    def save_data(self, usePSFit=False):
        # exit()
        atten_guess = self.atten_guess

        if usePSFit:
            # if skip != None:
            #     atten_guess = np.delete(atten_guess,skip)

            self.mlFile = ('.').join(inferenceFile.split('.')[:-1]) + '-ml.txt'
            if os.path.isfile(self.mlFile):
                self.mlFile = self.mlFile+time.strftime("-%Y-%m-%d-%H-%M-%S")
                #shutil.copy(self.mlFile, self.mlFile+time.strftime("-%Y-%m-%d-%H-%M-%S"))
            print 'wrote', self.mlFile
            mlf = open(self.mlFile,'wb') #mlf machine learning file is temporary
        
            for ag in atten_guess:
                line = "%12d\n" % ag
                mlf.write(line)
            mlf.close()
            #on ubuntu 14.04 and matplotlib-1.5.1 backend 'Qt4Agg' running matplotlib.show() prior to this causes segmentation fault
            #os.system("python PSFit.py 1")
            #os.remove(self.mlFile)

        else:
            baseFile = ('.').join(inferenceFile.split('.')[:-1])
            saveFile = baseFile[:-16] + '.txt'
            sf = open(saveFile,'wb')
            sf.write('1\t1\t1\t1 \n')
            for r in range(len(atten_guess)):#np.delete(range(len(atten_guess)),skip):
                line = "%10.9e\t0\t0\t%4i\n" % (self.freqs[r, self.get_peak_idx(r, atten_guess[r])], 
                                             self.attens[atten_guess[r]] )
                sf.write(line)
            sf.close()        
    
def next_batch(trainImages, trainLabels, batch_size):
    '''selects a random batch of batch_size from trainImages and trainLabels'''
    perm = random.sample(range(len(trainImages)), batch_size)
    trainImages = np.array(trainImages)[perm,:]
    trainLabels = np.array(trainLabels)[perm,:]
    return trainImages, trainLabels

def loadPkl(filename):
    '''load the train and test data to train and test mlClass

    pkl file hirerachy is as follows:
        -The file is split in two, one side for train data and one side for test data -These halfs are further divdided into image data and labels
        -makeTrainData creates image data of size: xWidth * xWidth * res_nums and the label data of size: res_nums
        -each time makeTrainData is run a new image cube and label array is created and appended to the old data

    so the final size of the file is (xWidth * xWidth * res_nums * "no of train runs") + (res_nums * "no of train runs") + [the equivalent test data structure]

    A more simple way would be to separate the train and test data after they were read but this did not occur to the 
    me before most of the code was written

    Input
    pkl filename to be read.

    Outputs
    image cube and label array
    '''
    file =[]
    with open(filename, 'rb') as f:
        while 1:
            try:
                file.append(pickle.load(f))
            except EOFError:
                break
    
    trainImages = file[0][0]
    trainLabels = file[0][1]
    testImages = file[1][0]
    testLabels = file[1][1]

    print np.shape(file)[0]/2 -1
    if np.shape(file)[0]/2 > 1:
        for i in range(1, np.shape(file)[0]/2):
            trainImages = np.append(trainImages, file[2*i][0], axis=0)
            trainLabels = np.append(trainLabels, file[2*i][1], axis=0)
            testImages = np.append(testImages, file[2*i+1][0], axis=0)
            testLabels = np.append(testLabels, file[2*i+1][1], axis=0)

    print np.shape(trainLabels)

    print "loaded dataset from ", filename
    return trainImages, trainLabels, testImages, testLabels

def get_PS_data(h5File=None, searchAllRes= True, res_nums=250):
    '''A function to read and write all resonator information so stop having to run the PSFit function on all resonators 
    if running the script more than once. This is used on both the initial and inference file

    Inputs:
    h5File: the power sweep h5 file for the information to be extracted from. Can be initialFile or inferenceFile
    '''
    baseFile = ('.').join(h5File.split('.')[:-1])
    PSPFile = baseFile[:-16] + '.pkl'
    if os.path.isfile(PSPFile):
        file = []
        with open(PSPFile, 'rb') as f:
            for v in range(5):
                file.append(pickle.load(f))
        
        if searchAllRes:
            res_nums = -1

        freqs = file[0][:res_nums]
        iq_vels = file[1][:res_nums]
        Is = file[2][:res_nums]
        Qs= file[3][:res_nums]
        attens = file[4]

    else:
        PSFit = PSFitting(initialFile=h5File)
        PSFit.loadps()
        tot_res_nums= len(PSFit.freq)
        if searchAllRes:
            res_nums = tot_res_nums

        res_size = np.shape(PSFit.loadres()['iq_vels'])

        freqs = np.zeros((res_nums, res_size[1]+1))
        iq_vels = np.zeros((res_nums, res_size[0], res_size[1]))
        Is = np.zeros((res_nums, res_size[0], res_size[1]+1))
        Qs = np.zeros((res_nums, res_size[0], res_size[1]+1))
        attens = np.zeros((res_size[0]))

        for r in range(res_nums):
            sys.stdout.write("\r%d of %i" % (r+1,res_nums) )
            sys.stdout.flush()
            res = PSFit.loadres()
            freqs[r,:] =res['freq']
            iq_vels[r,:,:] = res['iq_vels']
            Is[r,:,:] = res['Is']
            Qs[r,:,:] = res['Qs']
            attens[:] = res['attens']
            PSFit.resnum += 1

        with open(PSPFile, "wb") as f:
            pickle.dump(freqs, f)
            pickle.dump(iq_vels, f)
            pickle.dump(Is, f)
            pickle.dump(Qs, f)
            pickle.dump(attens, f)
                
    print 'len freqs', len(freqs)
    return  freqs, iq_vels, Is, Qs, attens

def main(initialFile=None, inferenceFile=None, res_nums=50):
    mlClass = mlClassification(initialFile=initialFile)
    
    # mlClass.makeTrainData()
    
    mlClass.mlClass()
    
    #mlClass.plotWeights()
    
    mlClass.findAtten(inferenceFile=inferenceFile, searchAllRes=True, showFrames=False, res_nums=50)  
    
    # if initialFile == inferenceFile:
    #     mlClass.i = 0
    mlClass.loopTrain()

    #mlClass.save_data(usePSFit=False)

if __name__ == "__main__":
    initialFile = None
    inferenceFile = None
    if len(sys.argv) > 2:
        initialFileName = sys.argv[1]
        inferenceFileName = sys.argv[2]
        mdd = os.environ['MKID_DATA_DIR']
        initialFile = os.path.join(mdd,initialFileName)
        inferenceFile = os.path.join(mdd,inferenceFileName)
    else:
        print "need to specify an initial and inference filename located in MKID_DATA_DIR"
        exit()
    main(initialFile=initialFile, inferenceFile=inferenceFile)

