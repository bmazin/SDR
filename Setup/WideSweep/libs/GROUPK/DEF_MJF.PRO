;+
; NAME:
;        DEF_MJF
;
; PURPOSE:
;        Defines the anonymous major frame data structure appropriate
;        for the given data file.
;
; CATEGORY:
;        I/O
;
; CALLING SEQUENCE:
;        Result = DEF_MJF( Unit [, FORMAT=Format] )
;
; INPUTS:
;         Unit:    Logical unit associated with the data file.
;
; INPUT KEYWORD PARAMETERS:
;       FORMAT:     String describing the format of the data file.
;             The following formats are defined:
;
;             ================================================================
;             ASPECTS  :  This is the "current" data format (11/14/94)
;                         used by FMT_IDL.  The resulting structure tags
;                         or members are defined as follows:
;             ----------------------------------------------------------------
;
;             Format   :  Name of the file format = 'ASPECTS'
;
;             Mjf      :  Major frame number, [long integer].
;
;             Mode     :  Timing mode of the scan in milliseconds (320 or 5).
;
;             Module   :  Module number (3, 4, 5, 6 or 7).
;
;             T77i,T77f:  Integer,fraction of time at the start of major frame in seconds
;                         since 1977, [long integer, double].
;
;             T77c     :  Barycentric time correction for the primary source
;                         at the beginning and end of the major frame in
;                         seconds, [ double(2,nsrc) ].
;
;             Raz,Dez  :  The RA,DEC of the satellite's Z-axis at the start of
;                         this major frame in DEGREES, [double].
;
;             Sat      :  Structure holding information about the satellite's
;                         position with the following tags defined:
;
;                         xyz     : Satellite 3-vector from the earth at
;                                   the beginning and end of the major frame,
;                                   [ float( 3,2 )].
;                         aspects : Structure holding the aspects of the
;                                   satellite at each bin with the following
;                                   tags defined:
;
;                                   y  : The RA and DEC of the y-axis
;                                        in RADIANS, [ float( 2, nbin )]
;                                   z  : The RA and DEC of the z-axis
;                                        in RADIANS, [ float( 2, nbin )]
;
;             Ray,Dey  :  The RA of the satellite's Y-axis at the start of
;                         this major frame in DEGREES, [double].
;
;             Nsrc     :  Number of sources = 1 (Kept to maintain backward
;                         compatibility with the STANDARD format).
;
;             Srcnam   :  Name of the primary source, [string].
;
;             SrcRA    :  RA of the primary source in DEGREES, [ double ].
;
;             SrcDEC   :  DEC of the primary source in DEGREES, [ double ].
;
;             Nbin     :  Number of bins in each major frame.
;
;             Cts      :  An array holding the counts for this major frame,
;                         [ float(nbin) ].
;
;             Trns     :  A 1 x nbin array holding the transmission
;                         functions of the primary source for this major frame,
;                         [float( 1, nbin )].
;
;             ================================================================
;             STANDARD :  This is the "standard" data format most
;                         commonly used by FMT_SRCDATA.  This format contains
;                         information for multiple sources specified by
;                         the user in FMT_SRCDATA. It is identical to the
;                         ASPECTS format with the omission of the tags:
;                                      ( sat, format )
;                         and modifications to the following tags:
;             ----------------------------------------------------------------
;
;             T77c     :  Barycentric time correction for each source at the
;                         beginning and end of the major frame in seconds,
;                         [ double(2,nsrc) ].
;
;             Nsrc     :  The number of sources for which transmission
;                         functions are given in the data, (1-20).
;
;             Srcnam   :  A string array of the names of the sources,
;                         [string( Nsrc)].
;             SrcRA    :  An array of the source RA's in DEGREES, [ double( Nsrc ) ].
;
;             SrcDEC   :  An array of the source DEC's in DEGREES, [ double( Nsrc ) ].
;
;             Trns     :  A (Nsrc) x nbin array holding the transmission
;                         functions of each source for this major frame,
;                         [float( nsrc, nbin )].
;
;             ================================================================
;             NOBARY   :  This is an older data format whose structure is
;                         identical to the STANDARD format except for the
;                         omission of the T77c member.
;
;             ================================================================
;             DIRS     :  This format is identical to the NOBARY format
;                         except for the addition of two new members:
;             ----------------------------------------------------------------
;
;             Phis     :  The scan longitude in RADIANS for each bin in the
;                         major frame [double(nbin)].
;
;             Thts     :  The scan latitude in RADIANS for each bin in the
;                         major frame [double(nbin)].
;
; OUTPUTS:
;        Returns the anonymous major frame data structure as described
;        above under the FORMAT keyword specification.
;
; COMMON BLOCKS:
;      MJF_COM:   Holds a copy of the data structure in the MJFstruc variable
;             so that other routines can copy this anonymous structure. This
;             method was chosen over a NAMED data structure because the
;             dimension of some of the members or tags may change depending
;             on different data files.
;
; RESTRICTIONS:
;        This routine must be called before any calls to READ_MJF.
;
; EXAMPLE:
;
; EXAMPLE:
;        Let's create some arrays and read in the first major frame of
;        a data file with data from the Crab pulsar at 320 ms mode.
;
;        openr,unit,'crab.idl',/GET_LUN
;        MJFstrucvar = DEF_MJF( Unit )
;
;        ISS = READ_MJF( Unit, DATA=Data )
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August, 1994.
;        25-AUG-1994    Added the DIRS format for response function
;                       calibration.
;-
function DEF_MJF, Unit, FORMAT=Format

         common MJF_COM, MJFstruc

; Read in the General header

         chk  = ' '      & mjf  = long(1)   & mode = 0
         module = 0      & t77i = long(1)   & t77f = double(1)
         raz = double(1) & dez  = double(1) & ray  = double(1)
         dey = double(1) & nsrc = 0

         readf,unit, $
              format = '(A5,I8,I4,I2,I9, F10.7, 4(F15.7),I3)', $
              chk, mjf, mode, module, t77i, t77f, raz, dez, ray, dey, nsrc

;   Reset file pointer to the beginning of the file
         POINT_LUN, Unit, 0

         CASE Mode OF
              320       : nbin = 128
                5       : nbin = 8192
                ELSE    : message, 'Invalid Mode.'
         ENDCASE

         if not keyword_set( FORMAT ) then Format = !HEAO_FMT

         fmt = strupcase( Format )
         CASE fmt OF
              'ASPECTS'  : begin
                           aspstruc = { $
                                 y        : fltarr(2,nbin),$
                                 z        : fltarr(2,nbin) }

                           satstruc = { $
                                 xyz      : fltarr(3,2),   $
                                 aspects  : aspstruc       }

                           MJFstruc = { $
                                 format   : 'ASPECTS',     $
                                 mjf      : long(0),       $
                                 mode     : Mode,          $
                                 module   : fix(0),        $
                                 t77i     : long(0),       $
                                 t77f     : double(0),     $
                                 t77c     : dblarr(2,nsrc),$
                                 raz      : double(0),     $
                                 dez      : double(0),     $
                                 ray      : double(0),     $
                                 dey      : double(0),     $
                                 nsrc     : Nsrc,          $
                                 srcnam   : strarr(nsrc),  $
                                 srcRA    : dblarr(nsrc),  $
                                 srcDEC   : dblarr(nsrc),  $
                                 nbin     : nbin,          $
                                 cts      : fltarr(nbin),  $
                                 trns     : fltarr(nsrc,nbin), $
                                 sat      : satstruc       }
                           end
              'STANDARD' : MJFstruc = { $
                                 mjf      : long(0),       $
                                 mode     : Mode,          $
                                 module   : fix(0),        $
                                 t77i     : long(0),       $
                                 t77f     : double(0),     $
                                 t77c     : dblarr(2,nsrc),$
                                 raz      : double(0),     $
                                 dez      : double(0),     $
                                 ray      : double(0),     $
                                 dey      : double(0),     $
                                 nsrc     : Nsrc,          $
                                 srcnam   : strarr(nsrc),  $
                                 srcRA    : dblarr(nsrc),  $
                                 srcDEC   : dblarr(nsrc),  $
                                 nbin     : nbin,          $
                                 cts      : fltarr(nbin),  $
                                 trns     : fltarr(nsrc,nbin) }

              'NOBARY'   : MJFstruc = { $
                                 mjf      : long(0),       $
                                 mode     : Mode,          $
                                 module   : fix(0),        $
                                 t77i     : long(0),       $
                                 t77f     : double(0),     $
                                 raz      : double(0),     $
                                 dez      : double(0),     $
                                 ray      : double(0),     $
                                 dey      : double(0),     $
                                 nsrc     : Nsrc,          $
                                 srcnam   : strarr(nsrc),  $
                                 srcRA    : dblarr(nsrc),  $
                                 srcDEC   : dblarr(nsrc),  $
                                 nbin     : nbin,          $
                                 cts      : fltarr(nbin),  $
                                 trns     : fltarr(nsrc,nbin) }

              'DIRS'     : MJFstruc = { $
                                 mjf      : long(0),       $
                                 mode     : Mode,          $
                                 module   : fix(0),        $
                                 t77i     : long(0),       $
                                 t77f     : double(0),     $
                                 raz      : double(0),     $
                                 dez      : double(0),     $
                                 ray      : double(0),     $
                                 dey      : double(0),     $
                                 nsrc     : Nsrc,          $
                                 srcnam   : strarr(nsrc),  $
                                 srcRA    : dblarr(nsrc),  $
                                 srcDEC   : dblarr(nsrc),  $
                                 nbin     : nbin,          $
                                 cts      : fltarr(nbin),  $
                                 trns     : fltarr(nsrc,nbin),$
                                 phis     : fltarr(nbin),  $
                                 thts     : fltarr(nbin) }

                   ELSE  : message, 'Invalid FORMAT.'
         ENDCASE

         return, MJFstruc
end
