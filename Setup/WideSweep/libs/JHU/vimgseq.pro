;-------------------------------------------------------------
;+
; NAME:
;       VIMGSEQ
; PURPOSE:
;       Display a sequence of byte images.
; CATEGORY:
; CALLING SEQUENCE:
;       imgseq
; INPUTS:
;       Prompts for all inputs.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         XSIZE=sx  Size of display window to use.
;         YSIZE=sy  The default is full screen.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Images should be scaled byte images
;         saved using the save2 procedure.  A file
;         with one image name per line should be setup.
;         This file is the sequence file.  After imgseq
;         has read in the file names the images may be
;         sequenced through by using to move RETURN forward,
;         and SPACE to move backwards.  Random access is
;         also allowed.  Experiment with the other options.
; MODIFICATION HISTORY:
;       R. Sterner 3 Jan, 1990
;       R. Sterner, 7 Jun, 1990 --- converted to vms.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro vimgseq, xsize=sxsize, ysize=sysize, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Display a sequence of byte images.'
	  print,' imgseq'
	  print,'   Prompts for all inputs.         in'
	  print,' Keywords:'
	  print,'   XSIZE=sx  Size of display window to use.'
	  print,'   YSIZE=sy  The default is full screen.'
	  print,' Notes: Images should be scaled byte images'
	  print,'   saved using the save2 procedure.  A file'
	  print,'   with one image name per line should be setup.'
	  print,'   This file is the sequence file.  After imgseq'
	  print,'   has read in the file names the images may be'
	  print,'   sequenced through by using to move RETURN forward,'
	  print,'   and SPACE to move backwards.  Random access is'
	  print,'   also allowed.  Experiment with the other options.'
	  return
	endif
 
	;-----  setup defaults  --------
	last = topc()				; Last color value.
	fwd = string(13b)			; Display forward (RETURN)
	bwd = string(32b)			; Display backward (SPACE)
	if n_elements(sxsize) eq 0 then sxsize = 1020	; Full screen size.
	if n_elements(sysize) eq 0 then sysize = 840	; for DEC WS 3100.
	oflag = 1				; Turn outline off.
;	ocolor = last-2				; Outline color.
	ocolor = last				; Outline color.
	iflag = 0				; No sequence file loaded.
	r = indgen(256)				; Current color table.
	g = r
	b = r
	wshow,0,0				; Hide window 0.
	flag1 = 0				; Window 1 does not exist.
	lxsize = 0				; Last window size.
	lysize = 0
	mflag = 0				; Mouse flag. 0=keys, 1=mouse.
	dflag = 0				; No image was displayed.
 
loop:	wdelete, 1				; Hide window.
	flag1 = 0				; Window hidden.
	dflag = 0
	print,' '
	print,' Image sequence display commands:'
	print,' s - enter sequence file.              '+$
	  'q - quit.'
	print,' RETURN - display next image.          '+$
	  'SPACE - display last image.'
	print,' = - redisplay current image.          '+$
	  'n - enter image number to display. '
	print,' g - display an alignment grid.        '+$
	  'o - toggle window outline on/off.'
	print,' l - list images.                      '+$
	  '# - change window outline color.'
	print,' c - load color table.                 '+$
	  '? - list these commands.'
	print,' f - list sequence file format.        '+$
	  '@ - debug stop.'
	print,' m - use mouse buttons to display forward and backward.'
	print,' '
loop2:	k = get_kbrd(1) 
loop3:	k = strlowcase(k)
 
	;--------  load sequence file  ---------
	if k eq 's' then begin
	  wdelete,1
	  flag1 = 0
	  print,' '
	  print,' Load a sequence file'
	  ff = ''
	  read, ' Sequence file name: ',ff
	  if ff eq '' then goto, loop2
	  get_lun, lun
	  openr, lun, ff
	  list = ['']
	  name = ''
	  while not eof(lun) do begin
	    readf, lun, name
	    name = repchr(name,'	')	; Replace tabs.
	    name = repchr(name,',')		; Replace commas.
	    list = [list, name]
	  endwhile
	  close, lun
	  free_lun, lun
	  list = list(1:*)
	  inum = -1
	  lstnum = n_elements(list)-1
	  iflag = 1
	  print,' Sequence file loaded.'
	  print,' There are '+strtrim(lstnum+1,2)+' images'
	  goto, loop2
	endif  
 
	;-----  quit  ---------
	if k eq 'q' then begin
	  wdelete, 1
	  return
	endif
 
	;-----  display forward  ----------
	if k eq fwd then begin
frwd:	  if iflag eq 0 then begin
	    print,' Must first load a sequence file.  Use s command.'
	    goto, loop
	  endif
	  if inum ge lstnum then bell	; Image # out of range.
	  di = 1
	  goto, dsply
	endif
 
	;-----  display backward  ----------
	if k eq bwd then begin
bkwd:	  if iflag eq 0 then begin
	    print,' Must first load a sequence file.  Use s command.'
	    goto, loop
	  endif
	  if inum le 0 then bell	; Image # out of range.
	  di = -1
	  goto, dsply
	endif
 
	;-----  display number  ----------
	if k eq 'n' then begin
	  if iflag eq 0 then begin
	    print,' Must first load a sequence file.  Use s command.'
	    goto, loop
	  endif
	  wdelete,1
	  flag1 = 0
	  tmp = ''
	  read,' Image number to display: ',tmp
	  if tmp eq '' then begin
	    print,' No display.'
	    goto, loop
	  endif
	  inum = tmp + 0
	  inum = inum>0<lstnum
	  di = 0
	  goto, dsply
	endif
 
	;-------  Redisplay current image. ---------
	if k eq '=' then begin
	  if iflag eq 0 then begin
	    print,' Must first load a sequence file.  Use s command.'
	    goto, loop
	  endif
	  goto, dsply2
	endif
 
	;--------  list images  --------------
	if k eq 'l' then begin
	  if iflag eq 0 then begin
	    print,' Must first load a sequence file.  Use s command.'
	    goto, loop
	  endif
	  wdelete,1
	  flag1 = 0
	  for i = 0, lstnum do print,i,'  ',list(i)
	  goto, loop2
	endif
 
	;-------  list commands  ---------
	if k eq '?' then goto, loop
 
	;-------  toggle outline flag  ---------
	if k eq 'o' then begin
	  oflag = 1 - oflag
	  goto, dsply2
	endif
 
	;-------  Set outline color  -------
	if k eq '#' then begin
	  wdelete, 1
	  flag1 = 0
	  tmp = ''
;	  read,' Enter outline color (def = ',last-2,'): ',tmp
;	  if tmp eq '' then tmp = last-2
	  read,' Enter outline color (def = ',last,'): ',tmp
	  if tmp eq '' then tmp = last
	  ocolor = tmp + 0
	  goto, loop2
	endif
 
	;--------  display alignment grid  ----------
	if k eq 'g' then begin
	  rtt = indgen(256)  & gtt = rtt  & btt = rtt
	  tvlct,rtt,gtt,btt
	  wxsize = 513				; Make a 513 x 513 grid.
	  wysize = 513
	  xposg = 1+.5*(sxsize - wxsize)	; Center grid.
	  yposg = 1+.5*(sysize - wysize)
	  if flag1 eq 0 then window, 1, xsize=sxsize, ysize=sysize ; window.
	  erase
	  for ix = 0, 512, 64 do plots,xposg+[ix,ix],yposg+[0,512],$
	    /dev,color=ocolor	; Plot grid.
	  for iy = 0, 512, 64 do plots,xposg+[0,512],yposg+[iy,iy],$
	    /dev,color=ocolor
	  plots,xposg+[192,320],yposg+[320,192],/dev,color=ocolor
	  plots,xposg+[192,320],yposg+[192,320],/dev,color=ocolor
	  wait, 0
	  k = get_kbrd(1) 
	  tvlct, r, g, b
	  if dflag eq 0 then begin
	    wdelete,1
	    flag1 = 0
	    goto, loop3
	  endif else begin
	    erase
;	    tv, img<(last-2), xpos, ypos
	    tv, img, xpos, ypos
	    goto, loop2
	  endelse
	endif
 
	;-------  load color table  ------------
	if k eq 'c' then begin
	  wdelete,1
	  flag1 = 0
	  tmp = ''
cloop:	  read,' Color table name to load: ',tmp
	  if tmp eq '' then begin
	    print,' No color table.'
	    goto, loop2
	  endif
	  restore2, tmp, r, g, b, error=err
	  if err ne 0 then goto, cloop
	  print,' Loading color table ' + tmp
	  tvlct, r, g, b
	  goto, loop2
	endif
 
	;-----  file format ----------
	if k eq 'f' then begin
	  wdelete, 1
	  flag1 = 0
	  print,' '
	  print,' Sequence file format:'
	  print,'   Each sequence file line lists one image file name'
	  print,'   optionally followed by a color table file name.'
	  print,'   Any text following the color table name is considered'
	  print,'   a comment and displayed above the image (so the color'
	  print,'   table file must be given to display a comment.'
	  print,' Ex:'
	  print,'   img1.img  ct1.ct  This image shows the optional comments.'
	  print,'   img2.img'
	  print,'   img3.img  ct3.ct'
	  print,' where the images and color tables were saved using SAVE2'
	  print," (save2,'img1.img',a  & save2,'ct1'ct',r,g,b)."
	  print,' Images saved must be scaled, byte images.'
	  print,' '
	  goto, loop2
	endif
 
	;-----  debug stop  ----------
	if k eq '@' then begin
	  wdelete,1
	  flag1 = 0
	  stop,' Debug stop.  Do .con to continue.'
	  goto, loop
	endif
 
	;-------  Enter mouse mode  ---------
	if k eq 'm' then goto, mouse0
 
	goto, loop2
 
mouse0:	print,' Use mouse buttons to load images.'
	print,' Button_1 = load next image.'
	print,' Button_2 = load previous image.'
	print,' Button_3 = exit mouse mode.'
	tmp = ''
	read,' Press return to enter mouse mode, '+$
	  'then press mouse button to load image.', tmp
	mflag = 1
mouse:	if flag1 ne 1 then begin	; window 1 not displayed, display it.
	  window, 1, xsize=sxsize, ysize=sysize
	  flag1 = 1
	endif
	wset, 1			; Read mouse in window 1 = image window.
	cursor,/dev, xx, yy
	wait,.2
        if !err eq 1 then cmd='BUTTON_1'
        if !err eq 2 then cmd='BUTTON_2'
        if !err eq 4 then cmd='BUTTON_3'
        !err = 0
	if cmd eq 'BUTTON_1' then goto, frwd
	if cmd eq 'BUTTON_2' then goto, bkwd
	if cmd eq 'BUTTON_3' then begin
	  mflag = 0
	  goto,  loop
	endif
	stop,' Error in mouse mode. Check cmd.' 
	
 
dsply:	inum = (inum + di)>0<lstnum
	name = getwrd(list(inum), 0)
	print,' Loading image '+strtrim(inum,2)+' from file '+name
	restore2,name,img, error=err
	if err ne 0 then begin
	  print,' Image not available: '+name
	  print,' Ignored.'
	  goto, loop
	endif
	ct = getwrd(list(inum), 1)
	if ct ne '' then begin
	  restore2, ct, r, g, b, error=err
	  if err ne 0 then begin
	    print,' Color table not available: '+ct
	    print,' Ignored.'
	  endif 
	endif
	print,' loading color table from '+ct
	tvlct, r, g, b
	cmt = getwrd(list(inum),2,99)		; Extract comment.
 
dsply2:	sz = size(img)				; Make window fit the image.
	wxsize = sz(1)
	wysize = sz(2)
	xpos = .5*(sxsize - wxsize)		; Center window.
	ypos = .5*(sysize - wysize)
	;-- Make window if it doesn't exit, or there is a size change. ---
	if flag1 eq 0 then begin
	  window, 1, xsize=sxsize, ysize=sysize		; display window.
	endif ;else begin
	lxsize = wxsize
	lysize = wysize
	flag1 = 1					; Window now displayed.
	wset, 1						; Use window 1.
	erase
;	tv, img<(last-2), xpos, ypos
	tv, img, xpos, ypos
	dflag = 1					; Image is displayed.
	wait, 0			; Wrong image sometimes displayed without this!
	if oflag eq 1 then plots,xpos+[0,wxsize-1,wxsize-1,0,0],$
	  ypos+[0,0,wysize-1,wysize-1,0],/dev,color=ocolor
	wait, 0
	if cmt ne '' then begin
	  xyouts, /dev, xpos+wxsize/2., ypos+wysize+10, cmt, align=.5, $
	    size = 1.5
	endif
	if mflag eq 1 then goto, mouse
	k = get_kbrd(1) 
	goto, loop3
 
	end
