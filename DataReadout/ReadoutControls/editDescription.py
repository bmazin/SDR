#!/bin/python

import tables
import sys
import os
import glob
import lib.pulses_v1 as pulses

def is_int(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

def confirm(prompt=None, resp=False):
    """prompts for yes or no response from the user. Returns True for yes and
    False for no.

    'resp' should be set to the default value assumed by the caller when
    user simply types ENTER.

    >>> confirm(prompt='Create Directory?', resp=True)
    Create Directory? [y]|n: 
    True
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: 
    False
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: y
    True
    from http://code.activestate.com/recipes/541096-prompt-the-user-for-confirmation/

    """
    
    if prompt is None:
        prompt = 'Confirm'

    if resp:
        prompt = '%s [%s]|%s: ' % (prompt, 'y', 'n')
    else:
        prompt = '%s [%s]|%s: ' % (prompt, 'n', 'y')
        
    while True:
        ans = raw_input(prompt)
        if not ans:
            return resp
        if ans not in ['y', 'Y', 'n', 'N']:
            print 'please enter y or n.'
            continue
        if ans == 'y' or ans == 'Y':
            return True
        if ans == 'n' or ans == 'N':
            return False

if len(sys.argv) != 2 and len(sys.argv) != 3:
    print 'Usage: %s numLatestObs|path [cal]'%sys.argv[0]
    print 'Displays the description for obsPath and prompts the user to change the description for numLatestObs-th from latest obs file. Or if given a path, checks current location and at path given by MKID_DATA_DIR'
    exit(1)

obsBase = 'obs*.h5'
calBase = 'cal*.h5'
if len(sys.argv) == 3 and sys.argv[2] == 'cal':
    base = calBase
else:
    base = obsBase
toOpen = sys.argv[1]
path = os.environ['MKID_DATA_DIR']
if is_int(toOpen):
    obsIndex = int(sys.argv[1])
    obsPaths = sorted(glob.glob(os.path.join(path,base)))[::-1]
    obsPath = obsPaths[obsIndex]
    if obsIndex == 0:
        print 'Filename: ',os.path.basename(obsPath)
        if confirm('Thats the latest file.  Continue only if this is not currently exposing.  Continue?') == False:
            exit(0)
elif os.path.exists(toOpen):
    obsPath = toOpen
elif os.path.exists(os.path.join(path,toOpen)):
    obsPath = os.path.join(path,toOpen)
else:
    print 'File doesn\'t exist: ',sys.argv[1]

#open existing file for reading/writing
obsFile = tables.openFile(obsPath,mode='r+')
hdr=obsFile.root.header.header.read()
print 'Filename: ',os.path.basename(obsPath)
print 'Target: ',hdr['target'][0]
print 'Local time: ',hdr['localtime'][0]
print 'UTC: ',hdr['utc'][0]
print 'Description: ',hdr['description'][0]
print 'Filter: ',hdr['filt'][0]
print 'Exposure Time: ',hdr['exptime'][0]
print ''
if confirm('Update target?') == True:
    newDesc = raw_input('Enter new target then hit Enter: ')
    hdr['target'] = newDesc
    obsFile.removeNode('/header',recursive=True)
    hdrgrp = obsFile.createGroup('/','header','Group containing observation target')
    filt1 = tables.Filters(complevel=1, complib='zlib', fletcher32=False)
    h5table = obsFile.createTable(hdrgrp, 'header', pulses.ObsHeader, "Header",filters=filt1)
    h5table.append(hdr)
    obsFile.flush() 
if confirm('Update description?') == True:
    newDesc = raw_input('Enter new description then hit Enter: ')
    hdr['description'] = newDesc
    obsFile.removeNode('/header',recursive=True)
    hdrgrp = obsFile.createGroup('/','header','Group containing observation description')
    filt1 = tables.Filters(complevel=1, complib='zlib', fletcher32=False)
    h5table = obsFile.createTable(hdrgrp, 'header', pulses.ObsHeader, "Header",filters=filt1)
    h5table.append(hdr)
    obsFile.flush() 
obsFile.close()



