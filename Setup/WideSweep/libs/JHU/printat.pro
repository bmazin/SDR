;-------------------------------------------------------------
;+
; NAME:
;       PRINTAT
; PURPOSE:
;       Print given items at specified screen column and line.
; CATEGORY:
; CALLING SEQUENCE:
;       printat,C,L,itm1,itm2,itm3,...itm9
; INPUTS:
;       C = column (1 - 80).                     in
;       L = line (1 - 24).                       in
;       itm1,itm2,... = up to 9 items to print.  in
;         Items may be text strings or numbers.
; KEYWORD PARAMETERS:
;       Keywords:
;         /BOLD gives bold text.
;         /UNDERLINE gives underlined text.
;         /BLINK gives blinking text.
;         /NEGATIVE gives negative text.
;         Any combination of the above keywords are allowed.
;         /CLEAR clears the screen from given position to end.
;         CLEAR=n clears the next n characters (vt200 mode only).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner  26 Nov, 1985.
;       R. Sterner, 27 Jan, 1992 --- rewrote.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO PRINTAT,CL,LN,I1,I2,I3,I4,I5,I6,I7,I8,I9, help=hlp, $
	  bold=bld, underlined=und, blinking=blk, negative=neg, $
	  clear=clear
 
	IF (n_params(0) lt 2) or keyword_set(hlp) then begin
	  PRINT,' Print given items at specified screen column and line.'
	  PRINT,' printat,C,L,itm1,itm2,itm3,...itm9
	  print,'   C = column (1 - 80).                     in'
	  PRINT,'   L = line (1 - 24).                       in'
	  PRINT,'   itm1,itm2,... = up to 9 items to print.  in'
	  print,'     Items may be text strings or numbers.
	  print,' Keywords:'
	  print,'   /BOLD gives bold text.'
	  print,'   /UNDERLINE gives underlined text.'
	  print,'   /BLINK gives blinking text.'
	  print,'   /NEGATIVE gives negative text.'
	  print,'   Any combination of the above keywords are allowed.'
	  print,'   /CLEAR clears the screen from given position to end.'
	  print,'   CLEAR=n clears the next n characters (vt200 mode only).'
	  RETURN
	ENDIF
 
	;-------  Setup ANSI Escape sequence for position ----------
	csi = string([27b,91b])
	vtcup = csi+strtrim(ln,2)+';'+strtrim(cl,2)+'H'
 
	;-------  Clear screen  --------------------
	if n_elements(clear) ne 0 then $
	  if clear eq 1 then print,vtcup+csi+'J' else $
	    print,vtcup+csi+strtrim(clear,2)+'X'
 
	;-------  Setup ANSI Escape sequence for text attributes  ----
	txtflag = 0
	sgr = '0'
	if keyword_set(bld) then sgr = sgr + ';1'
	if keyword_set(und) then sgr = sgr + ';4'
	if keyword_set(blk) then sgr = sgr + ';5'
	if keyword_set(neg) then sgr = sgr + ';7'
	if sgr ne '0' then begin
	  sgr = sgr+'m'
	  txtflag = 1
	endif
	if txtflag then print,csi+sgr
 
	;-------  Build up output string  ---------
	OUT = ''
	if n_elements(i1) ne 0 then out = out+string(i1) else goto, done
	if n_elements(i2) ne 0 then out = out+string(i2) else goto, done
	if n_elements(i3) ne 0 then out = out+string(i3) else goto, done
	if n_elements(i4) ne 0 then out = out+string(i4) else goto, done
	if n_elements(i5) ne 0 then out = out+string(i5) else goto, done
	if n_elements(i6) ne 0 then out = out+string(i6) else goto, done
	if n_elements(i7) ne 0 then out = out+string(i7) else goto, done
	if n_elements(i8) ne 0 then out = out+string(i8) else goto, done
	if n_elements(i9) ne 0 then out = out+string(i9) else goto, done
 
	;-------  Print total string  -------
done:	print,vtcup+out,form='($,a)'
	if txtflag then print,csi+'0m',form='($,a)'
 
	return
 
	end
