import numpy as np
import os
import sys
import subprocess

# get seeing log from http://nera.palomar.caltech.edu/P18_seeing/current.log
# read in last line of file and extract seeing value
# return this value

def getPalomarSeeing(verbose=False):
    #set Verbose = True if you want debug messages
    f="current.log"
    address = "http://nera.palomar.caltech.edu/P18_seeing/%s"%f
    if verbose==True:
        print "Grabbing file from %s"%address
    if verbose== True:
        p = subprocess.Popen("wget %s"%address,shell=True)
    else:
        p = subprocess.Popen("wget --quiet %s"%address,shell=True)
    p.communicate()
    stdin,stdout = os.popen2("tail -1 %s"%f)
    stdin.close()
    line = stdout.readlines(); stdout.close()
    if verbose==True:
        print line
    breakdown = line[0].split('\t')
    seeing = breakdown[4]
    if verbose==True:
        print "Seeing = %s"%seeing
        print "Deleting %s"%f
    os.remove(f)
    return seeing

if __name__ == "__main__":
    verbose=False
    if len(sys.argv)>1:
        if sys.argv[1]=='v':
            verbose=True
        else: print "To set verbose mode use syntax:\npython getSeeing.py v"
    seeing = getPalomarSeeing(verbose)
    print "Got seeing as %s"%seeing
