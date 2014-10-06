from tables import *
from numpy import *
from lib.iqsweep import *
class PSFile():
    def __init__(self,fileName):
        self.openfile = fileName
        hd5File = openFile(fileName,mode='r')
        group = hd5File.getNode('/','r0')
        self.freq=empty(0,dtype='float32')
        for sweep in group._f_walkNodes('Leaf'):
            k=sweep.read()
            self.scale = k['scale'][0]
            #print "Scale factor is ", self.scale                               
            self.freq=append(self.freq,[k['f0'][0]])
        hd5File.close()


    def loadres(self, resnum):
        self.resnum = resnum
        self.Res1=IQsweep()
        self.Res1.LoadPowers(str(self.openfile), 'r0', self.freq[self.resnum])
        #self.ui.res_num.setText(str(self.resnum))
        self.resfreq = self.resnum
        #self.ui.frequency.setText(str(self.resfreq))
        self.NAttens = len(self.Res1.atten1s)
        self.res1_iq_vels=zeros((self.NAttens,self.Res1.fsteps-1))
        self.res1_iq_amps=zeros((self.NAttens,self.Res1.fsteps))
        for iAtt in range(self.NAttens):
            for i in range(1,self.Res1.fsteps-1):
                self.res1_iq_vels[iAtt,i]=sqrt((self.Res1.Qs[iAtt][i]-self.Res1.Qs[iAtt][i-1])**2+(self.Res1.Is[iAtt][i]-self.Res1.Is[iAtt][i-1])**2)
                self.res1_iq_amps[iAtt,:]=sqrt((self.Res1.Qs[iAtt])**2+(self.Res1.Is[iAtt])**2)
        #Sort the IQ velocities for each attenuation, to pick out the maximums
        sorted_vels = sort(self.res1_iq_vels,axis=1)
        #Last column is maximum values for each atten (row)
        self.res1_max_vels = sorted_vels[:,-1]
        #Second to last column has second highest value
        self.res1_max2_vels = sorted_vels[:,-2]
        #Also get indices for maximum of each atten, and second highest
        sort_indices = argsort(self.res1_iq_vels,axis=1)
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
                max_neighbor = maximum(self.res1_iq_vels[iAtt,max_indices[iAtt]-1],self.res1_iq_vels[iAtt,max_indices[iAtt]+1])
            max_neighbors[iAtt]=max_neighbor
            self.res1_max_ratio[iAtt] = self.res1_max_vels[iAtt]/max_neighbor
            if max2_indices[iAtt] == 0:
                max2_neighbor = self.res1_iq_vels[iAtt,max2_indices[iAtt]+1]
            elif max2_indices[iAtt] == len(self.res1_iq_vels[iAtt,:])-1:
                max2_neighbor = self.res1_iq_vels[iAtt,max2_indices[iAtt]-1]
            else:
                max2_neighbor = maximum(self.res1_iq_vels[iAtt,max2_indices[iAtt]-1],self.res1_iq_vels[iAtt,max2_indices[iAtt]+1])
            max2_neighbors[iAtt]=max2_neighbor
            self.res1_max2_ratio[iAtt] = self.res1_max2_vels[iAtt]/max2_neighbor
        #normalize the new arrays
        self.res1_max_vels /= max(self.res1_max_vels)
        self.res1_max_vels *= max(self.res1_max_ratio)
        self.res1_max2_vels /= max(self.res1_max2_vels)
        #self.res1_relative_max_vels /= numpy.max(self.res1_relative_max_vels)
        #self.ui.plot_1.canvas.ax.clear()
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,self.res1_max_vels,'b.-',label='Max IQ velocity')
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,max_neighbors,'r.-')
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,self.res1_max_ratio,'k.-',label='Ratio (Max Vel)/(2nd Max Vel)')
        #self.ui.plot_1.canvas.ax.legend()
        #self.ui.plot_1.canvas.ax.set_xlabel('attenuation')
        
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,self.res1_max2_vels-1,'b.-')
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,max2_neighbors-1,'b.-')
        #self.ui.plot_1.canvas.ax.plot(self.Res1.atten1s,self.res1_max2_ratio-1,'g.-')
        #cid=self.ui.plot_1.canvas.mpl_connect('button_press_event', self.click_plot_1)
        #self.ui.plot_1.canvas.format_labels()
        #self.ui.plot_1.canvas.draw()

        max_ratio_threshold = 1.5
        guess_atten_idx = where(self.res1_max_ratio < max_ratio_threshold)
        rule_of_thumb_offset = 2
        if size(guess_atten_idx) >= 1:
            if guess_atten_idx[0][0]+rule_of_thumb_offset < len(self.Res1.atten1s):
                guess_atten_idx[0][0] += rule_of_thumb_offset
            guess_atten = self.Res1.atten1s[guess_atten_idx[0][0]]
            print 'Guessing attenuation is ',guess_atten
            #self.select_atten(guess_atten)
        else:
            print 'Defaulting guess attenuation to center'
            #self.select_atten(self.Res1.atten1s[self.NAttens/2])

