;-------------------------------------------------------------
;+
; NAME:
;       RDCOL
; PURPOSE:
;       Read columns of numbers or times from a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       a = rdcol(file, rec1, rec2, cols)
; INPUTS:
;       file = name of text file.                  in
;       rec1, rec2 = file records to read.         in
;         First record is number 1.
;         To read to end of file set rec2 to a large value.
;       cols = array of column numbers to read.    in
;         First column is 1.  Use negatives for
;         times. Ex: if column 2 is a time use -2.
; KEYWORD PARAMETERS:
;       Keywords:
;         /UNEVEN means file records have a variable number of
;           columns. Process each record by itself.  Slower.
;         /SIGN means return only arithmetic sign of each number.
;           -1 if first char is -, else 1.
;         ERR = e.  Error flag.  0=ok, 1=file not opened,
;           2=probably didn't skip over header.
; OUTPUTS:
;       a = array of selected columns.  Floating.  out
;         There are as many columns as elements.
;         in cols. There are rec2-rec1+1 rows.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Jan, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function rdcol, file, rec1, rec2, cols, uneven=un, help=hlp, err=ee, $
	   sign=sgn
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Read columns of numbers or times from a text file.'
	  print,' a = rdcol(file, rec1, rec2, cols)'
	  print,'   file = name of text file.                  in'
	  print,'   rec1, rec2 = file records to read.         in'
	  print,'     First record is number 1.'
	  print,'     To read to end of file set rec2 to a large value.'
	  print,'   cols = array of column numbers to read.    in'
	  print,'     First column is 1.  Use negatives for' 
	  print,'     times. Ex: if column 2 is a time use -2.'
	  print,'   a = array of selected columns.  Floating.  out'
	  print,'     There are as many columns as elements.'
	  print,'     in cols. There are rec2-rec1+1 rows.'
	  print,' Keywords:'
	  print,'   /UNEVEN means file records have a variable number of'
	  print,'     columns. Process each record by itself.  Slower.'
	  print,'   /SIGN means return only arithmetic sign of each number.'
	  print,'     -1 if first char is -, else 1.'
	  print,'   ERR = e.  Error flag.  0=ok, 1=file not opened,'
	  print,"     2=probably didn't skip over header."
	  return, -1
	endif
 
	get_lun, lun		; Get a unit number.
	on_ioerror, ioerr
	openr, lun, file	; Open file.
	n = rec2 - rec1 + 1
	lst = n - 1
	s = strarr(rec2-rec1+1)	; Set up string array to read.
	t = ''
	for i = 1L, rec1-1 do readf, lun, t	; Read & skip unwanted records.
	i = 0					; Counter.
	while not eof(lun) do begin		; Loop through file records.
	  readf, lun, t				; Read a record.
	  s(i) = t				; Store it.
	  if i eq lst then goto, jmp
	  i = i + 1				; Count it.
	endwhile
	i = i - 1
jmp:	s = s(0:i)		; Trim off un-used space.
	close, lun		; Close file.
	free_lun, lun		; Free unit number.
 
	nx = n_elements(cols)
	ny = n_elements(s)
 
	out = dblarr(nx, ny)
 
	;-----  process uneven records  ----------
	if keyword_set(un) then begin
	  wp0 = where(cols gt 0, countp)		; Indices of numbers.
	  if countp gt 0 then wp = cols(wp0)-1		; Word pos. in record.
	  wn0 = where(cols lt 0, countn)		; Indices of times.
	  if countn gt 0 then wn = abs(cols(wn0))-1	; Word pos. in records.
	  for i=0L, ny-1 do begin			; Loop thru records.
	    t0 = s(i)					; Pull out record.
	    if countp gt 0 then begin			; Numbers.
	      t = wordorder(t0,wp)			;   Pull out words.
	      wordarray, t, x				;   Put words in array.
	      if keyword_set(sgn) then begin		;   Want sign of #s.
		x = 1 - 2*(strmid(x,0,1) eq '-')	;   -1 if x<0 else, 1.
	      endif
	      out(wp0,i) = x + 0.0d0			;   Put into out.	
	    endif
	    if countn gt 0 then begin			; Times.
	      t = wordorder(t0, wn)
	      wordarray, t, x
	      out(wn0,i) = secstr(x) 
	    endif
	  endfor
	  ee = 0
	  return, out
	endif
 
	;-----  Process even records  ----------
	nr = nwrds(s(0))		; # words in record.
	wordarray, s, wds		; Linear word array.
	ind = indgen(nr*ny) mod nr	; Rec pos of words.
	for i = 0L, nx-1 do begin	; Loop thru columns.
	  ic = cols(i)			; Rec word pos for i'th out col.
	  w = where(ind eq (abs(ic)-1), count)  ; Indices for i'th out col. 
	  if count eq 0 then begin	; Error, probably didn't skip header.
	    print,' Error in RDCOL: First record = ' + s(0)
	    ee = 2
	    return, -1
	  endif
	  t = wds(w)				; Get column.
	  if ic lt 0 then begin			; Convert times.
	    t = secstr(t)
	  endif else begin			; Convert numbers.
	    if keyword_set(sgn) then begin	;   Want sign of numbers.
	      t = 1 - 2*(strmid(t,0,1) eq '-')	;     -1 if t lt 0, else 1.
	    endif
	    t = t + 0.0d0
	  endelse
	  out(i,0) = transpose(t)		; Put column in output array.
	endfor
	ee = 0
	return, out
 
ioerr:	print,' Error in rdcol: could not open file '+file
	print, strmessage(!error)
	ee = 1
	free_lun, lun
	return, -1
 
	end
