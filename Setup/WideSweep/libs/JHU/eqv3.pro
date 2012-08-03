;-------------------------------------------------------------
;+
; NAME:
;       EQV3
; PURPOSE:
;       Execute IDL code using interactively varied parameters.
; CATEGORY:
; CALLING SEQUENCE:
;       eqv3, file
; INPUTS:
;       file = equation file.   in
;         Instead of file name the contents of the file may be
;         given in a text array (same format).
; KEYWORD PARAMETERS:
;       Keywords:
;         P1=var1, P2=var2, ... P5=var5  Up to 5 variables.
;           may be passed into the program using these keywords.
;           May reference p1, p2, ... in the IDL code to execute.
;         /WAIT means wait until the routine is exited instead
;            returning right after startup.
;         PARVALS=pv Structure with parameter names and values.
;            Must be used with /WAIT or pv will be undefined.
;         EXITCODE=excd 0=normal, 1=cancel.  Must use with /WAIT.
;         RES=res  Returned widget ID of an unused top level
;            base that will on exit from EQV3 contain a structure
;            with parameter names and final values.
;              widget_control,res,get_uval=s,/dest
;              s.name and s.val are arrays of names and values.
;         TOP=top    Returns widget ID of top level base.
;           Use widget_control to retrieve or store info structure.
;         OK=wid  ID of widget to notify when OK button pressed.
;           If not given no OK button is displayed.
;           Useful to allow a higher level widget routine to call
;           EQV3.  The OK button then sends an event to the higher
;           level widget which can then destroy the eqv3 widget.
;         WID_OK=wid  Returned widget ID of the OK button.
;           Can use to set /input_focus.
;         GROUP_LEADER=grp  Set group leader.
;         XOFFSET=xoff, YOFFSET=yoff Widget position.
;         XSCROLL=xpixels.  Parameter X scrolling size (def=800 pix).
;         YSCROLL=ypixels.  Parameter Y scrolling size (def=400 pix).
;       
; OUTPUTS:
; COMMON BLOCKS:
;       eqv3_var_com
;       eqv3_var_com
;       eqv3_help_com
;       eqv3_var_com
;       eqv3_help_com
; NOTES:
;       Notes: This routine will not work in an IDL Virtual Machine.
;       Use the Help button for more details.
;       Equation file format: This text file defines the IDL code,
;       and range of each adjustable parameter.
;       Null and comment lines (* in first column) are allowed.
;       The tags are shown by an example:
;          title: Parabola
;          eq: x=maken(-10,10,100) & plot,a + b*x + c*x^2
;          par:  a -50 50 0
;          par:  b -50 50 0
;          par:  c -10 10 1
;       
;       The parameter tags are followed by 4 items:  Parameter name (as in the
;       equation), min value, max value, initial value.  An optional 5th item
;       may be the word int to force an integer value (for flags or harmonics).
; MODIFICATION HISTORY:
;       R. Sterner, 2000 May 11 --- From EQV2.
;       R. Sterner, 2000 Aug 21 --- Added XOFFSET, YOFFSET.
;       R. Sterner, 2001 Jun 19 --- Upgraded snapshot.
;       R. Sterner, 2001 Jun 20 --- Added optional parameter units.
;       R. Sterner, 2002 Oct 25 --- Switched to cw_dslider for drag on Windows.
;       R. Sterner, 2005 Apr 04 --- Added X/YSCROLL keywords.
;       R. Sterner, 2005 May 13 --- Better handling of YSCROLL.
;       May differ on Windows.
;       R. Sterner, 2006 Mar 07 --- Ignored leading spaces in eqv file.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-------------------------------------------------------------
;	Index of routines
;
;       eqv3_print = Print plot and list settings.
;       eqv3_plot = Execute equation text.
;       eqv3_sp2v = Function to convert slider position to value.
;       eqv3_sv2p = Function to convert slider value to position.
;       eqv3_show_win = Show plot window.  For external use.
;       eqv3_get_val = Retrieve parameter values.  For external use.
;       eqv3_set_val = Set parameter values.  For external use.
;       eqv3_compile = Equation file parser
;       eqv3_quit = Execute any exit code
;       eqv3_grabpar = Grab parameters and values
;	eqv3_event = Event handler
;	eqv3 = Main Equation viewer version II routine	
;
;-------------------------------------------------------------
 
;===============================================================
;       eqv3_print = Print plot and list settings.
;===============================================================
 
	pro eqv3_print, pnum, d
 
	  wset, d.dsave.window				; Select plot window.
	  !x = d.xsave
	  !y = d.ysave
	  !p = d.psave
 
	  xmess,' Printing current display . . .',/nowait,wid=wid
	  ;-------  Print image  ------------
	  a = tvrd()				; Grab screen image.
	  tvlct,r,g,b,/get			; Grab current color table.
	  psinit, pnum, /auto, cflag=flag	; Set to specified printer.
	  ;-------  Deal with BW  -----------
	  if flag eq 0 then begin		; Color flag not set so BW.
	    print,' Converting image to Black and White . . .' 
	    lum = ROUND(.3 * r + .59 * g + .11 * b) < 255  ; Image brightness.
	    a = lum(a)                                     ; To B&W.
	    if total(a lt 128)/total(a ge 128) gt 5. then begin
	      bell
	      if xyesno('Reverse brightness for printout?') eq 'Y' then $
	        a = 255-a
	    endif
	  endif                                              
	  tvlct,r,g,b				; Load color table.
	  psimg, a				; Display image.
	  ;-------  List equation and settings  ---------
	  widget_control, d.equat, get_val=equat	; Get equation.
	  equat = strtrim(equat(0),2)
	  n = n_elements(d.pname)			; List parameters.
	  txt = strarr(n)
	  for i=0,n-1 do txt(i)=strtrim(d.pname(i),2)+' = '+ $
	    strtrim(d.pval(i),2)
	  txtarr = ['Current parameter values for',equat,' ',txt]
	  xprint,/init,!x.window(0),-.1,dy=1.5,/norm,chars=1.2	; Set xprint.
	  for i=0,n_elements(txtarr)-1 do xprint,txtarr(i)	; Print.
	  psterm				; Plot all done.
	  widget_control, wid,/ dest		; Kill message widget.
          return
	end
 
;===============================================================
;       eqv3_plot = Execute equation text.
;===============================================================
 
        pro eqv3_plot, _d
 
	common eqv3_var_com, p1, p2, p3, p4, p5
 
	wset, _d.dsave.window			; Set to plot window.
	!x = _d.xsave
	!y = _d.ysave
	!p = _d.psave
 
        ;-------  Read equation  -------------
        widget_control, _d.equat, get_val=_equat
        _equat = _equat(0)
 
        ;-----  Set parameters to their values ------
        for _i = 0, n_elements(_d.pname)-1 do begin
          _t = _d.pname(_i)+'='+string(_d.pval(_i))
          _err = execute(_t)
        endfor
 
        ;-----  Set flags to their values ------
	if _d.flagnam(0) ne '' then begin
          for _i = 0, n_elements(_d.flagnam)-1 do begin
            _t = _d.flagnam(_i)+'='+string(_d.flagset(_i))
            _err = execute(_t)
          endfor
	endif
 
        ;------  Execute code  --------------------
        _err = execute(_equat)
        if _err ne 1 then begin
          xhelp,exit='OK',['Error executing:',_equat,!err_string,$
            ' ','Do the following to recover:',$
            '1. Correct any errors in the executable text',$
            '   the name of the independent variable.',$
            '2. Do retall.','3. Do xmanager.','4. Press the OK button below.']
          return
        endif
 
        return
        end
 
 
;===============================================================
;       eqv3_sp2v = Convert slider position to value.
;===============================================================
 
        function eqv3_sp2v, p, smax, pmin, pmax, int=int
	if keyword_set(int) then begin
          return, fix((p/float(smax))*(pmax-pmin) + pmin)
	endif else begin
          return, (p/float(smax))*(pmax-pmin) + pmin
	endelse
        end
 
;===============================================================
;       eqv3_sv2p = Convert slider value to position.
;===============================================================
 
        function eqv3_sv2p, v, smax, pmin, pmax
        p = fix(.5+float(smax)*(v-pmin)/(pmax-pmin))
        return, p>0<smax
        end
 
;===============================================================
;       eqv3_show_win = Show plot window.  For external use.
;===============================================================
 
        pro eqv3_show_win, top
 
	widget_control, top, get_uval=info
	wset, info.dsave.window
	wshow
 
        end
 
;===============================================================
;       eqv3_get_val = Retrieve parameter values.  For external use.
;===============================================================
 
        pro eqv3_get_val, top, val, unlock=unlock
 
	widget_control, top, get_uval=info
	val = info.pval
	;-----  Unlock specified values  ---------
	if n_elements(unlock) ge 0 then begin
	  for i=0, n_elements(unlock)-1 do begin
	    widget_control, info.id_pbase(unlock(i)), sensitive=1
	    widget_control, info.id_slid(unlock(i)), sensitive=1
	  endfor
	endif
 
        end
 
;===============================================================
;       eqv3_set_val = Set parameter values.  For external use.
;===============================================================
 
        pro eqv3_set_val, top, val, lock=lock
 
	widget_control, top, get_uval=info
	info.pval = val
	;-----  Update widget values and slider positions  -------
	for i=0, n_elements(val)-1 do begin
	  widget_control, info.id_pval(i),set_val=strtrim(val(i),2)
	  widget_control, info.id_slid(i),set_val=eqv3_sv2p(val(i), $
	    info.smax,info.pmin(i),info.pmax(i))
	endfor
	;-----  Update plot  -----------
	eqv3_plot,info
	;-----  Lock specified values  ---------
	if n_elements(lock) ge 0 then begin
	  for i=0, n_elements(lock)-1 do begin
	    widget_control, info.id_pbase(lock(i)), sensitive=0
	    widget_control, info.id_slid(lock(i)), sensitive=0
	  endfor
	endif
	;-----  Save new info  ---------
	widget_control, top, set_uval=info
 
        end
 
;==============================================================
;       eqv3_compile = Equation file parser
;==============================================================
 
        pro eqv3_compile, file, title=title, flags=flags, $
          par=par, equation=equat, text=txt0, error=err, $
	  init_txt=init_txt, exit_txt=exit_txt
 
	common eqv3_var_com, p1, p2, p3, p4, p5
 
	err = 0
 
	;-------  Check for code text instead of file name  --------
	if n_elements(file) gt 1 then begin
	  txt = file
	  goto, skip
	endif
 
        ;-------  Add default extension  -------
        filebreak, file, dir=dir, name=name, ext=ext
        if ext eq '' then ext='eqv'
        f = dir+name+'.'+ext
 
        ;-------  Read in equation file  ----------
        txt = getfile(f)
        if (size(txt))(0) eq 0 then begin
          xmess,['Equation file not opened:',f]
          err = 1
          return
        endif
skip:   txt0 = txt			   ; Save file text.
	tmp = txtgetkey(init=txt,del=':')  ; Only txtgetkey init in routine.
	;-------  Find and execute any init commands (and return)  -------
	init_txt = ['']				; Want to save any init text.
	init_flag = 0				; Set flag to no init text yet.
	repeat begin				; Look for init text.
	  init = txtgetkey('init', del=':',start=1-init_flag)
	  if init ne '' then begin		; Found an init line.
	    init_txt = [init_txt,init]		; Add it to array.
	    init_flag = 1			; Set flag to found some.
	  endif
	endrep until init eq ''			; Get all init lines.
	if init_flag ne 0 then begin		; Any init text found?
	  init_txt = init_txt(1:*)		; Yes, drop seed value.
	  print,' Init commands:'
	  for i=0,n_elements(init_txt)-1 do begin  ; Loop through init lines.
	    init = init_txt(i)			; Extract.
	    print,init				; List.
	    tmp=execute(init)			; Execute.
	  endfor
	endif
	;-------  Find and return any exit commands  -------
	exit_txt = ['']				; Want to save any exit text.
	exit_flag = 0				; Set flag to no exit text yet.
	repeat begin				; Look for exit text.
	  etxt = txtgetkey('exit', del=':',start=1-exit_flag)
	  if etxt ne '' then begin		; Found an exit line.
	    exit_txt = [exit_txt,etxt]		; Add it to array.
	    exit_flag = 1			; Set flag to found some.
	  endif
	endrep until etxt eq ''			; Get all exit lines.
	if exit_flag ne 0 then begin		; Any exit text found?
	  exit_txt = exit_txt(1:*)		; Drop seed value.
	endif
	;-------  Get equation title  ----------
	title = txtgetkey('title', del=':',/start)
	if title eq '' then title=' '
 
        ;---------  Get equation  ---------------
        w = where(strupcase(strmid(strtrim(txt,2),0,3)) eq 'EQ:', cnt)
        if cnt eq 0 then begin
          xmess,['Error in equation file:',file,' No equation found.']
          err = 1
          return
        endif
        equat = ''
        i = w(0)
        tmp = txt(i)                    ; First line of equation.
        p = strpos(tmp,':')             ; Skip over eq:.
        tmp = strmid(tmp,p+1,999)
loop:   p = strpos(tmp,'$')             ; $? = continued?
        if p gt 0 then begin            ; Yes:
          tmp = ' '+strtrim(strmid(tmp,0,p),2) ;   1. Drop $.
          equat = equat + tmp                ;   2. Concat line.
          i = i + 1                          ;   3. Read next.
          tmp = txt(i)
          goto, loop                         ;   4. Process.
        endif else begin                     ; No.
          equat = equat + ' '+strtrim(tmp,2) ; Last line, concat.
        endelse
 
        ;--------  Get adjustable parameters  ----------
        w = where(strupcase(strmid(strtrim(txt,2),0,4)) $
	  eq 'PAR:', cnt)   		; Any par lines?
        if cnt eq 0 then begin          ; No.
          par = {n:0}                   ; Set par count to 0 and return.
          err = 0
          goto, flags
        endif
        txt = txt(w)                    ; Extract parameter lines.
        pname = strarr(cnt)
        pmin = fltarr(cnt)
        pmax = fltarr(cnt)
        pdef = fltarr(cnt)
        pflag = bytarr(cnt)
        punits = strarr(cnt)
        for i = 0, cnt-1 do begin
          tmp = getwrd(txt(i),delim=':',/last)  ; i'th parameter line.
          tmp = repchr(tmp,',')         ; Drop any commas.
          pname(i)= getwrd(tmp,0)       ; Get name.
          pmin(i) = getwrd(tmp,1) + 0.  ; Get parameter range min.
          pmax(i) = getwrd(tmp,2) + 0.  ; Get parameter range max.
          pdef(i) = getwrd(tmp,3) + 0.  ; Get parameter range def.
          pflag(i) = strlowcase(getwrd(tmp,4)) eq 'int'  ; Get parameter type.
	  punits(i) = getwrd(tmp,1,del='=')	; Get any units.
        endfor
        par = {n:cnt, name:pname, min:pmin, max:pmax, def:pdef, $
	  flag:pflag, units:punits}
 
        ;--------  Get flags  ----------
	; Allow entry like (no spaces around =):
	; flags: rev=0 red=1 green=0 blue (blue defaults to 0).
flags:	w = where(strupcase(strmid(strtrim(txt0,2),0,4)) $
	  eq 'FLAG',cnt) ; Any flag lines?
	if cnt eq 0 then begin          ; No.
	  flags = {n:0}                 ; Set flags count to 0 and return.
	  err = 0
	  return
	endif
	txt = txt0(w(0))		; Extract flags line (1 only).
	txt = getwrd(txt,1,99)		; Drop keyword flags:.
	wordarray,txt,fnames		; Put all flags in a text array.
	n = n_elements(fnames)		; Number of flags.
	nam = strarr(n)			; Space for flag names.
	set = intarr(n)			; Space for flag settings.
	for i=0,n-1 do begin		; Loop through all flags.
	  nam(i) = getwrd(fnames(i),0,del='=')		; Grab name.
	  set(i) = getwrd(fnames(i),1,del='=')+0	; Grab initial setting.
	endfor
	flags = {n:n, name:nam, set:set}  ; Pack up.
 
        err = 0
 
        return
        end
 
 
;==============================================================
;	eqv3_quit = Execute any exit code
;==============================================================
 
	pro eqv3_quit, d
 
	;-------  Execute any exit commands  -------
	print,' Exit commands:'
	repeat begin
	  etxt = txtgetkey('exit', del=':')
	  print,etxt
	  if etxt ne '' then tmp=execute(etxt)
	endrep until etxt eq ''
 
	end
 
 
;==============================================================
;	eqv3_grabpar = Grab parameters and values
;==============================================================
 
	pro eqv3_grabpar, d, out
	  out = {pname:d.pname,   pval:d.pval,    $
	         fname:d.flagnam, fval:d.flagset}
	end
 
 
;==============================================================
;	eqv3_event = Event handler
;==============================================================
 
	pro eqv3_event, ev
 
	common eqv3_help_com, h_1,h_2,h_3,h_4,h_5,h_6,h_7,h_8,h_9,h_10
 
	widget_control, ev.id, get_uval=name0	; Get name of action.
        widget_control, ev.top, get_uval=d      ; Get data structure.
        name = strmid(name0,0,3)                ; First 3 chars.
        if nwrds(name0) gt 1 then begin
          name2 = getwrd(name0,1,99)
        endif
 
	wset, d.dsave.window			; Select plot window.
	!x = d.xsave
	!y = d.ysave
	!p = d.psave
 
	if name eq 'SNA' then begin
	  ans = xyesno('Save current equation and settings to a file?', $
	    def='Y')
	  if ans eq 'Y' then begin
	    xtxtin,file,def='temp',/wait, $
	      title='Name of file to save equation in:'
	    if file ne '' then begin
	      filebreak, file, dir=dir, name=name, ext=ext
	      if ext eq '' then ext='eqv'
	      f = filename(dir,name+'.'+ext,/nosym)
	      openw,lun,f,/get_lun
	      printf,lun,'* EQV3 Snapshot'
	      printf,lun,'*'+created()
	      printf,lun,' '
	      printf,lun,'title: '+d.title
	      if d.init_txt(0) ne '' then begin
	        for i=0,n_elements(d.init_txt)-1 do begin
	          printf,lun,'init: '+d.init_txt(i)
	        endfor
	      endif
	      widget_control, d.equat, get_val=equat
	      printf,lun,'eq:  '+equat(0)
	      for i=0,n_elements(d.id_pval)-1 do begin
	        widget_control, d.id_pnam(i), get_val=nam
	        widget_control, d.id_pmin(i), get_val=pmn
	        widget_control, d.id_pmax(i), get_val=pmx
	        widget_control, d.id_pval(i), get_val=pvl
	        printf,lun,'par:  '+nam(0)+'  '+pmn(0)+'  '+pmx(0)+'  '+pvl(0)
	      endfor
	      if d.exit_txt(0) ne '' then begin
	        for i=0,n_elements(d.exit_txt)-1 do begin
	          printf,lun,'exit: '+d.exit_txt(i)
	        endfor
	      endif
	      free_lun, lun
	      xmess,'Equation saved in file '+f
	    endif  ; Gave a non-null file name.
	  endif  ; Yes, save equation in file.
	  return
	endif  ; SNAP
 
	if name eq 'OK' then begin
	  print,' Sending OK button event to ',d.ok
	  ok_event = {OK, id:ev.id, top:ev.top, handler:0L}
	  widget_control, d.ok, send_event=ok_event
          return
        endif
 
	if name eq 'WIN' then begin
	  wshow
          return
        endif
 
	if name eq 'ERA' then begin
	  tv,d.img
	  !x = d.xsave
	  !y = d.ysave
	  !p = d.psave
	  d.flag = 0
          eqv3_plot, d
          widget_control, ev.top, set_uval=d      ; Update parameter values.
          return
        endif
 
	if name eq 'PRI' then begin
          setwin, err=err
          if err ne 0 then return
          eqv3_print, name2, d
          return
	end
 
	if name eq 'PRO' then begin
          if !d.window lt 0 then return
          err = execute(name2)
          return
	end
 
        if name eq 'CAN' then begin
	  widget_control, d.equat, get_val=equat
	  equat = equat(0)
	  eqv3_grabpar, d, outpar		; Grab slider names/values.
	  widget_control, d.res, set_uval=outpar
	  widget_control, d.exbase, set_uval=1
	  eqv3_quit, d				; Execute any exit code.
          widget_control, /dest, ev.top
          return
        endif
 
        if name eq 'QUI' then begin
	  widget_control, d.equat, get_val=equat
	  equat = equat(0)
	  eqv3_grabpar, d, outpar		; Grab slider names/values.
	  widget_control, d.res, set_uval=outpar
	  widget_control, d.exbase, set_uval=0
	  eqv3_quit, d				; Execute any exit code.
          widget_control, /dest, ev.top
          return
        endif
 
        if name eq 'LIS' then begin
	  widget_control, d.equat, get_val=equat
	  equat = equat(0)
	  n = n_elements(d.pname)
	  txt = strarr(n)
	  for i=0,n-1 do txt(i)=strtrim(d.pname(i),2)+' = '+strtrim(d.pval(i),2)
	  xhelp,['Current parameter values for',equat,' ',txt], $
	    exit_text='Continue'
          return
        endif
 
        ;-------  Handle plot related items  ---------------
        if name eq 'PLT' then begin
          eqv3_plot, d
	  goto, update_str
        endif
 
        ;-------  Handle parameter related items  ----------
        if name eq 'PAR' then begin
          act = strmid(name0,3,3)       ; Parameter action code.
          i = strmid(name0,6,2) + 0     ; Parameter index.
 
          ;-------  Process action code  --------
          case act of
'SLD':    begin         ;*** Moved slider. ***
            widget_control, d.id_slid(i), get_val=p             ; New pos.
          end
'MIN':    begin         ;*** Entered new range min. ***
            widget_control, d.id_pmin(i), get_val=t             ; Get ran min.
            d.pmin(i) = t+0.                                    ; Store.
            p = eqv3_sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))   ; New pos.
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
          end
'MAX':    begin         ;*** Entered new range max. ***
            widget_control, d.id_pmax(i), get_val=t             ; Get ran min.
            d.pmax(i) = t+0.                                    ; Store.
            p = eqv3_sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))   ; New pos.
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
          end
'STN':    begin         ;*** Set current value as new range min. ***
            d.pmin(i) = d.pval(i)       ; Update and display new range min.
            widget_control, d.id_pmin(i), set_val=strtrim(d.pmin(i),2)
            p = 0
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
          end
'STX':    begin         ;*** Set current value as new range max. ***
            d.pmax(i) = d.pval(i)       ; Update and display new range max.
            widget_control, d.id_pmax(i), set_val=strtrim(d.pmax(i),2)
            p = d.smax
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
          end
'DEF':    begin         ;*** Set current value back to default  ***
            widget_control,d.id_pval(i),set_val=strtrim(d.pdef(i),2) ; Val 2 Def
            p = eqv3_sv2p(d.pdef(i), d.smax, d.pmin(i), d.pmax(i))
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
          end
'VAL':    begin
            widget_control, d.id_pval(i), get_val=t             ; Get ran min.
            d.pval(i) = t+0.                                    ; Store.
            p = eqv3_sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))   ; New pos.
            widget_control, d.id_slid(i), set_val=p             ; Update slider.
            widget_control, ev.top, set_uval=d    ; Update parameter values.
            eqv3_plot, d                           ; Update plot.
	    goto, update_str
          end
'NAM':    begin
            widget_control, d.id_pnam(i), get_val=t             ; Get par name.
            d.pname(i) = t                                      ; Replace old.
            widget_control, ev.top, set_uval=d    ; Update parameter values.
            eqv3_plot, d                           ; Update plot.
	    goto, update_str
          end
          endcase
          ;-------  Always: compute new val, display it, store it.
          v = eqv3_sp2v(p,d.smax,d.pmin(i),d.pmax(i),int=d.pflag(i)) ; New val.
          widget_control,d.id_pval(i),set_val=strtrim(v,2)      ; Display.
          d.pval(i) = v                                         ; Store.
          widget_control, ev.top, set_uval=d      ; Update parameter values.
          eqv3_plot, d                             ; Update plot.
	  goto, update_str
        endif
 
	;-------  Help  ------------
	if name eq 'HLP' then begin
	  case name2 of
'1':	    xhelp,h_1
'2':	    xhelp,h_2
'3':	    xhelp,h_3
'4':	    xhelp,h_4
'5':	    xhelp,h_5
'6':	    xhelp,h_6
'7':	    xhelp,h_7
'8':	    xhelp,h_8
'9':	    xhelp,h_9
	  endcase
          return
        endif
 
	;-------  Flags  ------------
	; UVAL is something like flag_2.  name is 1st 3 letters.
	if name eq 'FLA' then begin
	  i = getwrd(name0,1,del='_')+0		; Grab flag number.
	  set = ev.select			; New setting freom ev str.
	  d.flagset(i) = set			; Update flag setting.
 
          if d.flagset(i) eq 1 then txt='=yes' else txt='=no'
          widget_control,d.id_flags(i),set_value=d.flagnam(i)+txt
 
 
	  widget_control, ev.top, set_uval=d    ; Update parameter values.
          eqv3_plot, d				; Update plot.
	  return
	endif
 
 
	print,' Unkown command: ',name0
	return
 
update_str:
	d.flag = 1				; Always on at this point.
        widget_control, ev.top, set_uval=d      ; Save data structure.
	return
 
	end
 
 
;==============================================================
;	eqv3 = Main Equation viewer version II routine	
;
;	Executes given IDL code using parameter values.
;==============================================================
 
	pro eqv3, file, top=top, ok=ok, res=res, help=hlp, wait=wait, $
	  group_leader=grp, wid_ok=wid_ok, smax=smax0, parvals=parvals, $
	  exitcode=excode, xoffset=xoff, yoffset=yoff, yscroll=yscroll, $
	  xscroll=xscroll, p1=p10, p2=p20, p3=p30, p4=p40, p5=p50
 
	common eqv3_var_com, p1, p2, p3, p4, p5
	common eqv3_help_com, h_1,h_2,h_3,h_4,h_5,h_6,h_7,h_8,h_9,h_10
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
help:	  print,' Execute IDL code using interactively varied parameters.'
	  print,' eqv3, file'
	  print,'   file = equation file.   in'
	  print,'     Instead of file name the contents of the file may be'
	  print,'     given in a text array (same format).'
	  print,' Keywords:'
	  print,'   P1=var1, P2=var2, ... P5=var5  Up to 5 variables.'
	  print,'     may be passed into the program using these keywords.'
	  print,'     May reference p1, p2, ... in the IDL code to execute.'
	  print,'   /WAIT means wait until the routine is exited instead'
	  print,'      returning right after startup.'
	  print,'   PARVALS=pv Structure with parameter names and values.'
	  print,'      Must be used with /WAIT or pv will be undefined.'
	  print,'   EXITCODE=excd 0=normal, 1=cancel.  Must use with /WAIT.'
	  print,'   RES=res  Returned widget ID of an unused top level'
	  print,'      base that will on exit from EQV3 contain a structure'
	  print,'      with parameter names and final values.'
	  print,'        widget_control,res,get_uval=s,/dest'
	  print,'        s.name and s.val are arrays of names and values.'
	  print,'   TOP=top    Returns widget ID of top level base.'
	  print,'     Use widget_control to retrieve or store info structure.'
	  print,'   OK=wid  ID of widget to notify when OK button pressed.'
	  print,'     If not given no OK button is displayed.'
	  print,'     Useful to allow a higher level widget routine to call'
	  print,'     EQV3.  The OK button then sends an event to the higher'
	  print,'     level widget which can then destroy the eqv3 widget.'
	  print,'   WID_OK=wid  Returned widget ID of the OK button.'
	  print,'     Can use to set /input_focus.'
	  print,'   GROUP_LEADER=grp  Set group leader.'
	  print,'   XOFFSET=xoff, YOFFSET=yoff Widget position.'
	  print,'   XSCROLL=xpixels.  Parameter X scrolling size (def=800 pix).'
	  print,'   YSCROLL=ypixels.  Parameter Y scrolling size (def=400 pix).'
	  print,' '
	  print,' Notes: This routine will not work in an IDL Virtual Machine.'
	  print,' Use the Help button for more details.'
	  print,' Equation file format: This text file defines the IDL code,'
	  print,' and range of each adjustable parameter.'
	  print,' Null and comment lines (* in first column) are allowed.'
	  print,' The tags are shown by an example:'
	  print,'    title: Parabola'
	  print,'    eq: x=maken(-10,10,100) & plot,a + b*x + c*x^2'
	  print,'    par:  a -50 50 0'
	  print,'    par:  b -50 50 0'
	  print,'    par:  c -10 10 1'
	  print,' '
	  print,' The parameter tags are followed by 4 items:  Parameter name (as in the'
	  print,' equation), min value, max value, initial value.  An optional 5th item'
	  print,' may be the word int to force an integer value (for flags or harmonics).'
	  return
	endif
 
	;------  Init var common  ----------------
	;--  Allows variables to be passed in  ------
	if n_elements(p10) ne 0 then p1=p10
	if n_elements(p20) ne 0 then p2=p20
	if n_elements(p30) ne 0 then p3=p30
	if n_elements(p40) ne 0 then p4=p40
	if n_elements(p50) ne 0 then p5=p50
 
	;------  Initialize help text  ----------------
	if n_elements(h_1) eq 0 then begin
	  print,' Initializing help text . . .'
	  eqv3_load_help, h_1, h_2, h_3, h_4, h_5, h_6, h_7, h_8, h_9
	endif
 
	;----  Deal with equation file  ----
	eqv3_compile, file, equation=equat, title=title, $ 
          par=par, flags=flags, text=txt0, error=err, $
	  init_txt=init_txt, exit_txt=exit_txt
	if err ne 0 then return
 
	;--------  Set up widget  ------------
	if n_elements(smax0) eq 0 then smax0=800
	smax = smax0
	
	top = widget_base(/col, title=title, group_leader=grp, $
	  xoff=xoff,yoff=yoff)
 
	;--------  Equation window  -------
	id_eq = widget_text(top,val=equat,xsize=60,ysize=1,/edit,uval='PLT')
 
	;--------  Sliders  ---------------
	id_pbase  = lonarr(par.n)   ; Base with all but slider itself.
        id_slid   = lonarr(par.n)   ; Parameter slider related wids.
        id_parnam = strarr(par.n)
        id_parval = lonarr(par.n)
        id_parmin = lonarr(par.n)
        id_parmax = lonarr(par.n)
	units_len = max(strlen(par.units))
	name_len = max(strlen(par.name))
	if n_elements(xscroll) eq 0 then xscroll=smax+23
	if n_elements(yscroll) eq 0 then begin
	  yscroll = 42 + 57*((par.n<4)-1)	; Linux.  May differ for Windows.
	endif
	parbase = widget_base(top,/col,x_scroll=xscroll,y_scroll=yscroll) ; Parameter base.
        for i = 0, par.n-1 do begin         	; Loop through parameters.
          b2 = widget_base(parbase,/row)	; Parameter row base.
	  id_pbase(i) = b2			; Remember slider base.
          id = widget_text(b2,val=par.name(i),xsize=name_len+3, /edit, $
            uval='PARNAM'+strtrim(i,2))
          id_parnam(i) = id
	  if units_len gt 0 then begin
	    id = widget_text(b2,val=par.units(i),xsize=units_len)
	  endif
	  tmp = par.def(i)
	  if par.flag(i) eq 1 then tmp=fix(tmp)
          id = widget_text(b2,val=strtrim(tmp,2),xsize=15,/edit,$
            uval='PARVAL'+strtrim(i,2))
          id_parval(i) = id
          id = widget_label(b2,val='Range: ')
	  tmp = par.min(i)
	  if par.flag(i) eq 1 then tmp=fix(tmp)
          id = widget_text(b2,val=strtrim(tmp,2),/edit,$
            uval='PARMIN'+strtrim(i,2),xsize=15)
          id_parmin(i) = id
          id = widget_label(b2,val=' to ')
	  tmp = par.max(i)
	  if par.flag(i) eq 1 then tmp=fix(tmp)
          id = widget_text(b2,val=strtrim(tmp,2),/edit,$
            uval='PARMAX'+strtrim(i,2),xsize=15)
          id_parmax(i) = id
          id = widget_button(b2,val='Min',uval='PARSTN'+strtrim(i,2))
          id = widget_button(b2,val='Max',uval='PARSTX'+strtrim(i,2))
          id = widget_button(b2,val='Def',uval='PARDEF'+strtrim(i,2))
;          s = cw_dslider(top,uval='PARSLD'+strtrim(i,2),size=smax+1,max=smax)
          s = cw_dslider(parbase,uval='PARSLD'+strtrim(i,2),size=smax+1,max=smax)
          id_slid(i) = s
        endfor
 
	;--------  Flags  ---------------
	flgnam = ''
	flgset = 0
	id_flags = 0
	if flags.n gt 0 then begin
	  id_flags = lonarr(flags.n)
          flgnam = flags.name
	  flgset = flags.set
	  b = widget_base(top,/row,/nonexclusive,/frame)  ; Flags base.
	  for i=0,flags.n-1 do begin
	    uv = 'FLAG_'+strtrim(i,2)
	    if flgset(i) eq 1 then txt='=yes' else txt='=no'
	    id = widget_button(b,value=flgnam(i)+txt,uval=uv)
	    id_flags(i) = id
	    if flgset(i) eq 1 then widget_control,id,/set_button
	  endfor
	endif
 
        ;-------  Display widget and update plot  -------
        for i=0, par.n-1 do begin	; Set parameter slider starting points.
          widget_control, id_slid(i),set_val=$
            eqv3_sv2p(par.def(i),smax,par.min(i),par.max(i))
        endfor
 
	;-------  Function buttons  ----------------
	b = widget_base(top,/row)
	;-------  OK button  -----------------
	if n_elements(ok) ne 0 then begin
	  wid_ok = widget_button(b, value='OK', uval='OK')
	endif else ok=0
	;-------  FILE button  ---------------
	bb = widget_button(b, value='File',menu=2)
	  id = widget_button(bb, value='Quit', uval='QUIT')
	  id = widget_button(bb, value='Cancel', uval='CANCEL')
	  id = widget_button(bb, value='List', uval='LIST')
	  id = widget_button(bb, value='Snap', uval='SNAP')
	;-------  DISPLAY button  -------------
	bb = widget_button(b, value='Display',menu=2)
	  id = widget_button(bb, value='Bring window to front', uval='WIN')
	  if !x.type le 1 then $	; If not a map plot.
	    id = widget_button(bb, value='Refresh the window', uval='ERASE')
	;-------  PRINT button  ---------------
        ;------  Check for user defined buttons  --------
        ;  If xview.txt exists in home directory read it.  It
        ;  defines custom buttons using the following format:
        ;  print: button_label / printer_number
        ;  process: button_label / procedure_name
        ;  . . .
        ;  You can have any number of print: and process: lines.
        ;  Null lines and lines with * as first char are ignored.
        ;  Ex:
        ;  print: Phaser 340 paper / 5
        ;  print: Phaser 340 trans / 6
        ;  process: Negative / imgneg
        ;-----------------------------------------------------
        a = getfile(filename(getenv('HOME'),'xview.txt',/nosym), err=err,/q)
	cpri = 0			; Assume no user defined buttons.
	cpro = 0
        if err eq 0 then begin		; Found button definition file.
          a = drop_comments(a)		; Drop comments.
          one = strupcase(strmid(a,0,3))	; Grab first word.
          wpri = where(one eq 'PRI',cpri)       ; Print buttons.
          wpro = where(one eq 'PRO',cpro)       ; Process buttons.
        endif
        if cpri gt 0 then begin
          pdp = widget_button(b, value='  PRINT ', menu=2)
          for i=0,cpri-1 do begin
            t = a(wpri(i))
            v = getwrd(getwrd(t,del='/'),1,del=':')     ; Label.
            n = getwrd(t,/last,del='/')                 ; Printer #.
            id = widget_button(pdp,value=v,uval='PRI '+n)
          endfor
        endif
        if cpro gt 0 then begin
          for i=0,cpro-1 do begin
            t = a(wpro(i))
            v = getwrd(getwrd(t,del='/'),1,del=':')     ; Label.
            n = getwrd(t,/last,del='/')                 ; Command.
            id = widget_button(bb,value=v,uval='PRO '+n); Add proc to display.
          endfor
        endif
	;---------  HELP button  ---------------------
	bb = widget_button(b, value='Help',menu=2)
	  id = widget_button(bb, value='Overview', uval='HLP 1')
	  id = widget_button(bb, value='Plot window', uval='HLP 2')
	  id = widget_button(bb, value='Code display and entry area', uval='HLP 3')
	  id = widget_button(bb, value='Adjustable parameters', uval='HLP 4')
	  id = widget_button(bb, value='Command buttons', uval='HLP 5')
	  id = widget_button(bb, value='Equation file format', uval='HLP 6')
	  id = widget_button(bb, value='Adding functions and printers', $
	     uval='HLP 7')
 
	;----  Grab screen for plot refresh  ----------
	if !d.window ne -1 then img=tvrd() else img=0
 
	;------  Set up unused widget bases for returned values  -----
	res = widget_base()		; Final parameters.
	exbase = widget_base()		; Exit code.
 
	;----  Set up info structure  -------
	info = {top:top,pflag:[par.flag],pname:[par.name], $
	  pdef:[par.def], pval:[par.def], pmin:[par.min], pmax:[par.max], $
	  equat:id_eq, smax:smax, $
	  flagnam:flgnam, flagset:flgset, id_flags:id_flags, $
	  id_pbase:[id_pbase], $
	  id_slid:[id_slid], id_pval:[id_parval], id_pmin:[id_parmin], $
	  id_pmax:[id_parmax], id_pnam:[id_parnam], $
	  flag:0, img:img, txt:txt0, ok:ok, res:res, exbase:exbase, $
	  xsave:!x, ysave:!y, dsave:!d, psave:!p, $
	  title:title, init_txt:init_txt, exit_txt:exit_txt }
	widget_control, top, set_uval=info
 
	;----  Do first plot here  --------
        eqv3_plot, info
	widget_control, top, set_uval=info
 
        ;-------  xmanager  -------
	if keyword_set(wait) then no_block=0 else no_block=1
        widget_control, top, /real
        xmanager, 'eqv3', top, no_block=no_block
 
	;-------  Return parameter values  ---------
	if keyword_set(wait) then begin
	  widget_control, res, get_uval=parvals, /dest
	  widget_control, exbase, get_uval=excode, /dest
	endif
 
	return
	end
