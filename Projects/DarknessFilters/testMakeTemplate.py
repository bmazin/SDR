from matplotlib import rcParams, rc
import matplotlib.pyplot as plt
import numpy as np
import scipy.optimize as opt
from baselineIIR import IirFilter
import makeNoiseSpectrum as mNS
import makeArtificialData as mAD
import makeTemplate as mT

reload(mNS)
reload(mAD)
reload(mT)

##### Test number of itterations of offset correction that are needed #####
if True:
    #make templates
    template0=()
    template1=()       
    template2=()   
    template3=()   
    template4=() 
    template5=()     
    for ii in range(0,100):
        #generate raw data
        rawdata, rawtime = mAD.makePoissonData(totalTime=2*131.072e-3)      
        #calculate template
        finalTemplate, time , _, templateList = mT.makeTemplate(rawdata,numOffsCorrIters=5)
        template0+=(templateList[0],)
        template1+=(templateList[1],)
        template2+=(templateList[2],)
        template3+=(templateList[3],)
        template4+=(templateList[4],)
        template5+=(templateList[5],)
    
    #Calculate residuals for each template variable
    sampleRate=1e6
    nPointsBefore=100.
    riseTime=2e-6
    fallTime=50e-6
    tmax=nPointsBefore/sampleRate
    t0=tmax+riseTime*np.log(riseTime/(riseTime+fallTime))    
    realTemplate = mAD.makePulse(time,t0,riseTime,fallTime)
    residual0=()
    residual1=()       
    residual2=()   
    residual3=()   
    residual4=() 
    residual5=()      
    for ii in range(len(template0)):
        residual0+=(np.sum((realTemplate-template0[ii])**2),)
        residual1+=(np.sum((realTemplate-template1[ii])**2),)
        residual2+=(np.sum((realTemplate-template2[ii])**2),)
        residual3+=(np.sum((realTemplate-template3[ii])**2),)
        residual4+=(np.sum((realTemplate-template4[ii])**2),)
        residual5+=(np.sum((realTemplate-template5[ii])**2),)
        
    #plot histograms
    if False:
        fig=plt.figure()
        plt.hist(residual0, 50, normed=1, facecolor='red', alpha=0.4)   
        plt.hist(residual1, 50, normed=1, facecolor='orange', alpha=0.4)  
        plt.hist(residual2, 50, normed=1, facecolor='yellow', alpha=0.4)  
        plt.hist(residual3, 50, normed=1, facecolor='green', alpha=0.4)  
        plt.hist(residual4, 50, normed=1, facecolor='blue', alpha=0.4)  
        plt.hist(residual5, 50, normed=1, facecolor='purple', alpha=0.4) 
        plt.show()     
        
    #plot medians and maxs
    if True:
        maxes=[np.max(residual0),np.max(residual1),np.max(residual2),np.max(residual3),np.max(residual4),np.max(residual5)]
        medians=[np.median(residual0),np.median(residual1),np.median(residual2),np.median(residual3),np.median(residual4),np.median(residual5)]
        fig=plt.figure()
        plt.plot([0,1,2,3,4,5],medians,label='medians')
        plt.legend()
        plt.show()
        fig=plt.figure()
        plt.plot([0,1,2,3,4,5],maxes,label='maxes')
        plt.legend()
        plt.show()     