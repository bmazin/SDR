;+
; NAME:
;        STRPARSE
;
; PURPOSE:
;
;        This function parses a string using the space (' ') token.
;
; CATEGORY:
;        String Processing.
;
; CALLING SEQUENCE:
;
;        Result = STRPARSE( String )
;
; INPUTS:
;        String:  The string to be parsed.
;
; EXAMPLE:
;        Create a string variable S:
;
;        S = 'This is a string with !@#$% in it.'
;
;        Now parse S by entering:
;
;        ss = STRPARSE(S)
;        help,ss
;        print,TRANSPOSE(ss)
;
;        IDL prints:
;
;        SS              STRING    = Array(8)
;        This
;        is
;        a
;        string
;        with
;        !@#$%
;        in
;        it.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1996.
;-
function STRPARSE, Str1

         inf  = 100000
         Strs = ''
         Str  = STRTRIM(Str1,2)
         pSPC = STRPOS(Str,' ')
         if (pSPC eq -1) then return, Str

         repeat begin
              s    = STRMID(Str,0,pSPC)
              Strs = [Strs,s]
              Str  = STRTRIM(STRMID(Str,pSPC+1,inf),1)
              pSPC = STRPOS(Str,' ')
         endrep until (pSPC eq -1)
         if (Str ne '') then Strs = [Strs,Str]

         return, Strs(1:*)
end
