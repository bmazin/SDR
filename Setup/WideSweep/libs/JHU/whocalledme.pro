;-------------------------------------------------------------
;+
; NAME:
;       WHOCALLEDME
; PURPOSE:
;       Returns to calling routine its parent's directory and name.
; CATEGORY:
; CALLING SEQUENCE:
;       whocalledme, dir, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         LINE=n  Line number just after parent's last call.
;         BACK=n  Look back, 0=self, 1=parent (def),
;           2=grandparent, 3=great grandparent, ...
; OUTPUTS:
;       dir = Source directory of parent routine.   out
;       file = name of parent routine.              out
; COMMON BLOCKS:
; NOTES:
;       Notes: It can be useful for a routine to know
;         what routine called it.
;         See also: whoami.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 23
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro whocalledme, dir, file, line=line, back=back, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print," Returns to calling routine its parent's directory and name."
	  print,' whocalledme, dir, file'
	  print,'   dir = Source directory of parent routine.   out'
	  print,'   file = name of parent routine.              out'
	  print,' Keywords:'
	  print,"   LINE=n  Line number just after parent's last call."
	  print,'   BACK=n  Look back, 0=self, 1=parent (def),'
	  print,'     2=grandparent, 3=great grandparent, ...'
	  print,' Notes: It can be useful for a routine to know'
	  print,'   what routine called it.'
	  print,'   See also: whoami.'
	  return
	endif
 
	help,calls=cc		; Get list of all calls.
	cc = [cc,'']		; Pad.
 
	if n_elements(back) eq 0  then back=1	; Look back (def=parent).
	is=cc([1+back]) & is=is(0)
	t = getwrd(is,delim='<',1)
	f = getwrd(t+' ',delim='(')
	line = getwrd('',1)+0
 
	filebreak, f, dir=dir, nvfile=file
 
	return
	end
