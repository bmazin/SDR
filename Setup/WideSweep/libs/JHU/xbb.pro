;-------------------------------------------------------------
;+
; NAME:
;       XBB
; PURPOSE:
;       Widget bill board utility for text display.
; CATEGORY:
; CALLING SEQUENCE:
;       xbb
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;        LINES=txt  Text array of initial lines to display.
;        RES=RES    Specified array of reserved line numbers.
;          Top line is number 0.
;        NID=nid    Returned widget IDs of reserved lines.
;        WID=wid    Returned xbb widget ID so this widget may
;          be destroyed at a later time.
;        TITLE=tt   Optional title text (def=none).
;        GROUP_LEADER=grp  specified group leader.  When the
;          group leader widget is destroyed this widget is also.
;        XOFFSET=xoff, YOFFSET=yoff  x,y offset to position widget.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: this utility is useful for displaying varying
;         text such as a status update and so on.  It is designed
;         to be positioned somewhere out of the way by the user
;         It is initialized to display some specified lines of text
;         and one or more lines are requested as reserved.  The
;         widget IDs of the requested reserved lines are returned
;         and are used to update the corresponding lines.  When
;         this widget is no longer needed it may be destroyed.
;         Use widget_control to update a line:
;           widget_control,nid(2),set_val='New value'
;         To delete do: widget_control,wid,/destroy
; MODIFICATION HISTORY:
;       R. Sterner, 16 Nov, 1993
;       R. Sterner, 1997 Nov 12 --- Better help.
;       R. Sterner, 2002 Sep 22 --- Added XOFFSET, YOFFSET.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xbb, lines=lines, res=res, nid=nid, wid=top, title=title, $
	  group_leader=grp, help=hlp, xoffset=xoff, yoffset=yoff
 
	if keyword_set(hlp) or n_elements(lines) eq 0 then begin
	  print,' Widget bill board utility for text display.'
	  print,' xbb'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'  LINES=txt  Text array of initial lines to display.'
	  print,'  RES=RES    Specified array of reserved line numbers.'
	  print,'    Top line is number 0.'
	  print,'  NID=nid    Returned widget IDs of reserved lines.'
	  print,'  WID=wid    Returned xbb widget ID so this widget may'
	  print,'    be destroyed at a later time.'
	  print,'  TITLE=tt   Optional title text (def=none).'
	  print,'  GROUP_LEADER=grp  specified group leader.  When the'
	  print,'    group leader widget is destroyed this widget is also.'
	  print,'  XOFFSET=xoff, YOFFSET=yoff  x,y offset to position widget.'
	  print,' Notes: this utility is useful for displaying varying'
	  print,'   text such as a status update and so on.  It is designed'
	  print,'   to be positioned somewhere out of the way by the user'
	  print,'   It is initialized to display some specified lines of text'
	  print,'   and one or more lines are requested as reserved.  The'
	  print,'   widget IDs of the requested reserved lines are returned'
	  print,'   and are used to update the corresponding lines.  When'
	  print,'   this widget is no longer needed it may be destroyed.'
	  print,'   Use widget_control to update a line:'
	  print,"     widget_control,nid(2),set_val='New value'"
	  print,'   To delete do: widget_control,wid,/destroy'
	  return
	endif
 
	;--------  Defaults  ------------
	if n_elements(title) eq '' then title = ' '
	if n_elements(res) eq 0 then res = [-1]
 
	;--------  Top level base  ----------
	top = widget_base(title=title,/column,xoff=xoff,yoff=yoff)
	if n_elements(grp) then widget_control, top, group=grp
 
	;---------  Reserve line IDs  ---------
	num = n_elements(res)	; Number of reserved lines.
	nid = lonarr(num)
 
	;--------  Display given lines of text  ----------
	j = 0
	for i = 0, n_elements(lines)-1 do begin
	  id = widget_label(top, val=lines(i),/dynamic)
	  w = where(i eq res, cnt)
	  if cnt gt 0 then begin
	    nid(j) = id
	    j = j + 1
	  endif
	endfor
 
	;---------  Activate widget  --------------
	widget_control, top, /real
 
	return
	end
