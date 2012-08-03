;-------------------------------------------------------------
;+
; NAME:
;       RBAR
; PURPOSE:
;       Plot a color bars with defined ranges.
; CATEGORY:
; CALLING SEQUENCE:
;       rbar, file
; INPUTS:
;       file = color bar definition file name.   in
;       s = Instead a file may give a structure. in
;         s must contain the following items:
;         n: # colors
;         clr: Array of n colors (24 bit values)
;         tick_lab: n+1 Labels for ticks (some may be space)
;         tick_flag: n+1 flags: 0=ignore, 1=show.
;       The bar will have labels at the top and bottom and
;       at each color boundary between. Some labels may be blank.
; KEYWORD PARAMETERS:
;       Keywords:
;         /vertical    Plot a vertical color bar (default).
;         /horizontal  Plot a horizontal color bar.
;         GET_STRUCT=s Read the structure from the file and return.
;         /FILE_FORM   Show help on the file format.
;         ERROR=err    Error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Use plot keywords to position and control the bar.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jun 24
;       R. Sterner, 2005 Jun 28 --- Fixed to preserve existing map scaling.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro rbar_file_form
 
	print,' A color bar is defined in a text file.'
	print,' Each color in the color bar is defined by it value'
	print,' range (min max) and color.  The special values Lo and HI (case'
	print,' ignored) can be used to mean anything less than the lowest'
	print,' specified value or higher than the highest specified value. The'
	print,' color may be a single 24 bit value (in a long int), or any'
	print,' format taken by tarclr. Example color bar definition:'
	print,'   color = 50 hi  /hsv,0,.5,1'
	print,'   color = 40 50  /hsv,30,.5,1'
	print,'   color = 30 40  /hsv,60,.5,5'
	print,'   color = lo 30  /hsv,120,.5,1'
	print,''
	print,' Above there are 4 colors: <30-30, 30-40, 40-50, 50->50.  There'
	print,' will be 3 labeled ticks: 30, 40, 50.'
 
	end
 
 
	pro rbar_read, file, sout, err=err
 
	;------  Read file  ---------------
	t = getfile(file)			; Read bar definition file.
	s = txtgetkey(init=t,/struct)		; Garb items into a structure.
	err = 0
 
	;-----  Deal with colors and ranges  ------
	if tag_test(s,'color') ne 1 then begin
	  print,' Error in rbar_read: Must define colors and ranges.'
	  err = 1
	  return
	endif
	txt = s.color				; Color lines.
	n = n_elements(txt)			; # color lines.
	bot_txt = strarr(n)			; Range bottom.
	top_txt = strarr(n)			; Range top.
	clr_txt = strarr(n)			; Color spec.
	for i=0,n-1 do begin			; Separate bin bottom,top,color.
	  bot_txt(i) = getwrd(txt(i),0) 
	  top_txt(i) = getwrd(txt(i),1) 
	  clr_txt(i) = getwrd(txt(i),2,99) 
	endfor
	bot_txt = strupcase(bot_txt)
	top_txt = strupcase(top_txt)
	botv = fltarr(n)			; Working values.
	topv = fltarr(n)
	clrv = lonarr(n)
	bflag = bytarr(n)+1			; Range bottom. Labeled tick?
	tflag = bytarr(n)+1			; Range top.
	for i=0,n-1 do begin
	  ;----  Deal with color  -------
	  c = clr_txt(i)			; Color spec.
	  flag = 0				; Need tarclr?
	  if strpos(c,',') ge 0 then flag=1	; Yes if any commas.
	  if strpos(c,' ') ge 0 then flag=1	; Yes if any spaces.
	  if flag then clrv(i)=tarclr(c) else clrv(i)=c+0L
	  ;----  Deal with ranges  -------
	  r1 = bot_txt(i)			; Bin bottom as text.
	  r2 = top_txt(i)			; Bin top as text.
	  if r1 eq 'LO' then begin		; Special cases.
	    r1 = r2-1.
	    bflag(i) = 0
	  endif
	  if r2 eq 'HI' then begin
	    r2 = r1+1.
	    tflag(i) = 0
	  endif
	  botv(i) = r1+0.
	  topv(i) = r2+0.
	endfor
 
	;----- Get boundaries between colors (regions) ----
	w = where(bflag eq 1)
	reg = reverse(botv(w))	; One less boundary than ticks.
 
	;--------------------------------------------------------------------
	;  Collect info and pack into a return structure
	;
	;  tick_lab is an array of labels to use for color bar ticks.
	;  tick_flag is 1 if the label is shown, 0 if not.
	;--------------------------------------------------------------------
	tick_lab = reverse([top_txt,bot_txt(n-1)])
	tick_flag = reverse([tflag,bflag(n-1)])
	
	sout = {n:n, reg:reg, tick_lab:tick_lab, tick_flag:tick_flag, $
		clr:clrv}
 
	end
 
	;-----------------------------------------------------------
	;  Main routine
	;-----------------------------------------------------------
	pro rbar, file, horizontal=hor, vertical=ver, _extra=extra, $
	  get_struct=sout, error=err, color=col, file_form=ff, help=hlp
 
	if keyword_set(ff) then begin
	  rbar_file_form
	  return
	endif
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a color bars with defined ranges.'
	  print,' rbar, file'
	  print,'   file = color bar definition file name.   in'
	  print,'   s = Instead a file may give a structure. in'
	  print,'     s must contain the following items:'
	  print,'     n: # colors'
	  print,'     clr: Array of n colors (24 bit values)'
	  print,'     tick_lab: n+1 Labels for ticks (some may be space)'
	  print,'     tick_flag: n+1 flags: 0=ignore, 1=show.'
	  print,'   The bar will have labels at the top and bottom and'
	  print,'   at each color boundary between. Some labels may be blank.'
	  print,' Keywords:'
	  print,'   /vertical    Plot a vertical color bar (default).'
	  print,'   /horizontal  Plot a horizontal color bar.'
	  print,'   GET_STRUCT=s Read the structure from the file and return.'
	  print,'   /FILE_FORM   Show help on the file format.'
	  print,'   ERROR=err    Error flag: 0=ok.'
	  print,' Notes: Use plot keywords to position and control the bar.'
	  return
	endif
 
	;----------------------------------------------
	;  Get bar definition structure
	;
	;  If a filename is given to rbar it will try
	;  to read the bar definition from the file.
	;  May give a structure containing the bar
	;  definition instead of a file name.
	;----------------------------------------------
	if datatype(file) eq 'STC' then begin	; Was a structure.
	  s = file				;   Just copy to expected name.
	endif else begin			; Was a text file.
	  rbar_read, file, s, err=err		;    Try to read it into struct.
	  if err ne 0 then return		;    Error in file.
	  if arg_present(sout) then begin	;    Just wanted strct returned.
	    sout = s
	    return
	  endif
	endelse
 
	;----------------------------------------------
	;  Horizontal color bar
	;----------------------------------------------
	if keyword_set(hor) then begin
	  ;-----  Deal with labels  ---------
	  ylab = strarr(60)+' '			; No labels on this axis.
	  xlab = s.tick_lab			; Labels for labeled axis.
	  w = where(s.tick_flag eq 0, cnt)	; Find unused labels.
	  if cnt gt 0 then xlab(w) = ' '	; Blank them out.
	  ;-----  Deal with plot range  -----
	  xx = [0,s.n]
	  yy = [0,1]
	  ;-----  Ticks  --------------------
	  xticks = s.n
	  yticks = 1
	  ;-----  Color blocks  -------------
	  x0 = 0
	  dx = 1
	  y0 = 0
	  dy = 0
	  ;-----  Outline  ------------------
	;----------------------------------------------
	;  Verical color bar
	;----------------------------------------------
	endif else begin
	  ;-----  Deal with labels  ---------
	  xlab = strarr(60)+' '			; No labels on this axis.
	  ylab = s.tick_lab			; Labels for labeled axis.
	  w = where(s.tick_flag eq 0, cnt)	; Find unused labels.
	  if cnt gt 0 then ylab(w) = ' '	; Blank them out.
	  ;-----  Deal with plot range  -----
	  xx = [0,1]
	  yy = [0,s.n]
	  ;-----  Ticks  --------------------
	  xticks = 1
	  yticks = s.n
	  ;-----  Color blocks  -------------
	  x0 = 0
	  dx = 0
	  y0 = 0
	  dy = 1
	endelse
 
	;----------------------------------------------
	;  Set up bar plot window
	;----------------------------------------------
	map_state_save
	plot, xx, yy, _extra=extra, xstyle=1, ystyle=1, $
	  xticknam=xlab, yticknam=ylab,/nodata, $
	  xticks=xticks, yticks=yticks, color=col,/noerase
 
	;----------------------------------------------
	;  Plot color blocks
	;----------------------------------------------
	for i=0,s.n-1 do begin
	  x = x0 + dx*i + [0,1,1,0]
	  y = y0 + dy*i + [0,0,1,1]
	  polyfill,x,y,col=s.clr(i)
	endfor
 
	;----------------------------------------------
	;  Outline
	;----------------------------------------------
	plots,xx([0,1,1,0,0]),yy([0,0,1,1,0]),color=col
	map_state_restore
 
	end
