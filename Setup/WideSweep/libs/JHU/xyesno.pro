;-------------------------------------------------------------
;+
; NAME:
;       XYESNO
; PURPOSE:
;       Widget Yes/No selection panel.
; CATEGORY:
; CALLING SEQUENCE:
;       ans = xyesno(qtxt)
; INPUTS:
;       qtxt = Question text.  Must have a Yes or No answer.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         DEFAULT=x Default answer: 'Y' or 'N' (else none).
;         TITLE=txt A scalar text string or array to use
;           as title (def=none).
; OUTPUTS:
;       ans = returned answer, Y or N.                        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jul 28
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function xyesno, txt, default=def, title=ttl, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Widget Yes/No selection panel.'
	  print,' ans = xyesno(qtxt)'
	  print,'   qtxt = Question text.  Must have a Yes or No answer.  in'
	  print,'   ans = returned answer, Y or N.                        out'
	  print,' Keywords:'
	  print,"   DEFAULT=x Default answer: 'Y' or 'N' (else none)."
	  print,'   TITLE=txt A scalar text string or array to use'
	  print,'     as title (def=none).'
	  return,''
	endif
 
        ;-------  Set up and display widget  --------
        nx = max(strlen(txt))
        ny = n_elements(txt)
        top = widget_base(title=' ',/column)
        if n_elements(ttl) ne 0 then begin
          for i=0, n_elements(ttl)-1 do t = widget_label(top,val=ttl(i))
        endif
	t = widget_label(top,val=' ')
        t = widget_text(top,value=txt,xsize=nx,ysize=ny)
	b = widget_base(top,/row,/frame)
	idy = widget_button(b,val='Yes',uval='Y')
	idn = widget_button(b,val='No',uval='N')
 
        widget_control, top, /real
	if n_elements(def) eq 0 then def=''
	if strupcase(def) eq 'Y' then widget_control, idy, /input_focus
	if strupcase(def) eq 'N' then widget_control, idn, /input_focus
 
	;--------  Process events  ---------------
loop:   ev = widget_event(top)
        widget_control, ev.id, get_uval=uval
 
	widget_control, top, /dest
 
	return, uval
 
	end
