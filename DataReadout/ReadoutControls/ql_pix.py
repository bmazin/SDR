from Tkinter import *
import pylab as plt
import sys
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import numpy as np
import os
import time

def main(obs):
	root = Tk()
	obsName,obsExtension = os.path.splitext(obs)
	app = App(root,obsName)
	root.mainloop()

class App:

	def __init__(self, master,obs):
		self.master = master
		frame = Frame(master)
		frame.pack()
		self.index = 0
		self.obs = obs
		self.label = Label(frame, text=self.obs)
		self.label.pack()
		self.back_button = Button(frame, text="back", command=self.back_plot)
		self.back_button.pack(side=LEFT)

		self.next_button = Button(frame, text="next", command=self.next_plot)
		self.next_button.pack(side=LEFT)

		self.autoscale_var = IntVar()
		self.autoscale_button = Checkbutton(frame,text='autoscale',command=self.autoscale,variable=self.autoscale_var)
		self.autoscale_button.pack(side=RIGHT)
		self.autoscale_button.toggle()

		self.rescale_button = Button(frame, text="rescale", command=self.rescale)
		self.rescale_button.pack(side=RIGHT)

		self.go_button = Button(frame, text="go", command=self.go)
		self.go_button.pack(side=RIGHT)

		self.fig = plt.figure()
		self.ax = self.fig.add_subplot(111)
		mat = np.zeros((32,32)) #np.load('bin/'+self.obs+'_'+str(self.index)+'.npy')
		self.mat_history = mat
		
		self.image = self.ax.matshow(mat,cmap='gray')
		self.cbar = self.fig.colorbar(self.image)
		self.canvas = FigureCanvasTkAgg(self.fig,master=master)
		self.canvas.show()
		self.canvas.get_tk_widget().pack(side='top', fill='both', expand=1)
		self.fig_pixel = plt.figure()
		self.ax_pixel = self.fig_pixel.add_subplot(111)
		self.canvas_pixel = FigureCanvasTkAgg(self.fig_pixel,master=master)
		self.canvas_pixel.show()
		self.canvas_pixel.get_tk_widget().pack(side='bottom', fill='both')
		self.index_entry = Entry(frame,text='index',width=4)
		self.index_entry.pack(side=TOP,padx=10,pady=12)
		self.vmin_entry = Entry(frame,text='vmin',width=10)
		self.vmax_entry = Entry(frame,text='vmax',width=10)
		self.vmax_entry.pack(side=RIGHT,padx=10,pady=12)
		self.vmin_entry.pack(side=RIGHT,padx=10,pady=12)
		self.x_entry = Entry(frame,text='x',width=10)
		self.y_entry = Entry(frame,text='y',width=10)
		self.y_entry.pack(side=RIGHT,padx=10,pady=12)
		self.x_entry.pack(side=RIGHT,padx=10,pady=12)
		self.x_entry.insert(0,'5')
		self.y_entry.insert(0,'25')

		self.exptime_entry = Entry(frame,text='exptime',width=4)
		self.exptime_entry.insert(0,'30')
		self.exptime_entry.pack(side=BOTTOM,padx=10,pady=12)
		self.autoscale()
		frame.pack()

	def go(self):
		self.index = 0
		self.mat_history = np.zeros((32,32))
		while (self.index < int(self.exptime_entry.get())):
			self.wait_for_next()

	def back_plot(self):
		if (self.index > 0):
			self.index-=1
		self.index_entry.delete(0,END)
		self.index_entry.insert(0,str(self.index))
		mat = np.rot90(np.load('bin/'+self.obs+'_'+str(self.index)+'.npy'),3)
		self.image.set_data(mat)
		self.autoscale()
		self.rescale()
		self.image.changed()
		self.canvas.draw()

	def next_plot(self):
		self.index+=1
		self.index_entry.delete(0,END)
		self.index_entry.insert(0,str(self.index))

		mat = np.rot90(np.load(self.path),3)
		self.mat_history = np.dstack([self.mat_history,mat])

		x = int(self.x_entry.get())
		y = int(self.y_entry.get())
		length = len(self.mat_history[x,y,:])
		self.ax_pixel.clear()
		self.ax_pixel.plot(range(length),self.mat_history[x,y,:],'r.-')
		self.canvas_pixel.draw()

		self.image.set_data(mat)
		self.autoscale()
		self.rescale()
		self.image.changed()
		self.canvas.draw()

	def autoscale(self):
		if self.autoscale_var.get() == 1:
			self.image.autoscale()
			self.vmin_entry.delete(0,END)
			self.vmin_entry.insert(0,str(self.image.norm.vmin))
			self.vmax_entry.delete(0,END)
			self.vmax_entry.insert(0,str(self.image.norm.vmax))
			self.image.changed()
			self.canvas.draw()


	def rescale(self):
		self.image.set_clim((self.vmin_entry.get()),(self.vmax_entry.get()))
		self.image.changed()
		self.canvas.draw()

	def wait_for_next(self):
		self.master.update()
		self.path = 'bin/'+self.obs+'_'+str(self.index)+'.npy'
		if (os.path.isfile(self.path)):
			self.next_plot()

if __name__ == "__main__":
    main(sys.argv[1])


