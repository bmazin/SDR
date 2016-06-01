''' A replacement for WideAna.py which uses tensor flow to identify the
positions of peaks using an image classification algorithm.


Usage:  python WideAna_ml.py test/Asteria_FL1_100mK_ws.txt


The script requires a series of images to train and test the algorithm with. If
it exists the image data will be loaded from a pkl file

Alternatively, using the peak location data from either previous WideAna.py
click-throughs (if available) or from WideSweepFile.py, images can be made which
need to be confirmed manually as one of a series of classes by the user. Either
no peak (just noise), peak in center or peak off to the side. If the spectra has
collisions then there is a fifth class where the rightmost peak should be
central and the colliding peak is left of center

These new image data will be saved as pkl files (or appened to existing pkl
files) and reloaded

The machine is then trained and its ability to predict the type of image is
validated

The weights applied to each class and used to make predictions can be displayed
using the plotWeights function

A window the size of the training/testing images scans across the inference
spectrum and the locations of peaks and collisions are identified


Smaller window widths are better for spectra with many collisions but bad for
those with low average Qi When subtracting the baseline be the spectra does not
have overdriven asymetric resonators as this can make the wings of resonators
look like peaks

Rupert Dodkins

to do: gui '''

from WideSweepFile import WideSweepFile
import numpy as np
import sys, os
import matplotlib.pyplot as plt
import tensorflow as tf
import pickle
import random
import time

#from PyQt4 import QtGui
#from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
#from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
#from matplotlib.backends.backend_qt4agg import NavigationToolbar2QT as NavigationToolbar

class mlClassification():
    def __init__(self, inferenceFile=None, base_corr=False):
        self.nClasses = 5
        
        self.baseFile = ('.').join(inferenceFile.split('.')[:-1])
        self.goodFile = self.baseFile + '-good.txt'
        
        self.wsf = WideSweepFile(inferenceFile)
        self.wsf.fitFilter(wn=0.01)
        self.wsf.findPeaks()

        self.xWidth =150
        if base_corr:
            self.trans = self.wsf.mag - self.wsf.baseline
            self.trainFile = 'train_w%i_c%i_bc.pkl' % (self.xWidth, self.nClasses)
            self.testFile = 'test_w%i_c%i_bc.pkl' % (self.xWidth, self.nClasses)
            rescaling_factor = 1.5
        else:
            self.trans = self.wsf.mag
            self.trainFile = 'train_w%i_c%i.pkl' % (self.xWidth, self.nClasses)
            self.testFile = 'test_w%i_c%i.pkl' % (self.xWidth, self.nClasses)
            rescaling_factor = 3.5
        
        self.yLims=[min(self.trans), max(self.trans)]
        self.trainFrac = 0.8
        self.testFrac=1 - self.trainFrac
        
        self.trans_adjusted= self.trans-min(self.trans)
        self.trans_adjusted = np.round(self.trans_adjusted*rescaling_factor*self.xWidth/max(self.trans_adjusted) )

    def makePeakImage(self, xCenter=25, markers=True, showFrames=False, saveFrame=False, showArray=False):
        
        start = int(xCenter - self.xWidth/2)
        end = int(xCenter + self.xWidth/2)
        
        trans = self.trans_adjusted[start:end]#-sum(self.baseline_adjusted[start:end]/self.xWidth))
        trans = map(int, np.array(trans) + (self.xWidth*4.5/5)-np.median(trans) )

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

            if saveFrame:
                plt.savefig('/home/rupert/Documents/ARCONS_data/%i.png' % xCenter)

            plt.show()
            plt.close()
        
        image = np.zeros((self.xWidth, self.xWidth))
        for i in range(self.xWidth-1):
            if trans[i] < trans[i+1]:
                image[trans[i]:trans[i+1],i]=1
            else:
                image[trans[i]:trans[i-1],i]=1

        try:
            image[map(int,trans), range(self.xWidth)]=1
        except IndexError:
            pass

        if showArray:
            plt.imshow(image)
            plt.show()

        image = image.flatten()
        return image
        

    def makeTrainData(self, trainSteps=20, saveFile=True):
        self.yLims=[min(self.trans), max(self.trans)]

        trainImages, trainLabels, testImages, testLabels = [], [], [], []
        
        if os.path.isfile(self.goodFile):
            print 'loading peak location data from %s' % self.goodFile
            peaks = np.loadtxt(self.goodFile)[:,1]

        else:
            print 'using WideSweepFile.py to predict where the peaks are'
            peaks = self.wsf.peaksDict['big']

        peakVel = abs(np.roll(peaks, 1) - peaks)

        if self.xWidth <= 140: 
            colls_thresh = self.xWidth/2    # two peaks in one frame
        else: 
            colls_thresh= 70                # true collision threshold
        print colls_thresh
        colls = peaks[np.where( peakVel < colls_thresh)[0]]#7
       
        random.shuffle(colls)
        print colls
        print len(peaks)
        # to stop multiple peaks appearing in training data
        peaks = peaks[np.where( peakVel >= self.xWidth)[0]] 
        print len(peaks)
        class_steps = trainSteps/self.nClasses
        
        # not enough frequency collisions to bother training the model to recognise them
        if len(colls) < class_steps or self.nClasses == 4:
            colls=[]
            self.nClasses=4

        noise = range(len(self.wsf.x))
        lefts = peaks+self.xWidth/3
        centrals = peaks
        rights = peaks-self.xWidth/3

        noise_trainImages, noise_trainLabels, noise_testImages, noise_testLabels = \
            self.makeImageDataset(xCenter=random.sample(noise, class_steps) , showFrames=True, showHelp=True)
        left_trainImages, left_trainLabels, left_testImages, left_testLabels = \
            self.makeImageDataset(xCenter=random.sample(lefts,class_steps) , showFrames=True)
        peak_trainImages, peak_trainLabels, peak_testImages, peak_testLabels = \
            self.makeImageDataset(xCenter=random.sample(peaks,class_steps) , showFrames=True)
        right_trainImages, right_trainLabels, right_testImages, right_testLabels = \
            self.makeImageDataset(xCenter=random.sample(rights,class_steps) , showFrames=True)
        
        trainImages = noise_trainImages + left_trainImages + peak_trainImages+ right_trainImages
        trainLabels = noise_trainLabels + left_trainLabels + peak_trainLabels + right_trainLabels 
        testImages =  noise_testImages + left_testImages + peak_testImages + right_testImages 
        testLabels = noise_testLabels + left_testLabels + peak_testLabels + right_testLabels 

        if len(colls) > 0:
            coll_trainImages, coll_trainLabels, coll_testImages, coll_testLabels = \
                self.makeImageDataset(xCenter=random.sample(colls,class_steps) , showFrames=True)
            trainImages = trainImages  + coll_trainImages
            trainLabels = trainLabels + coll_trainLabels
            testImages = testImages + coll_testImages
            testLabels = testLabels + coll_testLabels

        # ensure there are equal amounts of each class in the training data
        lengths = np.array(trainLabels, dtype=int).sum(axis=0)
        uniform = np.ones((self.nClasses))*int((class_steps)*self.trainFrac)
        while (lengths!=uniform).any():
            self.trainFrac = 1
            self.testFrac = 0

            diff = np.ones((self.nClasses), dtype=int)*max(lengths) - lengths
            print diff, 'images required to make equal'
            if diff[0]!=0: 
                noise_trainImages, noise_trainLabels, noise_testImages, noise_testLabels = \
                    self.makeImageDataset(xCenter=random.sample(noise,diff[0]) , showFrames=True)
                if noise_trainLabels != []:
                    trainImages = np.append(trainImages, noise_trainImages, axis=0)
                    trainLabels = np.append(trainLabels, noise_trainLabels, axis=0)

            if diff[1]!=0: 
                left_trainImages, left_trainLabels, left_testImages, left_testLabels = \
                    self.makeImageDataset(xCenter=random.sample(lefts,diff[1]) , showFrames=True)
                if left_trainLabels != []:
                    trainImages = np.append(trainImages, left_trainImages, axis=0)
                    trainLabels = np.append(trainLabels, left_trainLabels, axis=0)

            if diff[2]!=0: 
                peak_trainImages, peak_trainLabels, peak_testImages, peak_testLabels = \
                    self.makeImageDataset(xCenter=random.sample(centrals, diff[2]) , showFrames=True)
                if peak_trainLabels != []:
                    trainImages = np.append(trainImages, peak_trainImages, axis=0)
                    trainLabels = np.append(trainLabels, peak_trainLabels, axis=0)

            if diff[3]!=0: 
                right_trainImages, right_trainLabels, right_testImages, right_testLabels = \
                    self.makeImageDataset(xCenter=random.sample(rights,diff[3]) , showFrames=True)
                if right_trainLabels != []:
                    trainImages = np.append(trainImages, right_trainImages, axis=0)
                    trainLabels = np.append(trainLabels, right_trainLabels, axis=0)

            if len(colls) > 0:
                if diff[4]!=0: 
                    coll_trainImages, coll_trainLabels, coll_testImages, coll_testLabels = \
                        self.makeImageDataset(xCenter=random.sample(colls,diff[4]) , showFrames=True)
                    if coll_trainLabels != []:
                        trainImages = np.append(trainImages, coll_trainImages, axis=0)
                        trainLabels = np.append(trainLabels, coll_trainLabels, axis=0)

            lengths = np.array(trainLabels, dtype=int).sum(axis=0)
            uniform = np.ones((self.nClasses), dtype=int)*max(lengths)

        if saveFile:
            append = None
            if os.path.isfile(self.trainFile): 
                append = raw_input('Do you want to append this training data to previous data [y/n]')
            if (append  == 'y') or (os.path.isfile(self.trainFile)== False):
                print 'saving files %s & %s to %s' % (self.trainFile, self.testFile, os.path.dirname(os.path.abspath(self.testFile)) )
                pickle.dump([trainImages, trainLabels], open(self.trainFile, 'ab'))
                pickle.dump([testImages, testLabels], open(self.testFile, 'ab'))#f=open(self.trainFile,'ab')

        return trainImages, trainLabels, testImages, testLabels

    def makeImageDataset(self, xCenter, showFrames, showHelp=False):
        trainImages, trainLabels, testImages, testLabels = [], [], [], []
        if showHelp:
            print "0: noise, 1: left, 2: central, 3: right, 4: collision. s: skip"
        for i in range(int(self.trainFrac*len(xCenter)) ):
            image = self.makePeakImage(xCenter=xCenter[i], showFrames=showFrames)
            score = raw_input()
            while score not in ['0' , '1' , '2', '3', '4' , 's']: score = raw_input("try again")#while not(score == '0' or score == '1' or score == '2' or score == '3' or score == '4' or score == 's'): score = raw_input("try again")
            if score != 's':
                trainImages.append(image)
                one_hot = np.zeros(self.nClasses)
                one_hot[int(score)] = 1
                trainLabels.append(one_hot)

        if self.testFrac == 0: return trainImages, trainLabels, testImages, testLabels
        for i in range(int(self.trainFrac*len(xCenter)), int(self.trainFrac*len(xCenter) + self.testFrac*len(xCenter)) ):
            image = self.makePeakImage(xCenter=xCenter[i], showFrames=showFrames )
            score = raw_input()
            while score not in ['0' , '1' , '2', '3', '4' , 's']: score = raw_input("try again")
            if score != 's':
                testImages.append(image)
                one_hot = np.zeros(self.nClasses)
                one_hot[int(score)] = 1
                testLabels.append(one_hot)

        return trainImages, trainLabels, testImages, testLabels

    def mlClass(self):
        '''
        Code adapted from the tensor flow MNIST tutorial 1
        '''
        
        if os.path.isfile(self.trainFile) and os.path.isfile(self.testFile):
            trainImages, trainLabels = loadPkl(self.trainFile)
            testImages, testLabels = loadPkl(self.testFile)

        else:
            trainImages, trainLabels, testImages, testLabels = self.makeTrainData()

        print 'Number of training images:', np.shape(trainImages)[0], ' Number of test images:', np.shape(testImages)[0]

        if np.shape(trainImages)[1]!=self.xWidth**2:
            print 'Please make new training images of the correct size'
            exit()
        self.nClasses = np.shape(trainLabels)[1]

        self.x = tf.placeholder(tf.float32, [None, self.xWidth**2])
        self.W = tf.Variable(tf.zeros([self.xWidth**2, self.nClasses]))
        self.b = tf.Variable(tf.zeros([self.nClasses]))

        self.y = tf.nn.softmax(tf.matmul(self.x, self.W) + self.b)

        y_ = tf.placeholder(tf.float32, [None, self.nClasses])
        cross_entropy = -tf.reduce_sum(y_*tf.log(tf.clip_by_value(self.y,1e-10,1.0)) )

        train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)

        init = tf.initialize_all_variables()
        self.sess = tf.Session()
        self.sess.run(init)

        batch_xs, batch_ys = trainImages, trainLabels
        self.sess.run(train_step, feed_dict={self.x: batch_xs, y_: batch_ys})
        
        trainReps = 500
        batches = 100
        if np.shape(trainLabels)[0]< batches:
            batches = np.shape(trainLabels)[0]/2
        
        print 'Performing', trainReps, 'training repeats, using batches of', batches
        for i in range(trainReps):
            batch_xs, batch_ys = next_batch(trainImages, trainLabels, batches) 
            self.sess.run(train_step, feed_dict={self.x: batch_xs, y_: batch_ys})
        
        print 'true class labels: ', self.sess.run(tf.argmax(y_,1), feed_dict={self.x: testImages, y_: testLabels})[:25]
        print 'class estimates:   ', self.sess.run(tf.argmax(self.y,1), feed_dict={self.x: testImages, y_: testLabels})[:25]  
        #print self.sess.run(self.y, feed_dict={self.x: testImages, y_: testLabels})[:25]  
        
        correct_prediction = tf.equal(tf.argmax(self.y,1), tf.argmax(y_,1))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        score = self.sess.run(accuracy, feed_dict={self.x: testImages, y_: testLabels}) * 100
        print 'Accuracy of model in testing: ', score, '%'
        if score < 95: print 'Consider making more training images'

        del trainImages, trainLabels, testImages, testLabels

    def plotWeights(self):
        weights = self.sess.run(self.W)
        weights = np.reshape(weights,(self.xWidth,self.xWidth,self.nClasses))
        weights = np.flipud(weights)
        for nc in range(self.nClasses):
            plt.imshow(weights[:,:, nc])
            plt.title('class %i' % nc)
            plt.show()

    def findPeaks(self, inferenceFile, steps =50, start=1000, searchWholeSpec=False):
        try:
            self.sess
        except AttributeError:
            print 'You have to train the model first'
            exit()

        self.inferenceFile = inferenceFile

        self.wsf = WideSweepFile(inferenceFile)
        self.wsf.fitFilter(wn=0.01)
        self.wsf.findPeaks()

        centers = np.arange(self.xWidth/2,len(self.wsf.x)-self.xWidth/2, self.xWidth/20 ) 
        centers = [int(c) for c in centers]

        inferenceImages = []
        if searchWholeSpec:
            steps = len(centers)
            start=0
        span = range(start, steps+start)

        self.inferenceLabels = np.ones((steps,self.nClasses))

        print 'Using trained algorithm on images across the inference spectrum'
        for i,c in enumerate(span): 
            inferenceImage=[]
            sys.stdout.write("\r%d of %i" % (i+1,steps) )
            sys.stdout.flush()

            image = self.makePeakImage(xCenter=centers[c], showFrames=False, saveFrame=False)
            inferenceImage.append(image)
            self.inferenceLabels[i,:] = self.sess.run(self.y, feed_dict={self.x: inferenceImage} )
            
            del inferenceImage
            del image
        
        print '\n'
        stdLabels = np.argmax(self.inferenceLabels, 1)

        del inferenceImages

        peakLocations=[]
        scores = np.zeros((len(stdLabels)))
        peaks = np.where(np.logical_or(stdLabels ==2, stdLabels ==4) )
        peaks = np.split(peaks[0], np.where(np.diff(peaks[0]) >= 2)[0]+1)

        if len(peaks[0]) == 0:
            print 'No peaks found in search range'
            peakLocations = None
        else:
            for p in peaks:
                if len(p)>2:
                    middle = (p[0]+p[len(p)-1]) /2
                    peakLocations.append(middle)

        #peakLocations = np.array(peakLocations)
        centers = np.array(centers)
        dist = abs(np.roll(centers[peakLocations], -1) - centers[peakLocations])
        peakLocations = np.delete(peakLocations,np.where(dist<100))

        print 'Number of resonators located:', len(peakLocations)

        plt.plot(self.wsf.x[centers[start:start+steps]], self.wsf.mag[centers[start:start+steps]])#- self.wsf.baseline[centers[start:start+steps]])
        if peakLocations != []:
            for pl in peakLocations:
                plt.axvline(self.wsf.x[centers[pl+start]], color='r')
                
        plt.xlabel('Frequency (GHz)')
        plt.ylabel('Transmitance')
        plt.show()

        if os.path.isfile(self.goodFile):
            self.goodFile = self.goodFile + time.strftime("-%Y-%m-%d-%H-%M-%S")
        
        gf = open(self.goodFile,'wb')
        id = 0
        if peakLocations != []:
            for pl in peakLocations:
                line = "%8d %12d %16.7f\n"%(id,centers[pl],self.wsf.x[centers[pl]])
                gf.write(line)
                id += 1
            gf.close()

def next_batch(trainImages, trainLabels, batch_size):
    perm = random.sample(range(len(trainImages)), batch_size)
    trainImages = np.array(trainImages)[perm,:]
    trainLabels = np.array(trainLabels)[perm,:]

    return trainImages, trainLabels

def loadPkl(filename):
    file =[]
    with open(filename, 'rb') as f:
        while 1:
            try:
                file.append(pickle.load(f))
            except EOFError:
                break
    
    images=file[0][0]
    labels=file[0][1]
    if len(file) > 1:
        for i in range(len(file)-1):
            images = np.append(images, file[i+1][0], axis=0)
            labels = np.append(labels, file[i+1][1], axis=0)

    print "loaded dataset from ", filename
    return images, labels 

def main(inferenceFile=None):
    mlClass = mlClassification(inferenceFile=inferenceFile,base_corr=False)
    #mlClass.makeTrainData(trainSteps =20)
    
    start_time = time.clock()
    mlClass.mlClass()
    #mlClass.plotWeights()
    #mlClass.findPeaks(inferenceFile, searchWholeSpec=True)
    mlClass.findPeaks(inferenceFile, start=0, steps= 2000)

    print 'run time %f seconds' % (time.clock()-start_time)
    

if __name__ == "__main__":
    inferenceFile= None
    if len(sys.argv) > 1:
        mdd = os.environ['MKID_DATA_DIR']
        inferenceFile = os.path.join(mdd,sys.argv[1])
    else:
        print "need to specify a filename located in MKID_DATA_DIR"
        exit()
    main(inferenceFile=inferenceFile)