''' 
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
        self.scalexWidth = 0.5
        self.oAttDist = -1 # rule of thumb attenuation steps to reach the overpowered peak
        #self.uAttDist = +2 # rule of thumb attenuation steps to reach the underpowed peak

        self.initialFile = initialFile
        self.baseFile = ('.').join(initialFile.split('.')[:-1])
        self.PSFile = self.baseFile[:-16] + '.txt'#os.environ['MKID_DATA_DIR']+'20160712/ps_FL1_1.txt' # power sweep fit, .txt 
        
        self.trainFile = 'ps_peaks_train_w%i_s%.2f.pkl' % (self.xWidth, self.scalexWidth) 
        self.trainFrac = 0.8
        self.testFrac=1 - self.trainFrac

    def makeWindowImage(self, res_num, iAtten, xCenter, showFrames=False, test_if_noisy=False):
        '''Using a given x coordinate a frame is created at that location of size xWidth x xWidth, and then flattened 
        into a 1d array. Called multiple times in each function.

        inputs 
        xCenter: center location of frame in wavelength space
        res_num: index of resonator in question
        iAtten: index of attenuation in question
        self.scalexWidth: typical values: 1/2, 1/4, 1/8
                          uses interpolation to put data from an xWidth x xWidth grid to a 
                          (xWidth/scalexWidth) x (xWidth/scalexWidth) grid. This allows the 
                          user to probe the spectrum using a smaller window while utilizing 
                          the higher resolution training data
        showFrames: pops up a window of the frame plotted using matplotlib.plot
        test_if_noisy: test spectrum by comparing heights of the outer quadrants to the center. A similar test to what 
                       the pattern recognition classification does
        '''     
        xWidth= self.xWidth 
        start = int(xCenter - xWidth/2)
        end = int(xCenter + xWidth/2)

        scalexWidth = self.scalexWidth

        # for spectra where the peak is close enough to the edge that some points falls across the bounadry, pad zeros
        if start < 0:
            start_diff = abs(start)
            start = 0
            iq_vels = self.iq_vels[res_num, iAtten, start:end]
            iq_vels = np.lib.pad(iq_vels, (start_diff,0), 'constant', constant_values=(0))
        elif end >= np.shape(self.freqs)[1]:
            iq_vels = self.iq_vels[res_num, iAtten, start:end]
            iq_vels = np.lib.pad(iq_vels, (0,end-np.shape(self.freqs)[1]+1), 'constant', constant_values=(0))
        else:
            iq_vels = self.iq_vels[res_num, iAtten, start:end]

        iq_vels = np.round(iq_vels * xWidth / max(self.iq_vels[res_num, iAtten, :]) )
    
        if showFrames:
            fig = plt.figure(frameon=False)
            fig.add_subplot(111)
            plt.plot( iq_vels)
            plt.ylim((0,xWidth))
            plt.show()
            plt.close()

        # interpolate iq_vels onto a finer grid
        if scalexWidth!=None:
            x = np.arange(0, xWidth+1)
            iq_vels = np.append(iq_vels, iq_vels[-1])
            f = interpolate.interp1d(x, iq_vels)
            xnew = np.arange(0, xWidth, scalexWidth)
            iq_vels = f(xnew)/ scalexWidth
            xWidth = int(xWidth/scalexWidth)

        if test_if_noisy:
            peak_iqv = mean(iq_vels[int(xWidth/4): int(3*xWidth/4)])
            nonpeak_indicies=np.delete(np.arange(xWidth),np.arange(int(xWidth/4),int(3*xWidth/4)))
            nonpeak_iqv = iq_vels[nonpeak_indicies]
            nonpeak_iqv = mean(nonpeak_iqv[np.where(nonpeak_iqv!=0)]) # since it spans a larger area
            noise_condition = 0.7 
            
            if (peak_iqv/nonpeak_iqv < noise_condition):
                return None 
        
        # populates 2d image with ones at location of iq_vel 
        image = np.zeros((xWidth, xWidth))
        for i in range(xWidth-1):
            if iq_vels[i]>=xWidth: iq_vels[i] = xWidth-1
            if iq_vels[i] < iq_vels[i+1]:
                image[int(iq_vels[i]):int(iq_vels[i+1]),i]=1
            else:
                image[int(iq_vels[i]):int(iq_vels[i-1]),i]=1
            if iq_vels[i] == iq_vels[i+1]:
                image[int(iq_vels[i]),i]=1        
        try:
            image[map(int,iq_vels), range(xWidth)]=1
        except IndexError:
            pass

        image = image.flatten()
        return image

    def get_peak_idx(self,res_num,iAtten):
        return argmax(self.iq_vels[res_num,iAtten,:])

    def makeTrainData(self):                
        '''creates images of each class with associated labels and saves to pkl file

        0: saturated peak, too much power
        1: goldilocks, not too narrow or short
        2: underpowered peak, too little power
        
        outputs
        train file.pkl. contains...
            trainImages: cube of size- xWidth * xWidth * xCenters*trainFrac
            trainLabels: 1d array of size- xCenters*trainFrac
            testImages: cube of size- xWidth * xWidth * xCenters*testFrac
            testLabels: 1d array of size- xCenters*testFrac
        '''

        self.freqs, self.iq_vels,self.Is,self.Qs, self.attens = get_PS_data(h5File=initialFile)
        self.res_nums = np.shape(self.freqs)[0]
        if os.path.isfile(self.PSFile):
            print 'loading peak location data from %s' % self.PSFile
            PSFile = np.loadtxt(self.PSFile, skiprows=1)[:self.res_nums]
            opt_freqs = PSFile[:,0]
            opt_attens = PSFile[:,3]
            self.opt_iAttens = opt_attens -40
        else: 
            print 'no PS.txt file found' 
            exit()
        
        good_res = np.arange(self.res_nums)
        i=0
        for r in range(len(opt_freqs)):
            if r+i < len(opt_freqs):
                cen_freq = self.freqs[r+i,self.get_peak_idx(r+i,self.opt_iAttens[r])]
                s=0
                while not np.isclose(cen_freq,opt_freqs[r],rtol=1e-03):
                    i += 1
                    self.res_nums -= 1
                    good_res = np.delete(good_res,r)
                    cen_freq = self.freqs[r+i,self.get_peak_idx(r+i,self.opt_iAttens[r])]
                    s+= 1
                    if s>5:
                        print "couldn't match frequencies after", r, "resonators"
                        break
            if s>5: break


        iAttens = np.zeros((self.res_nums,self.nClass))
        iAttens[:,0] = self.opt_iAttens[:self.res_nums] + self.oAttDist
        iAttens[:,1] = self.opt_iAttens[:self.res_nums]                    # goldilocks attenuation
        iAttens[:,2] = np.ones((self.res_nums))*20#self.opt_iAttens[:self.res_nums] + self.uAttDist

        lb_rej = np.where(iAttens[:,0]<0)[0]
        if len(lb_rej) != 0:
            iAttens = np.delete(iAttens,lb_rej,axis=0) # when index is below zero
            good_res = np.delete(good_res,lb_rej)
            self.res_nums = self.res_nums-len(lb_rej)
        
        ub_rej = np.where(iAttens[:,2]>len(self.attens))[0]
        if len(ub_rej) != 0:
            iAttens = np.delete(iAttens,ub_rej,axis=0) 
            good_res = np.delete(good_res,ub_rej)
            self.res_nums = self.res_nums-len(ub_rej)

        self.res_indicies = np.zeros((self.res_nums,self.nClass))
        for i, rn in enumerate(good_res):
            self.res_indicies[i,0] = self.get_peak_idx(rn,iAttens[i,0])
            self.res_indicies[i,1] = self.get_peak_idx(rn,iAttens[i,1])
            self.res_indicies[i,2] = self.get_peak_idx(rn,iAttens[i,2])

        self.iq_vels=self.iq_vels[good_res]
        self.freqs=self.freqs[good_res]
        self.Is = self.Is[good_res]
        self.Qs = self.Qs[good_res]

        trainImages, trainLabels, testImages, testLabels = [], [], [], []
        for c in range(self.nClass):
            for rn in range(int(self.trainFrac*self.res_nums) ):
                image = self.makeWindowImage(res_num = rn, iAtten= iAttens[rn,c], xCenter=self.res_indicies[rn,c])
                if image!=None:
                    trainImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[c] = 1
                    trainLabels.append(one_hot)

        # A more simple way would be to separate the train and test data after they were read but this did not occur to me 
        #before most of the code was written
        for c in range(self.nClass):
            for rn in range(int(self.trainFrac*self.res_nums), int(self.trainFrac*self.res_nums + self.testFrac*self.res_nums)) :
                image = self.makeWindowImage(res_num = rn, iAtten= iAttens[rn,c], xCenter=self.res_indicies[rn,c])
                if image!=None:
                    testImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[c] = 1
                    testLabels.append(one_hot)
        

        append = None
        if os.path.isfile(self.trainFile): 
            append = raw_input('Do you want to append this training data to previous data [y/n]')
        if (append  == 'y') or (os.path.isfile(self.trainFile)== False):
            print 'saving files %s & to %s' % (self.trainFile, os.path.dirname(os.path.abspath(self.trainFile)) )
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
        if not os.path.isfile(self.trainFile):
            self.makeTrainData()

        trainImages, trainLabels, testImages, testLabels = loadPkl(self.trainFile)

        print 'Number of training images:', np.shape(trainImages)[0], ' Number of test images:', np.shape(testImages)[0]
        
        if self.scalexWidth != None:
            self.xWidth = self.xWidth/self.scalexWidth
        if np.shape(trainImages)[1]!=self.xWidth**2:
            print 'Please make new training images of the correct size'
            exit()
        
        self.nClass = np.shape(trainLabels)[1]

        self.x = tf.placeholder(tf.float32, [None, self.xWidth**2]) # correspond to the images
        self.W = tf.Variable(tf.zeros([self.xWidth**2, self.nClass])) #the weights used to make predictions on classes
        self.b = tf.Variable(tf.zeros([self.nClass])) # the biases also used to make class predictions

        self.y = tf.nn.softmax(tf.matmul(self.x, self.W) + self.b) # class lables predictions made from x,W,b

        y_ = tf.placeholder(tf.float32, [None, self.nClass]) # true class lables identified by user 
        cross_entropy = -tf.reduce_sum(y_*tf.log(tf.clip_by_value(self.y,1e-10,1.0)) ) # find out how right you are by finding out how wrong you are

        train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy) # the best result is when the wrongness is minimal

        init = tf.initialize_all_variables()
        self.sess = tf.Session()
        self.sess.run(init) # need to do this everytime you want to access a tf variable (for example the true class labels calculation or plotweights)
        
        trainReps = 500
        batches = 100
        if np.shape(trainLabels)[0]< batches:
            batches = np.shape(trainLabels)[0]/2
        
        print 'Performing', trainReps, 'training repeats, using batches of', batches
        for i in range(trainReps):  #perform the training step using random batches of images and according labels
            batch_xs, batch_ys = next_batch(trainImages, trainLabels, batches) 
            self.sess.run(train_step, feed_dict={self.x: batch_xs, y_: batch_ys}) #calculate train_step using feed_dict
        
        print 'true class labels: ', self.sess.run(tf.argmax(y_,1), 
                                                   feed_dict={self.x: testImages, y_: testLabels})[:25]
        print 'class estimates:   ', self.sess.run(tf.argmax(self.y,1), 
                                                   feed_dict={self.x: testImages, y_: testLabels})[:25] #1st 25 printed
        #print self.sess.run(self.y, feed_dict={self.x: testImages, y_: testLabels})[:100]  # print the scores for each class
        
        correct_prediction = tf.equal(tf.argmax(self.y,1), tf.argmax(y_,1)) #which ones did it get right?
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        score = self.sess.run(accuracy, feed_dict={self.x: testImages, y_: testLabels}) * 100
        print 'Accuracy of model in testing: ', score, '%'
        if score < 95: print 'Consider making more training images'

        del trainImages, trainLabels, testImages, testLabels

    def plotWeights(self):
        '''creates a 2d map showing the positive and negative weights for each class'''
        weights = self.sess.run(self.W)
        weights = np.reshape(weights,(self.xWidth,self.xWidth,self.nClass))
        weights = np.flipud(weights)
        for nc in range(self.nClass):
            plt.imshow(weights[:,:, nc])
            plt.title('class %i' % nc)
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
        
        return bool((max_theta >theta1 > min_theta) * 
                    (max_theta > theta2 > min_theta) * 
                    (max_ratio < max_ratio_threshold))

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

        if self.scalexWidth!= None:
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
            for ia in range(len(self.attens)):                
                # first check the loop for saturation                
                nonsaturated_loop = self.checkLoopAtten(res_num=rn, iAtten= ia, showLoop=showFrames)
                if nonsaturated_loop:
                    # each image is formatted into a single element of a list so sess.run can receive a single values dictionary 
                    # argument and save memory
                    image = self.makeWindowImage(res_num = rn, iAtten= ia, 
                                                 xCenter=self.get_peak_idx(rn,ia), 
                                                 showFrames=showFrames)
                    inferenceImage=[]
                    inferenceImage.append(image)            # inferenceImage is just reformatted image
                    self.inferenceLabels[rn,ia,:] = self.sess.run(self.y, feed_dict={self.x: inferenceImage} )
                    del inferenceImage
                    del image
                else:
                    self.inferenceLabels[rn,ia,:] = [1,0,0] # would just skip these if certain 

            if np.all(self.inferenceLabels[rn,:,1] ==0): # if all loops appear saturated for resonator then set attenuation to highest
                self.inferenceLabels[rn,-1,:] = [0,1,0]  # or omit from list
                skip.append(rn)

        print '\n'

        max_2nd_vels = np.zeros((res_nums,len(self.attens)))
        for r in range(res_nums):
            for iAtten in range(len(self.attens)):
                vindx = (-self.iq_vels[r,iAtten,:]).argsort()[:2]
                max_2nd_vels[r,iAtten] = self.iq_vels[r,iAtten,vindx[1]]

        atten_guess=numpy.zeros((res_nums))
        # choose attenuation where there is the maximum in the 2nd highest IQ velocity
        for r in range(res_nums):
            class_guess = np.argmax(self.inferenceLabels[r,:,:], 1)
            if np.any(class_guess==1):
                atten_guess[r] = np.where(class_guess==1)[0][argmax(max_2nd_vels[r,:][np.where(class_guess==1)[0]] )]
            else:
                atten_guess[r] = argmax(self.inferenceLabels[r,:,1])        

        if usePSFit:
            if skip != None:
                atten_guess = np.delete(atten_guess,skip)

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
            os.system("python PSFit.py 1")
            #os.remove(self.mlFile)

        else:
            baseFile = ('.').join(inferenceFile.split('.')[:-1])
            saveFile = baseFile[:-16] + '.txt'
            sf = open(saveFile,'wb')
            #sf.write('1\t1\t1\t1 \n')
            for r in np.delete(range(len(atten_guess)),skip):
                line = "%10.9e \t %4i \n" % (self.freqs[r, self.get_peak_idx(r, atten_guess[r])], 
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

    if np.shape(file)[0]/2 > 1:
        for i in range(1, np.shape(file)[0]/2-1):
            trainImages = np.append(trainImages, file[2*i][0], axis=0)
            trainLabels = np.append(trainLabels, file[2*i][1], axis=0)
            testImages = np.append(testImages, file[2*i+1][0], axis=0)
            testLabels = np.append(testLabels, file[2*i+1][1], axis=0)

    print "loaded dataset from ", filename
    return trainImages, trainLabels, testImages, testLabels

def get_PS_data(h5File=None, searchAllRes= False, res_nums=50):
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
                
    return  freqs, iq_vels, Is, Qs, attens

def main(initialFile=None, inferenceFile=None, res_nums=50):
    mlClass = mlClassification(initialFile=initialFile)
    #mlClass.makeTrainData()

    mlClass.mlClass()
    mlClass.plotWeights()
    
    mlClass.findAtten(inferenceFile=inferenceFile, searchAllRes=False, usePSFit=False, showFrames=False, res_nums=50)  

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
