;-------------------------------------------------------------
;+
; NAME:
;       RESEDIT
; PURPOSE:
;       Replace values in a res file.
; CATEGORY:
; CALLING SEQUENCE:
;       resedit, file, tag, new_val
; INPUTS:
;       file = Name of res file.      in
;       tag = tag to update.          in
;       new_val = New value for tag.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok.
;         /QUIET do not give update message.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: New value must be the same type as the old
;         and have the same shape if an array.
;         >>>===> Only works for native endian so far.
;         >>>===> Make sure new value has the same endian
;         as the old value in the file.  The endian is
;         transparent for normal use but the new value
;         must have the same endian as other data in the res
;         file.  This must be done before sending it to this
;         routine.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 20
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro resedit, file, tag, new_val, error=err, quiet=quiet, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Replace values in a res file.'
	  print,' resedit, file, tag, new_val'
	  print,'   file = Name of res file.      in'
	  print,'   tag = tag to update.          in'
	  print,'   new_val = New value for tag.  in'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   /QUIET do not give update message.'
	  print,' Notes: New value must be the same type as the old'
	  print,'   and have the same shape if an array.'
	  print,'   >>>===> Only works for native endian so far.'
;	  print,'   >>>===> Make sure new value has the same endian'
;	  print,'   as the old value in the file.  The endian is'
;	  print,'   transparent for normal use but the new value'
;	  print,'   must have the same endian as other data in the res'
;	  print,'   file.  This must be done before sending it to this'
;	  print,'   routine.'
	  return
	endif
 
	;----------------------------------------------
	;  Get old value and location and header
	;----------------------------------------------
	resopen, file, header=h, err=err
	if err ne 0 then return
	resget, tag, old_val, address=add, found=in, error=err
	resclose
	if err ne 0 then begin
	  print,' Error in resedit: No such tag: '+tag
	  return
	endif
 
	;----------------------------------------------
	;  Make sure data types match
	;----------------------------------------------
	sz_new = size(new_val)
	;------  Old value was an array  ----------
	if add gt 0 then begin
	  sz_old = size(old_val)
	  if max(abs(sz_old-sz_new)) ne 0 then begin
	    err = 1
	    print,' Error in resedit: New value does not match old value'
	    print,'   in type or shape.'
	    return
	  endif
	;------  Old value was a scalar  ----------
	endif else begin
	  if sz_new(0) ne 0 then begin
	    err = 1
	    print,' Error in resedit: New value must be a scalar like old.'
	    return
	  endif
	  ;----  Get new value ready for header  ------
	  val2 = new_val	; Copy a scalar since it may be modified.
	  dtyp = datatype(new_val)
	  if dtyp eq 'BYT' then val2 = fix(new_val)  ; Scalar byte -> int.
	  if dtyp eq 'FLO' then val2 = string(new_val,form='(G16.8)')
	  if dtyp eq 'DOU' then val2 = string(new_val,form='(G26.17)')
	  t = strtrim(tag,2)+' = '+strtrim(val2,2)
	endelse
 
	;----------------------------------------------
	;  Open res file and update value
	;----------------------------------------------
	openu, lun, file, /get_lun	; Openres file for update.
	;------  Old value was an array  ----------
	if add gt 0 then begin
	  point_lun, lun, add		; Point to array address.
	  writeu, lun, new_val		; Write new array.
	;------  Old value was a scalar  ----------
	endif else begin
	  front = lonarr(3)		; First find header address.
	  point_lun,lun,0		; Read 3 long ints at front.
	  readu,lun,front
	  p = front(0)			; May be header address.
	  if p lt 0 then begin		; Was extended file size.
	    p = 0LL			; Long64 value.
	    readu, lun, p		; Read it.
	  endif
	  h(in) = t
	  b = byte(h)			; Convert header to a byte array.
	  sz = size(b)			; Get size.
	  front(1) = sz(1:2)		; Move header size to FRONT array.
	  point_lun, lun, 0		; Set file pointer to file start.
	  writeu, lun, front		; Write header pointer and size.
	  point_lun, lun, p 		; Set file pointer to header position.
	  writeu, lun, b		; Write header as byte array.
	endelse
	free_lun, lun			; Close file.
	if not keyword_set(quiet) then $
	  print,' Value for '+tag+' updated in '+file
 
	end
