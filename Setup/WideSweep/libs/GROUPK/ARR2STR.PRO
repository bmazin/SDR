;+
; NAME:
;        ARR2STR
;
; PURPOSE:
;        Converts an array of numbers to a string of numbers separated
;        by commas.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        Result = ARR2STR( Array [, Nsig ] )
;
; INPUTS:
;        Array:    Array of numbers to convert.
;
; OPTIONAL INPUTS:
;        Nsig:     Number of significant figures to keep when converting
;                  each number to a string.
;
; OUTPUTS:
;        Returns a string containing the elements of the Array parameter
;        separated by commas.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1994.
;        23-APR-1995    Convert byte arrays to integers before applying the STRING
;                       function.
;        31-OCT-1995    Added ON_ERROR,2
;        19-NOV-1995    Remove leading/trailing blank spaces.
;-
function ARR2STR, array1, nsig

         ON_ERROR, 2

         NP   = N_PARAMS()
         n    = N_ELEMENTS( array1 )
         if NP eq 2 then begin
              nlen      = nsig+7
              fmt       = '(G'+strtrim(nlen,2)+'.'+$
                               strtrim(nsig,2)+')'
         endif else $
              fmt       = ''
         array = array1
         sz   = size(array(0))
         if (sz(1) eq 1) then array = fix(array)      ;convert byte array
                                                      ;    -> integer array
         dump = string(array(0),format=fmt)
         for i=1,n-1 do $
              dump = dump+','+string(array(i),format=fmt)

         return, strtrim(strcompress( dump ),2)
end
