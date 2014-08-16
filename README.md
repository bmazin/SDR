SDR
===

Firmware and Software to control the SDR readout for the instrument Arcons.



Required external software components:
---------------------

Enthought Python Distribution (EPD) 7.3 (http://www.enthought.com/products/epd.php)
 
PyEphem (http://rhodesmill.org/pyephem/) 

(you can check if you have them with help('modules') within the (i)python interpreter)

If you are having troubles with PyTables (which you shouldn't since it is built into EPD), see http://www.tumblr.com/tagged/pytables and instructions therein for Mac.

***


Firmware:
---------------------

Firmware/ contains Simulink model files (.mdl) for the channelizer program used to find phase pulse peaks, as well as compilation logs for those models


DataReadout
---------------------

DataReadout/ChannelizerControls/ contains python code to characterize MKID resonators, and to start the DAC with a waveform catered to current resonators, and to set up parameters so that the firmware can capture photon pulses.

DataReadout/ReadoutControls/ contains the main dashboard controls to take observation data at the telescope.

Setup:
---------------------

Setup/ contains code needed to process resonator characterization data.

Projects:
---------------------

Projects/ contains code for smaller projects related to the ARCONS instrument, such as tools based on the main channelizer controls that test new aspects of the firmware.


Data Model
==========

Environment Variables
---------------------

These are set in a script.  The reference scripts are in
`SDR/DataReadout/setEnvironment.sh` and `setEnvironmentFNAL.sh`.
These are the environment variables used:

  1.  `MKID_DATA_DIR`: where data live.  

Program Input and Output for Setup
----------------------------------

1.  `SDR/Setup/WideSweep/SegmentedSweep.vi` creates 'data01.txt'.
This program does not use `MKID_DATA_DIR` so you need to specify it in
the dialog box.

2.  

  
