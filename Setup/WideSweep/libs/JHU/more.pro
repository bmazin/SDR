;-------------------------------------------------------------
;+
; NAME:
;       MORE
; PURPOSE:
;       Display a text array using the MORE method.
; CATEGORY:
; CALLING SEQUENCE:
;       more, arr [,arr2, arr3, ..., arr9]
; INPUTS:
;       arr = 1-D array to display.  in
;         May give up to 9 1-d arrays to display, all with same # elements.
; KEYWORD PARAMETERS:
;       Keywords:
;         /NUMBERS display all array elements and index numbers.
;         NUMBERS=lo  display numbered array elements starting at
;           element number lo.
;         NUMBERS=[lo,hi] display requested array elements
;           and index numbers.
;         FORMAT=fmt  specify format string (def=A).
;           Useful for listing numeric arrays, ex:
;           more,a,form='f8.3'  or  more,a,form='3x,f8.3'
;           Do not use for multiple arrays.
;       LINES=n  Printout will pause after displaying n lines (def=15).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: After n lines output will pause
;        until user presses SPACE to continue.
; MODIFICATION HISTORY:
;       R. Sterner, 26 Feb, 1992
;       Jayant Murthy murthy@pha.jhu.edu 31 Oct 92 --- added FORMAT keyword.
;       R. Sterner, 29 Apr, 1993 --- changed for loop to long int.
;       R. Sterner, 1994 Nov 29 --- Allowed specified index range.
;       R. Sterner, 1998 Jan 15 --- Dropped use of terminal output from filepath.
;       R. Sterner, 2005 Aug 09 --- Allowed more digits in index number.
;       R. Sterner, 2007 Jun 12 --- Allowed multiple arrays.
;       Also improved output.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro more, txt0, txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9, $
	  help=hlp, numbers=num0, format=fmt, lines=lines
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a text array using the MORE method.'
	  print,' more, arr [,arr2, arr3, ..., arr9]'
	  print,'   arr = 1-D array to display.  in'
	  print,'     May give up to 9 1-d arrays to display, all with same # elements.'
	  print,' Keywords:'
	  print,'   /NUMBERS display all array elements and index numbers.'
	  print,'   NUMBERS=lo  display numbered array elements starting at'
	  print,'     element number lo.'
	  print,'   NUMBERS=[lo,hi] display requested array elements'
	  print,'     and index numbers.'
	  print,'   FORMAT=fmt  specify format string (def=A).'
	  print,'     Useful for listing numeric arrays, ex:'
	  print,"     more,a,form='f8.3'  or  more,a,form='3x,f8.3'"
	  print,'     Do not use for multiple arrays.'
	  print,' LINES=n  Printout will pause after displaying n lines (def=15).'
	  print,' Note: After n lines output will pause'
	  print,'  until user presses SPACE to continue.'
	  return
	endif
 
	txt = txt0
	if n_params(0) gt 1 then begin
	  txt = string(txt0)
	  if n_elements(txt1) gt 0 then txt=txt+string(txt1)
	  if n_elements(txt2) gt 0 then txt=txt+string(txt2)
	  if n_elements(txt3) gt 0 then txt=txt+string(txt3)
	  if n_elements(txt4) gt 0 then txt=txt+string(txt4)
	  if n_elements(txt5) gt 0 then txt=txt+string(txt5)
	  if n_elements(txt6) gt 0 then txt=txt+string(txt6)
	  if n_elements(txt7) gt 0 then txt=txt+string(txt7)
	  if n_elements(txt8) gt 0 then txt=txt+string(txt8)
	  if n_elements(txt9) gt 0 then txt=txt+string(txt9)
	endif
 
	if n_elements(lines) eq 0 then lines=15	  ; Lines to display before pause.
 
	os = !version.os_family
	if os eq 'unix' then bflag=1 else bflag=0 	; Backspace for unix only.
 
	if n_elements(fmt) eq 0 then fmt='a'	  ; Default format.
 
	;---------  Element numbering  ---------
	num = 0						; Assume no numbering.
	lo = 0L						; Start at first,
	hi = n_elements(txt)-1				; go till last.
 
	if n_elements(num0) ne 0 then begin		; Numbers requested.
	  num = 1
	  lo = 0					; Default index range.
	  hi = n_elements(txt)-1
	  if num0(0) gt 1 then lo=num0(0)		; Set start index.
	endif
	if n_elements(num0) eq 2 then begin		; Requested range.
	  lo = num0(0)>0
	  hi = num0(1)<hi
	endif
 
	;---------  List array  ------------
	off = long(lo)-1				; Offset for mod.
	lines0 = lines					; Actual number to mod.
 
	for i = long(lo), hi do begin			; Loop through lines.
	  if keyword_set(num) then $
	    print,i,txt(i),form='(i7,2x,'+fmt+')' $	; Numbered lines.
	  else print,txt(i),form='('+fmt+')'		; Unnumbered lines.
	  ;-----  Check if time to pause  ------------
	  ;-----  Overwrite pause message using backspaces  -------
	  if ((i-off) mod lines0) eq 0 then begin
	    print,'      <SPACE to continue, Q to quit>',form='(A,$)'
	    a = get_kbrd(1)				; Wait for a key.
	    if strupcase(a) eq 'Q' then begin		; Was a Q, clean up and quit.
	      if bflag then print,spc(36,char=string(8B))+spc(36)+ $
		spc(36,char=string(8B)) else print,''
	      return
	    endif
	    if bflag then print,spc(36,char=string(8B))+spc(36)+ $
	      spc(36,char=string(8B)),format='(A,$)' else print,''
	    if a eq ' ' then lines0=lines else lines0=1	; Non-Space does single line.
	  endif
	endfor
 
	return
	end
