;-------------------------------------------------------------
;+
; NAME:
;       HASH_STATS
; PURPOSE:
;       Look at the statistics of a hash table.
; CATEGORY:
; CALLING SEQUENCE:
;       hash_stats, h
; INPUTS:
;       h = hash table structure.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: lists various values of the given hash table.
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
	pro hash_stats, h, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Look at the statistics of a hash table.'
	  print,' hash_stats, h'
	  print,'   h = hash table structure.   in'
	  print,' Notes: lists various values of the given hash table.'
	  return
	endif
 
	;----  Make sure given structure is the expected hash table  ----
	test = tag_test(h,'link') < tag_test(h,'mkey') < $
	       tag_test(h,'fjump') < tag_test(h,'okey')
	if test eq 0 then begin
	  print,' Error in hash_stats: given hash table does not have'
	  print,'   the expected structure.'
	  return
	endif
 
	;------  Look at main table  ----------
	wm_null = where(h.link eq -2, cm_null)	; Main table unused.
	wm_ent = where(h.link gt -2, cm_ent)	; Main table used.
	wm_ch = where(h.link ge 0, cm_ch)	; Main table chained to ovrflw.
	cm_1 = cm_ent - cm_ch			; # main table single entries.
 
	tmp = strtrim(h.mkey(wm_ent),2)
	m_maxlen = max(strlen(tmp))	; Max main table key length.
	m_minlen = min(strlen(tmp))	; Min main table key length.
 
	;------  Look at overflow table  -------
	wo_null = where(h.fjump eq -2, co_null)	; Overflow table unused.
	wo_ent = where(h.fjump gt -2, co_ent)	; Overflow table used.
	wo_ch = where(h.fjump ge 0, co_ch)	; Overflow table chained.
	wo_1 = where(h.fjump eq -1, co_1)	; Overflow table single entries.
 
	tmp = strtrim(h.okey(wo_ent),2)
	o_maxlen = max(strlen(tmp))	; Max ovrflw table key length.
	o_minlen = min(strlen(tmp))	; Min ovrflw table key length.
 
	;---  Measure chain lengths in overflow table  ----
	chains = intarr(10)		; Count chains of various lengths.
	chains(1) = co_1		; Single length chains.
	if co_ch gt 0 then begin	; Any longer chains?
	  for i=0, co_ch-1 do begin	; Yes, loop through all chains.
	    p = h.fjump(wo_ch(i))	; First link in chain.
	    len = 1			; Length 1 so far.
	    while p ge 0 do begin	; Follow chain until link is -1.
	      p = h.fjump(p)		; Next link.
	      len = len + 1		; Add to chain length.
	    endwhile
	    chains(len<9) = chains(len<9)+1	; Increment chain of length len.
	  endfor
	endif
	wch = where(chains gt 0, nch)	; Find all chains in overflow table.
	chmax = max(wch)		; Max chain length.
 
	;-------  List report  ------------------
	print,' '
	print,' Hash table statistics'
	print,' '
	print,' Total entries in hash table: '+strtrim(cm_ent+co_ent,2)
	print,'                  Collisions: '+strtrim(co_ent,2) + $
	  ' ('+string(100.*co_ent/(cm_ent+co_ent),form='(F5.1)')+'%)'
	print,'   Hash table key type: '+datatype(h.mkey,1)
	print,'   Hash table value type: '+datatype(h.mval,1)
	print,' '
	print,' Size of main table: '+strtrim(h.n_main)
	print,'   Entries filled: '+strtrim(cm_ent,2)+$
	  ' ('+string(100.*cm_ent/h.n_main,form='(F5.1)')+'%)'
	print,'   Entries unused: '+strtrim(cm_null,2)+$
	  ' ('+string(100.*cm_null/h.n_main,form='(F5.1)')+'%)'
	print,'   Single entries: '+strtrim(cm_1,2)+$
	  ' ('+string(100.*cm_1/h.n_main,form='(F5.1)')+'%)'
	print,'   Chained entries: '+strtrim(cm_ch,2)+$
	  ' ('+string(100.*cm_ch/h.n_main,form='(F5.1)')+'%)'
	print,'   Min key length: '+strtrim(m_minlen,2)
	print,'   Max key length: '+strtrim(m_maxlen,2)
	print,' '
	print,' Size of overflow table: '+strtrim(h.n_over)
	print,'   Entries filled: '+strtrim(co_ent,2)+$
	  ' ('+string(100.*co_ent/h.n_over,form='(F5.1)')+'%)'
	print,'   Entries unused: '+strtrim(co_null,2)+$
	  ' ('+string(100.*co_null/h.n_over,form='(F5.1)')+'%)'
	print,'   Single entries: '+strtrim(co_1,2)+$
	  ' ('+string(100.*co_1/h.n_over,form='(F5.1)')+'%)'
	print,'   Chained entries: '+strtrim(co_ch,2)+$
	  ' ('+string(100.*co_ch/h.n_over,form='(F5.1)')+'%)'
	print,'   Min key length: '+strtrim(o_minlen,2)
	print,'   Max key length: '+strtrim(o_maxlen,2)
	print,'   Chain lengths:'
	for i=1, chmax do begin
	  print,'     # chains of length '+ $
	    strtrim(i,2)+': '+strtrim(chains(i),2)
	endfor
	print,' '
 
	end
