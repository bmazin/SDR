;-------------------------------------------------------------
;+
; NAME:
;       HASH_EXAMPLE
; PURPOSE:
;       Example using a hash table.
; CATEGORY:
; CALLING SEQUENCE:
;       hash_example, file
; INPUTS:
;       file = Name of text file, or an array of text.   in
;         Prompts for file if nothing given.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Counts occurrances of words in the text.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Aug 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hash_example, file, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Example using a hash table.'
	  print,' hash_example, file'
	  print,'   file = Name of text file, or an array of text.   in'
	  print,'     Prompts for file if nothing given.'
	  print,' Notes: Counts occurrances of words in the text.'
	  return
	endif
 
	;---------------------------------------------
	;	Get text
	;---------------------------------------------
	if n_params(0) eq 0 then begin		; Nothing given.
	  print,' '				; Prompt for a
	  file = ''				; file name.
	  read,' Enter name of a text file: ',file
	  if file eq '' then return
	endif else begin			; Called with an argument.
	  if n_elements(file) gt 1 then txt=file  ; If an array assume text.
	endelse
 
	if n_elements(file) eq 1 then begin	; If given a scalar assume file.
	  txt = getfile(file,err=err)		; Read text from file.
	  if err ne 0 then return		; File not read.
	endif
	n = n_elements(txt)			; Lines of text.
 
	;------  Loop through lines in text file  --------
	iflag = 1				; Hash table need initialized?
	for i=0L, n-1 do begin			; Loop through text lines.
	  t = str_drop_punc(txt(i),/lower)	; Drop all but alphanumerics.
	  nw = nwrds(t)				; Count words.
	  if nw gt 0 then begin			; If any words left in line ...
	    for j=0,nw-1 do begin		; Loop through words.
	      wd = getwrd(t,j)			; Grab j'th word.
	      if iflag then begin		; Init hash table?
	        hash_init, key=wd,val=1L,n_main=6000,n_over=100,hash=h
	        iflag = 0			; Init done.
	      endif else begin			; Already initialized.
	        val = hash_get(wd, hash=h,err=err,/quiet)  ; Word in hash tbl?
	        if err eq 0 then val=val+1 else val=1	; If yes inc count.
	        hash_put,hash=h, wd,val, new=new	; Save new count.
	        if new then print,' ',wd	; Print word first time.
 	      endelse
	    endfor ; j
	  endif
	endfor ; i
 
	;------  List results  ---------
	hash_list, h, outkeys=keys, outvals=vals, /quiet  ; Get keys and vals.
	is = sort(vals+0)			; Sort on word count.
	tot = long(total(vals))			; Total words.
	vals = strtrim(vals,2)			; Make counts strings.
	keys = keys(is)				; Sort keys.
	vals = vals(is)				; Sort counts.
	print,' '
	if n_elements(file) eq 1 then begin
	  print,' Words found in the text file '+file+':'
	endif else begin
	  print,' Words found in the text:'
	endelse
	more,/num,keys+' = '+vals,lines=50
	print,' Total count: ',tot
 
	end
