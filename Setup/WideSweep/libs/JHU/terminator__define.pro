	;===========================================================
	;	terminator__define.pro = Sun terminator object.
	;	Compute and plot sun and terminator in map.
	;	R. Sterner, 2001 May 02
	;===========================================================
 
	;===========================================================
	;	DRAW
	;===========================================================
 
	pro terminator::draw, time, color=clr, linestyle=styl, thickness=thk, $
	  charsize=csz, offset=off, xmode=xmode, nosun=nosun, alt=alt, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Plot terminator and subsun position.'
	  print,' obj->draw, time'
	  print,' time = Time in GMT, JS or date/time string.'
	  print,'   Could use dt_tm_tojs(systime())+gmt_offsec()'
	  print,' Keywords:'
	  print,'   COLOR=clr, LINESTYLE=sty, THICKNESS=thk,'
	  print,'   CHARSIZE=csz Character size.'
	  print,'   NOSUN=ns  No sun flag.'
	  print,'   OFFSET=off, /XMODE for XOR.'
	  print,'   ALT=km  Satellite altitude in km instead of OFFSET.'
	  print,'     Will compute offset for terminator at satellite altitude.'
	  return
	endif
 
	if datatype(time) ne 'DOU' then js=dt_tm_tojs(time) else js=time
 
	;-------  Compute new positions  ----------------
	if n_elements(off) ne 0 then self.offset=off
	if n_elements(alt) ne 0 then $
	  self.offset=90.+!radeg*acos(6378./(6378.+alt))
	sunpos, js, sublng=lng, sublat=lat		; Sun position.
	rb2ll,lng,lat,self.offset,/deg,self.azi,lng2,lat2
 
	;----------------------------------------
	;  XOR mode
	;----------------------------------------
	if keyword_set(xmode) then begin
	  device,set_graphics=6		; XOR mode.
	  ;------  Plot last curves if any (to erase)  ----------------
	  if self.flag eq 1 then begin
	    plots,self.lng,self.lat,color=self.clr,thick=self.thk, $
	      linestyle=self.styl
	    if self.nosun eq 0 then begin
	      plots,self.lngss,self.latss,color=self.clr,psym=4
	      textplot,self.lngss,self.latss,color=self.clr,'SUN', $
	        charsize=self.csz, align=[.5,2]
	    endif
	    empty	; Force all graphics to be output (or xor fails).
	  endif
	  ;------  Update plot parameters  ---------------------
	  if n_elements(clr) ne 0 then self.clr=clr
	  if n_elements(styl) ne 0 then self.styl=styl
	  if n_elements(thk) ne 0 then self.thk=thk
	  if n_elements(csz) ne 0 then self.csz=csz
	  if n_elements(nosun) ne 0 then self.nosun=nosun
	  ;------  Plot new curves  ----------------------------
	  plots,lng2,lat2,color=self.clr,thick=self.thk,linestyle=self.styl
	  if self.nosun eq 0 then begin
	    plots,lng,lat,color=self.clr,psym=4
	    textplot,lng,lat,color=self.clr,'SUN', $
	       charsize=self.csz, align=[.5,2]
	  endif
	  device,set_graphics=3		; Copy mode.
	endif else begin
 
	;----------------------------------------
	;  Normal plot mode
	;----------------------------------------
	  if n_elements(clr) ne 0 then self.clr=clr
	  if n_elements(styl) ne 0 then self.styl=styl
	  if n_elements(thk) ne 0 then self.thk=thk
	  if n_elements(csz) ne 0 then self.csz=csz
	  if n_elements(nosun) ne 0 then self.nosun=nosun
	  plots,lng2,lat2,color=self.clr,thick=self.thk,linestyle=self.styl
	  if self.nosun eq 0 then begin
	    plots,lng,lat,color=self.clr,psym=4
	    textplot,lng,lat,color=self.clr,'SUN', $
	      charsize=self.csz, align=[.5,2]
	  endif
	endelse
 
	self.lngss = lng
	self.latss = lat
	self.lng = lng2
	self.lat = lat2
	self.flag = 1
 
	end
 
 
	;===========================================================
	;	SET
	;===========================================================
 
	pro terminator::set, color=clr, linestyle=styl, thickness=thk, $
	  charsize=csz, offset=off, flag=flag, nosun=nosun, $
	  alt=alt, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' All args are keywords:'
	  print,' FLAG=flag Plot flag, set to 0 for a new plot if needed.'
	  print,' NOSUN=ns  Sun no plot flag: 0=plot sun, 1=do not plot sun.'
	  print,' COLOR=clr Plot color (def=yellow).'
	  print,' LINESTYLE=styl Plot line style (def=0).'
	  print,' THICKNESS=thk Plot thickness (def=1).'
	  print,' CHARSIZE=csz Character size (def=1).'
	  print,' OFFSET=off Offset in degrees from subsun pt (def=90).'
	  print,' ALT=km  Satellite altitude in km instead of OFFSET.'
	  print,'    Will compute offset for terminator at satellite altitude.'
	  return
	endif
 
	if n_elements(flag) ne 0 then self.flag=flag
	if n_elements(nosun) ne 0 then self.nosun=nosun
 
	if n_elements(clr) ne 0 then self.clr=clr
	if n_elements(styl) ne 0 then self.styl=styl
	if n_elements(thk) ne 0 then self.thk=thk
	if n_elements(csz) ne 0 then self.csz=csz
	if n_elements(off) ne 0 then self.offset=off
	if n_elements(alt) ne 0 then $
	  self.offset=90.+!radeg*acos(6378./(6378.+alt))
 
	end
 
 
	;===========================================================
	;	LIST
	;===========================================================
 
	pro terminator::list
 
	print,' terminator status:'
 
	if self.flag eq 0 then print,' No plots made yet.' $
	  else print,' Have plotted.'
 
	if self.nosun eq 0 then print,' Will plot sun position.' $
	  else print,' Will not plot sun position.'
 
	print,' Plot color: '+strtrim(self.clr,2)
        print,' Plot style: '+strtrim(self.styl,2)
	print,' Plot thickness: '+strtrim(self.thk,2)
	print,' Character size: '+strtrim(self.csz,2)
	print,' Plot offset from subsun (deg): '+strtrim(self.offset,2)
 
	end
 
 
	;===========================================================
	;	INIT
	;===========================================================
 
	function terminator::init, alt=alt
 
	self.flag = 0
	self.nosun = 0
	self.clr = tarclr(255,255,0)
	self.styl = 0
	self.thk = 1
	self.csz = 1.
	if n_elements(alt) ne 0 then $
	  self.offset=90.+!radeg*acos(6378./(6378.+alt)) else self.offset=90.
	self.azi = maken(0.,360.,100)
	return, 1
	end
 
 
	;===========================================================
	;	terminator object structure
	;===========================================================
 
	pro terminator__define
 
	tmp = { terminator,	  $
		js: 0D0,	  $ Time in JS.
		latss: 0.,	  $ Sub-Sun latitude.
		lngss: 0.,	  $ Sub-Sun longitude.
		lat: fltarr(100), $ Terminator coordinates.
		lng: fltarr(100), $
		azi: fltarr(100), $ Azimuth array (internal use).
		clr: 0L,	  $ Plot color(s).
		styl: 0,	  $ Line style(s).
		thk: 0,	 	  $ Line thickness(es).
		csz: 1.,	  $ Character size.
		offset: 0.,	  $ Offsets from 90 deg.
		flag: 0,	  $ Plot flag.
		nosun: 0,	  $ No sun flag.
		dum: 0 }
 
	end
