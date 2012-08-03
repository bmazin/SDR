;+
; NAME:
;        IUPHBR
;
; PURPOSE:
;        This function extracts the 10 bins of 7.8125 usec High-Bit-Rate
;        data from the input word(s).  Starting from the LSB at bit 0,
;        bits 0-5 and 8-11 of the input word(s) are returned as bits 0-9.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        Result = IUPHBR( HBRwords )
;
; INPUTS:
;        HBRwords: A word or array of words containing High-Bit-Rate RAW data.
;
; OUTPUTS:
;        Defining bit 0 as the Least Significant Bit (LSB), bits 0-9 of the
;        returned value(s) are filled with bits 0-5 and bits 8-11 of HBRwords.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995.
;-
function IUPHBR, i
         return, (i and 63) or ( ishft(i,-2) and 960 )
end
