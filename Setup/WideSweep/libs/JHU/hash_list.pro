;-------------------------------------------------------------
;+
; NAME:
;       HASH_LIST
; PURPOSE:
;       List all keys in a hash table.
; CATEGORY:
; CALLING SEQUENCE:
;       hash_list, h
; INPUTS:
;       h = hash table structure.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /VALUES lists values with keys.
;         OUTKEYS=okeys Return all keys in hash table.
;         OUTVALUES=oval Return all values in hash table.
;         /QUIET do not list keys.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 30
;       R. Sterner, 2004 Apr 05 --- Added key return and /quiet.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hash_list, h, values=vflag, outkeys=okeys, outvals=ovals, $
	  quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' List all keys in a hash table.'
	  print,' hash_list, h'
	  print,'   h = hash table structure.   in'
	  print,' Keywords:'
	  print,'   /VALUES lists values with keys.'
	  print,'   OUTKEYS=okeys Return all keys in hash table.'
	  print,'   OUTVALUES=oval Return all values in hash table.'
	  print,'   /QUIET do not list keys.'
	  return
	endif
 
	;----  Make sure given structure is the expected hash table  ----
	test = tag_test(h,'link') < tag_test(h,'mkey') < $
	       tag_test(h,'fjump') < tag_test(h,'okey')
	if test eq 0 then begin
	  print,' Error in hash_list: given hash table does not have'
	  print,'   the expected structure.'
	  return
	endif
 
	;------  Look at main table  ----------
	wm_ent = where(h.link gt -2, cm_ent)	; Main table used.
	okeys = strtrim(h.mkey(wm_ent),2)	; Returned keys.
	ovals = h.mval(wm_ent)			; Returned values.
	keytxt = '  [M] '+strtrim(h.mkey(wm_ent),2)	; List text.
	if keyword_set(vflag) then $		; Add vals to list text.
	  keytxt=keytxt+' = '+strtrim(h.mval(wm_ent),2)
 
	;------  Look at overflow table  -------
	wo_ent = where(h.fjump gt -2, co_ent)	; Overflow table used.
	if co_ent gt 0 then begin
	  okeys = [okeys, strtrim(h.okey(wo_ent),2)]	; Returned keys.
	  ovals = [ovals, h.oval(wo_ent)]		; Returned values.
	  okeytxt = '  [O] '+strtrim(h.okey(wo_ent),2)	; List text.
	  if keyword_set(vflag) then $			; Add vals to list text.
	    okeytxt=okeytxt+' = '+strtrim(h.oval(wo_ent),2)
	  keytxt = [keytxt, okeytxt]
	endif
 
	;-------  List report  ------------------
	if keyword_set(quiet) then return
	n = cm_ent + co_ent
	print,' '
	print,' Hash table keys'
	print,' '
	print,' Total entries in hash table: '+strtrim(n,2)
	print,' '
	for i=0,n-1 do print,i,keytxt(i)
	print,' '
 
	end
