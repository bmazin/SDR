;-------------------------------------------------------------
;+
; NAME:
;       READTOKEY
; PURPOSE:
;       Read an open text file until a given key word is found.
; CATEGORY:
; CALLING SEQUENCE:
;       readtokey, lun
; INPUTS:
;       lun = unit number of an open text file.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         KEY=K   Key word to search for.  First line in
;           which key word K is found is return in OUT.
;           File is searched up to line MAXLINE (def=1000).
;           Next read gets the next file line.
;         MAXLINE=M  max line to search to.
;         START=S line to start key word search.
;         OUT=txt line of text in which key word was found.
;         ERROR=e error flag.  0=ok, 1=key word not found.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: This is used to skip to a certain line in a
;         file.  Readtokey may be called again to skip to the
;         next occurance of the key word (or another key word).
;         The file line containing the key word may be obtained
;         using the keyword OUT. Following lines in the file
;         may be read using readf.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Feb, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro readtokey, lun, key=k, help=hlp,$
	  start=st, out=out, maxline=max, error=err
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read an open text file until a given key word is found.'
	  print,' readtokey, lun'
	  print,'   lun = unit number of an open text file.   in'
	  print,' Keywords:'
	  print,'   KEY=K   Key word to search for.  First line in'
	  print,'     which key word K is found is return in OUT.'
	  print,'     File is searched up to line MAXLINE (def=1000).'
	  print,'     Next read gets the next file line.'
	  print,'   MAXLINE=M  max line to search to.'
	  print,'   START=S line to start key word search.'
	  print,'   OUT=txt line of text in which key word was found.'
	  print,'   ERROR=e error flag.  0=ok, 1=key word not found.'
	  print,' Notes: This is used to skip to a certain line in a'
	  print,'   file.  Readtokey may be called again to skip to the'
	  print,'   next occurance of the key word (or another key word).'
	  print,'   The file line containing the key word may be obtained'
	  print,'   using the keyword OUT. Following lines in the file'
	  print,'   may be read using readf.'
	  return
	endif
 
	;----------  No KEY set  --------------------------
	if n_elements(k) eq 0 then begin
	  print,' Error in readtokey: no key word given.'
	  err = 1
	  return
	endif
 
	if n_elements(k) ne 0 then k2 = strupcase(k)
	if n_elements(st) eq 0 then st = 1
	if n_elements(max) eq 0 then max = 1000
	txt = ''
	out = ''
	on_ioerror, err
	
	;--- Start at line st, so skip st-1 lines. ---
	if st gt 1 then for i = 1, st-1 do readf, lun, txt
 
	;--- Read up to MAXLINE. ---
	for i = st, max do begin
	  readf, lun, txt
	  ;--- Key word found? ---
	  if strpos(strupcase(txt),k2) ge 0 then goto, done
	endfor
 
	err = 1		; Key word not found.
	print,' Error in readtokey: key word not found.'
	txt = ''
	goto, done2
 
done:	err=0
	out = txt
done2:	return
 
err:	err = 1
	print,' Error in readtokey: End of file encountered.'
	return
 
	end
