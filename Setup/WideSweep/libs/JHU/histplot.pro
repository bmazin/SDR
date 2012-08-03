;-------------------------------------------------------------
;+
; NAME:
;       HISTPLOT
; PURPOSE:
;       Interactive histograms in a box.
; CATEGORY:
; CALLING SEQUENCE:
;       histplot
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ARRAY=array Data array to plot from.
;           If array was displayed as an image using:
;           tvscl,array,/order then use /YREVERSE on histplot call.
;         /YREVERSED means Image Y=0 for top row, else bottom.
;           Image must be displayed correctly before calling histplot.
;           If image was displayed as tvscl,img,/order then call
;           histplot with /YREVERSED.
;         XPOS=xpos, YPOS=ypos  Plot window x,y position.
;         BINWIDTH=binwid  Initial histogram bin width.
;         INFO=txt Text to print on snapshot.
;         INSTRUCTIONS=i_flag Display startup message? 0=no, 1=yes.
;           Needed if plot window to be moved before starting.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Sep 19
;       R. Sterner, 2002 Sep 22 --- Added XPOS, YPOS.
;       R. Sterner, 2003 Jan 16 --- Made update on move be default (ch_flag=2).
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro histplot, array=arr, yreversed=yrev, info=info, help=hlp, $
	  xpos=xpos, ypos=ypos, binwidth=binwidth, instructions=i_flag
 
	if keyword_set(hlp) then begin
	  print,' Interactive histograms in a box.'
	  print,' histplot'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   ARRAY=array Data array to plot from.'
	  print,'     If array was displayed as an image using:'
	  print,'     tvscl,array,/order then use /YREVERSE on histplot call.'
	  print,'   /YREVERSED means Image Y=0 for top row, else bottom.'
	  print,'     Image must be displayed correctly before calling histplot.'
	  print,'     If image was displayed as tvscl,img,/order then call'
	  print,'     histplot with /YREVERSED.'
	  print,'   XPOS=xpos, YPOS=ypos  Plot window x,y position.'
	  print,'   BINWIDTH=binwid  Initial histogram bin width.'
	  print,'   INFO=txt Text to print on snapshot.'
	  print,'   INSTRUCTIONS=i_flag Display startup message? 0=no, 1=yes.'
	  print,'     Needed if plot window to be moved before starting.'
	  return
	endif
 
	if n_elements(arr) eq 0 then begin
	  print,' Error in histplot: Must give data array to use.'
	  return
	endif
	if n_elements(xpos) eq 0 then xpos=0
	if n_elements(ypos) eq 0 then ypos=0
	if n_elements(binwidth) eq 0 then binwidth=50
 
	image_stats, init=arr, xpos=xpos, ypos=ypos, binwidth=binwidth
	img = tvrd()
 
	;------  Instructions  ----------------
	if keyword_set(i_flag) then begin
          xmess,['Position Plot Window as desired.',$
            'Then click CONTINUE and place cursor in image window.', $
            'Left button = drag open a box, grab and move',$
	    '  a side or corner, or box itself.', $
            'Other buttons = options (can scroll window also)'], $
            oktext='CONTINUE', /wait
	endif
 
	wshow
	tv, img
	opts = ['Snap JPEG','Set plot parameters']
	vals = [1,2]
	box2b, change='image_stats',yrev=yrev, ch_opts=opts, $
	    ch_vals=vals, info=info, ch_flag=2  ;,/xmode
 
	image_stats,/terminate
 
	end
