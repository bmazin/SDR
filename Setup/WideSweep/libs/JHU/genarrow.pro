;-------------------------------------------------------------
;+
; NAME:
;       GENARROW
; PURPOSE:
;       Generate an arrow polygon.
; CATEGORY:
; CALLING SEQUENCE:
;       genarrow, x1, y1, x2, y2, x, y
; INPUTS:
;       (x1,y1) = tail of arrow.           in
;       (x2,y2) = head of arrow.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         AWID=hw   arrowhead width.  Def=20% of shaft length.
;         ALEN=hl   arrowhead length. Def=40% of shaft length.
;         SHAFT=sw  shaft width.      Def=10% of shaft length.
;         /PERCENT means above values given as % arrow length.
; OUTPUTS:
;       x,y = arrow polygon (closed).      out
; COMMON BLOCKS:
; NOTES:
;       Note: if /PERCENT is given then all values are in %.
;         If /PERCENT is not given then given values are in
;         same units as (x1,y1), (x2,y2), and unspecified values
;         are default percents.
; MODIFICATION HISTORY:
;       R. Sterner.  5 SEP, 1986. FROM TVARROW.PRO.
;       R. Sterner, 17 Sep, 1992 --- upgraded to IDL V2.  Added some keywords.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro genarrow, x1, y1, x2, y2, x, y, $
	  help=hlp, awid=awid, alen=alen, shaft=shaft, percent=percent
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Generate an arrow polygon.'
	  print,' genarrow, x1, y1, x2, y2, x, y'
	  print,'   (x1,y1) = tail of arrow.           in'
	  print,'   (x2,y2) = head of arrow.           in'
	  print,'   x,y = arrow polygon (closed).      out'
	  print,' Keywords:'
	  print,'   AWID=hw   arrowhead width.  Def=20% of shaft length.'
	  print,'   ALEN=hl   arrowhead length. Def=40% of shaft length.'
	  print,'   SHAFT=sw  shaft width.      Def=10% of shaft length.'
	  print,'   /PERCENT means above values given as % arrow length.'
	  print,' Note: if /PERCENT is given then all values are in %.'
	  print,'   If /PERCENT is not given then given values are in'
	  print,'   same units as (x1,y1), (x2,y2), and unspecified values'
	  print,'   are default percents.'
	  return
	endif
 
	;------  Vector along arrow  --------
	vx = float(x2 - x1)		; vector along arrow.
	vy = float(y2 - y1)
	t = sqrt(vx*vx + vy*vy)		; length of arrow.
	if t eq 0 then begin
	  x = [x1]
	  y = [y1]
	  return
	endif	
 
	;------  Set default shape as % of arrow length. ---------
	p_awid = 20.
	p_alen = 40.
	p_shaft =10.
 
	;-------  User specified percents  ---------
	if keyword_set(percent) then begin
	  if n_elements(awid) ne 0 then p_awid = awid
	  if n_elements(alen) ne 0 then p_alen = alen
	  if n_elements(shaft) ne 0 then p_shaft = shaft
	  awid = t*p_awid/100.
	  alen = t*p_alen/100.
	  shaft = t*p_shaft/100.
	endif
 
	;-------  Set default sizes  ----------
	if n_elements(awid) eq 0 then awid = t*p_awid/100.
	if n_elements(alen) eq 0 then alen = t*p_alen/100.
	if n_elements(shaft) eq 0 then shaft = t*p_shaft/100.
 
	w2 = awid/2.			; half-width of head.
	w6 = shaft/2.			; half-width of shaft.
 
	vx = vx/t			; unit vector along arrow.
	vy = vy/t
	ux = vy				; unit vector across arrow.
	uy = -vx
 
	x3 = x1 + (t - alen)*vx		; point at base of arrow head.
	y3 = y1 + (t - alen)*vy
 
	ax1 = x1 + w6*ux	; point 1.
	ay1 = y1 + w6*uy
	ax2 = x3 + w6*ux	; point 2.
	ay2 = y3 + w6*uy
	ax3 = x3 + w2*ux	; point 3.
	ay3 = y3 + w2*uy
	ax4 = x2		; point 4.
	ay4 = y2
	ax5 = x3 - w2*ux	; point 5.
	ay5 = y3 - w2*uy
	ax6 = x3 - w6*ux	; point 6.
	ay6 = y3 - w6*uy
	ax7 = x1 - w6*ux	; point 7.
	ay7 = y1 - w6*uy
	ax8 = ax1		; point 8.
	ay8 = ay1
 
	x = [ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8]
	y = [ay1, ay2, ay3, ay4, ay5, ay6, ay7, ay8]
 
	return
 
	end
