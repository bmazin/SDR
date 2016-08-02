''' 
Author Rupert Dodkins

A script to automate resonator locating normally performed by WideAna.py. 
This is accomplished using Google's Tensor Flow machine learning package which 
implements a pattern recognition algorithm on the spectrum. The code implements 
a 2D image classification algorithm similar to the MNIST test. This code creates
a 2D image from a 1D variable by populating a matrix of zeros with ones at the 
y location of each datapoint.

Usage:  python WideAna_ml.py 20160418/Asteria_FL1_100mK_ws.txt

Inputs:
20160418/Asteria_FL1_100mK_ws.txt: transmission sweep across intire feedline

Intermediaries:
SDR/Setup/WideSweep/train_w<x>_c<y>.pkl: images and corresponding labels used 
                                         to train the algorithm

Outputs: 
Asteria_FL1_100mK_ws-ml.txt:    to be used with WideAna.py (temporary)
Asteria_FL1_100mK_ws-good.txt:  to be used with autofit.py (made by WideAna.py)

How it works:
The script requires a series of images to train and test the algorithm with. If
they exist the image data will be loaded from a train pkl file

Alternatively, if the peak location data exist for the inference file the 
training data will be made. The classes are no peak (just noise), peak in center
or peak off to the side. If the spectra has collisions then there is a fifth class 
where the rightmost peak should be central and the colliding peak is left of center

These new image data will be saved as pkl files (or appened to existing pkl
files) and reloaded

The machine is then trained and its ability to predict the type of image is
validated

The weights used to make predictions for each class can be displayed using
the plotWeights function

A window the size of the training images scans across the inference
spectrum and the locations of peaks and collisions are identified and printed to
file. This can either be in the format read by autofit if the user believes all
the peaks have been found or loaded into WideAna.py and the remianing peaks can be
identified by hand
'''

from WideSweepFile import WideSweepFile
import WideAna as WideAna
import numpy as np
import sys, os, time, shutil
import matplotlib.pyplot as plt
import tensorflow as tf
import pickle
import random
from scipy import interpolate
np.set_printoptions(threshold=np.inf)

class mlClassification():
    def __init__(self, inferenceFile=None, nClass = 5, xWidth=40):        
        '''
        inputs
        inferenceFile: the spectrum the user wishes to locate resonators in. If no 
                    training pkl files exist this file is used to create training data
        nClass:     Can be either 4 or 5 depending on whether the window width is large 
                    enough. If the window width is small, enough examples of collisions 
                    are hard to come by in the training data and there wont be enough 
                    of this class to match other classes
        xWidth:     The window size to make training data and scan on the inference 
                    spectrum. ScalexWidth is an option later which allows the training data
                    with large widths to analyse small windows on the inference spectrum
        '''

        self.baseFile = ('.').join(inferenceFile.split('.')[:-1])
        self.goodFile = self.baseFile + '-good.txt'
        self.mlFile = self.baseFile + '-ml.txt'
        
        self.wsf = WideSweepFile(inferenceFile) # use WideSweepFile to get access to the data in inferenceFile
        self.wsf.fitFilter(wn=0.01)
        self.wsf.findPeaks()

        self.nClass = nClass # can be 4 (no collisions class)
        self.xWidth = xWidth # the width of each frame in number of samples

        self.trans = self.wsf.mag # transmission
        self.trainFile = 'train_w%i_c%i.pkl' % (self.xWidth, self.nClass) # a collection of images of xWidth and associated class labels
        rescaling_factor = 2  # rule of thumb adjustment to amplitudes of each frame so peaks take up more of the frame
        
        self.yLims=[min(self.trans), max(self.trans)]
        self.trainFrac = 0.8
        self.testFrac=1 - self.trainFrac
        
        self.trans_adjusted= self.trans-min(self.trans)      # stretches, normalises and scales the amplitudes to fit on a 0-40 grid
        self.trans_adjusted = np.round(self.trans_adjusted*rescaling_factor*self.xWidth/max(self.trans_adjusted) )

    def makeWindowImage(self, xCenter=25, markers=True, scalexWidth=None, showFrames=False):
        '''Using a given x coordinate a frame is created at that location of size xWidth x xWidth, and then flattened into a 1d array. 
        Called multiple times in each function.

        inputs 
        xCenter: center location of frame in wavelength space
        markers: lines to guide the eye when the frame is shown
        scalexWidth: typical values: 1/2, 1/4, 1/8
                     uses interpolation to put data from an xWidth x xWidth grid to a 
                     (xWidth/scalexWidth) x (xWidth/scalexWidth) grid. This allows the 
                     user to probe the spectrum using a smaller window while utilizing 
                     the higher resolution training data
        showFrames: pops up a window of the frame plotted using matplotlib.plot (used with training)
        '''     
        xWidth= self.xWidth # to save pulling from global memory all the time
        
        if scalexWidth==None:
            start = int(xCenter - xWidth/2)
            end = int(xCenter + xWidth/2)
        else:
            start = int(xCenter - xWidth*scalexWidth/2) #can use a smaller window for finer detail and then scale the image later to fit training data
            end = int(xCenter + xWidth*scalexWidth/2)
            if end-start != xWidth*scalexWidth:
                end=end+1

        trans = self.trans_adjusted[start:end]
        trans = map(int, np.array(trans) + (xWidth*4.5/5)-np.median(trans) ) # adjusts the height of the trans data to the median

        if scalexWidth!=None:
            x = np.arange(0, xWidth*scalexWidth+1)
            trans = np.append(trans, trans[-1])
            f = interpolate.interp1d(x, trans)
            xnew = np.arange(0, xWidth*scalexWidth, scalexWidth)
            trans = f(xnew)

        image = np.zeros((xWidth, xWidth))
        
        #creates an image of the spectrum 
        for i in range(xWidth-1):
            if trans[i]>=xWidth: trans[i] = xWidth-1
            if trans[i]<0: trans[i] = 0
            if trans[i] < trans[i+1]:
                image[int(trans[i]):int(trans[i+1]),i]=1
            else:
                image[int(trans[i]):int(trans[i-1]),i]=1
            if trans[i] == trans[i+1]:
                image[int(trans[i]),i]=1
        
        try:
            image[map(int,trans), range(xWidth)]=1
        except IndexError:
            pass

        
        if showFrames:
            fig = plt.figure(frameon=False)
            fig.add_subplot(111)
            plt.plot(self.wsf.x[start:end], self.trans[start:end])
            
            if markers:
                plt.axvline(self.wsf.x[(end-start)/4 + start], ls='dashed')
                plt.axvline(self.wsf.x[end - (end-start)/4], ls='dashed')

            self.yLims=[min(self.trans), max(self.trans)]
        
            plt.ylim((self.yLims[0],self.yLims[1]))
            plt.xlim((self.wsf.x[start],self.wsf.x[end]))
            #plt.axis('off')

            plt.show()
            plt.close()

        image = image.flatten()
        return image

    def makeTrainData(self, trainSteps=500):
        '''creates images of each class with associated labels and saves to pkl file

        0: no peak, just flat
        1: the center of the peak is 1/3 of the way to the left of center
        2: the center of the peak is center of the frame
        3: like 1 but to the right
        4: the center of the middle peak is in the middle of the frame and there is another peak somewhere to the left of that one
        s: this image does not belong in the training dataset

        inputs
        trainSteps: how many total image does the user want to validate. testFrac adjusts what percentage are for testing

        outputs
        trainImages: cube of size- xWidth * xWidth * xCenters*trainFrac
        trainLabels: 1d array of size- xCenters*trainFrac
        testImages: cube of size- xWidth * xWidth * xCenters*testFrac
        testLabels: 1d array of size- xCenters*testFrac
        '''
            
        self.yLims=[min(self.trans), max(self.trans)]

        trainImages, trainLabels, testImages, testLabels = [], [], [], []
        
        print self.goodFile
        if os.path.isfile(self.goodFile):
            print 'loading peak location data from %s' % self.goodFile
            peaks = np.loadtxt(self.goodFile)[:,1]


        else:
            print 'using WideSweepFile.py to predict where the peaks are'
            peaks = self.wsf.peaksDict['big']

        peakDist = abs(np.roll(peaks, 1) - peaks)

        colls_thresh = self.xWidth/2    # two peaks in one frame
        colls = peaks[np.where( peakDist < colls_thresh)[0]]#9
       
        random.shuffle(colls)
        # to stop multiple peaks appearing in training data of classes 1-4
        peaks = peaks[np.where( peakDist >= self.xWidth)[0]]
        peakDist = abs(np.roll(peaks, 1) - peaks) 
        class_steps = trainSteps/self.nClass
        
        if len(colls) < class_steps or self.nClass == 4:
            print 'no 5th class or not enough collisions detected within the frame width to create one'
            #colls_class = raw_input('Do you want to create one? [y/n]')
            #if colls_class=='n':
            colls=[]
            self.nClass=4
            self.trainFile = 'train_w%i_c%i.pkl' % (self.xWidth, self.nClass)
            #colls = peaks # same criteria as centrals

        noise = range(len(self.wsf.x)) # noise locations are randomly selected across array. Hopefully peaks 
                                       # can be located this way (and labeled as other classes) to remove any 
                                       # biases from widesweepfile peaks 
        lefts = peaks+self.xWidth/3
        centrals = peaks
        rights = peaks-self.xWidth/3
        if os.path.isfile(self.goodFile):
            noise= peaks[np.where( peakDist > self.xWidth*2)[0]]-self.xWidth # no need for random searches 
            


            xCenters = np.zeros((class_steps,self.nClass))
            xCenters[:,0]=random.sample(noise, class_steps)
            xCenters[:,1]=random.sample(lefts, class_steps)
            xCenters[:,2]=random.sample(centrals, class_steps)
            xCenters[:,3]=random.sample(rights, class_steps)
            if self.nClass==5:
                xCenters[:,4]=random.sample(noise, class_steps)

            for i in range(self.nClass):
                for j in range(int(self.trainFrac*class_steps) ):
                    image = self.makeWindowImage(xCenter=xCenters[j,i], showFrames=False)
                    trainImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[i] = 1
                    trainLabels.append(one_hot)
            # A more simple way would be to separate the train and test data after they were read but this did not occur to me 
            #before most of the code was written
            for i in range(self.nClass):
                for j in range(int(self.trainFrac*class_steps), int(self.trainFrac*class_steps + self.testFrac*class_steps)) :
                    image = self.makeWindowImage(xCenter=xCenters[j,i], showFrames=False)
                    testImages.append(image)
                    one_hot = np.zeros(self.nClass)
                    one_hot[i] = 1
                    testLabels.append(one_hot)

        else:
            print 'No resonator location file found for this spectrum'

        append = None
        if os.path.isfile(self.trainFile): 
            append = raw_input('Do you want to append this training data to previous data [y/n]')
        if (append  == 'y') or (os.path.isfile(self.trainFile)== False):
            print 'saving files %s & to %s' % (self.trainFile, os.path.dirname(os.path.abspath(self.trainFile)) )
            with open(self.trainFile, 'ab') as tf:
                pickle.dump([trainImages, trainLabels], tf)
                pickle.dump([testImages, testLabels], tf)

        return trainImages, trainLabels, testImages, testLabels

    def mlClass(self):
        '''
        Code adapted from the tensor flow MNIST tutorial 1.
        
        Using training images and labels the machine learning class (mlClass) "learns" how to identify peaks. Using similar data the ability 
        of mlClass to identify peaks is tested

        The training and test matricies are loaded from file (those made earlier if chosen to not be appended to file will not be used)
        '''
        
        if os.path.isfile(self.trainFile):
            trainImages, trainLabels, testImages, testLabels = loadPkl(self.trainFile)

        else:
            trainImages, trainLabels, testImages, testLabels = self.makeTrainData()

        print 'Number of training images:', np.shape(trainImages)[0], ' Number of test images:', np.shape(testImages)[0]

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
        

        print 'true class labels: ', self.sess.run(tf.argmax(y_,1), feed_dict={self.x: testImages, y_: testLabels})[:25] #argmax finds the index with the max label value
        print 'class estimates:   ', self.sess.run(tf.argmax(self.y,1), feed_dict={self.x: testImages, y_: testLabels})[:25] #1st 25 printed
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

    def findPeaks(self, inferenceFile, scalexWidth=None, steps =50, start=0, searchWholeSpec=False, useWideAna=True, multi_widths=False):
        '''The trained machine learning class (mlClass) finds peaks in the inferenceFile spectrum

        inputs
        inferenceFile: widesweep data file to be used
        scalexWidth: allows a smaller/finer window to search spectrum without loss of resolution that comes with smaller window sizes
                     this variable, if set to a number, will act as a multiplication factor for self.xWidth e.g: 0.5 or 0.25
                     adds to computation time (maybe 4x longer for 0.25)
        searchWholeSpec: if only a few peaks need to be identified set to False
        steps: if searchWhileSpec is False, the number of frames (numer of center values in centers)
        start: if searchWhileSpec is False, the starting point of the frames (first center value in centers)
        useWideAna: if true once all the peaks have been located these values are fed into WideAna which opens
        the window where the user can manually check all the peaks have been found and make corrections if neccessary

        outputs
        Goodfile: either immediately after the peaks have been located or through WideAna if useWideAna =True
        mlFile:   temporary file read in to WideAna.py containing peak indicies
        
        *had some issues running WideAna at the end of this script on ubuntu 14.04 and matplotlib-1.5.1 backend 'Qt4Agg' 
        after running matplotlib.show(). Sometimes I received a segmentation fault
        '''
        try:
            self.sess
        except AttributeError:
            print 'You have to train the model first'
            exit()

        self.inferenceFile = inferenceFile

        self.wsf = WideSweepFile(inferenceFile)
        self.wsf.fitFilter(wn=0.01)
        self.wsf.findPeaks()

        #the center of each frame. xWidth wide, translated xWidth/20 from the previous
        if scalexWidth != None:
            xMove = float(self.xWidth*scalexWidth)/40 #1
            centers = np.arange(self.xWidth*scalexWidth/2,len(self.wsf.x)-self.xWidth*scalexWidth/2, xMove ) 
        else:
            xMove = float(self.xWidth)/40 #1
            centers = np.arange(self.xWidth/2,len(self.wsf.x)-self.xWidth/2, xMove ) 

        centers = [int(c) for c in centers]

        print len(self.wsf.x)

        if searchWholeSpec:
            steps = len(centers)
            start=0
        span = range(start, steps+start)

        self.inferenceLabels = np.ones((steps,self.nClass))

        print 'Using trained algorithm on images across the inference spectrum'
        for i,c in enumerate(span): 
            inferenceImage=[]
            # print how many frames remain to be studied inline
            sys.stdout.write("\r%d of %i" % (i+1,steps) )
            sys.stdout.flush()

            # each image is formatted into a single element of a list so sess.run can receive a single values dictionary argument
            # and save memory
            image = self.makeWindowImage(xCenter=centers[c], scalexWidth=scalexWidth, showFrames=False)
            # inferenceImage is just reformatted image
            inferenceImage.append(image)
            self.inferenceLabels[i,:] = self.sess.run(self.y, feed_dict={self.x: inferenceImage} )
            
            del inferenceImage
            del image
        
        print '\n'
        stdLabels = np.argmax(self.inferenceLabels, 1)
        
        scores = np.zeros((len(stdLabels)))
        # peaks is an array of positive peak identification locations
        peaks = np.where(np.logical_or(stdLabels ==2, stdLabels ==4) )
    
        # turn peaks into a list of lists of adjacent peak locations
        peaks = np.split(peaks[0], np.where(np.diff(peaks[0]) >= 5)[0]+1)
    
        #peakLocations takes the middle value of adjacent positive peak identifications in peaks
        peakLocations=[]
        if len(peaks[0]) == 0:
            print 'No peaks found in search range'
            peakLocations = None
        else:
            for p in peaks:
                if len(p)>3:
                    p = np.array(p)
                    centers = np.array(centers)
                    min_location = np.argmin(self.wsf.mag[centers[p]])
                    middle = (p[0]+p[len(p)-1]) /2                    
                    peakLocations.append(p[min_location])

        centers = np.array(centers)

        peak_dist = abs(np.roll(centers[peakLocations], -1) - centers[peakLocations])

        diff, coll_thresh = 0, 0
        while diff <= 5e-4:
            diff = self.wsf.x[coll_thresh]-self.wsf.x[0]
            coll_thresh += 1


        #remove collisions (peaks < 0.5MHz apart). This is also done in WideAna.py
        if useWideAna:
            collisions = np.delete(peakLocations,np.where(peak_dist>=coll_thresh))       

        else:
            #peakLocations = np.delete(peakLocations,np.where(dist<50))               
            collisions = []
            for i in range(len(peakLocations)):
                if peak_dist[i]<coll_thresh:
                    if self.wsf.mag[centers[peakLocations[i+1]]] - self.wsf.mag[centers[peakLocations[i]]] > 1.5:
                        collisions.append(centers[peakLocations[i+1]])
                    else:
                        collisions.append(centers[peakLocations[i]])

            peakLocations = np.delete(peakLocations,collisions)

            if not multi_widths:
                plt.plot(centers[start:start+steps], self.wsf.mag[centers[start:start+steps]])#- self.wsf.baseline[centers[start:start+steps]]) self.wsf.x[centers...]
                if peakLocations != []:
                    for pl in peakLocations:
                        plt.axvline(centers[pl+start], color='r')
                    for c in collisions:
                        plt.axvline(centers[c+start], color='g')
                plt.show()
                plt.close()
            

        print 'Number of resonators located:', len(peakLocations)
        print 'Number of collisions', len(collisions)

        # append the peak locations from each window width to this global variable
        if multi_widths:
            global mw_peakLocations 
            mw_peakLocations= np.concatenate((mw_peakLocations,centers[map(lambda x: x+start, peakLocations)]))

            #remove collisions during each successive run to avoid a build up identifications at near collisions
            mw_peakLocations = np.sort(mw_peakLocations)
            mw_peakLocations = map(int,mw_peakLocations)
            peak_dist = abs(np.roll(mw_peakLocations, -1) - mw_peakLocations)
            collisions = []
            for i in range(len(mw_peakLocations)-1):
                if peak_dist[i]<=3:
                    if self.wsf.mag[mw_peakLocations[i]] <= self.wsf.mag[mw_peakLocations[i+1]]:
                        collisions.append(i)
                    else:
                        collisions.append(i+1)

            #mw_peakLocations = np.delete(mw_peakLocations,np.where(peak_dist<3))
            mw_peakLocations = np.delete(mw_peakLocations,collisions)

        if useWideAna:
            # if file exists rename it with the current time
            if os.path.isfile(self.mlFile):
                self.mlFile = self.mlFile+time.strftime("-%Y-%m-%d-%H-%M-%S")
                #shutil.copy(self.mlFile, self.mlFile+time.strftime("-%Y-%m-%d-%H-%M-%S"))
            mlf = open(self.mlFile,'wb') #mlf machine learning file is temporary
            if peakLocations != []:
                if multi_widths:
                    peakLocations =mw_peakLocations
                    peakLocations = np.sort(peakLocations)
                    for pl in peakLocations:
                        line = "%12d\n" % pl# just peak locations
                        mlf.write(line)
                else:    
                    for pl in peakLocations:
                        line = "%12d\n" % centers[pl+start] # just peak locations
                        mlf.write(line)
                mlf.close()
            #on ubuntu 14.04 and matplotlib-1.5.1 backend 'Qt4Agg' running matplotlib.show() prior to this causes segmentation fault
            WideAna.main(initialFile=self.inferenceFile)
            os.remove(self.mlFile)
        
        else:
            gf = open(self.goodFile,'wb')
            id = 0
            if peakLocations != []:
                for pl in peakLocations:
                    line = "%8d %12d %16.7f\n"%(id,centers[pl]+start,self.wsf.x[centers[pl]])
                    gf.write(line)
                    id += 1
                gf.close()
        
def next_batch(trainImages, trainLabels, batch_size):
    '''selects a random batch of batch_size from trainImages and trainLabels'''
    perm = random.sample(range(len(trainImages)), batch_size)
    trainImages = np.array(trainImages)[perm,:]
    trainLabels = np.array(trainLabels)[perm,:]
    return trainImages, trainLabels

def loadPkl(filename):
    '''load the train and test data to train and test mlClass

    pkl file hirerachy is as follows:
        -The file is split in two, one side for train data and one side for test data 
        -These halfs are further divdided into image data and labels
        -makeTrainData creates image data of size: xWidth * xWidth * xCenters and the label data of size: xCenters
        -each time makeTrainData is run a new image cube and label array is created and appended to the old data

    so the final size of the file is (xWidth * xWidth * res_nums * "no of train runs") + (res_nums * "no of train runs") + 
    [the equivalent test data structure]

    A more simple way would be to separate the train and test data after they were read but this did not occur to the 
    author before most of the code was written

    input
    pkl filename to be read. Can be either train or test data

    outputs
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

def main(inferenceFile=None, xWidth=80, nClass=4, scalexWidth=1./2, useWideAna =True, multi_widths=False):
    mlClass = mlClassification(inferenceFile=inferenceFile, xWidth=xWidth, nClass=nClass)
    #mlClass.makeTrainData(trainSteps =100)

    mlClass.mlClass()
    #mlClass.plotWeights()
    mlClass.findPeaks(inferenceFile, scalexWidth=scalexWidth, searchWholeSpec=True, useWideAna=useWideAna, multi_widths=multi_widths)# 35200

def multi_widths(xWidths = [80,80,80], nClasses=[4,4,4], scalexWidths = [None,1./2,1./4]):
    '''Runs the main functions multiple times with different window sizes to catch peaks of various 
    Q factors. This is especially useful if there is a large variation in Q throughout spectrum'''
    global mw_peakLocations 
    mw_peakLocations= np.array([])

    for mw in range(len(xWidths)):
        print 'Searching for peaks using a model with xWidth=%s, xWidth interpolation scaling=%s, and %s peak classes' % (xWidths[mw],scalexWidths[mw],nClasses[mw])
        if mw == len(xWidths)-1:
            useWideAna = True
        else: 
            useWideAna = False
        main(inferenceFile=inferenceFile, xWidth = xWidths[mw], nClass = nClasses[mw], scalexWidth=scalexWidths[mw], useWideAna= useWideAna, multi_widths=True)

if __name__ == "__main__":
    inferenceFile= None
    if len(sys.argv) > 1:
        mdd = os.environ['MKID_DATA_DIR']
        inferenceFile = os.path.join(mdd,sys.argv[1])
    else:
        print "need to specify a filename located in MKID_DATA_DIR"
        exit()
    
    #main(inferenceFile=inferenceFile)
    multi_widths()