;-------------------------------------------------------------
;+
; NAME:
;       HASH_INIT
; PURPOSE:
;       Initialize a hash table.
; CATEGORY:
; CALLING SEQUENCE:
;       hash_init
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         KEY=key  Input string array of keys.
;         VAL=val  Input string array of values.
;         N_MAIN=nm  Input number of entries in the main table.
;         N_OVER=no  Input number of entries in the overflow table.
;         HASH=h  Returned hash table in a structure.
;         COLLISIONS=ncoll  Returned number of collisions on set up.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: User must also provide a hash function which takes
;         one key and converts it to an index into the hash table.
;         This hash function must be called hash_f and take a single
;         string arg (the key) and return a long int (the index into
;         the hash table).  A default hash function will be used
;         unless the user hash function is found on the IDL path
;         first (or is compiled).  The default hash function just
;         sums the ascii codes of the letters in the key and does
;         mod 6000 (so make n_main be 6000 if using the default
;         hash function.  Try n_over=100 or so and check # of
;         collisions to see how close, or check h.next).
;           A hash table allows a value to be looked up based on a
;         given text string, the key.  This version of hash_init
;         uses strings for both the keys and values (can be
;         generalized later).
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
	pro hash_init, key=key, val=val, n_main=n_main, $
	  n_over=n_over, hash=h, collisions=ncoll, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Initialize a hash table.'
	  print,' hash_init'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   KEY=key  Input string array of keys.'
	  print,'   VAL=val  Input string array of values.'
	  print,'   N_MAIN=nm  Input number of entries in the main table.'
	  print,'   N_OVER=no  Input number of entries in the overflow table.'
	  print,'   HASH=h  Returned hash table in a structure.'
	  print,'   COLLISIONS=ncoll  Returned number of collisions on set up.'
	  print,' Notes: User must also provide a hash function which takes'
	  print,'   one key and converts it to an index into the hash table.'
	  print,'   This hash function must be called hash_f and take a single'
	  print,'   string arg (the key) and return a long int (the index into'
	  print,'   the hash table).  A default hash function will be used'
	  print,'   unless the user hash function is found on the IDL path'
	  print,'   first (or is compiled).  The default hash function just'
	  print,'   sums the ascii codes of the letters in the key and does'
	  print,'   mod 6000 (so make n_main be 6000 if using the default'
	  print,'   hash function.  Try n_over=100 or so and check # of'
	  print,'   collisions to see how close, or check h.next).'
	  print,'     A hash table allows a value to be looked up based on a'
	  print,'   given text string, the key.  This version of hash_init'
	  print,'   uses strings for both the keys and values (can be'
	  print,'   generalized later).'
	  return
	endif
 
	;-------------------------------------------------------------------
	;  Set up hash table structure
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
;	mkey = strarr(n_main)	; Main table keys.
;	mval = strarr(n_main)	; Main table values.
;	okey = strarr(n_over)	; Overflow table keys.
;	oval = strarr(n_over)	; Overflow table values.
 
	mkey=make_array(n_main,val=zero_int(/null,key(0))) ; Main tbl keys.
	mval=make_array(n_main,val=zero_int(/null,val(0))) ; Main tbl values.
	okey=make_array(n_over,val=zero_int(/null,key(0))) ; Ovrflw tbl keys.
	oval=make_array(n_over,val=zero_int(/null,val(0))) ; Ovrflw tbl values.
 
	h = {n_main:n_main,         $	; Size of main table.
	     mkey:mkey,             $	; Main table keys.
	     mval:mval,             $	; Main table values.
	     link:lonarr(n_main)-2, $	; Link, if any, to overflow table.
	     n_over:n_over,         $	; Size of overflow table.
	     okey:okey,             $	; Overflow table keys.
	     oval:oval,             $	; Overflow table values.
	     fjump:lonarr(n_over)-2,$	; Chain link in overflow table.
	     next:0L }			; Next unused entry in overflow table.
 
 
	;-------------------------------------------------------------------
	;  Initialize hash table
	;    Below the variable in is the index into the main hash table.
	;    Must check if that index is already in use.
	;    If so then use overflow table.
	;-------------------------------------------------------------------
	ncoll = 0			; Number of collisions during setup.
	for j=0, n_elements(key)-1 do begin
 
	  in = hash_f(key(j))		; Convert key to hash table index.
 
	  ;-------------------------------------------------------------------
	  ;  Hash table index was unused (link(in) eq -2). No collision.
	  ;-------------------------------------------------------------------
	  if h.link(in) eq -2 then begin
	    h.mkey(in) = key(j)		; Add new entry.
	    h.mval(in) = val(j)
	    h.link(in) = -1		; Mark end of chain (1 element chain).
	    continue			; Skip to end of loop.
	  endif
 
	  ;-------------------------------------------------------------------
	  ;  Hash table index was used so this new item causes a
	  ;  collision and will go into overflow table.
	  ;-------------------------------------------------------------------
	  next = h.next			  ; Next overflow table index.
	  if next eq h.n_over then begin  ; Check if overflow table full.
	    print,' Error in hash_init: overflow table full.'
	    stop
	  endif
	  ncoll = ncoll + 1		; Count this collision.
 
	  ;-------------------------------------------------------------------
	  ;  Single hash table entry for this index (link(in) eq -1). 
	  ;  Add new item to overflow table.
	  ;-------------------------------------------------------------------
	  if h.link(in) eq -1 then begin
	    h.link(in) = next		; Set main table link to overflow table.
	    h.okey(next) = key(j)	; Add new entry to overflow table.
	    h.oval(next) = val(j)
	    h.fjump(next) = -1		; Mark end of chain (2 element chain).
	    h.next = next + 1		; Next available entry in overflow tbl.
	    continue
	  endif
 
	  ;-------------------------------------------------------------------
	  ;  in GE 0: Used hash table entry, chains into overflow.
	  ;-------------------------------------------------------------------
	  pn = h.link(in)		; Main tbl entry used, chain to end.
	  while (pn ge 0) do begin	; Find end of chain (-1) in ovrflw tbl.
	    pl = pn			; Index of next item in chain.
	    pn = h.fjump(pn)		; Step along chain.
	  endwhile			; Drops out of loop when pn is -1.
	  h.fjump(pl) = next		; pl was index of last item in chain.
	  h.okey(next) = key(j)
	  h.oval(next) = val(j)
	  h.fjump(next) = -1
	  h.next = next + 1
 
	endfor ; j
 
	end
