;+
; NAME:
;        READ_MJF
;
; PURPOSE:
;
;       This function reads in a major frame of HEAO A-1 data from a data file
;       and returns as a keyword a structure containing all the data.
;
; CATEGORY:
;       I/O
;
; CALLING SEQUENCE:
;
;    Result = READ_MJF( Unit [, PICKMJF=pickmjf, FORMAT=Format, DATA=data] )
;
; INPUTS:
;         Unit:    Logical unit associated with the data file.
;
; INPUT KEYWORD PARAMETERS:
;
;       PICKMJF:   The major frame number associated with the major frame
;             to be returned. Reads the file until it reaches this major frame
;             or the end-of-file.
;
;        FORMAT:   String describing the format of the data file. (See DEF_MJF.)
;
; OUTPUTS:
;       This function returns the end of file status for the current
;       file begin read.
;
; OUTPUT KEYWORD PARAMETERS:
;
;         DATA:    A structure containing all of the data of the major frame
;             read from file.  (See DEF_MJF for definition.)
;
; RESTRICTIONS:
;
;       The data structure, MJFstruc must be defined prior to calling
;       this routine using the DEF_MJF routine. The data file must be
;       in the proper IDL format as defined by the FMT_SRCDATA program.
;
; EXAMPLE:
;       Let's create some arrays and read in the first major frame of a data file with
;       data from the Crab pulsar at 320 ms mode.
;
;       openr,unit,'crab.idl',/GET_LUN
;       S   = DEF_MJF( Unit )
;
;       ISS = READ_MJF( Unit, DATA=Data )
;
;       print, data.mjf, data.mode, data.module, data.t77i, data.t77f
;       print, data.raz, data.dez,  data.ray,    data.dey,  data.nsrc
;
; MODIFICATION HISTORY:
;        Written by:  H.C. Wen, April, 1994.
;        22-APR-1994: Moved the parsing of the header into a separate
;                     function called PARSE_HEADER. I also created a simple
;                     function to return the major frame length in number
;                     of bins for a given timing mode, READ_MJF_LEN.
;        26-APR-1994: Changed the required outputs to OPTIONAL keywords.
;        08-MAY-1994: Simplified reading in of data by using FORTRAN-like
;                     format statements; READELE, PARSE_HEADER, PARSE_SOURCE
;                     and PARSE_DATA are now obsolete. Keywords no longer
;                     need to be initialized to a non-zero value to be filled.
;        09-MAY-1994: Added the GETMJF keyword to read file until desired
;                     major frame has been reached.
;        15-MAY-1994: Zero all output keyword parameters if end of file has been reached.
;        26-JUN-1994: Formerly, READ_MJF. Changed keyword outputs to keyword structure.
;                     Changed the GETMJF keyword to PICKMJF.
;        01-AUG-1994: Data structure defined in DEF_MJF
;        25-AUG-1994: Added the DIRS format, divided different formats into CASE
;                     statements to improve readability at a cost of redundancy.
;        15-NOV-1994: Added the ASPECTS format.
;        05-JAN-1994: Small bugfix read bin number I5 instead of I4 for cases
;                     when > 9999, e.g. sequential 5ms major frams, > 8192.
;-
function READ_MJF, unit, PICKMJF=pickmjf, FORMAT=Format, DATA=data

         common MJF_COM, MJFstruc

         ON_ERROR, 2          ; on error, return control to caller


         NP = N_PARAMS()
         if NP ne 1 then $
            message, 'Must be called with 1 parameter: Unit'

         if NOT keyword_set( FORMAT ) then Format = !HEAO_FMT

; Define data structure
         data           = MJFstruc

; Check if we're at the end of the file

NEW_MJF: if EOF( unit ) then return, 0

; Read in the General header

         chk  = ' '      & mjf  = long(1)   & mode = 0
         module = 0      & t77i = long(1)   & t77f = double(1)
         raz = double(1) & dez  = double(1) & ray  = double(1)
         dey = double(1) & nsrc = 0

         readf,unit, $
              format = '(A5,I8,I4,I2,I9, F10.7, 4(F15.7),I3)', $
              chk, mjf, mode, module, t77i, t77f, raz, dez, ray, dey, nsrc
         data.mjf       = mjf
         data.module    = module
         data.t77i      = t77i
         data.t77f      = t77f
         data.raz       = raz
         data.dez       = dez
         data.ray       = ray
         data.dey       = dey

;  Read in Source(s) header


         srcnam = strarr( nsrc )
         srcRA  = dblarr( nsrc ) & srcDEC = dblarr( nsrc )
         name   = ' ' & RA = double(1) & DEC = double(1)
         fmt    = strupcase( Format )
         CASE 1 OF
            (fmt eq 'ASPECTS' ) : $
                        begin
                             t77c1  = double(1)  & t77c2   = double(1)
                             readf,unit, format = '(A9, A8, 4(E15.7))', $
                                   chk, name, RA, DEC, t77c1, t77c2
                             srcnam(0) = name
                             srcRA(0)  = RA
                             srcDEC(0) = DEC
                             data.t77c(*,0) = [t77c1,t77c2]

                             readf,unit, format = '(A5, 6(F15.7))', $
                                   chk, x0, y0, z0, x1, y1, z1
                             xyz       = [ [x0,y0,z0], [x1,y1,z1] ]

                             fmtfile   = ''
                             readf,unit, format = '(A10)', fmtfile
                             data.sat.xyz   = xyz
                        end

            (fmt eq 'STANDARD') : $
                        begin
                             t77c1  = double(1)  & t77c2   = double(1)
                             for i=0,nsrc-1 do begin
                                  readf,unit, $
                                       format = '(A9, A8, 4(E15.7))', $
                                       chk, name, RA, DEC, t77c1, t77c2
                                  srcnam(i) = name
                                  srcRA(i)  = RA
                                  srcDEC(i) = DEC
                                  data.t77c(*,i) = [t77c1,t77c2]
                             endfor
                        end

            (fmt eq 'NOBARY')   : $
                        begin
                             for i=0,nsrc-1 do begin
                                  readf,unit, $
                                       format = '(A9, A8, 2(E15.7))', $
                                       chk, name, RA, DEC
                                  srcnam(i) = name
                                  srcRA(i)  = RA
                                  srcDEC(i) = DEC
                             endfor
                        end

            (fmt eq 'DIRS')     : $
                        begin
                             for i=0,nsrc-1 do begin
                                  readf,unit, $
                                       format = '(A9, A8, 2(E15.7))', $
                                       chk, name, RA, DEC
                                  srcnam(i) = name
                                  srcRA(i)  = RA
                                  srcDEC(i) = DEC
                             endfor
                        end

                        ELSE    : message,'Invalid format.'
         ENDCASE

         data.srcnam    = srcnam
         data.srcRA     = srcRA
         data.srcDEC    = srcDEC


; Read in data
; Dimension the output arrays according to the timing mode

         cts  = fltarr( data.nbin )
         trns = fltarr( nsrc, data.nbin )

         counts = 1. & trans = fltarr( nsrc )

         CASE 1 OF
            (fmt eq 'ASPECTS') : $
                        begin
                             y_asp     = fltarr(2,data.nbin)
                             z_asp     = fltarr(2,data.nbin)

                             for i=0,data.nbin-1 do begin
                                  readf,unit, $
                                       format = '(I5, I6, F8.4, 4E15.7)', $
                                       ibin, counts, trans, $
                                       y_RA, y_DEC, z_RA, z_DEC
                                  cts(i)    = counts
                                  trns(*,i) = trans
                                  y_asp(*,i)= [y_RA, y_DEC]
                                  z_asp(*,i)= [z_RA, z_DEC]
                             endfor
                             data.sat.aspects.y = y_asp
                             data.sat.aspects.z = z_asp
                        end

            (fmt eq 'STANDARD') : $
                        begin
                             for i=0,data.nbin-1 do begin
                                  readf,unit, $
                                       format = '(I5, I6, 21(F8.4))', $
                                       ibin, counts, trans
                                  cts(i)    = counts
                                  trns(*,i) = trans
                             endfor
                        end

            (fmt eq 'NOBARY')   : $
                        begin
                             for i=0,data.nbin-1 do begin
                                  readf,unit, $
                                       format = '(I5, I6, 21(F8.4))', $
                                       ibin, counts, trans
                                  cts(i)    = counts
                                  trns(*,i) = trans
                             endfor
                        end

            (fmt eq 'DIRS')     : $
                        begin
                             thts = fltarr( data.nbin )
                             phis = fltarr( data.nbin )

                             theta = 1. & phi = 1.
                             for i=0,data.nbin-1 do begin
                                  readf,unit, $
                                       format = '(I5, I6, 21(F16.12))', $
                                       ibin, counts, trans, theta, phi
                                  cts(i)    = counts
                                  trns(*,i) = trans
                                  thts(i)   = theta
                                  phis(i)   = phi
                             endfor
                             data.phis      = phis
                             data.thts      = thts
                        end

                        ELSE    : message,'Invalid format.'
         ENDCASE

         data.cts       = cts
         data.trns      = trns

         if keyword_set( PICKMJF ) then $
              if pickmjf lt mjf then begin
                   print,'Error: Find MJF number < next MJF number.'
                   print,'       Returning next major frame.'
              endif else $
                   if pickmjf gt mjf then goto, NEW_MJF

         return, 1

end

