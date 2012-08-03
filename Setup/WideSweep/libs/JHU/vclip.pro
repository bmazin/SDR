;-------------------------------------------------------------
;+
; NAME:
;       VCLIP
; PURPOSE:
;       Clip a vector to a clipping window.
; CATEGORY:
; CALLING SEQUENCE:
;       vclip,x1,y1,x2,y2
; INPUTS:
;       x1=[xa,xb]   Input vector endpoint x coordinates.  in
;       y1=[yy,yb]   Input vector endpoint y coordinates.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         XRANGE=[xlo,xhi] Clipping window x coordinates (def=[0,1]).
;         YRANGE=[ylo,yhi] Clipping window x coordinates (def=[0,1]).
;         FLAG=flg  flag for clipped result:
;            0=no part in window, 1=some part in window.
; OUTPUTS:
;       x2=[xc,xd]  Output vector endpoint x coordinates.  out
;       y2=[yc,yd]  Output vector endpoint y coordinates.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Dec 5
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function vclip_out, xmn,xmx,ymn,ymx,cx1,cx2,cy1,cy2
 
	if xmn ge cx2 then return, 1	; All out of window.
	if xmx le cx1 then return, 1	; All out of window.
	if ymn ge cy2 then return, 1	; All out of window.
	if ymx le cy1 then return, 1	; All out of window.
	return, 0			; Some may be in window.
 
	end
 
;===============================================================
;	vclip.pro = Clip a vector to a clipping window.
;===============================================================
 
	pro vclip,x1,y1,x2,y2,xrange=xr,yrange=yr,flag=flg,help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Clip a vector to a clipping window.'
	  print,' vclip,x1,y1,x2,y2'
	  print,'   x1=[xa,xb]   Input vector endpoint x coordinates.  in'
	  print,'   y1=[yy,yb]   Input vector endpoint y coordinates.  in'
	  print,'   x2=[xc,xd]  Output vector endpoint x coordinates.  out'
	  print,'   y2=[yc,yd]  Output vector endpoint y coordinates.  out'
	  print,' Keywords:'
	  print,'   XRANGE=[xlo,xhi] Clipping window x coordinates (def=[0,1]).'
	  print,'   YRANGE=[ylo,yhi] Clipping window x coordinates (def=[0,1]).'
	  print,'   FLAG=flg  flag for clipped result:'
	  print,'      0=no part in window, 1=some part in window.'
	  return
	endif
 
	;------  Make sure clipping window defined  ---------
	if n_elements(xr) eq 0 then xr = [0.,1.]
	if n_elements(yr) eq 0 then yr = [0.,1.]
 
	;------  Find clipping window in standard form  ------
	cx1 = min(xr,max=cx2)		; Makes order insensitive.
	cy1 = min(yr,max=cy2)
 
	;------  Find line to clip in standard form  ---------
	xmn = min(x1,max=xmx)
	ymn = min(y1,max=ymx)
	ax=x1(0) & ay=y1(0) & bx=x1(1) & by=y1(1)
	if bx lt ax then begin		; Swap order.
	  t=ax & ax=bx & bx=t
	  t=ay & ay=by & by=t
	endif
 
 
	;-------  Clip if needed  ------------------
	flg = 0
 
	if vclip_out(xmn,xmx,ymn,ymx,cx1,cx2,cy1,cy2) then return
	if xmn lt cx1 then begin		; Clip at lo x (cx1).
	  ay = ay + (cx1-ax)*(by-ay)/(bx-ax)
	  ax = cx1
	  xmn = cx1
	  ymn = by<ay
	  ymx = by>ay
	endif
 
	if vclip_out(xmn,xmx,ymn,ymx,cx1,cx2,cy1,cy2) then return
	if xmx gt cx2 then begin		; Clip at hi x (cx2).
	  by = ay + (cx2-ax)*(by-ay)/(bx-ax)
	  bx = cx2
	  xmx = cx2
	  ymn = ay<by
	  ymx = ay>by
	endif
 
	if vclip_out(xmn,xmx,ymn,ymx,cx1,cx2,cy1,cy2) then return
	if ymn lt cy1 then begin		; Clip at lo y (cy1).
	  xp = ax + (cy1-ay)*(bx-ax)/(by-ay)
	  if by eq ymn then begin
	    bx = xp
	    by = cy1
	    xmn = ax<bx
	    xmx = ax>bx
	  endif else begin
	    ax = xp
	    ay = cy1
	    xmn = bx<ax
	    xmx = bx>ax
	  endelse
	  ymn = cy1
	endif
 
	if vclip_out(xmn,xmx,ymn,ymx,cx1,cx2,cy1,cy2) then return
	if ymx gt cy2 then begin		; Clip at hi y (cy2).
	  xp = ax + (cy2-ay)*(bx-ax)/(by-ay)
	  if by eq ymx then begin
	    bx = xp
	    by = cy2
	    xmn = ax<bx
	    xmx = ax>bx
	  endif else begin
	    ax = xp
	    ay = cy2
	    xmn = bx<ax
	    xmx = bx>ax
	  endelse
	  ymx = cy2
	endif
 
	;------  Return clipped vector and set visible flag  ------
	x2 = [ax,bx]
	y2 = [ay,by]
	flg = 1
 
	return
	end
