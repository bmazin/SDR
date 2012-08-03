;-------------------------------------------------------------
;+
; NAME:
;       BYTARR_PUT
; PURPOSE:
;       Insert a byte array into a byte buffer.
; CATEGORY:
; CALLING SEQUENCE:
;       bytarr_put, buf, in
; INPUTS:
;       in = byte array to add to buffer.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         INDEX=indx  Returned index of inserted byte array:
;           0=1st, 1=2nd, ...  Can be used with bytarr_get to
;           retrieve a given array.
;         ADDRESS=a  returned byte address into buffer for in.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: To start set input buffer b to 1 element:
;         b = [0B] before using in bytarr_put.
;         Can use this routine to build up an array of
;         variable lengths arrays, or pack arrays of any data
;         type together in a compact form.  Must convert input
;         to a byte array first using field extraction.  Ex:
;         a=indgen(10) & b=byte(a,0,2*n_elements(a)) will create
;         an int array and convert it to a byte array.
;         The inverse routine, bytarr_get, allows extraction by
;         index number (1st input is 0, 2nd is 1, ...).
;         You must handle converting from byte when extracting.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 30
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro bytarr_put, b, in, index=indx, address=a, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Insert a byte array into a byte buffer.'
	  print,' bytarr_put, buf, in'
	  print,'   buf = byte buffer to add input to.  in/out'
	  print,'   in = byte array to add to buffer.   in'
	  print,' Keywords:'
	  print,'   INDEX=indx  Returned index of inserted byte array:'
	  print,'     0=1st, 1=2nd, ...  Can be used with bytarr_get to'
	  print,'     retrieve a given array.'
	  print,'   ADDRESS=a  returned byte address into buffer for in.'
	  print,' Notes: To start set input buffer b to 1 element:'
	  print,'   b = [0B] before using in bytarr_put.'
	  print,'   Can use this routine to build up an array of'
	  print,'   variable lengths arrays, or pack arrays of any data'
	  print,'   type together in a compact form.  Must convert input'
	  print,'   to a byte array first using field extraction.  Ex:'
	  print,'   a=indgen(10) & b=byte(a,0,2*n_elements(a)) will create'
	  print,'   an int array and convert it to a byte array.'
	  print,'   The inverse routine, bytarr_get, allows extraction by'
	  print,'   index number (1st input is 0, 2nd is 1, ...).'
	  print,'   You must handle converting from byte when extracting.'
	  return
	endif
 
	if datatype(b) ne 'BYT' then begin
	  print,' Error in bytarr_put: input buffer must be a byte array.'
	  return
	endif
 
	if datatype(in) ne 'BYT' then begin
	  print,' Error in bytarr_put: input array must be a byte array.'
	  print,' Use field extraction to convert other data types to byte.'
	  print,' Ex: a=indgen(10) & b=byte(a,0,2*n_elements(a)) will create'
          print,'   an int array and convert it to a byte array.'
	  return
	endif
 
	;-----  Initialize buffer  ----------
	;	to 3 long ints: pointer to pointer table,
	;	# entries in pointer table, next insertion byte.
	if n_elements(b) lt 12 then b=byte([4L,1L,4L],0,12)
 
	;------  Get pointers  ---------------
	;	Last entry in pointer table is always pointer
	;	to location to add next enrty.
	p = (long(b,0,1))(0)		; Offset to pointer table.
	c = (long(b,p,1))(0)		; Number of pointers in table.
	pt = long(b,p+4,c)		; Get pointer table.
 
	;------  Get ready to add new entry  --------------
	len = n_elements(in)		; Length of new entry in bytes.
	indx = c-1			; Index into pointer table.
	a = pt(indx)			; Insertion address.
	c = c+1				; Count new entry.
	nxt = a+len			; Next entry address.
	pt = [pt,nxt]			; Add next entry addr to pointer table.
	p = p+len			; Update offset to pointer table.
 
	;------  Actually add new entry and update buffer  ---------
	if c eq 2 then begin		; First entry.
	  b = [byte(p,0,4),in,byte(c,0,4),byte(pt,0,c*4)]
	endif else begin
	  b = [byte(p,0,4),b(4:a-1),in,byte(c,0,4),byte(pt,0,c*4)]
	endelse
 
	return
	end
