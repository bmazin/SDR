;+
; NAME:
;        PLUSMINUS
;
; PURPOSE:
;        Returns the ASCII plus/minus character.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        Result = PLUSMINUS()
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, September 1994.
;-
function PLUSMINUS
         return, string(177b)
end
