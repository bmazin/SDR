;-------------------------------------------------------------
;+
; NAME:
;       HASH_PUT
; PURPOSE:
;       Update a value in a hash table. If not there add as new item.
; CATEGORY:
; CALLING SEQUENCE:
;       hash_put, key, val
; INPUTS:
;       key = Key into hash table.       in
;       val = value to update (or add).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         HASH=h  Hash table in a structure.
;         NEWFLAG=new  1=added as new entry, 0=updated existing val.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Updates a value in an existing hash table (made by
;         hash_init.  If no entry for given key then will add key
;         and value as a new entry in the hash table.
;         See hash_init,/help for more on the user provided
;         hash function.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 30
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hash_put, key, val, hash=h, newflag=new, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Update a value in a hash table. If not there add as new item.'
	  print,' hash_put, key, val'
	  print,'   key = Key into hash table.       in'
	  print,'   val = value to update (or add).  in'
	  print,' Keywords:'
	  print,'   HASH=h  Hash table in a structure.'
	  print,'   NEWFLAG=new  1=added as new entry, 0=updated existing val.'
	  print,' Notes: Updates a value in an existing hash table (made by'
	  print,'   hash_init.  If no entry for given key then will add key'
	  print,'   and value as a new entry in the hash table.'
	  print,'   See hash_init,/help for more on the user provided'
	  print,'   hash function.'
	  return
	endif
 
	;-------------------------------------------------------------------
	;  Hash table structure:
	;    The complete hash table consists of a main table and
	;    an overflow table. Each subtable contains 3 arrays:
	;      key = Key for entry.
	;      val = Value for key.
	;      link = table index to next entry when multiple keys
	;        map to the same main table index.  If table index
	;        not used (main or overflow) the link is -2.  If it is
	;        used but is the only entry link is -1.  0 or more is the
	;        index into the overflow table for next entry.
	;        For the overflow table the link array is called fjump.
	;-------------------------------------------------------------------
 
	;-------------------------------------------------------------------
	;  Add or update a hash table entry.
	;    Below the variable in is the index into the main hash table.
	;-------------------------------------------------------------------
 
	in = hash_f(key)		; Convert key to hash table index.
 
	p = h.link(in)			; Link.
 
	new = 0				; Assume existing.
 
	;-------------------------------------------------------------------
	;  Hash table index was unused (link(in) eq -2). Add as new entry.
	;-------------------------------------------------------------------
	if p eq -2 then begin
	  h.mkey(in) = key		; Add new entry.
	  h.mval(in) = val
	  h.link(in) = -1		; Mark end of chain (1 element chain).
	  new = 1
	  return
	endif
 
	;-------------------------------------------------------------------
	;  Single entry for given key (link(in) eq -1).  Update value.
	;-------------------------------------------------------------------
	if p eq -1 then begin
	  h.mval(in) = val		; Update value.
	  return
	endif
 
	;-------------------------------------------------------------------
	;  Multiple entries for given key.
	;  Key found in main table. Update value. 
	;-------------------------------------------------------------------
	if key eq h.mkey(in) then begin
	  h.mval(in) = val
	  return
	endif
 
	;-------------------------------------------------------------------
	;  Search overflow table for key.
	;-------------------------------------------------------------------
	repeat begin		; Chain through multiple entries.
	  if key eq h.okey(p) then begin	; Found key match.
	    h.oval(p) = val	; Update value.
	    return
	  endif
	  pl = p		; Index of next item in chain.
	  p = h.fjump(p)	; Next item in chain (if not -1).
	endrep until (p lt 0)	; End of chain when p is -1.
	next = h.next
	if next eq h.n_over then begin  ; Check if overflow table full.
	  print,' Error in hash_put: overflow table full.'
	  stop
	endif
	new = 1			; Flag as new entry.
	h.fjump(pl) = next	; Was -1, update to point to new entry.
	h.okey(next) = key	; Add new entry to overflow table.
	h.oval(next) = val
	h.fjump(next) = -1	; Mark end of chain.
	h.next = next + 1	; Next available entry in overflow tbl.
 
	end
