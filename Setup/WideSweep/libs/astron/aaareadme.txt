THE IDL ASTRONOMY USER'S LIBRARY (July 2009)

The IDL Astronomy Users Library is a central repository for general purpose 
astronomy procedures written in IDL.    The library currently contains
500+ procedures including general FITS I/O, interfaces with STSDAS and IRAF,
astronomical utilities, and photometry and spectral analysis procedures.  
The library is not meant to be an integrated package, but rather is a
collection of procedures  from which users can pick and choose (and possibly
modify) for their own use. Submitted procedures are given a cursory testing,
but are basically stored in the library as submitted.     The IDL
Astronomy User's Library was funded through November 2000 under the NASA 
Astrophysics Data program.

The homepage for the IDL Astronomy Library is  http://idlastro.gsfc.nasa.gov.
There is no longer any FTP access and downloads must be performed from the Web
or using WGET.     The default version of the Library requires IDL V6.1,
although earlier frozen versions are available in the old/ directory.

The success of the IDL Astronomy User's Library depends upon the
willingness of users to give as well as take.   Submission of relevant
procedures is strongly encouraged.  Equally important is the notification 
(or correction) of programming bugs or documentation errors.


I have discontinued the previous mailing list because notices were so
infrequent.  I will post news about major updates to the comp.lang.idl-pvwave 
newsgroup.

Questions about the IDL Astronomy Library can be addressed to 
Wayne Landsman     Wayne.Landsman@nasa.gov
                   (301)-286-3625


The directory contains the following files

  aaareadme.txt - this file
  astron.tar.gz - a gzip'ed Unix tar file containing all Library procedures 
        text files, and data files.    
  astron.dir.tar.gz - This file is an alternative to astron.tar.gz.   It 
        contains the same files as astron.tar.gz but maintains the library
        procedures in their respective sub-directories.
  astron.zip - A .zip version of the Astronomy Library, but with X-windows-only
        procedures (e.g. curs.pro) removed
  contents.txt - an ASCII file giving one-line descriptions of all
        500+ procedures currently in the Library.   This listing is also 
        available at http://idlastro.gsfc.nasa.gov/contents.html
  guidelines.txt - Suggested programming guidelines for Astronomy library
        procedures.
  news.txt - an ASCII file listing all additions or changes to the Library 
        in the past 6 months in reverse chronological order.  This file 
        should be checked periodically as new and modified procedures are added
        to the Library.   Also availabile as an HTML file at 
        http://idlastro.gsfc.nasa.gov/news.html

The following subdirectories are available

  text - contains a collection of ASCII and LaTex files concerning various 
            categories of IDL procedures.
  data - contains data files used by a couple of Library procedures.   *Due to
         their size, the files testpo.405 and JPLEPH.405 are not included in
         the .tar and.zip files.    This environment variable ASTRO_DATA should
         point to this directory.  
  obsolete - repository for procedures removed from the Library because their 
         use has diminished or their functionality has been replaced by other
         procedures.
  pro  - Contains all the Library procedures as individual ASCII files.
            These procedures are placed in subdirectories according to their
            category, e.g. pro/fits, pro/sdas, pro/idlphot
  old - Contains tar files of frozen versions of the IDL Astronomy Library 
        compatible with IDL versions 4.0, 5.1, 5.2, 5.3, 5.4, 5.5. and V5.6
  v64 - A beta test directory of procedures using new features in IDL V6.4
  zdbase - Contains compressed binary tar files of popular astronomical
           catalogs formatted as IDL databases.   See the file
           zdbase/aaareadme.txt for more info. 
  contrib - contains self-contained IDL astronomy-related packages that
           are *not* part of the standard astronomy library distribution.
           See contrib/aaareadme.txt for more info.



