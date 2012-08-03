;-------------------------------------------------------------
;+
; NAME:
;       HELP_SAVE2
; PURPOSE:
;       Look at files made by save2 and list what they contain.
; CATEGORY:
; CALLING SEQUENCE:
;       help_save2, filename
; INPUTS:
;       filename = name of file made by save2.     in
; KEYWORD PARAMETERS:
;       Keywords:
;          /DEBUG to list debug info for save2 file.
;          /XDR examine an XDR save2 file.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 29 Jun, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO HELP_SAVE2, FILE, help=hlp, debug=dbg, xdr=xdr
 
	NP = N_PARAMS(0)
 
	IF (NP LT 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Look at files made by save2 and list what they contain.'
	  PRINT,' help_save2, filename'
	  PRINT,'   filename = name of file made by save2.     in'
	  print,' Keywords:'
	  print,'    /DEBUG to list debug info for save2 file.'
	  print,'    /XDR examine an XDR save2 file.'
	  RETURN
	ENDIF
 
	GET_LUN, LUN
	ON_IOERROR, FNF
	if keyword_set(xdr) then begin
	  OPENR, LUN, FILE, /xdr, /stream
	endif else begin
	  OPENR, LUN, FILE
	endelse
	ON_IOERROR, DONE
 
	N = 0
 
LOOP:	L = 0L			; Length of TXT is a long int.
	READU, LUN, L		; Read length.
	if abs(l) gt 200 then begin
	  print," Error in HELP_SAVE2. "+file+$
	    " doesn't look like a save2 file."
	  print,' Aborting.'
	  goto, done
	endif
	N = N + 1		; Found a variable, count it.
	if keyword_set(dbg) then print,'  setup txt length = ', l
 
	CASE 1 OF
  L LT 0: BEGIN			; Scalar text string.
	    TXT = SPC(-L)		; Set up for input string, TXT.
	    READU, LUN, TXT	; Read string, TXT.
	    if keyword_set(dbg) then print,'  String setup txt = ',txt 
	    TXT = 'String = ' + STRMID(TXT,2,99)	; Trim off leading 'T='
	  END
  L EQ 0: BEGIN
	    READU, LUN, L
	    if abs(l) gt 200 then begin
	      print," Error in HELP_SAVE2. "+file+$
		" doesn't look like a save2 file."
	      print,' Aborting.'
	      goto, done
	    endif
	    if keyword_set(dbg) then print,$
	      '  String array setup txt length = ',l
	    TXT = SPC(L)
	    READU, LUN, TXT
	    if keyword_set(dbg) then print,'  String array setup txt = ',txt 
	    I = EXECUTE(TXT)
	    TXT = STRMID(TXT,2,99)
	    NEL = N_ELEMENTS(T)
	    FOR I = 0, NEL-1 DO BEGIN
	      READU, LUN, L
	      if abs(l) gt 200 then begin
	        print," Error in HELP_SAVE2. "+file+$
		  " doesn't look like a save2 file."
	        print,' Aborting.'
	        goto, done
	      endif
	      if keyword_set(dbg) then print,$
		'  String array element length = ',l
	      TXT2 = SPC(L)
	      READU, LUN, TXT2
	      if keyword_set(dbg) then print,'  String array element = ',txt2 
	    ENDFOR
	  END
  L GT 0: BEGIN
	    TXT = SPC(L)
	    READU, LUN, TXT	; TXT contains code to set aside space.
	    if keyword_set(dbg) then print,'  Setup txt = ',txt 
	    I = EXECUTE(TXT)	; Executing TXT makes T have right space.
	    READU, LUN, T	; Now read contents of T.
	    IF NOT ISARRAY(T) THEN BEGIN
	      TMP = DATATYPE(T)
	      IF TMP EQ 'BYT' THEN BEGIN
	        TXT = DATATYPE(T,1)+' = '+STRTRIM(FIX(T),2)
	      ENDIF ELSE BEGIN
	        TXT = DATATYPE(T,1)+' = '+STRTRIM(T,2)
	      ENDELSE
	    ENDIF ELSE BEGIN
	      TXT = STRMID(TXT,2,99)	; Trim off leading 'T='
	    ENDELSE
	  END 
	ENDCASE
 
	PRINT,N,'.  ',TXT
 
	GOTO, LOOP
 
DONE:	CLOSE, LUN
	FREE_LUN, LUN
	ON_IOERROR, NULL
	RETURN
 
FNF:	PRINT,'File not found: '+FILE
	GOTO, DONE
 
	END
