import numpy as np

def makePoissonData(rate=1./5e-3,totalTime=65.536e-3, maxSignalToNoise=10. , riseTime=2e-6, fallTime=50e-6, sampleRate=1e6):
    dt  = 1./sampleRate    
    time = np.arange(0,totalTime+dt,dt)
    data = np.zeros(time.shape)

    #compute time until next pulse assuming a poisson distribution
    pulseTimes=[]
    currentTime=0
    while currentTime<totalTime:
        probability = np.random.rand()
        currentTime+= -np.log(probability)/rate     
        pulseTimes=np.append(pulseTimes,currentTime)
    pulseTimes=pulseTimes[0:-2]
    #add peaks
    for peak in pulseTimes:
        amplitude=maxSignalToNoise*np.random.rand()
        data+= amplitude*makePulse(time,peak,riseTime,fallTime)
    
    #add noise
    data+=np.random.rand(len(time))

    print len(pulseTimes), 'peaks generated'
    return data, time

def makePulse(time,t0,riseTime,fallTime,sampleRate=1e6):
    time=np.array(time) #double check time is np array
    dt=1./sampleRate
    startTime=t0+(dt-np.remainder(t0,dt))  #round up to nearest dt
    endTime=startTime+6*fallTime
    t=np.arange(startTime,endTime,dt)
    
    pulse= -(1-np.exp(-(t-t0)/riseTime))*np.exp(-(t-t0)/fallTime)
    
    pulseTemplate=np.zeros(time.shape)
    startIndex=np.where(time>=startTime)[0][0]
    endIndex=startIndex+len(pulse)
    if endIndex>len(time):
       endIndex=len(time)
       
    pulseTemplate[startIndex:endIndex]=pulse
    norm=fallTime/(riseTime+fallTime)*(riseTime/(riseTime+fallTime))**(riseTime/fallTime)
    pulseTemplate/=norm
    
    return pulseTemplate


