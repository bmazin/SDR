import pylab
import numpy as np

f = [3.5, 4.0, 3.0, 3.25, 3.75, 3.9, 4.25, 4.5/2, 4.75/2, 5./2, 5.25/2, 5.5/2, 5.75/2, 6./2, 6.25/2, 6.5/2]
 
channelizer_in = np.array([1.1e7, 1.1e6, 5.2e6, 1.2e7, 7.2e6, 3.8e6, 30., 1.3e7, 1.2e7, 1.0e7, 5.7e6, 6e5, 1e6, 5.2e6, 1.2e7, 1.2e7])

firstHarmonic = [-57.7, -60.6, -61, -57.3, -57.4, -59.6, -64, -69, -69, -71, -72, -70, -61.6, -60.8, -59.3, -56.6]

secondHarmonic = [-66, -78.5, -60.6, -71, -70, -73, -90, -60, -62.2, -58.8, -58.3, -57, -59.6, -60.25, -62.7, -71.4]

pylab.plot(f, 10*np.log10(channelizer_in)-180, 'bo', f, firstHarmonic, 'go', f, secondHarmonic, 'ro')
pylab.show()
