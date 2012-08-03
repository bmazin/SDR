;-------------------------------------------------------------
;+
; NAME:
;       XRESGET2
; PURPOSE:
;       Get items from a resfile using a menu.
; CATEGORY:
; CALLING SEQUENCE:
;       xresget2, out, resfile
; INPUTS:
;       resfile = Optional resfile name. in
;         Will prompt if not given.
; KEYWORD PARAMETERS:
;       Keywords:
;         DIR=dir Initial directory to search if prompting
;           for res files (def=current).
; OUTPUTS:
;       out = returned item.             out
;         Null string on error or cancel.
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         If a single item is requested it is returned in out.
;         If multiple items are requested then out will be a
;         structure with the items.
;         This is an extension of xresget by Amir Najmi.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jun 24
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xresget2, out, file, dir=dir, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get items from a resfile using a menu.'
	  print,' xresget2, out, resfile'
	  print,'   out = returned item.             out'
	  print,'     Null string on error or cancel.'
	  print,'   resfile = Optional resfile name. in'
	  print,'     Will prompt if not given.'
	  print,' Keywords:'
	  print,'   DIR=dir Initial directory to search if prompting'
	  print,'     for res files (def=current).'
	  print,' Notes:'
	  print,'   If a single item is requested it is returned in out.'
	  print,'   If multiple items are requested then out will be a'
	  print,'   structure with the items.'
	  print,'   This is an extension of xresget by Amir Najmi.'
	  return
	endif
 
	;-----  Get res file name  ---------
	out = ''
	if n_elements(file) eq 0 then begin		; No res file given.
	  if n_elements(dir) eq 0 then cd,curr=dir	; No directory given.
	  file = dialog_pickfile(filter='*.res',path=dir)  ; File dialog.
	  if file eq '' then return			; None, return.
	endif
 
	;-----  Get res file header  --------
	resopen,file,head=h,err=err,/quiet		; Open requested file.
	if err ne 0 then begin				; Could not open.
	  print,' Error in xresget2: Could not open resfile '+file
	  return
	endif
 
	;------  Get list of items  ---------
	list = xlist(h,/mult)			; Display res header as list.
	if list(0) eq '' then begin		; Nothing selected.
	  resclose
	  return
	endif
	n = n_elements(list)			; # items selected.
 
	;-------  Get ready for any comments  ------
	w = where(strmid(list,0,1) eq '*', cnt)	; Find which items are comments.
	ndig = strtrim(ceil(alog10(1+cnt)),2)	; Max digits in comment tags.
	fmt = '(I'+ndig+'.'+ndig+')'		; Format for digits.
	cmt = '_COMM'				; Comment front.
	ccnt = -1				; Comment counter.
 
	;------  Grab items from the res file  ------
	if n eq 1 then begin			; Single item.
	  if strmid(list(0),0,1) eq '*' then begin	; Comment.
	    out = strmid(list(0),1,999)		; Drop leading *.
	  endif else begin
	    resget,getwrd(list(0)),out		; Get res file item.
	  endelse
	  resclose
	  return
	endif
 
	for i=0,n-1 do begin			; Multiple items.
	  tag = getwrd(list(i))			; Tag name.
	  if strmid(tag,0,1) eq '*' then begin	; Comment?
	    ccnt = ccnt + 1			; Yes, count it.
	    val = strmid(list(i),1,999)		; Drop leading *.
	    tag = cmt+string(ccnt,form=fmt)	; Make structure tag.
	  endif else begin
	    resget,tag,val			; Grab item.
	  endelse
	  if i eq 0 then begin
	    out = create_struct(tag,val)	; Create structure.
	  endif else begin
	    out = create_struct(out,tag,val)	; Add to structure.
	  endelse
	endfor
	resclose
 
	end
