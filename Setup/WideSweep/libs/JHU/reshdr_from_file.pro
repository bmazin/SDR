;-------------------------------------------------------------
;+
; NAME:
;       RESHDR_FROM_FILE
; PURPOSE:
;       Replace a RES file header from a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       reshdr_from_file, resfile, txtfile
; INPUTS:
;       resfile = name of RES file.  in
;       txtfile = name of text file. in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Text from a specified text file is used to replace
;       the header in the specified RES file.
;       Use reshdr_to_file to put a RES file header into a text file.
;       May edit the text file with the header, adding comments
;       and scalar values, and changing the order of the items.
;       Do not change the data types,array sizes, or locations
;       or the data may be lost.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 20
;       R. Sterner, 2004 Feb 10 --- Supported extended file pointer (LONG64).
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro reshdr_from_file, resfile, txtfile, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Replace a RES file header from a text file.'
	  print,' reshdr_from_file, resfile, txtfile'
	  print,'   resfile = name of RES file.  in'
	  print,'   txtfile = name of text file. in'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok.'
	  print,' Notes: Text from a specified text file is used to replace'
	  print,' the header in the specified RES file.'
	  print,' Use reshdr_to_file to put a RES file header into a text file.'
	  print,' May edit the text file with the header, adding comments'
	  print,' and scalar values, and changing the order of the items.'
	  print,' Do not change the data types,array sizes, or locations'
	  print,' or the data may be lost.'
	  return
	endif
 
	;------  Read new header from text file  -------
	h = getfile(txtfile,err=err)	; Read new header text.
	if err ne 0 then return
	bb = byte(h)			; Convert to byte array.
	sz = size(bb)			; Dimensions.
	nx = sz(1)
	ny = sz(2)
 
	;------  Open RES file  ----------
	openu,lun,resfile,/get_lun,error=err
	if err ne 0 then begin
	  print,' Error in reshdr_from_file: '+!error_state.msg
	  return
	endif
 
	;----  Get header pointer -------
	a = lonarr(3)
	point_lun,lun,0
	readu,lun,a	; a(0) = location of header in file, a(1), a(2) = size.
 
	;----  New header pointer  ------
	b = [a(0),nx,ny]	; File byte # (or -1), bb width, bb length.
 
	;----  Update RES file  ---------
	fp = a(0)		; File pointer to hdr (or -1 if extended fp).
	if fp eq -1 then begin	; Using extended file pointer (long64).
	  fp = 0LL
	  readu,lun,fp		; Read extended file pointer.
	endif
;	point_lun, lun, a(0)	; Jump to header location.
	point_lun, lun, fp	; Jump to header location.
	writeu, lun, bb		; Write new header.
	point_lun, lun, 0	; Jump to front.
	writeu, lun, b		; Write new hdr pointer (new size, loc same).
 
	free_lun, lun		; Close file.
 
	end
