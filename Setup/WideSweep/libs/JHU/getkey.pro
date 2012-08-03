;-------------------------------------------------------------
;+
; NAME:
;       GETKEY
; PURPOSE:
;       Return a keyboard key.  Interpret escape sequences.
; CATEGORY:
; CALLING SEQUENCE:
;       k = getkey()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /INIT initializes internal lookup tables, should never
;           be needed but once was.  If arrow keys or other such
;           escape sequence keys gives wrong value try /INIT.
; OUTPUTS:
;       k = key string.  Actual key or key name.   out
;           Waits for a key. No type ahead allowed.
; COMMON BLOCKS:
;       getkey_com
; NOTES:
;       Notes: Key is returned as a string.  Keys that produce
;         escape sequences are interpreted and returned as a single
;         string.  For example the F2 key returns 'F2', the right
;         arrow key returns 'RIGHT', and so on.  Not all keys return
;         something.  To find what a key returns do print,getkey()
;         and press the desired key.
;         Has problems if there is a pause between calls to getkey.
;         Tries to handle problems but cannot always do so.  Its
;         best to type slowly when there are pauses between calls,
;         like for computations, etc.
; MODIFICATION HISTORY:
;       R. Sterner, 8 Nov, 1989
;       R. Sterner, 18 Apr, 1990 --- major rewrite.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function getkey, help=hlp, initialize=init
 
	common getkey_com, tbl, arr, esc
 
	if keyword_set(hlp) then begin
	  print,' Return a keyboard key.  Interpret escape sequences.'
	  print,' k = getkey()
	  print,'   k = key string.  Actual key or key name.   out'
	  print,'       Waits for a key. No type ahead allowed.
	  print,' Keywords:'
	  print,'   /INIT initializes internal lookup tables, should never'
	  print,'     be needed but once was.  If arrow keys or other such'
	  print,'     escape sequence keys gives wrong value try /INIT.'
	  print,' Notes: Key is returned as a string.  Keys that produce'	
	  print,'   escape sequences are interpreted and returned as a single'
	  print,"   string.  For example the F2 key returns 'F2', the right"
	  print,"   arrow key returns 'RIGHT', and so on.  Not all keys return"
	  print,'   something.  To find what a key returns do print,getkey()'
	  print,'   and press the desired key.'
	  print,'   Has problems if there is a pause between calls to getkey.'
	  print,'   Tries to handle problems but cannot always do so.  Its'
	  print,'   best to type slowly when there are pauses between calls,'
	  print,'   like for computations, etc.'
	  return, -1
	endif
 
	;------  initialize on first call  ------
	if (n_elements(tbl) eq 0) or keyword_set(init) then begin
	  tbl = strarr(96)			; multi-code key table.
 
 
	  tbl(7) = ['HELP','R1','R2','R3','R4','R5','R6','R7','',$
	    'R9','','R11','','R13','','R15']
	  tbl(25) = ['F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12']
	  tbl(93) = ['L2','L3','L4']
	  tbl(47) = ['INS','','DEL','ENTER','','','+_PAD','-_PAD','NUM_LOCK']
	  arr = ['UP','DOWN','RIGHT','LEFT']	; arrow table.
	  esc = string(27b)
	endif
 
	;------  Output char or interpreted esc seq  ------------
output:	x = get_kbrd(0)				; Read and discard first char.
	x = get_kbrd(1)				; Grab a char.	Char 1.
	if x eq '' then return, ''		; buffer empty, return null.
	x = (byte(x))(0)			; Convert to byte.
	if x ne 27 then begin			; 1 key, not ESC.
	  return, string(x)			;   Send back 1 char.
	endif
	;----  next char is esc  -------
char2:	x = get_kbrd(1)				; Get next char.  Char 2.
	x = (byte(x))(0)			; Convert to byte.
	if x ne 91 then begin			; If not esc seq then:
	  return, string(x)			;   Send back 1 char = ESC.
	endif
	;----  esc seq  --------
	x = get_kbrd(1)				; Get next char.  Char 3.
	x = (byte(x))(0)			; Convert to byte.
	if (x ge 65) and (x le 68) then begin	; Check if arrow char.
	  return, arr(x-65)			;   Send back arrow name.
	endif
	;----  assume 6 char esc seq  ------
	lo = get_kbrd(1)			; Get next char.  Char 4.
	lo = (byte(lo))(0)			; Convert to byte.
	hi = get_kbrd(1)			; Get next char.  Char 5.
	hi = (byte(hi))(0)			; Convert to byte.
	tmp = get_kbrd(1)			; Get next char.  Char 6. 
	tmp = (byte(tmp))(0)			; Convert to byte.
	i = 10*(lo-48) + (hi-48)		;   position.
	if (i lt 7) or (i gt 95) then begin	; Type ahead buffer error.
	  goto, char2				;   Assume ESC, read esc seq.
	endif
	return, tbl(i)				; Interpreted esc seq string.
 
	end
