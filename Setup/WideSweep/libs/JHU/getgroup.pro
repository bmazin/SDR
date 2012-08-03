;-------------------------------------------------------------
;+
; NAME:
;       GETGROUP
; PURPOSE:
;       N'th group of identical elements from a given array.'
; CATEGORY:
; CALLING SEQUENCE:
;       g = getgroup(a, n, [m])
; INPUTS:
;       a = array to process.                        in
;       n = group number to get (first = 0 = def).   in
;       m = optional last group number to get.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         LOCATION = l.  Return group n start location.
;         /LAST means n is offset from last group.  So n=0 gives
;           last group, n=-1 gives next to last, ...
;           If n=-2 and m=0 then last 3 groups are returned.
;         /LONGEST returns the longest group. n returned, m ignored.
; OUTPUTS:
;       g = returned group or groups.                out
; COMMON BLOCKS:
; NOTES:
;       Note: Getgroup works on any array type that allows.
;         the EQ operator.
;         See ngroups.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 02
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function getgroup, a, nth, mth, help=hlp, location=ll,$
	   last=last, longest=longest
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print," N'th group of identical elements from a given array.'
	  print,' g = getgroup(a, n, [m])'
	  print,'   a = array to process.                        in'
	  print,'   n = group number to get (first = 0 = def).   in'
	  print,'   m = optional last group number to get.       in'
	  print,'   g = returned group or groups.                out'
	  print,' Keywords:'
	  print,'   LOCATION = l.  Return group n start location.'
	  print,'   /LAST means n is offset from last group.  So n=0 gives'
	  print,'     last group, n=-1 gives next to last, ...'
	  print,'     If n=-2 and m=0 then last 3 groups are returned.'
	  print,'   /LONGEST returns the longest group. n returned, m ignored.'
	  print,'Note: Getgroup works on any array type that allows.'
	  print,'  the EQ operator.'
	  print,'  See ngroups.'
	  return, -1
	endif
 
	if n_elements(nth) eq 0 then nth = 0	; Default is first group.
	IF n_elements(mth) eq 0 then mth = nth	; Default is one group.
 
	d = a eq shift(a,1)			; Look for changes.
	loc = where(d ne 1)			; Elements NE at group starts.
	loc2 = [loc,n_elements(a)]		; Tack on next group start.
	len = loc2(1:*) - loc2			; Compute group lengths.
	nwds = n_elements(loc)			; Number of groups.
 
	if keyword_set(longest) then begin	; Find longest group.
	  nth = (where(len eq max(len)))(0)	; Index of longest group.
	  ll = loc(nth)				; Location of longest group.
	  return, a(ll:ll+len(nth)-1)		; Longest group.
	endif
 
	if keyword_set(last) then begin		; Offset from last group.
	  lst = nwds - 1
	  in = lst + nth			; Nth group.
	  im = lst + mth			; Mth group.
	  if (in lt 0) and (im lt 0) then return, -1	; Out of range.
	  in = in > 0				; Force smaller of in and im
	  im = im > 0				;  to zero.
	  if (in gt lst) and (im gt lst) then return,-1 ; Out of range.
	  in = in < lst				; Force larger of in and im
	  im = im < lst				;  to be last.
	  ll = loc(in)
	  return, a(ll:loc(im)+len(im)-1)	; Groups from # n to # m.
	endif
 
	n = abs(nth)				; Allow nth<0.
	if n gt nwds-1 then return,-1		; Group number out of range.
	ll = loc(n)				; Location of n'th group.
	if nth lt 0 then goto, neg		; handle nth<0.
	if mth gt nwds-1 then mth = nwds-1	; All groups up to end of a.
 
	return, a(ll:loc(mth)+len(mth)-1)	; Groups from # n to # m.
 
neg:	return, a(ll:*)				; From n'th group to end of a.
 
	end
