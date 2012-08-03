;+
; NAME:
;        STRLETTER
;
; PURPOSE:
;
;        The STRLETTER function returns a copy of Strings with all
;        non-alphabetical characters completely removed.
;
; CATEGORY:
;        String Processing.
;
; CALLING SEQUENCE:
;
;        Result = STRLETTER( Strings )
;
; INPUTS:
;        Strings:  The string or array of strings to be processed.
;
; EXAMPLE:
;        Create a string variable S and S2 by entering:
;
;        S = 'This is a string with !@#$% in it.'
;        S2= ['So what','Big !@#%%ing Deal.']
;
;        Now print S and S2 with all the non-alphabetical
;        characters removed by entering:
;
;        PRINT, STRLETTER(S)
;        PRINT, STRLETTER(S2)
;
;        IDL prints:
;
;        Thisisastringwithinit
;        Sowhat BigDeal
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;-
function STRLETTER, Str

;   Check integrity of input parameter

         NP        = N_PARAMS()
         if (NP ne 1) then message,'Must be called with 1 parameter, Str'

         sz        = SIZE(Str)
         ns        = n_elements(sz)
         if (sz(ns-2) ne 7) then message,'Parameter must be of string type.'
         ndim      = sz(0)

;   Find non-alphabetical characters

         strbyte   = BYTE(Str)
         here      = where( (strbyte lt 65)      or $
                            (strbyte gt 122)     or $
                            ((strbyte gt 90) and (strbyte lt 97)), n )

         if (n eq 0) then return, Str
         strbyte(here)  = 32           ; Fill with white-space characters
                                       ; Chose this method in order to preserve
                                       ;    the dimensionality of the input
                                       ;    argument.

         return,strcompress(strbyte,/REMOVE_ALL)
end
