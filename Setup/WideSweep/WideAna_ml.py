'''
to do gui, peak velocities

Rupert D: This script uses machine learning image classification algorithm to identify the positions of peaks. 

The train, test (validate) data (images and labels identified by the user) are stored in pkl files and read in future runs
'''

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

        self.xWidth =200
        if base_corr:
            self.trans = self.wsf.mag - self.wsf.baseline
            self.trainFile = 'train_w%i_bc.pkl' % self.xWidth
            self.testFile = 'test_w%i_bc.pkl' % self.xWidth
            rescaling_factor = 1.5
        else:
            self.trans = self.wsf.mag
            self.trainFile = 'train_w%i.pkl' % self.xWidth
            self.testFile = 'test_w%i.pkl' % self.xWidth
            rescaling_factor = 3.5
        
        self.yLims=[min(self.trans), max(self.trans)]
        self.trainFrac = 0.8
        self.testFrac=1 - self.trainFrac
        
        self.trans_adjusted= self.trans-min(self.trans)
        self.trans_adjusted = np.round(self.trans_adjusted*rescaling_factor*self.xWidth/max(self.trans_adjusted) )

        #self.baseline_correction = running_mean(self.wsf.baseline, self.xWidth)#self.wsf.baseline[np.arange(0,len(self.wsf.baseline),40)]

        #plt.plot(self.wsf.baseline, label='original')
        #plt.plot(self.baseline_correction, '.', label = 'correction') #np.arange(0,len(self.wsf.baseline),self.xWidth)
        #plt.plot(self.trans, label='trans')
        #self.trans_adjusted = self.wsf.mag - self.baseline_correction
        #plt.plot(self.wsf.mag, label='no correction')
        #plt.plot(self.trans_adjusted, label='trans_adjusted')
        #self.trans_adjusted = self.trans
        
        #self.trans_adjusted= self.trans_adjusted-min(self.trans)
        #plt.legend()
        #plt.show()
    def makePeakImage(self, xCenter=25, markers=True, showFrames=False, saveFrame=False, showArray=False):
        
        start = int(xCenter - self.xWidth/2)
        end = int(xCenter + self.xWidth/2)
        #print self.wsf.baseline[start:end]
        #print sum(self.wsf.baseline[start:end]/self.xWidth)
        #print self.trans_adjusted[start:end], self.baseline_adjusted[start:end]
        
        trans = self.trans_adjusted[start:end]#-sum(self.baseline_adjusted[start:end]/self.xWidth))

        trans = map(int, np.array(trans) + (self.xWidth*4.5/5)-np.median(trans) )
        #print trans
        #print (self.wsf.mag - self.wsf.baseline)[start:end]
        #trans = trans + 
        #trans = self.trans[start:end]
        #trans = trans - min(trans) 
        #trans = np.round(trans*self.xWidth/max(trans))
        #trans = map(int,trans)
        if showFrames:
            fig = plt.figure(frameon=False)
            fig.add_subplot(111)

            #print len(self.wsf.x[start:end]), len(trans)
            plt.plot(self.wsf.x[start:end], self.trans[start:end])
            
            if markers:
                plt.axvline(self.wsf.x[(end-start)/4 + start], ls='dashed')
                plt.axvline(self.wsf.x[end - (end-start)/4], ls='dashed')

            self.yLims=[min(self.trans), max(self.trans)]
        
            '''
        trans = map(int,self.trans_adjusted[start:end])

        if showFrames:
            fig = plt.figure(frameon=False)
            fig.add_subplot(111)

            plt.plot(self.wsf.x[start:end], self.trans[start:end])
            
            if markers:
                plt.axvline(self.wsf.x[(end-start)/4 + start], ls='dashed')
                plt.axvline(self.wsf.x[end - (end-start)/4], ls='dashed')

            self.yLims=[min(self.trans), max(self.trans)]
            '''
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

        #image[map(lambda y : y-1,trans),range(self.xWidth)] =1
        try:
            image[map(int,trans), range(self.xWidth)]=1
        except IndexError:
            pass

        #print map(lambda y : y-1,trans)

        if showArray:
            plt.imshow(image)
            plt.show()

        image = image.flatten()
        return image
        

    def makeTrainData(self, trainSteps=20, equal_amounts = True, saveFile=True):
        self.yLims=[min(self.trans), max(self.trans)]

        trainImages, trainLabels, testImages, testLabels = [], [], [], []
        
        if os.path.isfile(self.goodFile):
            peaks = np.loadtxt(self.goodFile)[:,1]

        else:
            peaks = self.wsf.peaksDict['big']

        peakVel = abs(np.roll(peaks, 1) - peaks)

        colls = peaks[np.where( peakVel < 7)[0]]
        random.shuffle(colls)
        if not colls:
            self.nClasses=4

        noise = range(len(self.wsf.x))
        lefts = peaks+self.xWidth/3
        centrals = peaks
        rights = peaks-self.xWidth/3
        
        noise_trainImages, noise_trainLabels, noise_testImages, noise_testLabels = \
            self.makeImageDataset(xCenter=random.sample(noise, trainSteps/self.nClasses) , showFrames=True, showHelp=True)
        left_trainImages, left_trainLabels, left_testImages, left_testLabels = \
            self.makeImageDataset(xCenter=random.sample(lefts,trainSteps/self.nClasses) , showFrames=True)
        peak_trainImages, peak_trainLabels, peak_testImages, peak_testLabels = \
            self.makeImageDataset(xCenter=random.sample(peaks,trainSteps/self.nClasses) , showFrames=True)
        right_trainImages, right_trainLabels, right_testImages, right_testLabels = \
            self.makeImageDataset(xCenter=random.sample(rights,trainSteps/self.nClasses) , showFrames=True)
        
        trainImages = noise_trainImages + left_trainImages + peak_trainImages+ right_trainImages
        trainLabels = noise_trainLabels + left_trainLabels + peak_trainLabels + right_trainLabels 
        testImages =  noise_testImages + left_testImages + peak_testImages + right_testImages 
        testLabels = noise_testLabels + left_testLabels + peak_testLabels + right_testLabels 

        if colls:
            coll_trainImages, coll_trainLabels, coll_testImages, coll_testLabels = \
                self.makeImageDataset(xCenter=random.sample(colls,trainSteps/self.nClasses) , showFrames=True)
            trainImages = trainImages  + coll_trainImages
            trainLabels = trainLabels + coll_trainLabels
            testImages = testImages + coll_testImages
            testLabels = testLabels + coll_testLabels

        if equal_amounts:
            lengths = np.array(trainLabels, dtype=int).sum(axis=0)
            uniform = np.ones((self.nClasses))*int((trainSteps/self.nClasses)*self.trainFrac)
            print type(lengths), type(uniform), lengths!=uniform, lengths, uniform
            while (lengths!=uniform).any():
                self.trainFrac = 1
                self.testFrac = 0

                diff = np.ones((self.nClasses), dtype=int)*max(lengths) - lengths
                print lengths, diff
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

                if colls:
                    if diff[4]!=0: 
                        coll_trainImages, coll_trainLabels, coll_testImages, coll_testLabels = \
                            self.makeImageDataset(xCenter=random.sample(colls,diff[4]) , showFrames=True)
                        if coll_trainLabels != []:
                            trainImages = np.append(trainImages, coll_trainImages, axis=0)
                            trainLabels = np.append(trainLabels, coll_trainLabels, axis=0)

                lengths = np.array(trainLabels, dtype=int).sum(axis=0)
                uniform = np.ones((self.nClasses), dtype=int)*max(lengths)
                print lengths, uniform, lengths!=uniform

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

        print np.shape(trainImages), np.shape(trainLabels), np.shape(testImages), np.shape(testLabels)
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
        peaks = np.split(peaks[0], np.where(np.diff(peaks[0]) >= 5)[0]+1)

        if len(peaks[0]) == 0:
            print 'No peaks found in search range'
            peakLocations = None
        else:
            for p in peaks:
                if len(p)>2:
                    middle = (p[0]+p[len(p)-1]) /2
                    #print p, middle
                    peakLocations.append(middle)

        print 'Number of resonators located:', len(peakLocations)

        plt.plot(self.wsf.x[centers[start:start+steps]], self.wsf.mag[centers[start:start+steps]])#- self.wsf.baseline[centers[start:start+steps]])
        if peakLocations != None:
            for pl in peakLocations:
                plt.axvline(self.wsf.x[centers[pl+start]], color='r')
                
        '''
            peaks = self.wsf.peaksDict['big']
            peakVel = abs(np.roll(peaks, 1) - peaks)
            colls = peaks[np.where( peakVel < 60)[0]]
            print colls[:20]
            for pks in peaks:
                plt.axvline(self.wsf.x[pks], color='g')
            for c in colls:
                plt.axvline(self.wsf.x[c], color='k')
            '''
        plt.xlabel('Frequency (GHz)')
        plt.ylabel('Transmitance')
        plt.show()

        if os.path.isfile(self.goodFile):
            self.goodFile = self.goodFile + time.strftime("-%Y-%m-%d-%H-%M-%S")
        
        gf = open(self.goodFile,'wb')
        id = 0
        if peakLocations != None:
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
        for i in range(np.shape(file)[0]-1):
            images = np.append(images, file[i+1][0], axis=0)
            labels = np.append(labels, file[i+1][1], axis=0)

    print "loaded dataset from ", filename
    return images, labels 

#def running_mean(x, N):
#    y = np.zeros((len(x),))
#    mids = np.arange(N/2,len(x)-N/2,N)
#    for ctr, mid in enumerate(mids[:-1]):
#        #print ctr, mid
#        y[mids[ctr]:mids[ctr+1]] = np.sum(x[mids[ctr]:mids[ctr+1]])/N
#        #print y[ctr]
#    y[:mids[0]] = np.sum(x[:mids[0]])/(N/2)
#    return y#/N

def main(inferenceFile=None):
    mlClass = mlClassification(inferenceFile=inferenceFile,base_corr=False)
    #mlClass.makeTrainData(trainSteps =20)
    
    start_time = time.clock()
    mlClass.mlClass()
    #mlClass.plotWeights()
    mlClass.findPeaks(inferenceFile, searchWholeSpec=True)

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