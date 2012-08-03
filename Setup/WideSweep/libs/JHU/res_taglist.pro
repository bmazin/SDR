;-------------------------------------------------------------
;+
; NAME:
;       RES_TAGLIST
; PURPOSE:
;       Get requested values from list list of res files.
; CATEGORY:
; CALLING SEQUENCE:
;       res_taglist, files, tags, vals
; INPUTS:
;       files = list of res files.                     in
;       tags = list of tags to read from those files.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         RESERR=char1 Character to indicate res file open
;           error (def='-').
;         TAGERR=char1 Character to indicate tag
;           error (def='*').
;         /LIST list results in a table.
;         /FRIGHT List res file on right side of table.
;         PIX=px Pixels/character for width (def=8).
;           May be needed if columns are not correct width.
;         NCOLS=nx Number of columns to display (def= up to 10).
;         NROWS=ny Number of rows to display (def= up to 20).
; OUTPUTS:
;       vals = returned list of values for those tags. out
; COMMON BLOCKS:
; NOTES:
;       Note: If there are N files and M tags then vals
;         will be a string array of dimensions M x N.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jan 11
;       R. Sterner, 2005 Nov 10 --- PIX change to 8 from 7. Added NCOLS, NROWS.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro res_taglist, files, tags, vals, help=hlp, $
	  reserr=reserr, tagerr=tagerr, list=list, $
	  fright=fright, pix=px, ncols=ncols,nrows=nrows
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Get requested values from list list of res files.'
	  print,' res_taglist, files, tags, vals'
	  print,'   files = list of res files.                     in'
	  print,'   tags = list of tags to read from those files.  in'
	  print,'   vals = returned list of values for those tags. out'
	  print,' Keywords:'
	  print,'   RESERR=char1 Character to indicate res file open'
	  print,"     error (def='-')."
	  print,'   TAGERR=char1 Character to indicate tag'
	  print,"     error (def='*')."
	  print,'   /LIST list results in a table.'
	  print,'   /FRIGHT List res file on right side of table.'
	  print,'   PIX=px Pixels/character for width (def=8).'
	  print,'     May be needed if columns are not correct width.'
	  print,'   NCOLS=nx Number of columns to display (def= up to 10).'
	  print,'   NROWS=ny Number of rows to display (def= up to 20).'
	  print,' Note: If there are N files and M tags then vals'
	  print,'   will be a string array of dimensions M x N.'
	  return
	endif
 
	;---------------------------------------
	;  Set up output values array
	;---------------------------------------
	n = n_elements(files)	; # Files.
	m = n_elements(tags)	; # Tags.
	vals = strarr(m,n)	; # Values.
	if n_elements(reserr) eq 0 then reserr = '-' ; Could not read res file.
	if n_elements(tagerr) eq 0 then tagerr = '*' ; Could not read tag.
	if n_elements(ncols) eq 0 then ncols=10
	if n_elements(nrows) eq 0 then nrows=20
 
	;---------------------------------------
	;  Loop through res files
	;---------------------------------------
	for i=0,n-1 do begin
 
	  ;---------------------------------------
	  ;  Open res file
	  ;---------------------------------------
	  resopen,files(i),error=err
 
	  ;---------------------------------------
	  ;  Handle open error
	  ;---------------------------------------
	  if err ne 0 then begin
	    vals(*,i) = reserr	; Could not open res file.  Flag.
	    continue		; Skip rest of i loop.
	  endif
 
	  ;---------------------------------------
	  ;  Loop through tags
	  ;---------------------------------------
	  for j = 0, m-1 do begin
	    resget,tags(j),v,err=err
	    if err ne 0 then v=tagerr	; Tag not read, flag.
	    vals(j,i) = v		; Insert value.
	  endfor ; j
 
	endfor ; i
	resclose			; Close last res file.
 
	;---------------------------------------
	;  List
	;---------------------------------------
	if not keyword_set(list) then return
	nx = dimsz(vals,1)		; # Columns.
	ny = dimsz(vals,2)		; # Rows.
	txt = strarr(nx+1,ny+1)		; Allow space for file and tag names.
	txt(1,1) = vals			; Insert values.
	txt(*,0) = ['RES File',tags]	; Column headers.
	txt(0,1:*) = files		; File names.
	if keyword_set(fright) then txt = shift(txt,-1,0) ; Shift files to rt.
 
	if n_elements(px) eq 0 then px=8  ; Need a better way to get this.
	wid = px*[max(strlen(txt),dim=2)] ; Column widths (pixels).
 
	top = widget_base(title=' ')	; Set up table widget.
	id=widget_table(top,val=txt,column_widths=wid, $
	  /no_column_head,/no_row_head,/scroll, $
	  x_scroll_size=(nx+1)<ncols, $
	  y_scroll_size=(ny+1)<nrows)
	widget_control,top,/real
 
	end
