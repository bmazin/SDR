;+
; NAME:
;        DEF_HBRDBS
;
; PURPOSE:
;        This routine defines the HEAO HBR database containing info on each
;        HEAO HBR data file.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        DEF_HBRDBS
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        VERBOSE:  Set this keyword to output a detailed listing of the
;                  HBR database structure.
;
; OUTPUTS:
;        A common block structure variable, HBRDBS_ gets defined. HBRDBS_ is
;        an array of structures, one element for each HBR data file. The tags
;        of each structure are defined as follows:
;
;             SLAC:     Structure describing the location of the file in
;                       the SLAC silos. The tags of this structure are:
;
;                       volser:   Volume serial number
;                       seq:      Sequence number
;
;             NRL:      Structure describing the location of the file at NRL.
;                       The tags of this structure are:
;
;                       seq:      Sequence number of the ANALOG tape ..
;                       tape:     Tape number of the DIGITIZED tape ..
;                       file:     File number on the DIGITIZED tape ..
;                                 .. containing this HBR data file.
;
;             chron:    Structure describing when the HBR data was downlinked
;                       to the ground station. The tags of this structure are:
;
;                       dd:       Day of the month (1-31)
;                       mn:       Month (1-12)
;                       yy:       Year (1977-1978)
;                       hh:       Hour (0:23)
;                       mm:       Minute (0:59)
;                       ss:       Seconds (0:59)
;                       doy:      Day of the year (1:365)
;                       JD:       Julian day number, long
;
;             mode:     Structure describing the current modes of the HEAO
;                       electronics and satellite. The tags of this structure are:
;
;                       config:   String describing K. Woods configuration notes
;                       HBR:      Mode of HEAO Random Decommutator,
;                                 {'bit','frame' or 'word')
;                       PM:       Describes which modules have been selected for
;                                 HBR data,(3 = Scan modules, 1-4; 7 = Module 7).
;                       NRZ:      Mode of the NRZ data, (5 = 5ms; 320 = 320ms).
;                       sat:      Describes the state of the satellite,
;                                 ('S' = spinning/scanning; 'P' = pointing)
;
;             rev:      HEAO satellite revolution number, integer.
;
;             pass:     Ground station pass abbreviation, ('H' = Hawaii;
;                       'G' = 'Guam';...).
;
;             length:   Length of the data in MINUTES, float.
;
;             target:   Description of the celestial target, string.
;
;             comments: Miscellaneous comments, string.
;
; COMMON BLOCKS:
;        DEF_HBRDBS:    This common block holds all the info on each HEAO HBR
;                  data file in its structure array, HBRDBS_.
;
; PROCEDURE:
;        The HBRDBS.SAV file, which contains the HBRDBS_ structure is restored.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, September 1995.
;        06-AUG-1996    Simplified directory structure, added VERBOSE keyword.
;-
pro DEF_HBRDBS, VERBOSE=Verbose

         common DEF_HBRDBS, HBRDBS_

         restore,GRPKPATH()+'hbrdbs.sav',VERB=KEYWORD_SET(Verbose)
         if KEYWORD_SET(Verbose) then begin
              help,hbrdbs_
              help,/STRUCT,hbrdbs_
         endif
end
