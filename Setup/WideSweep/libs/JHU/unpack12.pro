;-------------------------------------------------------------
;+
; NAME:
;       UNPACK12
; PURPOSE:
;       Unpack 12-bit data into 16-bit data.
; CATEGORY:
; CALLING SEQUENCE:
;       in = unpack12(bb)
; INPUTS:
;       bb = byte array with packed 12-bit data.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok, 1=error: wrong number of bytes.
; OUTPUTS:
;       in = returned unsigned 16-bit integer data.  out
; COMMON BLOCKS:
; NOTES:
;       Note: Must have correct number of bytes in bb to
;       contain a whole number of unpacked values.
;       Invalid numbers of bytes: 1, 4, 7, 10, ...
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 29
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function unpack12, bb0, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Unpack 12-bit data into 16-bit data.'
	  print,' in = unpack12(bb)'
	  print,'   bb = byte array with packed 12-bit data.     in'
	  print,'   in = returned unsigned 16-bit integer data.  out'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok, 1=error: wrong number of bytes.'
	  print,' Note: Must have correct number of bytes in bb to'
	  print,' contain a whole number of unpacked values.'
	  print,' Invalid numbers of bytes: 1, 4, 7, 10, ...'
	  return, ''
	endif
 
	bb = bb0			; Make a copy of data.
 
	;------------------------------------------------------------
	;  Check for incorrect number of bytes
	;	Not allowed to have 1, 4, 7, 10, ... bytes
	;	since those numbres cannot hold a whole
	;	number of unpacked values.  These are 3*n+1.
	;------------------------------------------------------------
	n = n_elements(bb)		; Number of incoming bytes.
	if ((n-1) mod 3) eq 0 then begin
	  err = 1
	  return, -1
	endif
	err = 0
 
	;------------------------------------------------------------
	;  Set up needed indexing tables
	;	tbl is the pick-off order from the incoming
	;	byte array.  Every 3rd byte has halves of
	;	two different unpacked values.  The pick-off
	;	indices will be 0,1,1,2,3,4,4,5,6,7,7,8,...
	;------------------------------------------------------------
	n_out = floor(n/1.5)		; Number of unpacked values.
	nrows = ceil(n_out/2.)		; Table size.
	if (nrows mod 2) eq 1 then nrows=nrows+1	; Force nrows even.
	tbl = rebin([0,1,1,2],4,nrows) + rebin(lindgen(nrows),4*nrows)*3
 
	;------------------------------------------------------------
	;  Extract bytes into a new byte array
	;	This new array will have the needed repeated bytes,
	;	and maybe a few 0s at end that will be dropped.
	;------------------------------------------------------------
	bb2 = ([bb(0:*),0B,0B,0B,0B,0B,0B])(tbl)
 
	;------------------------------------------------------------
	;  Now grab the correct bytes into 16-bit words.
	;	This will give words with extra bits on the end,
	;	and words that need shifted.
	;------------------------------------------------------------
	n_out2 = n_out
	if (n_out2 mod 2) eq 1 then n_out2=n_out2+1	; Force even.
	in = uint(bb2,0,n_out2)				; Extract 16-bit words.
	if endian() eq 0 then byteorder, in		; Swap bytes.
 
	;------------------------------------------------------------
	;  Correct the bits, and return.
	;	Words 0,2,4,... need upper bits masked off.
	;	Words 1,3,5,... need shifted first, then masked.
	;------------------------------------------------------------
	in = reform(in, 2, n_out2/2)	; Put in 2 columns.
	in(0,0) = ishft(in(0,*),-4)	; Shift 1st column.
	in = in and 4095		; Mask off upper 4 bits.
	
	return, in(0:n_out-1)		; Pick off needed values.
 
	end
