;=======================================================
;       izoomo object
;	izoom object version.
;       R. Sterner, 1998 Jan 23, Feb 5
;=======================================================

;=======================================================
;       Widget interface to Control settings method
;=======================================================

        ;------------------------------------------------
        ;       Event Handlers
        ;------------------------------------------------

        pro izoomo_event, ev

	widget_control, ev.top, get_uval=info   ; Get needed info.
        widget_control, ev.id, get_uval=uval    ; Get event command.

	if uval eq 'QUIT' then begin
          widget_control, ev.top, /destroy      ; Destroy widget.
	  ptr_free, info.pobj
          return
        endif

        if uval eq 'FULL' then begin      ; Set to full image.
	  wshow
	  *info.pobj->get, x=x, y=y
	  xran = [min(x),max(x)]
	  yran = [min(y),max(y)]
	  *info.pobj->set, xrange=xran, yrange=yran, /draw
          return
        endif

        if uval eq 'ZOOM' then begin      ; Set to full image.
	  xmess,/nowait,wid=wid,['Zoom box:',$
              ' ',$
              'Use left mouse button except to exit box.',$
              ' ',$
              'To get a box --- drag it open.',$
              'To move box --- drag inside box.',$
              'To move side or corner --- drag it.',$
              'To exit box --- click other button.']
	  wshow
	  box2b, ix1, ix2, iy1, iy2, exit=ex
	  widget_control, wid, /dest
	  if ex eq 1 then return
	  r = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_data)
	  r = transpose(r)
	  *info.pobj->get, off=off
	  xran = r(*,0)+off
	  yran = r(*,1)
	  *info.pobj->set, xrange=xran, yrange=yran, /draw
          return
        endif

        if uval eq 'REFRESH' then begin      ; Refresh image.
	  wshow
	  *info.pobj->draw
          return
        endif

        if uval eq 'CURSOR' then begin       ; Cursor.
	  wshow
	  *info.pobj->get,js_flag=js_flag
	  crossi, js=js_flag
          return
        endif

        if uval eq 'MAGCURSOR' then begin       ; Cursor.
	  wshow
	  *info.pobj->get,js_flag=js_flag, mag=mag
	  crossi, js=js_flag, mag=mag
          return
        endif

	return
	end

        ;------------------------------------------------
        ;       izoomo_xset = Widget set up.
        ;------------------------------------------------

        pro izoomo_xset, obj

        top = widget_base(/column, title=' ')
        id = widget_label(top,value='IZOOMO control panel')
        ;------  Buttons Row 1  -----------
        b = widget_base(top,/row)
          id = widget_button(b, value='Quit',uval='QUIT')
          id = widget_button(b, value='Full Image',uval='FULL')
          id = widget_button(b, value='Zoom',uval='ZOOM')
        ;------  Buttons Row 2  -----------
        b = widget_base(top,/row)
          id = widget_button(b, value='Refresh',uval='REFRESH')
          id = widget_button(b, value='Cursor',uval='CURSOR')
          id = widget_button(b, value=' Mag Cursor',uval='MAGCURSOR')

	info = {pobj: ptr_new(obj)}
        widget_control, top, set_uval=info

        widget_control, top, /real

        xmanager, 'izoomo_xset', top, /no_block, $
          event='izoomo_event'

        end

        ;------------------------------------------------
        ;       XSET method
        ;------------------------------------------------

        pro izoomo::xset

        izoomo_xset, self

        end


;=======================================================
;       LIST method
;	  List settings of flags and values.
;=======================================================

        pro izoomo::list

	xmn = min(*self.x, max=xmx)
	ymn = min(*self.y, max=ymx)
	zmn = min(*self.z, max=zmx)
	print,' '
	title=self.title & if title eq '' then title='Image'
	xtitle=self.xtitle & if xtitle eq '' then xtitle='X Axis'
	ytitle=self.ytitle & if ytitle eq '' then ytitle='Y Axis'

	print,title+': '+strtrim(zmn+0,2)+' to '+strtrim(zmx+0,2)

	if self.js_flag ne 1 then begin
	  print,xtitle+': '+strtrim(xmn,2)+' to '+strtrim(xmx,2)
	  print,'  X Display range: '+strtrim(self.xran(0),2)+' to '+ $
	    strtrim(self.xran(1),2)
	endif else begin
	  print,xtitle+': '+dt_tm_fromjs(xmn+0d0)+' to '+dt_tm_fromjs(xmx+0d0)
	  print,'  X Display range: '+dt_tm_fromjs(self.xran(0)+0d0)+' to '+ $
	    dt_tm_fromjs(self.xran(1)+0d0)
	  print,'  JS Offset: ',self.js_off
	endelse

	print,ytitle+': '+strtrim(ymn,2)+' to '+strtrim(ymx,2)
	print,'  Y Display range: '+strtrim(self.yran(0),2)+' to '+ $
	  strtrim(self.yran(1),2)

	print,' '
	print,' Plot position: ['+commalist(self.pos)+']'
	print,' Bold flag: ',self.bold
	print,' Interp flag: ',self.interp
	print,' Cursor mag factor: ',self.mag

	end


;=======================================================
;       HELP method
;	  Help text.
;=======================================================

        pro izoomo::help

        print,' '
        print,' Object: IZOOMO izoom object.'
        print,' Purpose: Dispay a 2-d data set with labeled axes.'
        print,' Methods:'
        print," INIT:  a = obj_new('izoomo',x,y,z)"
        print,'   z is 2-d data array scaled for display.'
	print,'   x,y are the axes arrays.'
        print,' DRAW: a->draw'
        print,'   Displays the labeled image on current display device.'
        print,' GET: a->get, offset=off'
	print,'   return JS offset value.'
        print,' SET: a->set, /draw, xtitle=xtitle, ytitle=ytitle, $
	print,'   title=title, xrange=xran, yrange=yran, charsize=csz, $
	print,'   position=pos, xnew=x, ynew=y, znew=z, bold=bold, $
	print,'   interp=interp, bar=bar, vmin=vmn, vmax=vmx, $
	print,'   cmin=cmn, cmax=cmx, btitle=btitle, js=js, mag=mag
	print,'     /DRAW redraw after setting any new values.' 
	print,'     xtitle, ytitle, title = x title, y title, main title.'
	print,'     xrange, yrange = set x and y range.'
	print,'     charsize = text size in points.'
	print,'     xnew, ynew, znew = set new x, y, and image.'
	print,'     /INTERP do bilinear interpolation.'
	print,'     BOLD=bld  set bold text and axes.'
	print,'     /BAR show color bar.'
	print,'     vmn, vmx, cmn, cmx = color bar min, max values and'
	print,'       corresponding gray scale.'
	print,'     btitle  color bar title.'
	print,'     /JS  x array is time in JS.'
	print,'     mag is cursor mag factor.'
        print,' LIST: a->list'
        print,'   List values and settings.'
	return

	end

;=======================================================
;       GET control parameters method
;=======================================================

        pro izoomo::get, js_flag=js_flag, offset=off, xaxis=x, yaxis=y, $
	  mag=mag

        off = self.js_off
        js_flag = self.js_flag
        mag = self.mag
	x = *self.x
	y = *self.y

        end


;=======================================================
;       SET method
;	  Set values (data or settings).
;=======================================================

        pro izoomo::set, draw=draw, xtitle=xtitle, ytitle=ytitle, $
	  title=title, xrange=xran, yrange=yran, charsize=csz, $
	  position=pos, xnew=x, ynew=y, znew=z, bold=bold, $
	  interp=interp, bar=bar, vmin=vmn, vmax=vmx, cmin=cmn, cmax=cmx, $
	  btitle=btitle, js=js, mag=mag

	;------  Color bar settings  ----------------
	if n_elements(bar) ne 0 then self.bar = keyword_set(bar)
	if n_elements(vmn) ne 0 then self.vmn=vmn
	if n_elements(vmx) ne 0 then self.vmx=vmx
	if n_elements(cmn) ne 0 then self.cmn=cmn
	if n_elements(cmx) ne 0 then self.cmx=cmx
	if n_elements(btitle) ne 0 then self.btitle=btitle

	;------  Set simple plot parameters  --------
	if n_elements(xtitle) ne 0 then self.xtitle=xtitle
	if n_elements(ytitle) ne 0 then self.ytitle=ytitle
	if n_elements(title) ne 0 then self.title=title

	if n_elements(mag) ne 0 then self.mag=mag
	if n_elements(csz) ne 0 then self.csz=csz>0.<50.
	if n_elements(bold) ne 0 then self.bold=bold>1<2
	if n_elements(pos) ne 0 then self.pos=pos
	if n_elements(interp) ne 0 then self.interp=keyword_set(interp)
	if n_elements(js) ne 0 then self.js_flag=keyword_set(js)

	if n_elements(pos) ne 0 then begin
	  self.pos=pos			  ; Set new positoin.
	  ;-----  Now set bar based on plot position  ---------
	  px1=pos(0) & py1=pos(1) & px2=pos(2) & py2=pos(3)
	  ymd = (py2+py1)/2.
	  dy2 = (py2-py1)/2.
	  by1 = ymd-.5*dy2
	  by2 = ymd+.5*dy2
	  bw = 20.                        ; Bar width in points.
          dx = (points(20,/norm))(0)      ; Convert to norm.
          bx1 = px2 + dx                  ; Offset bar 1 width to right.
          bx2 = bx1 + dx
          self.bpos = [bx1,by1,bx2,by2]      ; Bar position.
	endif

	;------  New image and axes  ---------
	nx = n_elements(x)	; X defined?
	ny = n_elements(y)	; Y defined?
	nz = n_elements(z)	; Z defined?
	;------  New X but not Z  -----------
	if (nx ne 0) and (nz eq 0) then begin
	  sz=size(*self.z) & nzx=sz(1) & nzy=sz(2)
	  if nx ne nzx then begin
            ok = dialog_message(['Error in izoomo object in:',$
              'New x axis array must match size of existing image.',$
              'X axis not changed.'])
	  endif else begin
	    ptr_free,self.x
	    self.x = ptr_new(x)
	    self.xran = [min(x),max(x)]
	  endelse
	endif
	;------  New Y but not Z  -----------
	if (ny ne 0) and (nz eq 0) then begin
	  sz=size(*self.z) & nzx=sz(1) & nzy=sz(2)
	  if ny ne nzy then begin
            ok = dialog_message(['Error in izoomo object in:',$
              'New y axis array must match size of existing image.',$
              'Y axis not changed.'])
	  endif else begin
	    ptr_free,self.y
	    self.y = ptr_new(y)
	    self.yran = [min(y),max(y)]
	  endelse
	endif
	;-------  New X, Y, and Z  --------------
	if (nx ne 0) and (ny ne 0) and (nz ne 0) then begin
	  sz=size(z) & nzx=sz(1) & nzy=sz(2)	; Image size.
	  flag = 1				; Assume ok.
	  if nx ne nzx then begin		; Check X size.
            ok = dialog_message(['Error in izoomo object in:',$
              'New x axis array must match size of new image.',$
              'image and axes not updated.'])
	    flag = 0				; Size error.
	  endif
	  if ny ne nzy then begin		; Check X size.
            ok = dialog_message(['Error in izoomo object in:',$
              'New y axis array must match size of new image.',$
              'image and axes not updated.'])
	    flag = 0				; Size error.
	  endif
	  if flag eq 1 then begin
	    ptr_free, self.x, self.y, self.z
	    self.x = ptr_new(x)
	    self.xran = [min(x),max(x)]
	    self.y = ptr_new(y)
	    self.yran = [min(y),max(y)]
	    self.z = ptr_new(z)
	  endif
	endif
	;-------  New Z only  --------------
	if (nx eq 0) and (ny eq 0) and (nz ne 0) then begin
	  ptr_free, self.z			; Drop old image.
	  self.z = ptr_new(z)                   ; Save new image.
	  sz=size(z) & nzx=sz(1) & nzy=sz(2)    ; New image size.
	  nx = n_elements(*self.x)		; Old x size.
	  ny = n_elements(*self.y)		; Old y size.
	  if nx ne nzx then begin		; Old x wrong size, make new.
	    x = findgen(nzx)			;   New x.
	    ptr_free, self.x			;   Drop old x.
	    self.x = ptr_new(x)			;   Save new x.
	    self.xran = [min(x),max(x)]		;   New range.
	  endif
	  if ny ne nzy then begin		; Old y wrong size, make new.
	    y = findgen(nzy)			;   New y.
	    ptr_free, self.y			;   Drop old y.
	    self.y = ptr_new(y)			;   Save new y.
	    self.yran = [min(y),max(y)]		;   New range.
	  endif
	endif

	;-------  Set any ranges after setting new axes  -------
	;-------  A range of [0,0] autoscales to full range  ----
	if n_elements(xran) ne 0 then begin
	  xran2 = xran
	  if (xran(0) eq 0) and (xran(1) eq 0) then begin
	    xran2=[min(*self.x),max(*self.x)]
	  endif
	  self.xran=xran2
	endif
	if n_elements(yran) ne 0 then begin
	  yran2 = yran
	  if (yran(0) eq 0) and (yran(1) eq 0) then begin
	    yran2=[min(*self.y),max(*self.y)]
	  endif
	  self.yran=yran2
	endif

	;------  Plot current plot  ----------
        if keyword_set(draw) then self->draw

        end



;=======================================================
;       DRAW method
;=======================================================

        pro izoomo::draw

	white = tarclr(255,255,255)	; Closest color to white.
	black = tarclr(0,0,0)		; Closest color to black.

	erase, white

	;----  Find tick lengths  ---------
	t = points(0.333*self.csz,/pixels)
	ticklen, -t(0), -t(1), xtk, ytk, pos=self.pos

	;----  Find text size  -------------
	csz = points(self.csz)

	;----  Bold flag  --------
	b = self.bold

	;----  Make plot  ---------
	izoom, /noerase, *self.x, *self.y, *self.z, xtitle=self.xtitle, $
	  ytitle=self.ytitle, title='!A'+self.title, xran=self.xran, $
	  yran=self.yran,pos=self.pos, col=black, xticklen=xtk, yticklen=ytk, $
	  chars=csz, charthick=b,xthick=b,ythick=b, interp=self.interp, $
	  js=self.js_flag, off=off
	self.js_off = off

	;----  Color bar  ----------
	if self.bar then begin
	  cbar, vmin=self.vmn, vmax=self.vmx, cmin=self.cmn, cmax=self.cmx, $
	    /vert, pos=self.bpos, col=black, yticklen=-.2,yminor=1, $
	    charsize=points(0.75*self.csz), title=self.btitle, $
	    charthick=b,xthick=b,ythick=b
	endif

	end


;=======================================================
;       INIT Initialize function.  Gets invoked only by IDL.
;       Must return a 0 (failed) or 1 (ok)
;       REQUIRED function for any IDL object.
;=======================================================

        function izoomo::init, x, y, z, _extra=extra, help=hlp

        catch, error
        if error ne 0 then begin
          ok = dialog_message(!err_string)
          return, 0
        endif

	if keyword_set(hlp) then begin
          print,' Object class: izoomo'
	  print,' Purpose: Display an image with axes.'
	  print," INIT:  a = obj_new('izoomo',x,y,z)"
	  print,'   x,y,z are the axes and image arrays.'
	  print,'   See object help for details (a->help).'
	  return,0
	endif

	;-------  No parameters given  --------------
	if n_params() eq 0 then begin
	  ok = dialog_message(['Error in izoomo object init:',$
	    'Must give image as argument.',$
	    'May also give x and y arrays (both):', $
	    "  a=obj_new('izoomo',x,y,z) or a=obj_new('izoomo',z)", $
	    'Object not initialized'])
	  return, 0
	endif

	;-------  1 parameter given  -------------------
	if n_params() eq 1 then begin
	  sz = size(x)
	  if sz(0) ne 2 then begin
	    ok = dialog_message(['Error in izoomo object init:',$
	      'Must give a 2-d image.',$
	      'Object not initialized'])
	    return, 0
	  endif
	  nx=sz(1) & ny=sz(2)
	  z = temporary(x)	; Rename from x to z.
	  x = findgen(nx)	; Supply default x and y.
	  y = findgen(ny)
	endif

	;-------  2 parameters given  -------------------
        if n_params() eq 2 then begin
	  ok = dialog_message(['Error in izoomo object init:',$
              'Must give either a 2-d image,',$
              'or the x and y axis arrays and a 2-d image.',$
              'Object not initialized'])
            return, 0
	endif

	;-------  3 parameters given  -------------------
        if n_params() eq 3 then begin
	  sz = size(z)
	  if sz(0) ne 2 then begin
	    ok = dialog_message(['Error in izoomo object init:',$
	      'Must give a 2-d image.',$
	      'Object not initialized'])
	    return, 0
	  endif
	  nx=sz(1) & ny=sz(2)
	  if n_elements(x) ne nx then begin
	    ok = dialog_message(['Error in izoomo object init:',$
	      'X axis values array size must match image size.',$
	      'Object not initialized'])
	    return, 0
	  endif
	  if n_elements(y) ne ny then begin
	    ok = dialog_message(['Error in izoomo object init:',$
	      'Y axis values array size must match image size.',$
	      'Object not initialized'])
	    return, 0
	  endif
	endif

	;-------  Store arrays  ----------
	self.extra = ptr_new(extra)         ; Save plot keywords. (Used?)
	self.x = ptr_new(x)                 ; Save x.
	self.y = ptr_new(y)                 ; Save y.
	self.z = ptr_new(z)                 ; Save image.

	;-------  Set other plot parameters  -------
	self.xran = [min(x),max(x)]
	self.yran = [min(y),max(y)]
	self.xtitle = ''
	self.ytitle = ''
	self.title = ''

	px1 = 0.14
	px2 = 0.85
	py1 = 0.17
	py2 = 0.85
	self.pos = [px1,py1,px2,py2]
	self.csz = 12.                     ; Text size in points.
	self.bold = 1                      ; Bold flag: 1=no, 2=yes.
	self.interp = 1                    ; Interp flag: 0=NN, 1=Bilinear.

	;------  Color bar  ------------
	ymd = (py2+py1)/2.
	dy2 = (py2-py1)/2.
	by1 = ymd-.5*dy2
	by2 = ymd+.5*dy2
	bw = 20.			; Bar width in points.
	dx = (points(20,/norm))(0)	; Convert to norm.
	bx1 = px2 + dx			; Offset bar 1 width to right.
	bx2 = bx1 + dx
	self.bpos = [bx1,by1,bx2,by2]      ; Bar position.
	self.bar = 0                       ; No color bar by defaulti (1=yes).
	self.vmn = 0.                      ; Bar min value.
	self.vmx = 100.                    ; Bar max value.
	self.cmn = min(z)                  ; Bar min gray.
	self.cmx = max(z)                  ; Bar max gray.
	self.btitle = ''                   ; No bar title.

	;-----  Cursor mag factor  -----------
	self.mag = 4                       ; Mag cursor mag factor.

        return, 1	; Init successful.

        end


;=======================================================
;       CLEANUP routine.  Called only by IDL.
;       REQUIRED procedure for any IDL object.
;=======================================================

        pro izoomo::cleanup

        ptr_free, self.x, self.y, self.z, self.extra

        end


;=======================================================
;       Define object structure
;       If the named structure is not defined IDL
;       searches for and calls this routine.
;       Note the two underscores in the name.
;       Cannot set initial values here, everything gets zeroed.'
;=======================================================

        pro izoomo__define

	dummy = {izoomo,                $
                 x: ptr_new(),          $       ; Pointer to x axis values.
                 y: ptr_new(),          $       ; Pointer to y axis values.
                 z: ptr_new(),          $       ; Pointer to image.
                 xtitle: '',            $       ; X axis title.
                 ytitle: '',            $       ; Y axis title.
                 title: '',             $       ; Overall title.
                 xran: fltarr(2),       $       ; X range.
                 yran: fltarr(2),       $       ; Y range.
                 pos: fltarr(4),        $       ; Plot position.
		 csz: 0.,               $       ; Text size in points.
		 bold: 0,               $       ; Bold flag.
		 interp: 0,             $       ; Interp flag.
		 js_flag: 0,            $       ; Set if X is time in JS.
		 js_off: 0d0,           $       ; Internal JS offset.

                 bpos: fltarr(4),       $       ; Bar position.
	         bar: 0,                $       ; Bar flag: 0=no, 1=yes.
	         vmn: 0.,               $       ; Bar min value.
	         vmx: 0.,               $       ; Bar max value.
	         cmn: 0,                $       ; Bar min gray.
	         cmx: 0,                $       ; Bar max gray.
	         btitle: '',            $       ; Bar title.

	         mag: 0,                $       ; Mag cursor mag factor.

                 win: intarr(2),        $       ; Up to 2 plot windows.
                 extra: ptr_new()}
        end
