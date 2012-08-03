;-------------------------------------------------------------
;+
; NAME:
;       IMAGE_AREA_GET
; PURPOSE:
;       Get image working area.
; CATEGORY:
; CALLING SEQUENCE:
;       image_area_get, area
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SIZE=wsize  Image size: [nx,ny], def=current window.
;         ERROR=err Error flag: 0=ok, else no area available.
; OUTPUTS:
;       area = working area: [ixlo,iylo,ixhi,iyhi]  out
;         Pixel coordinates from lower left corner.
; COMMON BLOCKS:
;       image_area_com
; NOTES:
;       Note: Image working area is in a text file with an entry for
;        each image size.  This file is created and updated using
;        image_area_set.  Do image_area_set,/list to view file.
;        The working areas may be used by image processing routines.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 May 30
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro image_area_get, area, size=wsize, error=err, help=hlp
 
	common image_area_com, afile
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get image working area.'
	  print,' image_area_get, area'
	  print,'   area = working area: [ixlo,iylo,ixhi,iyhi]  out'
	  print,'     Pixel coordinates from lower left corner.'
	  print,' Keywords:'
	  print,'   SIZE=wsize  Image size: [nx,ny], def=current window.'
	  print,'   ERROR=err Error flag: 0=ok, else no area available.'
	  print,' Note: Image working area is in a text file with an entry for'
	  print,'  each image size.  This file is created and updated using'
	  print,'  image_area_set.  Do image_area_set,/list to view file.'
	  print,'  The working areas may be used by image processing routines.'
	  return
	endif
 
	;------  Read file  ---------
	t = getfile(afile,err=err,/quiet)		; Read file.
	if err ne 0 then begin
	  print,' Error in image_area_get: no areas file found:'
	  print,' '+afile
	  err = 1
	  return
	endif
 
	;------ Image size  --------------
	if n_elements(wsize) ne 0 then begin
	  nx = wsize(0)		; use given size.
	  ny = wsize(1)
	endif else begin
	  nx = !d.x_size	; Use current image.
	  ny = !d.y_size
	endelse
	sz0 = string(nx,ny,form='(I0," x ",I0)')
 
	;------  Search for match  -------
	n = n_elements(t)
	flag = 0					; Any match?
	for i=0,n-1 do begin				; Search for match.
	  txt2 = t(i)					; Next line.
	  if strpos(txt2,':') ge 0 then begin		; Data line.
	    sz = getwrd(txt2,0,del=':')			; Grab image size.
	    sz = repchr(strupcase(sz),'X',' ')		; Break into nx, ny.
	    nx2 = getwrd(sz,0)
	    ny2 = getwrd(sz,1)
	    if (nx eq nx2) and (ny eq ny2) then begin	; Match?
	      atxt = getwrd(txt2,1,delim=':')		; Grab area.
	      ixlo = getwrd(atxt,0)
	      iylo = getwrd(atxt,1)
	      ixhi = getwrd(atxt,2)
	      iyhi = getwrd(atxt,3)
	      area = [ixlo,iylo,ixhi,iyhi]
	      print,' Found working area for image size '+sz0
	      flag = 1					; Flag match found.
	      break					; Quit looking.
	    endif  ; Match.
	  endif  ; Data line.
	endfor  ; Search loop.
 
	if flag eq 0 then begin
	  area = [-1,-1,-1,-1]
	  err = 1
	  print,' No working area found for image size '+sz0
	endif else begin
	  err = 0
	endelse
 
	end
