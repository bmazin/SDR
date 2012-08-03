;-------------------------------------------------------------
;+
; NAME:
;       TARCLR
; PURPOSE:
;       Find closest match to target color in current color table.
; CATEGORY:
; CALLING SEQUENCE:
;       in = tarclr(tclr)
; INPUTS:
;       tclr = target color.  Flexible format see notes.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         SET=i  Set color index i (if given) to specified color.
;           Ignored if in high color mode (> 256) except to
;           set the color table if it is given.  Reserves color.
;         /NOLOAD means use SET=i for color table only, not screen.
;         /HSV   Target colors is given in HSV instead of RGB.
;           Hue 0-360, Saturation 0-1 float, Value 0-1 float.
;           Same input options as for RGB.
;         RED=red, GREEN=green, BLUE=blue change values in these
;           given color tables also if SET=i is used.
;           If given use to find target color if SET not given.
;         To allow color sharing tarclr allows colors to be reserved.
;         INIT=[lo,hi] Set a range of working colors. /INIT for all.
;         /ADD means add target color to available space and reserve.
;         DROP=i or DROP=[lo,hi] Return reserved colors.
;         /LIST gives info on available colors.
;         /B24 means force 24 bit color mode (good for testing).
; OUTPUTS:
;       in = index in current color table of closest match. out
; COMMON BLOCKS:
;       tarclr_com
; NOTES:
;       Notes: input target color may be given in one of many ways.
;       It may be given in a single argument or in 3 arguments.  The
;       required order in either case is Red, Green, and Blue and
;       the target values of each are assumed to be in the range
;       0-255 (unless /HSV).  Some example single arg entries:
;       '100 120 255', '80,20,0', ['200','200','0'], [0,50,100]'
;       A single string argument may also contain /HSV.
;       The 3 values may also be given in 3 args.
;       A special case single arg entry may be in hex such as:
;       '#ffaa77' to match WWW format.'
;       If using high color (more than 8 bits) then the actual
;       color values is returned for use with the COLOR keyword.
;       SET=i can be used to construct a color table.
;         The inverse routine is c2rgb.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Oct 30
;       R. Sterner, 1997 Dec  3 --- Upgraded for high color use.
;       R. Sterner, 1999 Jul 28 --- Added /HSV keyword.
;       R. Sterner, 1999 Jul 29 --- Added RED,GREEN,BLUE,/NOLOAD.
;       R. Sterner, 1999 Oct 12 --- Handled cases for 1 or 2 values.
;       R. Sterner, 1999 Nov 11 --- Added reserved color items.
;       R. Sterner, 1999 Nov 24 --- Added forced 24 bit mode.
;       R. Sterner, 2000 Sep 20 --- Treats decomp=0 as 8-bit color.
;       R. Sterner, 2002 Jun 25 --- Mentioned inverse.  Allow /hsv in string.
;       R. Sterner, 2006 Jul 26 --- Handled Z buffer.
;       R. Sterner, 2007 Jun 08 --- Handled 1 arg case better.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function tarclr, a1, a2, a3, set=set, hsv=hsv, help=hlp, $
	  red=red, green=green, blue=blue, noload=noload, $
	  init=init, add=add, drop=drop, list=list, b24=b24
 
	common tarclr_com, clrmap	; Map protected and working colors.
 
	if keyword_set(hlp) then begin
	  print,' Find closest match to target color in current color table.'
	  print,' in = tarclr(tclr)'
	  print,'   tclr = target color.  Flexible format see notes.    in'
	  print,'   in = index in current color table of closest match. out'
	  print,' Keywords:'
	  print,'   SET=i  Set color index i (if given) to specified color.'
	  print,'     Ignored if in high color mode (> 256) except to'
	  print,'     set the color table if it is given.  Reserves color.'
	  print,'   /NOLOAD means use SET=i for color table only, not screen.'
	  print,'   /HSV   Target colors is given in HSV instead of RGB.'
	  print,'     Hue 0-360, Saturation 0-1 float, Value 0-1 float.' 
	  print,'     Same input options as for RGB.'
	  print,'   RED=red, GREEN=green, BLUE=blue change values in these'
	  print,'     given color tables also if SET=i is used.'
	  print,'     If given use to find target color if SET not given.'
	  print,'   To allow color sharing tarclr allows colors to be reserved.'
	  print,'   INIT=[lo,hi] Set a range of working colors. /INIT for all.'
	  print,'   /ADD means add target color to available space and reserve.'
	  print,'   DROP=i or DROP=[lo,hi] Return reserved colors.'
	  print,'   /LIST gives info on available colors.'
	  print,'   /B24 means force 24 bit color mode (good for testing).'
	  print,' Notes: input target color may be given in one of many ways.'
	  print,' It may be given in a single argument or in 3 arguments.  The'
	  print,' required order in either case is Red, Green, and Blue and'
	  print,' the target values of each are assumed to be in the range'
	  print,' 0-255 (unless /HSV).  Some example single arg entries:'
	  print," '100 120 255', '80,20,0', ['200','200','0'], [0,50,100]'"
	  print,' A single string argument may also contain /HSV.'
	  print,' The 3 values may also be given in 3 args.'
	  print,' A special case single arg entry may be in hex such as:'
	  print," '#ffaa77' to match WWW format.'"
	  print,' If using high color (more than 8 bits) then the actual'
	  print,' color values is returned for use with the COLOR keyword.'
	  print,' SET=i can be used to construct a color table.'
	  print,'   The inverse routine is c2rgb.'
	  return,''
	endif
 
	;-------- Set default color and cleanup input a bit  -----------
	if n_elements(a1) eq 0 then begin		; Def = white.
	  if keyword_set(hsv) then a1=[0.,0.,1.] else a1=[255,255,255]
	endif
;	if n_params(0) eq 3 then a=[a1,a2,a3] else a=a1	  ; 1 or 3 args.
	;---  Allow 1 arg or 3 arg cases  ---
	if (n_elements(a2) eq 0) and (n_elements(a3) eq 0) then begin
	  a = a1
	endif else begin
	  a = [a1,a2,a3]
	endelse
 
	if strmid(a(0),0,1) eq '#' then begin		  ; WWW format.
	  a=strmid(a,1,2)+' '+strmid(a,3,2)+' '+strmid(a,5,2)
	  wordarray,a,t
	  a = basecon(t,from=16)
	endif
 
	;-------  Allow /hsv in a single string  --------------------
	if n_elements(a) eq 1 then begin	; Single item given.
	  a = strupcase(a)			; Force upper case.
	  p = strpos(a,'/HSV')			; Does string contain /HSV?
	  if p ge 0 then begin			; Yes.
	    a = stress(strupcase(a),'D',0,'/HSV')  ; Remove /HSV and
	    hsv = 1				   ; set HSV flag.
	  endif
	endif
 
        ;-------  Make sure target color is defined and in correct format  ----
        wordarray,string(a),del=',',/white,tclr & tclr=tclr+0.
 
	;-------  Deal with HSV  ------------------------
	if keyword_set(hsv) then begin
	  color_convert, tclr(0),tclr(1),tclr(2), r,g,b, /hsv_rgb
	  tclr = [r,g,b]
	endif
 
	tclr = fix(tclr)
 
	;-------  Do something if not 3 elements  -------
	case n_elements(tclr) of
1:	tclr = [tclr,tclr,tclr]		; Consider as gray level.
2:	tclr = [tclr,tclr(1)]		; Use last element again.
else:	tclr = tclr(0:2)		; Might be > 3 elements.
	endcase
 
	;-------  Deal with high color  -----------------
	;  Return exact requested 24 bit color unless
	;  color tables are given, then return closest
	;  match found in given tables (happens below, skip
	;  this section if color tables given).
	;-------------------------------------------------
	flag24 = 0			; Set flag if in 24 bit color mode.
	if (!d.n_colors gt 256) and (n_elements(red) eq 0) then flag24=1
	if keyword_set(b24) then flag24=1
	;------  Treat decomp=0 as 8 bit color  ---------
	decomp = 1
	if !d.name eq 'Z' then decomp=0	; Z buffer is 8-bit color.
	if !d.name eq 'X' then device,get_decomp=decomp
	if decomp eq 0 then flag24=0
	;------------------------------------------------
	if flag24 eq 1 then begin
	  clr = tclr(0) + 256L*(tclr(1) + 256L*tclr(2))
	  if n_elements(set) ne 0 then begin
	    if n_elements(red) ne 0 then red(set)=tclr(0)    ; Update given CT.
	    if n_elements(green) ne 0 then green(set)=tclr(1)
	    if n_elements(blue) ne 0 then blue(set)=tclr(2)
	  endif
	  return, clr
	endif
 
	;==================================================================
	;	8 bit color
	;==================================================================
 
	;-------  Force color map to be defined  ----------
	if n_elements(clrmap) eq 0 then clrmap=bytarr(256)+2	; Protect all.
 
	;-------  Initialize a block of working colors  -------
	if n_elements(init) ne 0 then begin
	  if n_elements(init) ne 2 then begin
	    if init eq 1 then ii=[0,255] else ii=[init,init]
	  endif else begin
	    ii = init>0<topc()		; Keep in range.
	  endelse
	  clrmap(0:255) = 2		; Protect all first.
	  clrmap(ii(0):ii(1)) = 0	; Clear working block.
	endif
 
	;-------  Drop a working color or range  -----------
	if n_elements(drop) ne 0 then begin
	  dd = drop
	  if n_elements(dd) eq 1 then dd=[dd,dd]>0<255  ; Force to be a range.
	  if max(clrmap(dd(0):dd(1))) ne 2 then begin
	    clrmap(dd(0):dd(1)) = 0
	  endif else begin
	    print,' Error in tarclr: Attempt to drop a working color: ',dd
	    print,' Do x=tarclr(/list) for more info.'
	    return,0
	  endelse
	endif
 
	;--------  List working color info  -------------
	if keyword_set(list) then begin
	  ww = where(clrmap lt 2, cntw)
	  txt = ''
	  if cntw gt 0 then txt=' ('+strtrim(min(ww),2)+ $
	    ' to '+strtrim(max(ww),2)+')'
	  w = where(clrmap eq 0, cnta)
	  print,' '
	  print,' tarclr reserved color info:'
	  print,'   Number of working colors = '+strtrim(cntw,2)+txt
	  print,'   Number of available colors = '+strtrim(cnta,2)
	endif
 
	;-------  Set color if index given  -------------
	if n_elements(set) ne 0 then begin
	  if not keyword_set(noload) then begin
	    tvlct,tclr(0),tclr(1),tclr(2), set		    ; Set device CT.
	    if clrmap(set) ne 2 then clrmap(set)=1	    ; Reserve this clr.
	  endif
	  if n_elements(red) ne 0 then red(set)=tclr(0)	    ; Update given CT.
	  if n_elements(green) ne 0 then green(set)=tclr(1)
	  if n_elements(blue) ne 0 then blue(set)=tclr(2)
	  return, set				; Return as best match.
	endif
 
	;-------  Add new working color if possible  --------------------
	if keyword_set(add) then begin
	  w = where(clrmap eq 0, cnt)		; Look for available clr.
	  if cnt gt 0 then begin		; Have space.
	    clr = w(0)				; Use first free.
	    tvlct,tclr(0),tclr(1),tclr(2), clr	; Set device CT.
	    clrmap(clr) = 1			; Reserve this clr.
	    return, clr
	  endif else begin
	    print,' tarclr: No free working colors, returning closest match.'
	  endelse
	endif
 
        ;-------  Find image color closest to given target color  --------
	tvlct,r,g,b,/get			; Get screen color table.
	if n_elements(red)   ne 0 then r=red	; But use given color table
	if n_elements(green) ne 0 then g=green  ;   if available to find
	if n_elements(blue)  ne 0 then b=blue   ;   target color.
        d = float(r-tclr(0))^2+float(g-tclr(1))^2+float(b-tclr(2))^2
	dmin =  min(d)
        clr = (where(d eq dmin))(0)
 
	return,clr
 
	end
