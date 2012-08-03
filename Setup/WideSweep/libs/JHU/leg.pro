;-------------------------------------------------------------
;+
; NAME:
;       LEG
; PURPOSE:
;       Make a plot legend.
; CATEGORY:
; CALLING SEQUENCE:
;       leg
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         LINESTYLE=sty  An array of line styles (def=0).
;         THICK=thk      An array of line & sym thicknesses (def=1).
;         COLOR=clr      An array of line colors (def=!p.color).
;         PSYM=sym       An array of plot symbol codes (def=none).
;         SYMSIZE=ssz    An array of symbol sizes (def=1).
;         SCOLOR=sclr    An array of symbol colors (def=COLOR).
;         NUMBER=nums    Number of symbols per line (def=1).
;         /INDENT        Means indent symbols from line ends.
;         LABEL=lbl      An array of line labels (def=none).
;         FONT=font      Font text (0=hardware, -1=Hershey (def)).
;         LSIZE=lsz      Label text size (def=1).
;         LCOLOR=lclr    Label color (def=same as line colors).
;         TITLE=ttl      Legend title.
;         TSIZE=tsz      Title size (def=1).
;         TCOLOR=tclr    Title color (def=!p.color).
;         BOLD=b         Bold (thickness) for labels & title (def=1).
;         POSITION=pos   Legend position in normalized window
;           coordinates.  If not given, positioning is interactive.
;         /DEVICE        pos is in device coordinates.
;         /NORMAL        pos is in normalized coordinates.
;         OUTPOS=opos    Returned legend position from interactive
;           mode. Useful to repeat legend plot non-interactively.
;           Also in normalized window coordinates, that is 0 to 1
;           from xmin or ymin to xmax or ymax.
;         BOX=box        Legend background box parameters.  If not
;           given no box is plotted.  May have up to 6 elements:
;           [BIC, BOC, BOT, BMX, BMY, BFLAG]
;           BIC: Box interior color.  Def=no box.
;           BOC: Box outline color.   Def=!p.color.
;           BOT: Outline thickness.   Def=1.
;           BMX: Box margin in x.     Def=1.
;           BMY: Box margin in y.     Def=1.
;           BFLAG: Margin units flag. Def unit (BFLAG=0) is 1 legend
;             line spacing (in y). 1 means units are norm coord.
;        keyword.  Which font is selected by placing a font selection
;        string at the start of the first label.  Ex: "!8Label 1"
;        gives the Italic font for Hershey.
;        Hint: set up array parameters in separate statements.
; OUTPUTS:
; COMMON BLOCKS:
;       leg_com
; NOTES:
;       Notes: Unless POSITION is given, an interactive box is used
;        to position plot legend.  The first line is the top of
;        the box, the last is the bottom, and the rest are uniformly
;        spaced between.  The last value of short arrays is repeated.
;        If given, the box outline color is used as the default.
;        Hardware or Hershey fonts are selected using the FONT
; MODIFICATION HISTORY:
;       R. Sterner, 26 Jul, 1993
;       Dick Jackson (djackson@ibd.nrc.ca), 1994 Aug 2 --- Added FONT keyword
;       and symbol thickness.
;       R. Sterner, 1994 Nov 18 --- Allowed array of symbol sizes.
;       R. Sterner, 2003 Dec 15 --- Allowed POS to be dev or norm coordinates.
;       R. Sterner, 2006 Jan 31 --- Added keyword BOLD=b for text.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro leg, linestyle=sty, thick=thk, color=clr, psym=sym, symsize=ssz, $
	  number=nums, label=lbl, lsize=lsz, title=ttl, tsize=tsz, tcolor=tclr,$
	  position=pos, outpos=outpos, scolor=sclr, lcolor=lclr, $
          indent=indent, box=box, help=hlp, font=font, device=dev, $
	  normalized=norm, bold=bold
 
	common leg_com, bx, by, bdx, bdy
 
	if keyword_set(hlp) then begin
	  print,' Make a plot legend.'
	  print,' leg'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   LINESTYLE=sty  An array of line styles (def=0).'
	  print,'   THICK=thk      An array of line & sym thicknesses (def=1).'
	  print,'   COLOR=clr      An array of line colors (def=!p.color).'
	  print,'   PSYM=sym       An array of plot symbol codes (def=none).'
	  print,'   SYMSIZE=ssz    An array of symbol sizes (def=1).'
	  print,'   SCOLOR=sclr    An array of symbol colors (def=COLOR).'
	  print,'   NUMBER=nums    Number of symbols per line (def=1).'
	  print,'   /INDENT        Means indent symbols from line ends.'
	  print,'   LABEL=lbl      An array of line labels (def=none).'
	  print,'   FONT=font      Font text (0=hardware, -1=Hershey (def)).'
	  print,'   LSIZE=lsz      Label text size (def=1).'
	  print,'   LCOLOR=lclr    Label color (def=same as line colors).'
	  print,'   TITLE=ttl      Legend title.'
	  print,'   TSIZE=tsz      Title size (def=1).'
	  print,'   TCOLOR=tclr    Title color (def=!p.color).'
	  print,'   BOLD=b         Bold (thickness) for labels & title (def=1).'
	  print,'   POSITION=pos   Legend position in normalized window'
	  print,'     coordinates.  If not given, positioning is interactive.'
	  print,'   /DEVICE        pos is in device coordinates.'
	  print,'   /NORMAL        pos is in normalized coordinates.'
	  print,'   OUTPOS=opos    Returned legend position from interactive'
	  print,'     mode. Useful to repeat legend plot non-interactively.'
	  print,'     Also in normalized window coordinates, that is 0 to 1'
	  print,'     from xmin or ymin to xmax or ymax.'
	  print,'   BOX=box        Legend background box parameters.  If not'
	  print,'     given no box is plotted.  May have up to 6 elements:'
	  print,'     [BIC, BOC, BOT, BMX, BMY, BFLAG]'
	  print,'     BIC: Box interior color.  Def=no box.'
	  print,'     BOC: Box outline color.   Def=!p.color.'
	  print,'     BOT: Outline thickness.   Def=1.'
	  print,'     BMX: Box margin in x.     Def=1.'
	  print,'     BMY: Box margin in y.     Def=1.'
	  print,'     BFLAG: Margin units flag. Def unit (BFLAG=0) is 1 legend'
	  print,'       line spacing (in y). 1 means units are norm coord.'
	  print,' Notes: Unless POSITION is given, an interactive box is used'
	  print,'  to position plot legend.  The first line is the top of'
	  print,'  the box, the last is the bottom, and the rest are uniformly'
	  print,'  spaced between.  The last value of short arrays is repeated.'
	  print,'  If given, the box outline color is used as the default.'
	  print,'  Hardware or Hershey fonts are selected using the FONT'
	  print,'  keyword.  Which font is selected by placing a font selection'
	  print,'  string at the start of the first label.  Ex: "!8Label 1"'
	  print,'  gives the Italic font for Hershey.'
	  print,'  Hint: set up array parameters in separate statements.'
	  return
	endif
 
	;-------  Make sure parameters are defined  -------------
	defclr = !p.color				; Default color.
	if n_elements(box) ge 2 then defclr = box(1)	; Use Box outln as def.
	if n_elements(sty) eq 0 then sty = [0]
	if n_elements(thk) eq 0 then thk = [0]
	if n_elements(clr) eq 0 then clr = [defclr]
	if n_elements(sclr) eq 0 then sclr = clr     ; Symbols def to line clrs.
	if n_elements(sym) eq 0 then sym = [0]
	if n_elements(ssz) eq 0 then ssz = [1]
	if n_elements(lbl) eq 0 then lbl = [' ']
	if n_elements(font) eq 0 then font = -1
	if n_elements(lsz) eq 0 then lsz = 1
	if n_elements(lclr) eq 0 then lclr = clr     ; Labels def to line clrs.
	if n_elements(nums) eq 0 then nums = 1
	if n_elements(ttl) eq 0 then ttl = ''
	if n_elements(tsz) eq 0 then tsz = 1
	if n_elements(tclr) eq 0 then tclr = defclr
	if n_elements(bold) eq 0 then bold = 1       ; Text thickness.
 
	;-------  Find last element of each array  -----------
	lst_sty = n_elements(sty)-1
	lst_thk = n_elements(thk)-1
	lst_clr = n_elements(clr)-1
	lst_sclr = n_elements(sclr)-1
	lst_ssz = n_elements(ssz)-1
	lst_lclr = n_elements(lclr)-1
	lst_sym = n_elements(sym)-1
	lst_lbl = n_elements(lbl)-1
	num = 1+(lst_sty>lst_thk>lst_clr>lst_sym>lst_lbl>lst_lclr)
 
	;--------  Interactive mode  ----------------
	if n_elements(pos) eq 0 then begin
	  if n_elements(bx) eq 0 then begin
	    bx=100 & by=100 & bdx=100 & bdy=100
	  endif
	  movbox,bx,by,bdx,bdy,code,col=-2, $	; Dev crds of legend.
	    /noerase,/exiterase
	  x=bx & y=by & dx=bdx & dy=bdy
	  if code eq 2 then return
	  xx = [x,x+dx]				; Convert to normal coords.
	  yy = [y,y+dy]
	  t = convert_coord(xx,yy,/dev,/to_norm)
	  x1 = t(0,0)				; Legend box in norm coord.
	  x2 = t(0,1)
	  y1 = t(1,0)
	  y2 = t(1,1)
	  dx = !x.window(1) - !x.window(0)	; Plot window size,
	  dy = !y.window(1) - !y.window(0)	;   in normalized coord.
	  nx1 = (x1-!x.window(0))/dx		; Norm. Data. coord.
	  nx2 = (x2-!x.window(0))/dx
	  ny1 = (y1-!y.window(0))/dy
	  ny2 = (y2-!y.window(0))/dy
	  pos = [nx1,ny1,nx2,ny2]
	  outpos = pos
	endif
 
	;========  Plot legend  ============
	flag = 0			   ; Assume pos in norm window coord.
	if keyword_set(dev) then flag=1    ; Pos in device coord..
	if keyword_set(norm) then flag=2   ; Pos in normalized coord..
	;--------  Convert position  -------
	case flag of
0:	begin				     ; Normalized window coord (def).
	  dx = !x.window(1) - !x.window(0)   ; Convert from normalized window,
	  dy = !y.window(1) - !y.window(0)   ;   to normalized.
	  x1 = pos(0)*dx + !x.window(0)
	  x2 = pos(2)*dx + !x.window(0)
	  y1 = pos(1)*dy + !y.window(0)
	  y2 = pos(3)*dy + !y.window(0)
	end
1:	begin				     ; Device coord. to normalize.
	  x1 = float(pos(0))/!d.x_size
	  x2 = float(pos(2))/!d.x_size
	  y1 = float(pos(1))/!d.y_size
	  y2 = float(pos(3))/!d.y_size
	end
2:	begin				     ; Normalized coord. to normalize.
	  x1 = pos(0)
	  x2 = pos(2)
	  y1 = pos(1)
	  y2 = pos(3)
	end
	endcase
 
	dy = (y2 - y1)/((num-1)>1)	   ; Line spacing in norm. coord.
 
	;------  Compute character size  ------
	cx = lsz*!d.x_ch_size/float(!d.x_size)  ; Char size in norm units.
	cy = lsz*.778*!d.y_ch_size/!d.y_size	; .778 = fract. filled by ch.
 
	;-------  Handle symbols  -------------
	sx = ssz*!d.x_ch_size/float(!d.x_size)  ; Sym size in norm units.
	if keyword_set(indent) then begin
	  dx = (x2 - x1)/(nums+1.)		; Symbol spacing (indented).
	  sx1 = x1 + dx/2.
	  sx2 = x2 - dx/2.
	  dx = (sx2 - sx1)/((nums-1.)>1.)
	  dx = dx(0)				; Use first case to indent.
	endif else begin
	  sx1 = x1 + sx/2.			; Indent by 1/2 sym size.
	  sx2 = x2 - sx/2.
	  dx = (sx2 - sx1)/((nums-1.)>1.)	; (Non-indented).
	  dx = dx(0)				; Use first case to indent.
	  sx1 = sx1(0)				; Use first case for start pt.
	endelse
 
	;----------  Find max text length  -----------
	widmax = 0.			; Keep track of max label width (norm).
	for ii = 0, num-1 do begin
	  xyouts,/norm,-10,-10,lbl(ii<lst_lbl),chars=lsz,width=wid,font=font
	  widmax = widmax>wid
	endfor
 
	;-----------  Handle legend box  ---------------
	nbox = n_elements(box)
	if nbox gt 0 then begin
	  bic = box(0)					; Interior color.
	  if nbox ge 2 then boc=box(1) else boc=!p.color  ; Outline color.
	  if nbox ge 3 then bot=box(2) else bot=1	; Outline thickness.
	  if nbox ge 4 then bmx=box(3) else bmx=1.	; X margin.
	  if nbox ge 5 then bmy=box(4) else bmy=bmx	; Y margin.
	  if nbox ge 6 then bfl=box(5) else bfl=0	; Units flag.
	  if bfl eq 0 then begin			; Units are
	    bmx = bmx*dy				;   legend line
	    bmy = bmy*dy				;   spacing in Y.
	  endif
	  bx1 = x1 - bmx		; Box boundary in norm. coord.
	  bx2 = x2 + widmax + bmx	;   Allow for longest text.
	  by1 = y1 - bmy
	  by2 = y2 + bmy
	  if ttl ne '' then by2 = by2 + dy	; Allow for title.
	  polyfill, /norm, [bx1,bx2,bx2,bx1],[by1,by1,by2,by2],color=bic
	  plots, /norm, [bx1,bx2,bx2,bx1,bx1],[by1,by1,by2,by2,by1],$
	    color=boc, thick=bot
	endif
 
	;-----------  Loop through and plot legend entries  --------------
	for ii = 0, num-1 do begin
	  i = num-1 - ii		; Reverse order.
	  symc = sym(ii<lst_sym)	; Symbol code.
	  ;-------  Plot lines  --------------
	  if symc le 0 then begin	; Plot line.
	    plots, /norm, [x1,x2],y1+i*[dy,dy], linestyle=sty(ii<lst_sty), $
	      thick=thk(ii<lst_thk), color=clr(ii<lst_clr)
	  endif
	  ;-------  Plot symbols  ------------
	  if abs(symc) ne 0 then begin		;--- Plot symbols.
	    if nums eq 1 then begin		;--- Single symbol (center).
              plots, /norm, [.5*(x1+x2)],[y1+i*dy], $
                psym=abs(symc), symsize=ssz(ii<lst_ssz),$
		color=sclr(ii<lst_sclr), thick=thk(ii<lst_thk)
	    endif else begin
	      if keyword_set(indent) then begin	;--- Indented.
	        plots,/norm, sx1+dx*(indgen(nums)),y1+i*dy+0*indgen(nums), $
	          psym=abs(symc), symsize=ssz(ii<lst_ssz),$
		  color=sclr(ii<lst_sclr), thick=thk(ii<lst_thk)
	      endif else begin			;--- Non-indented.
	        plots,/norm, sx1+dx*indgen(nums),y1+i*dy+0*indgen(nums), $
	          psym=abs(symc), symsize=ssz(ii<lst_ssz),$
		  color=sclr(ii<lst_sclr), thick=thk(ii<lst_thk)
	      endelse
	    endelse
	  endif
	  ;-------  Labels  ------------------
;	  xyouts, /norm, x2+cx, y1+i*dy-cy/2.,lbl(ii<lst_lbl),$
;	    charsize=lsz, color=lclr(ii<lst_lclr), font=font
	  xyoutb, /norm, x2+cx, y1+i*dy-cy/2.,lbl(ii<lst_lbl),$
	    charsize=lsz, color=lclr(ii<lst_lclr), font=font,bold=bold
	endfor
 
	;---------  Legend title  -------------
;	if ttl ne '' then xyouts, /norm, .5*(x1+x2+widmax), y1+dy*num, ttl, $
;	  charsize=tsz, align=.5, color=tclr, font=font
	if ttl ne '' then xyoutb, /norm, .5*(x1+x2+widmax), y1+dy*num, ttl, $
	  charsize=tsz, align=.5, color=tclr, font=font, bold=bold
 
	return
	end
