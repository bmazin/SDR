;-------------------------------------------------------------
;+
; NAME:
;       SAVE2
; PURPOSE:
;       Save IDL vars in a file. Allows them to be renamed during restore2.
; CATEGORY:
; CALLING SEQUENCE:
;       save2, filename, v1, [v2, v3, ... v9]
; INPUTS:
;       filename = name of file to save variable in.     in
;       v1, v2, ... = variables to save (up to 9).       in
; KEYWORD PARAMETERS:
;       keywords:
;         /XDR save using XDR format.
;         /MORE will keep the file open so more variables may be saved.
;            Save2 may be called repeatedly if /MORE is used each time.
;            A call to save2 without /MORE closes the file.
;            Ex: save2, 'test.tmp', a, b, c, /more
;                save2, 'test.tmp', d, e, f
; OUTPUTS:
; COMMON BLOCKS:
;       save2_com
; NOTES:
;       Note: This should work for any data type but structure.
;         See restore2.
; MODIFICATION HISTORY:
;       R. Sterner. 22 Jan, 1988.
;       RES  14 Mar, 1988 --- made for multiple variables.
;       RES  26 Jul, 1990 --- added XDR keyword.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO SAVE2, FILE, T1, T2, T3, T4, T5, T6, T7, T8, T9, $
	  help=hlp, more=mre, xdr=xdr
 
	common save2_com, openflag, lun
 
	NP = N_PARAMS(0)
 
	IF (NP LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Save IDL vars in a file. Allows them to be renamed '+$
	    'during restore2.'
	  PRINT,' save2, filename, v1, [v2, v3, ... v9]
	  PRINT,'   filename = name of file to save variable in.     in'
	  PRINT,'   v1, v2, ... = variables to save (up to 9).       in'
	  print,' keywords:'
	  print,'   /XDR save using XDR format.
	  print,'   /MORE will keep the file open so more variables may '+$
	    'be saved.'
	  print,'      Save2 may be called repeatedly if /MORE is used '+$
	    'each time.'
	  print,'      A call to save2 without /MORE closes the file.'
	  print,"      Ex: save2, 'test.tmp', a, b, c, /more"
	  print,"          save2, 'test.tmp', d, e, f"
	  print,' Note: This should work for any data type but structure.'
	  print,'   See restore2.
	  RETURN
	ENDIF
 
	if n_elements(openflag) eq 0 then openflag = 0
	if openflag eq 0 then begin		; Is file already open?
	  GET_LUN, LUN				; No, get a unit number.
	  if keyword_set(xdr) then begin
	    OPENW, LUN, FILE, /XDR, /stream	; Open unformatted file (XDR).
	  endif else begin
	    OPENW, LUN, FILE		 	; Open unformatted file.
	  endelse
	  openflag = 1				; Mark file as open.
	endif
 
;----------------  Loop thru variables  -----------------
	FOR IV = 1, NP-1 DO BEGIN
 
	  I = EXECUTE('T = N_ELEMENTS(T'+STRTRIM(IV,2)+')')
	  IF T EQ 0 THEN BEGIN	; Ti is undefined.
	    PRINT,'Variable number '+STRTRIM(IV,2)+' is undefined.'
	    PRINT,'SAVE2 aborted.'
	    GOTO, DONE
	  ENDIF
 
	  I = EXECUTE('T = T'+STRTRIM(IV,2))
 
	  SZ = SIZE(T)		; Get infor about var to save (T).
	  ND = SZ(0)		; Number of dimensions (0 = scalar).
	  NEL = SZ(1)		; Number of elements.
	  TY = SZ(ND+1)		; Data type.
 
	  TXT = 'T='		; Build TXT. To be executed in RESTORE2.
 
	  IF ND EQ 0 THEN GOTO, SCALAR	; T is a scalar.
 
;-------------  Array  -------------------
	  CASE TY OF		; Make TXT reflect an array of correct type.
1:	  TXT = TXT + 'BYTARR('
2:	  TXT = TXT + 'INTARR('
3:	  TXT = TXT + 'LONARR('
4:	  TXT = TXT + 'FLTARR('
5:	  TXT = TXT + 'DBLARR('
6:	  TXT = TXT + 'COMPLEXARR('
7:	  TXT = TXT + 'STRARR('
	  ENDCASE
 
	  FOR I = 1 , ND DO BEGIN		; Add dimensions to TXT.
	    TXT = TXT + STRTRIM(SZ(I),2)
	    IF I LT ND THEN TXT = TXT + ','	; Commas except after last.
	  ENDFOR
 
	  TXT = TXT + ')'			; Closing paren.
 
	  GOTO, SAVE
;--------  End of array  ----------------------
 
;------------  Scalar  ---------------
SCALAR:
	  CASE TY OF			; Want T to be a scalar of corr. type.
7:	  TXT = TXT + "'" + T + "'"	; Except actually store scalar string.
1:	  TXT = TXT + '0B'
2:	  TXT = TXT + '0'
4:	  TXT = TXT + '0.0'
3:	  TXT = TXT + '0L'
5:	  TXT = TXT + '0.0D0'
6:	  TXT = TXT + 'COMPLEX(0.0)'
	  ENDCASE
;------  End of scalar  ----------------
 
;----------  Save variable  ----------
SAVE:
	  L = LONG(STRLEN(TXT))			; Get length of TXT.
	  IF TY EQ 7 THEN BEGIN			; String:
	    IF ND EQ 0 THEN BEGIN		;   Scalar string.
	      WRITEU, LUN, -L			;     Flag with length<0.
	      WRITEU, LUN, TXT			;     Actual string embedded.
	    ENDIF ELSE BEGIN			;   String array.
	      WRITEU, LUN, 0L			;     L=0 for string array.
	      WRITEU, LUN, L			;     Length of TXT.
	      WRITEU, LUN, TXT			;     TXT for string array.
	      FOR I = 0 , NEL-1 DO BEGIN	;     Write string in strarr.
		S = T(I)			;	Pull out i'th string.
		WRITEU, LUN, LONG(STRLEN(S))	;	Write string length.
		WRITEU, LUN, S			;	Write string itself.
	      ENDFOR				;     End write array strings.
	    ENDELSE				;   End string array.
	  ENDIF ELSE BEGIN			; End string.  Other types. 
	    WRITEU, LUN, L			; Length of TXT.
	    WRITEU, LUN, TXT			; TXT itself.
	    WRITEU, LUN, T			; Stored variable.
	  ENDELSE
 
	ENDFOR  ; IV.
 
DONE:	if not keyword_set(mre) then begin	; If /MORE not given
	  CLOSE, LUN				; Close file.
	  FREE_LUN, LUN				; Free lun.
	  openflag = 0				; Mark file as closed.
	endif
 
	RETURN
	END
