;-------------------------------------------------------------
;+
; NAME:
;       MAP_PUT_BYTES
; PURPOSE:
;       Add extra info to resmap embedded scaling array.
; CATEGORY:
; CALLING SEQUENCE:
;       map_put_bytes, code, bb
; INPUTS:
;       code = Code for new info.  Must be 10001 to 10100.  in
;       bb = Byte array with new info to add.               in
; KEYWORD PARAMETERS:
;       Keywords:
;         /RESET clears all extra info from internal array.
;           If info already written to image this will not clear
;           it away unless a new image is created.
;         ERROR=err Error flag: 0=ok, else error.
; OUTPUTS:
; COMMON BLOCKS:
;       map_set2_com
; NOTES:
;       Notes: Do map commands using map_set2, which works just.
;         like map_set but keeps map projection info in a byte
;         array which is later embedded in the map by map_put_scale.
;         This routine, map_put_bytes, can be used to add extra info
;         beyond the end of the byte array.  code is a unique
;         value for the added user info and should be a value from
;         10001 through 10100.  Any info to be added should be
;         converted to a byte array by the caller.  A routine that
;         uses this info must know how to convert it back after
;         getting it using map_get_bytes.  A map_put_scale command
;         must be given after calling this routine to actually add
;         the extra info to the image, else it will be lost.
;       
;         See also map_get_bytes.pro.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Mar 18
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_put_bytes, code, bb, error=err, reset=reset, help=hlp
 
	common map_set2_com, pack
 
	if (n_params(0) eq 1) or keyword_set(hlp) then begin
	  print,' Add extra info to resmap embedded scaling array.'
	  print,' map_put_bytes, code, bb'
	  print,'   code = Code for new info.  Must be 10001 to 10100.  in
	  print,'   bb = Byte array with new info to add.               in'
	  print,' Keywords:'
	  print,'   /RESET clears all extra info from internal array.'
	  print,'     If info already written to image this will not clear'
	  print,'     it away unless a new image is created.'
	  print,'   ERROR=err Error flag: 0=ok, else error.'
	  print,' Notes: Do map commands using map_set2, which works just.'
	  print,'   like map_set but keeps map projection info in a byte'
	  print,'   array which is later embedded in the map by map_put_scale.'
	  print,'   This routine, map_put_bytes, can be used to add extra info'
	  print,'   beyond the end of the byte array.  code is a unique''
	  print,'   value for the added user info and should be a value from'
	  print,'   10001 through 10100.  Any info to be added should be'
	  print,'   converted to a byte array by the caller.  A routine that'
	  print,'   uses this info must know how to convert it back after'
	  print,'   getting it using map_get_bytes.  A map_put_scale command'
	  print,'   must be given after calling this routine to actually add'
	  print,'   the extra info to the image, else it will be lost.'
	  print,' '
	  print,'   See also map_get_bytes.pro.'
	  return
	endif
 
	packlen = 160		; Length in bytes of pack array.
 
	err = 1
 
	;------  Make sure a map_set2 command was done  -----------
	if n_elements(pack) eq 0 then begin
 	  print,' Error in map_put_bytes: Map scaling not available to add to.'
	  print,'   Must do a map_set2 command first.'
	  return
	endif
 
	;------  Reset  --------------------------
	if keyword_set(reset) then begin
	  pack = pack(0:packlen-1)
	endif
 
	;------  Check code  ---------------------
	if n_params(0) ne 2 then return
	if (code lt 10001) or (code gt 10100) then begin
	  print,' Error in map_put_bytes: code value out of range:'
	  print,'   10001 < code < 10100'
	  return
	endif
 
	;------  Add new info to end of pack array  ----------------
	n = fix(n_elements(bb))
	add = [byte(fix(code),0,2),byte(n,0,2),bb]
	pack = [pack, add]
 
	err = 0
 
	return
	end
