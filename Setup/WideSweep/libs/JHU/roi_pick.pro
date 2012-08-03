;-------------------------------------------------------------
;+
; NAME:
;       ROI_PICK
; PURPOSE:
;       Pick one or more regions of interest, return as text array.
; CATEGORY:
; CALLING SEQUENCE:
;       roi_pick, txt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=ttl Title text (def: Select region type).
;         /SINGLE select a single region, else loop for multiple.
; OUTPUTS:
;       txt = returned text array.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Interactive, pick region type from a menu, then
;         select that type region.  Regions are returned in a
;         text array when done.  The first value in each line of
;         the returned text indicates the region type:
;           1: box, 2: circle, 3: polygon.
;         The type codes and values following are described
;         below for the three types of lines:
;         Box:     1, x1, x2, y1, y2
;           Box min and max x, min and max y.
;         Circle:  2, radius, xcenter, ycenter
;         Polygon: 3, x1, y1, x2, y2, ..., xn, yn
;            Polygon vertices.
;         All coordinates and values are in device coordinates.
;         See also roi_indices.pro.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Sep 14
;       R. Sterner, 2004 Sep 15 --- Changed name from pickroi.pro.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro roi_pick, txt, single=sing, title=ttl, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Pick one or more regions of interest, return as text array.'
	  print,' roi_pick, txt'
	  print,'   txt = returned text array.   out'
	  print,' Keywords:'
	  print,'   TITLE=ttl Title text (def: Select region type).'
	  print,'   /SINGLE select a single region, else loop for multiple.'
	  print,' Notes: Interactive, pick region type from a menu, then'
	  print,'   select that type region.  Regions are returned in a'
	  print,'   text array when done.  The first value in each line of'
	  print,'   the returned text indicates the region type:'
	  print,'     1: box, 2: circle, 3: polygon.'
	  print,'   The type codes and values following are described'
	  print,'   below for the three types of lines:'
	  print,'   Box:     1, x1, x2, y1, y2'
	  print,'     Box min and max x, min and max y.'
	  print,'   Circle:  2, radius, xcenter, ycenter'
	  print,'   Polygon: 3, x1, y1, x2, y2, ..., xn, yn'
	  print,'      Polygon vertices.'
	  print,'   All coordinates and values are in device coordinates.'
	  print,'   See also roi_indices.pro.'
	  return
	endif
 
	txt = ['']
	bflag = 1
	cflag = 1
	pflag = 1
	if n_elements(ttl) eq 0 then ttl='Select region type'
 
loop:	opt = xoption(['Box','Circle','Polygon','Done'], $
	  val=['B','C','P','D'],title=ttl)
 
	;--------  Done  ------------
	if opt eq 'D' then begin
done:	  if n_elements(txt) eq 1 then begin
	    txt = ''
	  endif else begin
	    txt = txt(1:*)
	  endelse
	  return
	endif
 
	;--------  Box  ------------
	if opt eq 'B' then begin
	  if bflag then xhelp,['Drag open a box','Drag center or sides',$
	    'Right click when done'], /nowait,wid=wid
	  box2b, x1, x2, y1, y2, exit=ex
	  if bflag then widget_control, wid,/dest
	  bflag = 0
	  if ex ne 0 then goto, loop
	  t = '1, '+commalist([x1,x2,y1,y2])
	  txt = [txt,t]
	  plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]
	endif
 
	;--------  Circle  ------------
	if opt eq 'C' then begin
	  rad = 1
	  new = 1
	  if cflag then xhelp,['Drag open a circle','Drag center or circle',$
	    'Right click when done'], /nowait,wid=wid
cloop:	  xadjcirc,rad,ix=ix,iy=iy,new=new
	  if cflag then widget_control, wid,/dest
	  cflag = 0
	  opt2 = xoption(['Continue','OK','Abort'],def=1)
	  new = 0
	  if opt2 eq 0 then begin
	    tvcrs, ix, iy
	    goto, cloop
	  endif
	  if opt2 eq 2 then goto, loop
	  t = '2, '+commalist([rad,ix,iy])
	  txt = [txt,t]
	  tvcirc, ix,iy, rad
	endif
 
	;--------  Polygon  ------------
	if opt eq 'P' then begin
	  if pflag then xhelp,['Left click for new point', $
	    'Middle click to delete a point',$
	    'Right click when done'],/nowait,wid=wid
	  drawpoly,x,y
	  opt2 = xoption(['OK','Abort'],def=0)
	  if opt2 eq 1 then goto, loop
	  if pflag then widget_control, wid,/dest
	  pflag = 0
	  if n_elements(x) lt 3 then goto, loop
	  xy = transpose([[x],[y]])
	  t = '3, '+commalist(xy)
	  txt = [txt,t]
	endif
 
	if keyword_set(sing) then goto, done
	goto, loop
 
	end
