;-------------------------------------------------------------
;+
; NAME:
;       XAUTOHELP
; PURPOSE:
;       Display auto help when mouse moves over a widget.
; CATEGORY:
; CALLING SEQUENCE:
;       xautohelp, ev, text
; INPUTS:
;       ev = Event structure.  Give widget ID to init.     in
;       text = Text to display.  Init only.                in
;         Only given to intialize, to display call with ev only.
;         May be multiline, delimited by / or DELIMETER=del.
; KEYWORD PARAMETERS:
;       Keywords:
;         DISPLAY=label_id  Widget ID of label area for display.
;           Must give to display text.  May be array of label IDs.
;         /NOCLEAR means do not clear the given event structure.
;         DELIMITER=del Set multiline delimiter if not /.
;         /MORE_HELP  displays a text file with more details.
; OUTPUTS:
; COMMON BLOCKS:
;       xautohelp_com
; NOTES:
;       Notes on how to use: This routine is used in two phases:
;         Initialization and Display.  It is initialized as the
;         widgets are added to the total widget device.  Set
;         tracking_events for each widget that will display autohelp
;         text.  Right after adding the widget give xautohelp
;         its help text using its widget ID as the index.
;         On the display call give the event structure itself.
;         If the event structure is a tracking_event it is used to
;         display or clear the autohelp text and then set to 0 for
;         return.  Test the event structure when it comes back from
;         xautohelp, if it is still a structure continue in the
;         event handler normally, else just return:
;            xautohelp, ev, display=lab
;            if (size(ev))(2) ne 8 then return
; MODIFICATION HISTORY:
;       R. Sterner, 1998 May 1
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xautohelp, ev, text, display=label_id, noclear=noclear, $
	  delimiter=del, help=hlp, more_help=mhlp
 
	common xautohelp_com, ids, txt, mrk
 
	;-----  Give more detailed help  ----------------
	if keyword_set(mhlp) then begin
	  whoami, dir
	  file = filename(dir,'xautohelp.hlp',/nosym)
	  t = getfile(file,err=err)
	  if err eq 0 then more,t
	  return
	endif
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display auto help when mouse moves over a widget.'
	  print,' xautohelp, ev, text'
	  print,'   ev = Event structure.  Give widget ID to init.     in'
	  print,'   text = Text to display.  Init only.                in'
	  print,'     Only given to intialize, to display call with ev only.'
	  print,'     May be multiline, delimited by / or DELIMETER=del.'
	  print,' Keywords:'
	  print,'   DISPLAY=label_id  Widget ID of label area for display.'
	  print,'     Must give to display text.  May be array of label IDs.'
	  print,'   /NOCLEAR means do not clear the given event structure.'
	  print,'   DELIMITER=del Set multiline delimiter if not /.'
	  print,'   /MORE_HELP  displays a text file with more details.'
	  print,' Notes on how to use: This routine is used in two phases:'
	  print,'   Initialization and Display.  It is initialized as the'
 	  print,'   widgets are added to the total widget device.  Set'
	  print,'   tracking_events for each widget that will display autohelp'
	  print,'   text.  Right after adding the widget give xautohelp'
	  print,'   its help text using its widget ID as the index.'
	  print,'   On the display call give the event structure itself.
	  print,'   If the event structure is a tracking_event it is used to'
	  print,'   display or clear the autohelp text and then set to 0 for'
	  print,'   return.  Test the event structure when it comes back from'
	  print,'   xautohelp, if it is still a structure continue in the'
	  print,'   event handler normally, else just return:'
	  print,'      xautohelp, ev, display=lab'
	  print,'      if (size(ev))(2) ne 8 then return'
	  return
	endif
 
	;-----  Initialize common variables  ------------
	if n_elements(ids) eq 0 then begin
	  ids = lonarr(100)		; Allow for 100 widgets to start.
	  txt = strarr(100)		; each with help text.
	  mrk = string(10B)		; Internal line delimiter.
	endif
 
	;---------------------------------------------------------
	;  Incoming ev should be either an event structure or
	;  a widget ID.  Widget IDs are given to initialize the
	;  help text, event structures are given to display or
	;  clear the help text.
	;---------------------------------------------------------
	;---------  INITIALIZE  ----------------
	;---------------------------------------------------------
	;  If widget is already in table just update text, else
	;  add to table if room.  If no room make room first.
	;---------------------------------------------------------
	if (size(ev))(2) ne 8 then begin	; Not structure, assume ID.
	  ;-----  Replace printable multiline delimeters in text  ------
	  if n_elements(del) eq 0 then del='/'
	  text2 = repchr(text,del,mrk)		; Use standard delimiters.
	  w = where(ids eq ev, cnt)		; See if already there.
	  if cnt gt 0 then begin		; Yes, Widget ID was there.
	    txt(w(0)) = text2			;   Update with new text.
	  endif else begin			; No it wasn't there.
	    w = where(ids eq 0, cnt)		;   Look for an unused entry.
	    if cnt gt 0 then begin		;   Found one.
	      ids(w(0)) = ev			;     Add the widget ID
	      txt(w(0)) = text2			;     and its help text.
	    endif else begin			;   No more room, add some.
	      ids = [ids,lonarr(100)]		;     Add 100 more IDs.
	      txt = [txt,strarr(100)]		;     and 100 more help texts.
	      w = where(ids eq 0, cnt)		;     Find first entry slot.
	      ids(w(0)) = ev			;     Add the widget ID
	      txt(w(0)) = text2			;     and its help text.
	    endelse
	  endelse
	  return				; All done adding text.
 
	;---------------------------------------------------------
	;  DISPLAY or CLEAR
	;---------------------------------------------------------
	;  Given an event structure.  Might be a real event, not
	;  a tracking_event.  If so return right away.  If it is
	;  a tracking_event check if entry (display text) or exit
	;  (clear text).  Clear the tracking_event so it can be
	;  ignored by the event_handler on return from here.
	;  The display area label ID may be an array of widget IDs.
	;  This should only happen for multiple label widgets, not
	;  needed for a text widget.  Label widgets look a bit better.
	;---------------------------------------------------------
	endif else begin
	  if tag_names(ev,/structure_name) ne 'WIDGET_TRACKING' then return
	  w = where(ids eq ev.id, cnt)		; Find in table.
	  if cnt eq 0 then return		; Unknown, ignore.
	  ;---  Widget entry:  DISPLAY TEXT  ---------------------
	  if ev.enter eq 1 then begin		; Cursor enters over widget.
	    t = txt(w(0))			; Extract text to display.
	    ;--  Multple widget IDs, display one line of text in each  ---
	    if n_elements(label_id) gt 1 then begin
	      for i=0,n_elements(label_id)-1 do $	  ; Display each line.
	        widget_control, label_id(i), set_val=getwrd(t,i,del=mrk)
	    ;--  Single widget ID, send all text to it  ---
	    endif else begin
	      widget_control, label_id, set_val=t	  ; Display all.
	    endelse
	  ;---  Widget exit:  CLEAR TEXT  -----------------------
	  endif else begin			; Cursor exits from over widget.
	    ;--  Multple widget IDs, display one line of text in each  ---
	    if n_elements(label_id) gt 1 then begin
	      for i=0,n_elements(label_id)-1 do $	  ; Clear each line.
	        widget_control, label_id(i), set_val=" "
	    ;--  Single widget ID, send all text to it  ---
            endif else begin
	      widget_control, label_id, set_val=" "	  ; Clear.
	    endelse
	  endelse
	  if not keyword_set(noclear) then ev=0	; Clear event.
	endelse
 
	return
	end
