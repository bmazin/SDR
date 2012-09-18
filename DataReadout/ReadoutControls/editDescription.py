#!/bin/python

import tables
import sys
import os
import glob
import lib.pulses_v1 as pulses

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

if len(sys.argv) != 2 or os.path.exists(sys.argv[1]) == False:
    if os.path.exits(path) == False:
        print 'obsPath %s is not found'%sys.argv[1]
    print 'Usage: %s obsPath.h5'%sys.argv[0]
    print 'Displays the description for obsPath and prompts the user to change the description'
    exit(1)
path = sys.argv[1]
#open existing file for reading/writing
obsFile = tables.openFile(path,mode='r+')
hdr=obsFile.root.header.header.read()
print os.path.basename(path)
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



