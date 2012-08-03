function numlines,file
;+
; NAME:
;     NUMLINES() 
; PURPOSE:
;     Return the number of lines in a file.  
;
;     This procedures became  obsolete in V5.6 with the introduction of
;     the FILE_LINES() procedure
; CALLING SEQUENCE:
;     nl = NUMLINES( filename )
; INPUT:
;     filename = name of file, scalar string
; OUTPUT:
;     nl = number of lines in the file, scalar longword
;          Set to -1 if the number of lines could not be determined
; METHOD:
;      Call FILE_LINES() 
;
; MODIFICATION HISTORY:
;     W. Landsman                              February 1996
;     Use /bin/sh shell with wc under Unix     March 1997
;     Use EXPAND_TILDE() under Unix         September 1997
;     Converted to IDL V5.0   W. Landsman   September 1997
;     Call intrinsic FILE_LINES() if V5.6 or later   December 2002
;     Always return a scalar even if 1 element array is input  March 2004
;     Always assume FILE_LINES is available
;-
 On_error,2

 if N_params() EQ 0 then begin
        print,'Syntax - nl = NUMLINES( file)'
        return,-1
 endif

 return,file_lines(file[0])
 end
