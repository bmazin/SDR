;------  map_outline.pro  ---------------------
;       R. Sterner, 2002 Apr 04
;
	pro map_outline, map, color=clr, thickness=thk, linestyle=sty, $
	  label=lab, charsize=csz, help=hlp, reset=reset, nooutline=noout
 
	common map_outline_com, last_map, last_win
 
	if keyword_set(hlp) then begin
	  print,' Outline a map on current map on screen.'
	  print,' map_outline, map'
	  print,'   map = Name of map image file.    in'
	  print,' Keywords:'
	  print,'   COLOR=clr Outline color (def=!p.color).'
	  print,'   THICKNESS=thk Outline thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Outline line style (def=!p.linestyle).'
	  print,'   LABEL=lab  Label for outlined map (def=none).'
	  print,'   /NOOUTLINE Do not plot outline.  Useful with /LABEL.'
	  print,'   CHARSIZE=csz Label character size (def=1).'
	  print,'   /RESET just restore last map (before outline plot).'
	  print,' Notes: maps must have scaling info embedded by'
	  print,'   map_put_scale.'
	endif
 
	;-------  Reset  --------------------
	if keyword_set(reset) then begin
	  wset, last_win
	  tv,tr=1,last_map
	endif
 
	;-------  Save entry map and window  --------
	last_win = !d.window
	last_map = tvrd(tr=1)
	map_state_save			; Save current map scaling.
 
	if n_elements(map) eq 0 then return
 
	;-------  Defaults  -----------------
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(sty) eq 0 then sty=!p.linestyle
	if n_elements(lab) eq 0 then lab=''
	if n_elements(csz) eq 0 then csz=1.
 
	screenpng, map, /pixmap, win=winpix	; Load image in hidden window.
	map_set_scale, image=img, out=s	; Get image info.
	img_shape, img, nx=nx, ny=ny
	ix1 = s.position(0)*nx		; Map window screen coordinates.	
	ix2 = s.position(2)*nx
	iy1 = s.position(1)*ny
	iy2 = s.position(3)*ny
 
	;-------  Map window outline in device coordinates  --------------
	x = [maken(ix1,ix2,100),maken(ix2,ix2,100),maken(ix2,ix1,100), $
	     maken(ix1,ix1,100)]
	y = [maken(iy1,iy1,100),maken(iy1,iy2,100),maken(iy2,iy2,100), $
	     maken(iy2,iy1,100)]
 
	;-------  Convert outline to lat/long  ----------------------------
	tmp = convert_coord(x,y,/dev,/to_data)	; Needs a window.
	lng = tmp(0,*)
	lat = tmp(1,*)
 
	;------  Restore screen map scaling  ----------------
	wdelete, winpix		; Delete hidden window.
	wset, last_win
	tv,last_map,tr=1	; Restore screen map image.
	map_state_restore
 
	;-------  Plot outline  ------------------
	if not keyword_set(noout) then $
	  plotsh,lng,lat,color=clr,thick=thk,linestyle=sty
 
	;-------  Label  --------------------------
	if lab eq '' then return
	textplot,mean(lng),mean(lat),lab,chars=csz,col=[0,clr], $
	  shift=[-1,1],bold=[2,1],align=[0.5,0.5]
 
	end
