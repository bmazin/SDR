# make_image.py
# 05/30/11 version 2 updated to make image as numpy array and return mplib figure to arcons quicklook

#from data2ascii import unpack_data
from PIL import Image
from PIL import ImageDraw
from numpy import *
import matplotlib
from matplotlib.pyplot import plot, figure, show, rc, grid
import matplotlib.pyplot as plt

#will actually need intermediate work to unpack these arrays from file and pass them in
def make_image(photon_count, median_energy, color_on = True, white_pixels = .10):

	'''
	Updated from 08/31/10 version.  Image generation will happen on GUI machine now.  organize_data
	will be run on SDR to pass over binary file with arrays of each pixels photon count and median energy.
	Those arrays will be unpacked in GUI image generation thread, combined into cumulative arrays if we
	are doing an observation, then passes arrays of photon counts and energies to make_image
	'''
	array_rows = 32
	array_cols = 32
	total_pixels = array_rows * array_cols
	
	print "Generating image"
	im = Image.new("RGB",(array_cols,array_rows))
	draw = ImageDraw.ImageDraw(im)

	#to get better v gradient we want to saturate brightest 10% of pixels
	#make histogram out of the lengths of each pixel.  Histogram peak will be at the low end
	#as most pixels will be dark, thus having small "lengths" for their photon lists.
	hist_counts, hist_bins = histogram(photon_count, bins=100)
	brightest_pixels = 0
	nbrightestcounts = 0.0
	q=1
	#starting at the high end of the histogram (bins containing the pixels with the most photons),
	#count backwards until we get to the 5th brightest, then set that to maximum v value.
	#Thus the few brighter pixels will be saturated, and the rest will be scaled to this
	#5th brightest pixel.
	
	ncounts = float(sum(photon_count))
	#print "ncounts ", ncounts
	cdf = array(cumsum(hist_counts*hist_bins[:-1]),dtype = float32)
	#print cdf
	idx  = (where(cdf > (ncounts*(1.0-white_pixels))))[0][0] #where cdf has 1-white_pixels percent of max number of counts
	#print idx
	vmax = hist_bins[idx]
	
	#while float(nbrightestcounts/float(ncounts)) <= white_pixels:
		#brightest_pixels += hist_bins[-q]
		#nbrightestcounts += hist_counts[-q]
		#q+=1
	
	#if vmax == 0: #if vmax = 0 then no pixels are illuminated
		#while vmax ==0: #check through brightest pixels until one is found 
			#q -= 1
			#vmax = pixel_hist[1][-q]
	
	for m in range(total_pixels):
		try:
			if median_energy[m] >= 3.1:
				hue= 300
			elif median_energy[m] <= 1.9:
				hue= 0
			else:
				hue = int(((median_energy[m]-1.9)/(3.1-1.9))*300)
		except ValueError:
			hue = 150 #if median energy is NaN, that pixel has no photons, so set hue to green and v will be 0

		#normalize number of photons in that pixel by vmax, then *80 to give brightness
		try:
			v = int((photon_count[m]/vmax)*80)
			if v < 0: 
				v=0 #after sky subtraction we may get negative counts for some pixels
		except ValueError:
			v=0 #if v is NaN set v to 0
		if color_on == True:
			s=v #scale saturation with v so brightest pixels show most color, dimmer show less color
		else:
			s=0 #make image black and white if color is turned off
		colorstring = "hsl(%i,%i%%,%i%%)" %(hue,s,v)
		imx = m%(array_cols)
		#to flip image vertically use: imy = m/array_cols
		imy = (array_rows - 1) - m/(array_cols)
		draw.point((imx,imy),colorstring)

	return im

#10/5/10 added main portion so single binary data file can be turned into an image
if __name__ == "__main__":
	file = raw_input("enter binary data file name: ")
	newpixel, newtime, newenergy = unpack_data(file)
	imagefile = raw_input("enter image file name to save data to: ")
	
	obs = len(newenergy)
	print "creating list of each pixel's photons"
	each_pixels_photons = []
	lengths = []
	#generate empty list for pixels to have photons dumped into
	for j in range(1024):
		each_pixels_photons.append([])
	#search through data and place energies in right pixels
	for k in range(obs):
		each_pixels_photons[newpixel[k]].append(newenergy[k])
	for l in range(1024):
		lengths.append(len(each_pixels_photons[l]))

	print "Generating image"
	im = Image.new("RGB",(32,32))
	draw = ImageDraw.ImageDraw(im)

	#to get better v distribution  we want to saturate brightest 0.5% of pixels
	pixel_hist = histogram(lengths, bins=100)
	photon_sum=0
	q=1
	while photon_sum <=4:
		photon_sum += pixel_hist[0][-q]
		q+=1
	vmax = pixel_hist[1][-q]

	for m in range(1024):
		#normalize pixel's ave energy by max of 5, then multiply by 300 to give hue value between 0 and 300
		median_energy = median(each_pixels_photons[m]) 
		
		try:
			if median_energy >= 3.1:
				hue= 300
			elif median_energy <= 1.9:
				hue= 0
			else:
				hue = int(((median_energy-1.9)/(3.1-1.9))*300)
		except ValueError:
			hue = 150 #if median energy is NaN, that pixel has no photons, so set hue to green and v will be 0

		#normalize number of photons in that pixel by vmax, then *80 to give brightness
		try:
			v = (len(each_pixels_photons[m])/vmax)*80
		except ValueError:
			v=0 #if v is NaN set v to 0
		s=v #scale saturation with v so brightest pixels show most color, dimmer show less color
		colorstring = "hsl(%i,%i%%,%i%%)" %(hue,s,v)
		imx = m%(32)
		#switch between two lines below to flip array vertically
		#imy = m/array_cols
		imy = (31) - m/(32)
		#imy = m/(32)
		
		draw.point((imx,imy),colorstring)

	im.show()
	