;-------------------------------------------------------------
;+
; NAME:
;       TPRINT
; PURPOSE:
;       Turn print statements into a text array.
; CATEGORY:
; CALLING SEQUENCE:
;       tprint,a1,a2,a3,...
; INPUTS:
;       a1,a2,a3,... = args to tprint.  in
;         May have up to 15.
; KEYWORD PARAMETERS:
;       Keywords:
;         BUFFER=buf  Set up and use an external buffer, buf instead
;           of internal buffer. Use BUFFER=buf on each call to
;           tprint.  Will create and return it on /INIT, then
;           send as an input on following calls.
;         /INIT Clear internal text array.
;           May also give an initial text array: INIT=txt.
;         ADD=txt Add given text array to internal text.
;         OUT=txt Return internal text array.
;         /PRINT print internal text array.
;         SAVE=file  Save internal text array in a text file.
;         /REVERSE reverse text array order (for /PRINT, OUT=, or SAVE=).
;         ERROR=err 0=ok, 1=error if OUT or /PRINT used with no text.
; OUTPUTS:
; COMMON BLOCKS:
;       tprint_com
; NOTES:
;       Notes: Intended to make it easy to take a set of print
;         statements in a program and change them to build up
;         a text array.  Uses the IDL string function in place
;         of the print statement to handle the arguments.  Can
;         then return the text array built up from multiple
;         tprint calls and use it elsewhere.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Aug 17
;       R. Sterner, 2001 Mar 21 --- Added /REVERSE flag.
;       R. Sterner, 2001 May 25 --- Allowed INIT=txt to start with text.
;       R. Sterner, 2001 May 25 --- Added new keyword: ADD=txt to add text.
;       R. Sterner, 2001 May 30 --- Added new keyword: SAVE=file to save text.
;       R. Sterner, 2004 May 20 --- Dropped execute to allow in IDL VM.
;       R. Sterner, 2006 Apr 26 --- Added BUFFER=buf keyword.
;       R. Sterner, 2006 May 17 --- Fixed BUFFER=buf for ADD and OUT.
;       R. Sterner, 2006 Jul 14 --- Fixed the /PRINT command.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tprint, p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
	  init=init,out=out, print=print, error=err, reverse=rev, $
	  add=add, save=save, buffer=buf, help=hlp
 
	common tprint_com, txt, flag
	;--------------------------------------------------
	;  Internal memory
	;  txt = Internal text buffer.
	;  flag = Internal text flag: 0=no text, 1=text.
	;--------------------------------------------------
	;  If BUFFER=buf is used on each call to tprint
	;  then use the values in buf (external memory):
	;    buf.txt and buf.flag.
	;  If BUFFER is not used then use the values in
	;  internal memory (tprint_com common):
	;    txt and flag.
	;  In either case move the values to the working
	;  variables txt0 and flag0.  They are moved back
	;  to buf or common after any operation.
	;
	;  Any time text buffer is changed update the
	;  internal or external buffer.  This will happen
	;  for /INIT or INIT=txt, ADD=txt, or the
	;  straight tprint command.
	;--------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Turn print statements into a text array.'
	  print,' tprint,a1,a2,a3,...'
	  print,'   a1,a2,a3,... = args to tprint.  in'
	  print,'     May have up to 15.'
	  print,' Keywords:'
	  print,'   BUFFER=buf  Set up and use an external buffer, buf instead'
	  print,'     of internal buffer. Use BUFFER=buf on each call to'
	  print,'     tprint.  Will create and return it on /INIT, then'
	  print,'     send as an input on following calls.'
	  print,'   /INIT Clear internal text array.'
	  print,'     May also give an initial text array: INIT=txt.'
	  print,'   ADD=txt Add given text array to internal text.'
	  print,'   OUT=txt Return internal text array.'
	  print,'   /PRINT print internal text array.'
	  print,'   SAVE=file  Save internal text array in a text file.'
	  print,'   /REVERSE reverse text array order (for /PRINT, OUT=, or SAVE=).'
	  print,'   ERROR=err 0=ok, 1=error if OUT or /PRINT used with no text.'
	  print,' Notes: Intended to make it easy to take a set of print'
	  print,'   statements in a program and change them to build up'
	  print,'   a text array.  Uses the IDL string function in place'
	  print,'   of the print statement to handle the arguments.  Can'
	  print,'   then return the text array built up from multiple'
	  print,'   tprint calls and use it elsewhere.'
	  return
	endif
 
	;-----------------------------------------------------------------
	;  Define internal buffer (even if not used)
	;-----------------------------------------------------------------
	if n_elements(flag) eq 0 then flag=0	; Define flag (0 = no text yet).
	if n_elements(txt) eq 0 then txt=''	; Define txt.
 
	;-----------------------------------------------------------------
	;  /INIT or INIT=text_array
	;  Initialize or add given text to working text array
	;  and update internal or external buffer.
	;-----------------------------------------------------------------
	if n_elements(init) gt 0 then begin	; Anything in INIT?
	  if (n_elements(init) eq 1) and (init(0) eq '1') then begin	; /INIT
	    txt0 = ''				; Define.
	    flag0 = 0				; Set no text flag.
	  endif else begin						; INIT=text
	    txt0 = init				; Start with given text.
	    flag0 = 1				; Set have text flag.
	  endelse
	  ;----  Update internal or external buffer  ----
	  if arg_present(buf) then begin	; Create a structure buffer.
	    buf = {txt:txt0, flag:flag0}	; External memory (buffer).
	  endif else begin			; Use internal memory (buffer).
	    txt = txt0
	    flag = flag0
	  endelse
	endif
 
	;-----------------------------------------------------------------
	;  Grab working values from  internal or external buffer
	;-----------------------------------------------------------------
	if arg_present(buf) then begin		; Use external buffer.
	  txt0 = buf.txt
	  flag0 = buf.flag
	endif else begin			; Use internal buffer.
	  txt0 = txt
	  flag0 = flag
	endelse
 
	;-----------------------------------------------------------------
	;  SAVE = file
	;  Save from working text array
	;-----------------------------------------------------------------
	if n_elements(save) ne 0 then begin	; Have a file name for save.
	  if flag0 eq 0 then begin		; If no text return error.
	    err = 1
	    return
	  endif
	  if keyword_set(rev) then tt=reverse(txt0) else tt=txt0
	  openw,lun,save,/get_lun		; Open save file.
	  for i=0,n_elements(tt)-1 do printf,lun,tt(i)	; Print text.
	  free_lun,lun
	  print,' Text saved to '+save
	  err = 0				; OK.
	endif
 
	;-----------------------------------------------------------------
	;  /PRINT 
	;  Print to screen from working text array
	;-----------------------------------------------------------------
	if keyword_set(print) then begin
	  if flag0 eq 0 then begin		; If no text return error.
	    err = 1
	    return
	  endif
	  if keyword_set(rev) then tt=reverse(txt0) else tt=txt0
	  for i=0,n_elements(tt)-1 do print,tt(i)	; Print text.
	  err = 0				; OK.
	endif
 
	;-----------------------------------------------------------------
	;  OUT = txt
	;  Return text from working text array
	;-----------------------------------------------------------------
	if arg_present(out) then begin		; Return text requested.
	  if flag0 eq 0 then begin
	    err = 1
	    return
	  endif
	  err = 0
	  if keyword_set(rev) then tt=reverse(txt0) else tt=txt0
	  out = tt
	  return
	endif
 
	;-----------------------------------------------------------------
	;  ADD = txt
	;  Add given text array to working text array
	;  and update internal or external buffer.
	;-----------------------------------------------------------------
	if n_elements(add) ne 0 then begin
	  if flag0 eq 0 then txt0=add else txt0=[txt0,add] ; Add it to array.
	  flag0 = 1				; Flag array as existing.
	  ;----  Update internal or external buffer  ----
	  if arg_present(buf) then begin	; Use external buffer.
	    buf = {txt:txt0, flag:flag0}
	  endif else begin			; Use internal buffer.
	    txt = txt0
	    flag = flag0
	  endelse
	  return
	endif
 
	;-----------------------------------------------------------------
	;  TPRINT given items
	;  Add items to working text array
	;  and update internal or external buffer.
	;-----------------------------------------------------------------
	n = n_params(0)			; How many args?
	if n eq 0 then return		; None, nothing to do.
 
	case n of
1:	p = string(p1)
2:	p = string(p1,p2)
3:	p = string(p1,p2,p3)
4:	p = string(p1,p2,p3,p4)
5:	p = string(p1,p2,p3,p4,p5)
6:	p = string(p1,p2,p3,p4,p5,p6)
7:	p = string(p1,p2,p3,p4,p5,p6,p7)
8:	p = string(p1,p2,p3,p4,p5,p6,p7,p8)
9:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9)
10:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
11:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11)
12:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12)
13:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13)
14:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14)
15:	p = string(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15)
	endcase
 
 
	if flag0 eq 0 then txt0=p else txt0=[txt0,p]	; Add it to array.
	flag0 = 1			; Flag array as existing.
 
	;----  Update internal or external buffer  ----
	if arg_present(buf) then begin	; Use external buffer.
	  buf = {txt:txt0, flag:flag0}
	endif else begin		; Use internal buffer.
	  txt = txt0
	  flag = flag0
	endelse
 
	end
