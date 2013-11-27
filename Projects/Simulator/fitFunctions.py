import numpy as np


def benitez2(p, fjac=None, x=None, y=None, err=None):
    model = pow(x,p[0]) * np.exp( -(pow(x/p[1]),p[2]))
    status = 0
    return([status, (y-model)/err])    

def parabola(p, fjac=None, x=None, y=None, err=None):
    #p[0] = x_offset
    #p[1] = amplitude
    #p[2] = y_offset
    model = p[1] * (pow( (x - p[0]), 2 )) + p[2]
    status = 0
    return([status, (y-model)/err])

def parabola2(p, fjac=None, x=None, y=None, err=None):
    #p[0] = a
    #p[1] = b
    #p[2] = c
    model = p[0] * (pow(x, 2 )) + p[1] * x + p[2]
    status = 0
    return([status, (y-model)/err])

def gaussian(p, fjac=None, x=None, y=None, err=None):
    #p[0] = sigma
    #p[1] = x_offset
    #p[2] = amplitude
    #p[3] = y_offset
    model = p[3] + p[2] * np.exp( - (pow(( x - p[1]),2) / ( 2. * pow(p[0],2))))
    # Non-negative status value means MPFIT should continue, negative means
    # stop the calculation.
    status = 0
    return([status, (y-model)/err])

def twogaussian(p, fjac=None, x=None, y=None, err=None):
    #p[0] = sigma1
    #p[1] = x_offset1
    #p[2] = amplitude1
    #p[3] = sigma2
    #p[4] = x_offset2
    #p[5] = amplitude2
    gauss1 = p[2] * np.exp( - (pow(( x - p[1]),2) / ( 2. * pow(p[0],2))))
    gauss2 = p[5] * np.exp( - (pow(( x - p[4]),2) / ( 2. * pow(p[3],2))))
    model = gauss1 + gauss2 
    status = 0
    return([status, (y-model)/err])

def twogaussianexp(p, fjac=None, x=None, y=None, err=None):
    #p[0] = sigma1
    #p[1] = x_offset1
    #p[2] = amplitude1
    #p[3] = sigma2
    #p[4] = x_offset2
    #p[5] = amplitude2
    #p[6] = scalefactor
    #p[7] = x_offset3
    #p[8] = amplitude3
    gauss1 = p[2] * np.exp( - (pow(( x - p[1]),2) / ( 2. * pow(p[0],2))))
    gauss2 = p[5] * np.exp( - (pow(( x - p[4]),2) / ( 2. * pow(p[3],2))))
    expo = p[8] * np.exp(p[6] * (x - p[7]))
    model = gauss1 + gauss2 + expo 
    status = 0
    return([status, (y-model)/err])

def threegaussian(p, fjac=None, x=None, y=None, err=None):
    #p[0] = sigma1
    #p[1] = x_offset1
    #p[2] = amplitude1
    #p[3] = sigma2
    #p[4] = x_offset2
    #p[5] = amplitude2
    #p[6] = sigma3
    #p[7] = x_offset3
    #p[8] = amplitude3
    gauss1 = p[2] * np.exp( - (pow(( x - p[1]),2) / ( 2. * pow(p[0],2))))
    gauss2 = p[5] * np.exp( - (pow(( x - p[4]),2) / ( 2. * pow(p[3],2))))
    gauss3 = p[8] * np.exp( - (pow(( x - p[7]),2) / ( 2. * pow(p[6],2))))
    model = gauss1 + gauss2 + gauss3
    status = 0
    return([status, (y-model)/err])
