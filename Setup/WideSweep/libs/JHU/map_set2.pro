;--------------------------------------------------------------------------
;	map_set2.pro = Wrapper for map_set to capture settings
;	R. Sterner, 2002 Jan 17
;	R. Sterner, 2002 Jan 29 --- Added flag for CLIP=0.
;	R. Sterner, 2005 Jun 15 --- Added !d.x_px_cm,!d.y_px_cm.
;
;	This routine works identically to map_set but captures the
;	info needed to set up the map projection and scaling at a
;	later time.  After doing a map_set2, call map_put_scale to
;	embed the scaling info in the current map on the screen.
;	Image must be saved in a non-lossy format (such as PNG).
;	After loading the image to the display call map_set_scale to
;	restore map scaling.  map_set2 just captures the info passing
;	through it and packs it into a compact form for map_put_scale.
;--------------------------------------------------------------------------
 
	pro map_set2, lat0, lng0, ang0, _extra=extra
 
	common map_set2_com, pack
 
	on_error, 2			; Return to caller on error.
 
	;-------------------------------------------------
	;	Default central point values
	;-------------------------------------------------
	if n_elements(lat0) eq 0 then lat0=0.
	if n_elements(lng0) eq 0 then lng0=0.
	if n_elements(ang0) eq 0 then ang0=0.
	lat=float(lat0) & lng=float(lng0) & ang=float(ang0)
 
	;-------------------------------------------------
	;	Actual map_set command
	;-------------------------------------------------
	map_set, lat0, lng0, ang0, _extra=extra
 
	;-------------------------------------------------
	;	Analyze given map_set keywords
	;-------------------------------------------------
	tnames = tag_names(extra)	; Array of tag names (uppercase).
 
	m = '1234567891'	; Magic number to indicate embedded scaling.
 
	;-------------------------------------------------
	;	Flags
	;-------------------------------------------------
 
	;--- /NOBORDER:
	w = where(strmid(tnames,0,3) eq 'NOB',c)
	flag_noborder = c ne 0
 
	;--- /ISO:
	w = where(strmid(tnames,0,1) eq 'I',c)
	flag_iso = c ne 0
 
	;--- CLIP=0:
	w = where(strmid(tnames,0,2) eq 'CL',c)
	flag_clip = c ne 0
 
	;-------------------------------------------------
	;	Single values
	;-------------------------------------------------
 
	;--- COLOR=:
	w = where(strmid(tnames,0,3) eq 'COL',c)
	flag_col = c ne 0
	if flag_col then val_col=long(extra.(w(0))) else val_col=0L
 
	;--- SCALE=:
	w = where(strmid(tnames,0,2) eq 'SC',c)
	flag_scale = c ne 0
	if flag_scale then val_scale=float(extra.(w(0))) else val_scale=0.0
 
	;--- CENTRAL_AZI=:
	w = where(strmid(tnames,0,2) eq 'CE',c)
	flag_azi = c ne 0
	if flag_azi then val_azi=float(extra.(w(0))) else val_azi=0.0
	
	;-------------------------------------------------
	;	Array values	
	;-------------------------------------------------
 
	;--- LIMIT=:
	w = where(strmid(tnames,0,2) eq 'LI',c)
	flag_lim = c ne 0
	if flag_lim then val_lim=float(extra.(w(0))) else val_lim=fltarr(4)
	nlim = n_elements(val_lim)
	if nlim eq 4 then begin
	  val_lim = [val_lim,0.,0.,0.,0.]
	endif
 
	;--- STANDARD_PARALLELS=:
	w = where(strmid(tnames,0,3) eq 'STA',c)
	flag_par = c ne 0
	if flag_par then val_par=float(extra.(w(0))) else val_par=fltarr(2)
 
	;--- SAT_P=:
	w = where(strmid(tnames,0,4) eq 'SAT_',c)
	flag_sat = c ne 0
	if flag_sat then val_sat=float(extra.(w(0))) else val_sat=fltarr(3)
 
	;--- ELLIPSOID=:
	w = where(strmid(tnames,0,2) eq 'EL',c)
	flag_ell = c ne 0
	if flag_ell then val_ell=float(extra.(w(0))) else val_ell=fltarr(3)
	  
	;-------------------------------------------------
	;	Grab values from system variables
	;-------------------------------------------------
 
	;--- POSITION=:
	pos = ([!x.window,!y.window])([0,2,1,3])
 
	;--- PROJECTION=:
	proj = !map.projection
 
	;---  SCREEN SIZE=:
	pxcm = [!d.x_px_cm, !d.y_px_cm]
 
 
	;-------------------------------------------------
	;	Pack all needed values into a byte array.
	;-------------------------------------------------
					;      #items lo   hi #bytes typ
	pack = byte(m)				; 1    0    9   10   chr
	pack = [pack,byte([lat,lng,ang],0,12)]	; 3   10   21   12   flt
	pack = [pack,flag_noborder]		; 1   22   22    1   byt
	pack = [pack,flag_iso]			; 1   23   23    1   byt
	pack = [pack,flag_col]			; 1   24   24    1   byt
	pack = [pack,byte(val_col,0,4)]		; 1   25   28    4   lon
	pack = [pack,flag_scale]		; 1   29   29    1   byt
	pack = [pack,byte(val_scale,0,4)]	; 1   30   33    4   flt
	pack = [pack,flag_azi]			; 1   34   34    1   byt
	pack = [pack,byte(val_azi,0,4)]		; 1   35   38    4   flt
	pack = [pack,flag_lim]			; 1   39   39    1   byt
	pack = [pack,byte(nlim,0,4)]		; 1   40   43    4   lon
	pack = [pack,byte(val_lim,0,32)]	; 8   44   75   32   flt
	pack = [pack,flag_par]			; 1   76   76    1   byt
	pack = [pack,byte(val_par,0,8)]		; 2   77   84    8   flt
	pack = [pack,flag_sat]			; 1   85   85    1   byt
	pack = [pack,byte(val_sat,0,12)]	; 3   86   97   12   flt
	pack = [pack,flag_ell]			; 1   98   98    1   byt
	pack = [pack,byte(val_ell,0,12)]	; 3   99  110   12   flt
	pack = [pack,byte(pos,0,16)]		; 4  111  126   16   flt
	pack = [pack,byte(proj,0,4)]		; 1  127  130    4   lon
	pack = [pack,flag_clip]			; 1  131  131    1   byt
	pack = [pack,byte(pxcm,0,8)]		; 2  132  139    8   flt
	pack = [pack,bytarr(20)]		; Pad a bit extra for 160 bytes.
 
	end
