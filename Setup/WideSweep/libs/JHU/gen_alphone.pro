;-------------------------------------------------------------
;+
; NAME:
;       GEN_ALPHONE
; PURPOSE:
;       Generate an alph.one file for an IDL library.
; CATEGORY:
; CALLING SEQUENCE:
;       gen_alphone
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=out  Returned alph.one text in a text array.
;         DIR=dir Directory to process (def=current).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Run this routine in any IDL library where the
;       routines have a standard IDL template at the front end.
;       The PURPOSE: text will be extracted and used as the one
;       line description in alph.one.  This text will be place on
;       a single long line in alph.one for each routine.  If no
;       purpose text is found only the routine name will be listed.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jan 08
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro gen_alphone, out=out, dir=dir, save=save, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Generate an alph.one file for an IDL library.'
	  print,' gen_alphone'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   OUT=out  Returned alph.one text in a text array.'
	  print,'   DIR=dir Directory to process (def=current).'
	  print,' Notes: Run this routine in any IDL library where the'
	  print,' routines have a standard IDL template at the front end.'
	  print,' The PURPOSE: text will be extracted and used as the one'
	  print,' line description in alph.one.  This text will be place on'
	  print,' a single long line in alph.one for each routine.  If no'
	  print,' purpose text is found only the routine name will be listed.'
	  return
	endif
 
	;-------  Defaults  ---------------------
	if n_elements(dir) eq 0 then cd,curr=dir
 
	;-------  Find all IDL routines  --------
	wild = filename(dir,'*.pro',/nosym)
	f = file_search(wild,count=fcnt)
	if fcnt eq 0 then begin
	  print,' Error in gen_alphone: No files found in '+dir
	  return
	endif
 
	;-------  Start output  -----------------
	tprint,/init
 
	;-------  Loop through all routines and extract purpose  ------
	print,' Processing '+strtrim(fcnt,2)+' files ...'
	for i=0, fcnt-1 do begin
	  filebreak,f(i),name=nam			; Name of routine.
	  print,' '+nam
	  t = getfile(f(i))				; Read in routine code.
	  strfind,t,'PURPOSE:',index=in1,count=c1,/q	; Find PURPOSE.
	  if c1 eq 0 then begin
	    print,' Error in gen_alphone: could not find PURPOSE.'
	    print,'   Ignored.'
	    continue
	  endif
	  strfind,t,'CATEGORY:',index=in2,count=c2,/q	; Find CATEGORY
	  if c2 eq 0 then begin
	    print,'   Error in gen_alphone: could not find CATEGORY.'
	    print,'   Using a fixed # of lines.'
	    in2 = in1 + 6
	  endif
	  ;-----  Description on purpose line  ------
	  if strlen(t(in1(0))) gt 11 then begin
	    tt = getwrd(t(in1(0)),1,del=':')	; grab text after :.
	    tt = strcompress(tt)		; Drop extra spaces.
	  ;-----  Description follows purpose line  ------
	  endif else begin
	    lo = in1(0)+1			; Purpose text start index.
	    hi = in2(0)-1			; Purpose text end index.
	    if (hi-lo) lt 0 then begin		; No purpose given.
	      print,' Error in gen_alphone: no PURPOSE text.'
	      print,'   Ignored.'
	      continue
	    endif
	    t2 = t(lo:hi)			; Extract purpose text.
	    t2 = strmid(t2,1,99)		; Drop leading ;
	    t2 = strcompress(t2+' ')		; Drop extra space.
	    if t2(0) eq ' ' then begin
	      print,' Error in gen_alphone: no PURPOSE text.'
	      print,'   Ignored.'
	      continue
	    endif
	    w = where(t2 eq ' ',c)		; Include to 1st blank line.
	    if c gt 0 then t2=t2(0:w(0)-1)	; Keep only before blank line.	
	    tt = ''				; Final one line.
	    for j=0,n_elements(t2)-1 do tt=tt+t2(j)  ; Add up lines.
	  endelse
	  tt = nam+': '+tt			; Add name.
	  tprint,tt				; Store line in buffer.
	endfor
 
	;------  get one line descriptions  ------
	tprint,out=out
 
	;------  Save if requested  --------------
	if n_elements(save) ne 0 then begin
	  putfile, save, out
	endif
 
	end
