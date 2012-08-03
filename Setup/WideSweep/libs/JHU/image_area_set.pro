;-------------------------------------------------------------
;+
; NAME:
;       IMAGE_AREA_SET
; PURPOSE:
;       Set up image working area.
; CATEGORY:
; CALLING SEQUENCE:
;       image_area_set
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         AREA=area  Working area: [ixlo,iylo,ixhi,iyhi]
;           ixlo,ixhi are working range in x pixels.
;           iylo,iyhi are working range in y pixels.
;           Origin at lower left corner.
;         SIZE=winsize  Image size: [nx,ny] in pixels.
;           Not needed for interactive mode.
;         SET_FILE=file  Name of areas file.  Def=image_area.txt
;           in home directory.  SET_FILE should be used on first
;           call with no other items.
;         /LIST means list image_area file.
; OUTPUTS:
; COMMON BLOCKS:
;       image_area_com
; NOTES:
;       Note: If called with no arguments will give an interactive
;         box in current screen window.  Will update or create an
;         entry in the image_areas file for the current size window.
;         Each size window will have its own entry.  The current
;         working area for a given size image can be read back
;         using image_area_get, area
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
	pro image_area_set, area=area, size=wsize, $
	  set_file=afile0, list=list, help=hlp
 
	common image_area_com, afile
 
	if keyword_set(hlp) then begin
	  print,' Set up image working area.'
	  print,' image_area_set'
	  print,'   Interactive or keyword.'
	  print,' Keywords:'
	  print,'   AREA=area  Working area: [ixlo,iylo,ixhi,iyhi]'
	  print,'     ixlo,ixhi are working range in x pixels.'
	  print,'     iylo,iyhi are working range in y pixels.'
	  print,'     Origin at lower left corner.'
	  print,'   SIZE=winsize  Image size: [nx,ny] in pixels.'
	  print,'     Not needed for interactive mode.'
	  print,'   SET_FILE=file  Name of areas file.  Def=image_area.txt'
	  print,'     in home directory.  SET_FILE should be used on first'
	  print,'     call with no other items.'
	  print,'   /LIST means list image_area file.'
	  print,' Note: If called with no arguments will give an interactive'
	  print,'   box in current screen window.  Will update or create an'
	  print,'   entry in the image_areas file for the current size window.'
	  print,'   Each size window will have its own entry.  The current'
	  print,'   working area for a given size image can be read back'
	  print,'   using image_area_get, area'
	  return
	endif
 
	;-------  image_area file  ------------
	if n_elements(afile0) ne 0 then begin	; Given afile.
	  f = file_search(afile0, count=cnt)
	  if cnt eq 0 then begin
	    xmess,['Error in image_area_set.', $
		'Given image_area file not found:',$
		afile0]
	    stop
	  endif
	  afile = afile0
	endif
	if n_elements(afile) eq 0 then begin	; Default afile.
	  dir = getenv('HOME')
	  afile = filename(dir,'image_area.txt',/nosym)
	endif
 
	;-------  List  -----------------------
	if keyword_set(list) then begin
	  t = getfile(afile, err=err)
	  print,' '
	  print,' Image Areas File: '+afile
	  if err ne 0 then begin
	    print,' Not available.'
	  endif else begin
	    more,t,lines=100
	  endelse
	  return
	endif
 
	;-------  Image area  -----------------
	;-------  Interactive mode  -----------
	if n_elements(area) eq 0 then begin
	  image_area_get, area, error=err
	  if err eq 0 then begin
	    ixlo = area(0)+0
	    iylo = area(1)+0
	    ixhi = area(2)+0
	    iyhi = area(3)+0
	  endif
	  wshow
	  xmess,['Drag open a box on the current image.', $
		'May change size by dragging sides or corners.', $
		'Move by dragging inside the box.  Click other',$
		'mouse button when done.',' ','Click OK to start']
	  box2b,ixlo,ixhi,iylo,iyhi,/status,ex=ex
	  if ex eq 1 then begin
	    xmess,['No change to working area']
	    return
	  endif
	endif else begin
	;-------  Give area  ------------------
	  ixlo = area(0)
	  iylo = area(1)
	  ixhi = area(2)
	  iyhi = area(3)
	endelse
 
	;-------  Image size  -----------
	if n_elements(wsize) eq 0 then begin
	  nx = !d.x_size	; Use current image.
	  ny = !d.y_size
	endif else begin
	  nx = wsize(0)		; use given size.
	  ny = wsize(1)
	endelse
 
	;-------  Create entry  -------
	sz0 = string(nx,ny,form='(I0," x ",I0)')
	txt = sz0+': ' + $
	  string(ixlo,iylo,ixhi,iyhi,form='(4I6)')
 
	;-------  Update entry  --------
;	afile = '~/counters/area.txt'			; Areas file.
	t = getfile(afile,err=err,/quiet)		; Read file.
	if err ne 0 then begin				; New file.
	  t = [ '*-------------------------------------------',$
		'* area.txt = Define working areas for images.',$
		'* Each image size has its own working area.',$
		'* The area is given by ixlo, iylo, ixhi, iyhi', $
		'* and are x and y pixels values from the lower left corner.',$
		' ', txt]
	  print,' Creating new image working areas file ...'
	  pref = ' Added '
	endif else begin				; File exists.
	  n = n_elements(t)				; Lines in file.
	  flag = 0					; Any match?
	  for i=0,n-1 do begin				; Search for match.
	    txt2 = t(i)					; Next line.
	    if strpos(txt2,':') ge 0 then begin		; Data line.
	      sz = getwrd(txt2,0,del=':')		; Grab image size.
	      sz = repchr(strupcase(sz),'X',' ')	; Break into nx, ny.
	      nx2 = getwrd(sz,0)
	      ny2 = getwrd(sz,1)
	      if (nx eq nx2) and (ny eq ny2) then begin	; Match?
	        t(i) = txt				; Yes, replace with new.
	        flag = 1				; Flag match found.
	        print,' Updating image working area entry ...'
	        pref = ' Updated '
	        break					; Quit looking.
	      endif  ; Match.
	    endif  ; Data line.
	  endfor  ; Search loop.
	  if flag eq 0 then begin			; No match, new entry.
	    t = [t,txt]
	    print,' Adding new image working area entry ...'
	    pref = ' Added '
	  endif
	endelse
 
	;-------  Update file  --------
	putfile, afile, t
	print,' Working areas file complete:'+pref+sz0+' working area.'
 
	end
