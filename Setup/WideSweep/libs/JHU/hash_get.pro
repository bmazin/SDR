;-------------------------------------------------------------
;+
; NAME:
;       HASH_GET
; PURPOSE:
;       Get a value from a hash table given a key.
; CATEGORY:
; CALLING SEQUENCE:
;       val = hash_get(key)
; INPUTS:
;       key = key string.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         HASH=h hash table (made by hash_init).  Required.
;         ERROR=err  Error flag: 0=ok, else no entry for key.
;         /QUIET inhibit error messages.
;         FLAG=f  key found in 0: main table, 1: overflow table.
;         INDEX=indx Index of key in table (main or overflow).
; OUTPUTS:
;       val = value string.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 29
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function hash_get, key, hash=h, error=err, quiet=quiet, $
	  index=indx, flag=flag, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get a value from a hash table given a key.'
	  print,' val = hash_get(key)'
	  print,'   key = key string.    in'
	  print,'   val = value string.  out'
	  print,' Keywords:'
	  print,'   HASH=h hash table (made by hash_init).  Required.'
	  print,'   ERROR=err  Error flag: 0=ok, else no entry for key.'
	  print,'   /QUIET inhibit error messages.'
	  print,'   FLAG=f  key found in 0: main table, 1: overflow table.'
	  print,'   INDEX=indx Index of key in table (main or overflow).'
	  return,''
	endif
 
	if n_elements(h) eq 0 then begin
	  print,' Error in hash_get: must give hash table using'
	  print,'   the HASH keyword.'
	  stop
	endif
 
	err = 0
 
	in = hash_f(key)	; Hash index.
	indx = in		; Assume into main table.
	flag = 0		; Assume any match from main table.
 
	p = h.link(in)		; Link.
 
	;----  No entry for given key  ----------
	if p eq -2 then begin	; No entry at index in.
	  err = 1
	  if not keyword_set(quiet) then begin
	    print,' Error in hash_get: No entry for given key.'
	    print,'   Key = '+key
	  endif
	  return, ''
	endif
 
	;----  Single entry for given key  -------
	if p eq -1 then return, h.mval(in)
 
	;----  Multiple entries for given key  ---
	;----  Key found in main table  ----------
	if key eq h.mkey(in) then return, h.mval(in)
 
	flag = 1		; Any matches are from overflow table.
 
	;----  Search overflow table for key  ----
	repeat begin		; Chain through multiple entries.
	  if key eq h.okey(p) then begin
	    indx = p
	    return, h.oval(p)
	  endif
	  p = h.fjump(p)	; Next item in chain (if not -1).
	endrep until (p lt 0)	; End of chain when p is -1.
 
	err = 1
 
	if not keyword_set(quiet) then begin
	  print,' Error in hash_get: No entry for given key.'
	  print,'   Key = '+key
	endif
	return, ''
 
	end
