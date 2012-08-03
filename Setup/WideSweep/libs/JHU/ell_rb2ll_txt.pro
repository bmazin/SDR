;-------------------------------------------------------------
;+
; NAME:
;       ELL_RB2LL_TXT
; PURPOSE:
;       Convert a file with range/bear pairs into lat/long.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_rb2ll_txt, infile, outfile
; INPUTS:
;       infile = Name of input file with range and bearing.  in
;         See note for format.
; KEYWORD PARAMETERS:
;       Keywords:
;         X=x, Y=y, PEN=p  Returned lon, lat, pen code.
;         /QUIET do not list results to screen.
; OUTPUTS:
;       outfile = Name of output file with lat and long.     out
;         If this is a variable then the results are returned
;         as a text array.
; COMMON BLOCKS:
; NOTES:
;       Note: The format of the input file is keyword/value pairs
;       separated by =.  Comments start with * as first char
;       and along with null lines are ignored.
;       A starting point must be given, then ranges and bearings.
;       Each group of points must start with a label.  Exmaple:
;         label = 45 deg radial
;         lat = 38.6565
;         long = -76.5265
;         range = 10.7 nm
;         bearing = 60
;         range = 13.5 nm
;         ...
;       Known units are: m, meters, yds, yards, miles, nmiles,
;       ft, feet.  May abbreviate.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jul 22
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	;-----------------------------------------------------
	;  Format coordinates.
	;-----------------------------------------------------
	function ell_rb2ll_txt_fm, val, dec=dec
 
	if n_elements(dec) eq 0 then dec=2
	deg = fix(val)
	mn = roundn(abs(val-deg)*60.,dec,/str)
	return,strtrim(deg,2)+' '+mn
 
	end
 
 
	;-----------------------------------------------------
	;  Deal with conversion factors
	;-----------------------------------------------------
	pro ell_rb2ll_txt_cf, u, cf
 
	if u eq 'm' then cf=1.D0
	if strmid(u,0,5) eq 'meter' then cf=1.D0
	if strmid(u,0,2) eq 'yd' then cf=0.9144D0
	if strmid(u,0,4) eq 'yard' then cf=0.9144D0
	if u eq 'nm' then cf=1852.D0
	if strmid(u,0,3) eq 'nmi' then cf=1852.D0
	if strmid(u,0,2) eq 'mi' then cf=1609.344D0
	if strmid(u,0,1) eq 'f' then cf=0.3048D0
 
	end
 
 
 
	;-----------------------------------------------------
	;  ell_rb2ll_txt.pro = Convert a file with range/bearing
	;    pairs into lat/long.
	;  R. Sterner, 2005 Jul 22
	;-----------------------------------------------------
 
	pro ell_rb2ll_txt, infile, outfile, xa=xa, ya=ya, pen=pa, $
	  quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a file with range/bear pairs into lat/long.'
	  print,' ell_rb2ll_txt, infile, outfile'
	  print,'   infile = Name of input file with range and bearing.  in'
	  print,'     See note for format.'
	  print,'   outfile = Name of output file with lat and long.     out'
	  print,'     If this is a variable then the results are returned'
	  print,'     as a text array.'
	  print,' Keywords:'
	  print,'   X=x, Y=y, PEN=p  Returned lon, lat, pen code.'
	  print,'   /QUIET do not list results to screen.'
	  print,' Note: The format of the input file is keyword/value pairs'
	  print,' separated by =.  Comments start with * as first char'
	  print,' and along with null lines are ignored.'
	  print,' A starting point must be given, then ranges and bearings.'
	  print,' Each group of points must start with a label.  Exmaple:'
          print,'   label = 45 deg radial'
          print,'   lat = 38.6565'
          print,'   long = -76.5265'
          print,'   range = 10.7 nm'
          print,'   bearing = 60'
          print,'   range = 13.5 nm'
	  print,'   ...'
	  print,' Known units are: m, meters, yds, yards, miles, nmiles,'
	  print,' ft, feet.  May abbreviate.'
 
	  return
	endif
 
	;-----------------------------------------------------
	;  Read file and drop comments
	;-----------------------------------------------------
	tt = getfile(infile, err=err)	; read file.
	if err ne 0 then return		; File not read.
	tt = drop_comments(tt)		; Drop comments/null lines.
	ttl = strlowcase(tt)		; Lower case version.
 
	;-----------------------------------------------------
	;  Initialize
	;-----------------------------------------------------
	x_flag = 0		; No long yet.
	y_flag = 0		; No lat yet.
	r_flag = 0		; No range.
	b_flag = 0		; No bearing.
	l_flag = 0		; No label.
	tprint,/init		; Init internal print.
	xa = [0.]		; Output lon array.
	ya = [0.]		; Output lat array.
	pa = [0]		; Output pen codes.
 
	;-----------------------------------------------------
	;  Loop through input and process
	;-----------------------------------------------------
	for i=0,n_elements(tt)-1 do begin
	  t = ttl(i)				; i'th line.
	  w = getwrd(t,0,del='=')		; Item name.
	  ;-------  Extract item and set flags  -----------
	  if strmid(w,0,3) eq 'lat' then begin	; Starting latitude.
	    y = getwrd('',1,del='=')+0.
	    y_flag = 1
	  endif
	  if strmid(w,0,3) eq 'lon' then begin	; Starting longitude.
	    x = getwrd('',1,del='=')+0.
	    x_flag = 1
	  endif
	  if strmid(w,0,3) eq 'lab' then begin	; Label.
	    txt = tt(i)				; Grab original label text.
	    l_flag = 1				; Set label flag.
	    x_flag = 0				; Clear all other flags.
	    y_flag = 0
	    r_flag = 0
	    b_flag = 0
	  endif
	  if strmid(w,0,1) eq 'r' then begin	; Range.
	    r0 = getwrd('',1,del='=')		; Get range and units.
	    u = getwrd(r0,1)			; Get units.
	    ell_rb2ll_txt_cf, u, cf		; Conversion factor to meters.
	    r = r0*cf				; Convert range to meters.
	    r_flag = 1
	  endif
	  if strmid(w,0,1) eq 'b' then begin	; Bearing.
	    b = getwrd('',1,del='=')+0.
	    b_flag = 1
	  endif
	  ;-------  Process item  ------------------------
	  if l_flag then begin				; Label.
	    l_flag = 0
	    tprint,' '
	    tprint,' '+txt
	  endif
	  if (x_flag eq 1) and (y_flag eq 1) and $	; Starting point.
	     (r_flag eq 0) and (b_flag eq 0) then begin
	    tprint,' Starting point:'
	    tprint,'   Lat = '+strtrim(y,2)+' ('+ell_rb2ll_txt_fm(y)+')'
	    tprint,'   Lon = '+strtrim(x,2)+' ('+ell_rb2ll_txt_fm(x)+')'
	    xa = [xa,x]		; Add point to list.
	    ya = [ya,y]
	    pa = [pa,0]		; Pen up.
	  endif
	  if (x_flag eq 1) and (y_flag eq 1) and $	; Way point.
	     (r_flag eq 1) and (b_flag eq 1) then begin
	    tprint,' Range and bearing from last point:'
	    tprint,'   Range = '+r0
	    tprint,'   Bearing = '+strtrim(b,2)
	    ell_rb2ll, x, y, r, b, x2, y2
	    tprint,'   Lat = '+strtrim(y2,2)+' ('+ell_rb2ll_txt_fm(y2)+')'
	    tprint,'   Lon = '+strtrim(x2,2)+' ('+ell_rb2ll_txt_fm(x2)+')'
	    x = x2		; Current point becomes last point.
	    y = y2
	    r_flag = 0		; Clear range nad bearing flags.
	    b_flag = 0
	    xa = [xa,x]		; Add point to list.
	    ya = [ya,y]
	    pa = [pa,1]		; Pen down.
	  endif
 
	endfor
 
	;-----------------------------------------------------
	;  Deal with results
	;-----------------------------------------------------
	xa=xa(1:*) & ya=ya(1:*) & pa=pa(1:*)	; Drop seed values.
 
	tprint,out=out				; Grab output.
	if not keyword_set(quiet) then tprint,/print
 
	;----- Variable  ---------
	if arg_present(outfile) then begin
	  outfile=out
	  return
	endif
 
	;-----  Output file  -------
	if n_elements(outfile) ne 0 then begin
	  putfile, outfile, out
	  return
	endif
 
	end
