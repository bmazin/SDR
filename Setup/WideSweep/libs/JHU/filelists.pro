;-------------------------------------------------------------
;+
; NAME:
;       FILELISTS
; PURPOSE:
;       Return specified lists of files in directory.
; CATEGORY:
; CALLING SEQUENCE:
;       filelists
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         PREFILTER=pre  Given specification on prefiltering full
;           list.  This is optional.  pre is a structure:
;           pre={start:n1, len:n2, match:s}
;           n1 is substring start char, n2 is substring length,
;           s is a string to match against the position defined
;           by n1 and n2.  This gives the prefiltered list.  Example:
;           pre={start:19,len:4,match:'fit'}
;           The example will match "fit" at the end of the name but
;           not inside the name like "...fit_...".
;         FILTER=filt  Given specification on splitting prefiltered
;           list into sublists.  filt is a structure:
;           filt={start:n1, len:n2, match:[s1,s2,...,sn]
;           n1 is substring start char, n2 is substring length,
;           s1, s2, ..., sn are strings to match against the
;           position defined by n1 and n2.  s1 produces list1,
;           s2 list2, and so on.  If a list is returned as a
;           null string there were no matches for it.  Example:
;           filt={start:0,len:3,match:['wac','nac']}
;         LIST1=list1, LIST2=list2, ...  Returned file lists.
;         CNT1=c1, CNT2=c2, ...  Number of files on each list.
;           8 sublists are allowed.
;         ERROR=err  Error flag: 0=ok, 1=all files prefiltered out,
;           2=other error.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Designed for speed under unix (or linux).
;         Trades speed for generality.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Apr 18
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro filelists, prefilter=pre, filter=filt, error=err, help=hlp, $
	  list1=list1, list2=list2, list3=list3, list4=list4, $
	  list5=list5, list6=list6, list7=list7, list8=list8, $
	  cnt1=c1, cnt2=c2, cnt3=c3, cnt4=c4, $
	  cnt5=c5, cnt6=c6, cnt7=c7, cnt8=c8
 
	if keyword_set(hlp) then begin
help:	  print,' Return specified lists of files in directory.'
	  print,' filelists'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   PREFILTER=pre  Given specification on prefiltering full'
	  print,'     list.  This is optional.  pre is a structure:'
	  print,'     pre={start:n1, len:n2, match:s}'
	  print,'     n1 is substring start char, n2 is substring length,'
	  print,'     s is a string to match against the position defined'
	  print,'     by n1 and n2.  This gives the prefiltered list.  Example:'
	  print,"     pre={start:19,len:4,match:'fit'}"
	  print,'     The example will match "fit" at the end of the name but'
	  print,'     not inside the name like "...fit_...".'
	  print,'   FILTER=filt  Given specification on splitting prefiltered'
	  print,'     list into sublists.  filt is a structure:'
	  print,'     filt={start:n1, len:n2, match:[s1,s2,...,sn]'
	  print,'     n1 is substring start char, n2 is substring length,'
	  print,'     s1, s2, ..., sn are strings to match against the'
	  print,'     position defined by n1 and n2.  s1 produces list1,'
	  print,'     s2 list2, and so on.  If a list is returned as a'
	  print,'     null string there were no matches for it.  Example:'
	  print,"     filt={start:0,len:3,match:['wac','nac']}"
	  print,'   LIST1=list1, LIST2=list2, ...  Returned file lists.'
	  print,'   CNT1=c1, CNT2=c2, ...  Number of files on each list.'
	  print,'     8 sublists are allowed.'
	  print,'   ERROR=err  Error flag: 0=ok, 1=all files prefiltered out,'
	  print,'     2=other error.'
	  print,' Notes: Designed for speed under unix (or linux).'
	  print,'   Trades speed for generality.'
	  return
	endif
 
	nsub = 8			; Number of sublists allowed.
 
	;---------  Get full list  --------------
	if !version.os_family eq 'unix' then begin
	  spawn,'ls',list,/noshell	; Unix fast listing.
	endif else begin
	  list = file_search()		; Everything else.
	endelse
 
	;---------  Pre-filter  -------------------
	if n_elements(pre) ne 0 then begin
	  t = strmid(list,pre.start,pre.len)	; Pre-filter substring.
	  w = where(t eq pre.match,c)		; Look for match.
	  if c eq 0 then begin
	    err = 1
	    print,' Error in filelists: no files left after prefiltering.'
	    return
	  endif
	  list = list(w)			; Pre-filter.
	endif
 
	;--------  Filter into sublists  -----------
	if n_elements(filt) eq 0 then begin
	  err = 2
	  goto, help
	endif
	t = strmid(list,filt.start,filt.len)	; Filter substring.
	n = n_elements(filt.match)		; Number of sublists.
	if n eq 0 then begin
	  err = 2
	  print,' Error in filelists: no filter match items given.'
	  return
	endif
	if n gt nsub then begin
	  err = 2
	  print,' Error in filelists: too many filter match items given.'
	  print,' Max = '+strtrim(nsub,2)
	  return
	endif else err=0
 
	;-------  List1  --------------------
	w = where(t eq filt.match(0),c1)
	if c1 eq 0 then list1='' else list1=list(w)
	if n eq 1 then return
 
	;-------  List2  --------------------
	w = where(t eq filt.match(1),c2)
	if c2 eq 0 then list2='' else list2=list(w)
	if n eq 2 then return
 
	;-------  List3  --------------------
	w = where(t eq filt.match(2),c3)
	if c3 eq 0 then list3='' else list3=list(w)
	if n eq 3 then return
 
	;-------  List4  --------------------
	w = where(t eq filt.match(3),c4)
	if c4 eq 0 then list4='' else list4=list(w)
	if n eq 4 then return
 
	;-------  List5  --------------------
	w = where(t eq filt.match(4),c5)
	if c5 eq 0 then list5='' else list5=list(w)
	if n eq 5 then return
 
	;-------  List6  --------------------
	w = where(t eq filt.match(5),c6)
	if c6 eq 0 then list6='' else list6=list(w)
	if n eq 6 then return
 
	;-------  List7  --------------------
	w = where(t eq filt.match(6),c7)
	if c7 eq 0 then list7='' else list7=list(w)
	if n eq 7 then return
 
	;-------  List8  --------------------
	w = where(t eq filt.match(7),c8)
	if c8 eq 0 then list8='' else list8=list(w)
	if n eq 8 then return
 
	end
