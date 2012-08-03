;-------------------------------------------------------------
;+
; NAME:
;       SPRINT
; PURPOSE:
;       Print text on screen, allows easy update.
; CATEGORY:
; CALLING SEQUENCE:
;       sprint, n, txt
; INPUTS:
;       n = text index number.    in
;       txt = new text.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         INDEX=in on text setup returned text index.
;         SIZE=s text size (def=1).
;         COLOR=c text color (def=max).
;         ERASE=e erase color (def=0).
; OUTPUTS:
; COMMON BLOCKS:
;       sprint_com
;       sprint_com
; NOTES:
;       Notes:
;         To setup text do:
;         sprint, x, y, txt
;           x,y = screen coordinates of text.     in
;           txt = initial text at that location.  in
;         To display all current text do:
;         sprint
; MODIFICATION HISTORY:
;       R. Sterner, 6 Oct, 1991
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        pro sprint, p1, p2, p3, index=ind, color=color, $
          erase=erase,  size=size, help=hlp
 
        common sprint_com, xx, yy, ss, cc, ee, txt
 
        if keyword_set(hlp) then begin
          print,' Print text on screen, allows easy update.'
          print,' sprint, n, txt'
          print,'   n = text index number.    in'
          print,'   txt = new text.           in'
          print,' Keywords:'
          print,'   INDEX=in on text setup returned text index.'
          print,'   SIZE=s text size (def=1).'
          print,'   COLOR=c text color (def=max).'
          print,'   ERASE=e erase color (def=0).'
          print,' Notes:'
          print,'   To setup text do:'
          print,'   sprint, x, y, txt'
          print,'     x,y = screen coordinates of text.     in'
          print,'     txt = initial text at that location.  in'
          print,'   To display all current text do:'
          print,'   sprint'
          return
        endif
 
        ;----------  Initialize  --------------
        if n_params(0) eq 3 then begin
          if n_elements(color) eq 0 then color = !p.color
          if n_elements(size)  eq 0 then size=1.
          if n_elements(erase) eq 0 then erase=0
          xyouts, /dev, p1, p2, p3, color=color, size=size
          if n_elements(xx) eq 0 then begin     ; Must start common.
            xx = intarr(1)+p1
            yy = intarr(1)+p2
            ss = fltarr(1)+size
            cc = intarr(1)+color
            ee = intarr(1)+erase
            txt = strarr(1)
            txt(0) = p3
          endif else begin                      ; Common exists.
            xx = [xx,p1]
            yy = [yy,p2]
            ss = [ss, size]
            cc = [cc, color]
            ee = [ee, erase]
            txt = [txt,p3]
          endelse
          ind = n_elements(xx)-1
          return
        endif
 
        ;-----------  Update text  -----------
        if n_params(0) eq 2 then begin
          if (p1 lt 0) or (p1 gt n_elements(xx)-1) then return
          if n_elements(erase) eq 0 then erase = ee(p1)
          xyouts, /dev, xx(p1), yy(p1), txt(p1), size=ss(p1), color=erase
          if n_elements(color) eq 0 then color = cc(p1)
          if n_elements(size) eq 0 then size = ss(p1)
          xyouts, /dev, xx(p1), yy(p1), p2, size=size, color=color
          txt(p1)=p2
          ss(p1)=size
          cc(p1)=color
          ee(p1)=erase
          return
        endif
 
        if n_params(0) eq 0 then begin
          for i = 0, n_elements(xx)-1 do begin
            xyouts, /dev, xx(i), yy(i), txt(i), size=ss(i), color=cc(i)
          endfor
          return
        endif
 
        end
