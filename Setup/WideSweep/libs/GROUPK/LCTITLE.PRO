;
; NAME:
;        LCTITLE
;
; PURPOSE:
;        Returns the Standard Light Curve title.
;
; CATEGORY:
;        String manipulation.
;
; CALLING SEQUENCE:
;
;        Result = LCTITLE( Mjf )
;
; INPUTS:
;           Mjf:   A list of sequential major frame numbers, [long(nmjf)].
;
; OUTPUTS:
;        A title string containing a list of sequential major frame numbers.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May, 1994.
;
function LCTITLE, mjf

         nmjf  = N_ELEMENTS(mjf)
         mjfs  = string( format='(I7)', mjf(0) )
         for i=1,nmjf-1 do $
              mjfs = mjfs + ',' + string( format='(I7)',mjf(i) )
         title = 'Light Curve for MJF(s):'+mjfs

         return, title
end
