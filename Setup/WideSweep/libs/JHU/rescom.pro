;-------------------------------------------------------------
;+
; NAME:
;       RESCOM
; PURPOSE:
;       Display values from the results common and also file header.
; CATEGORY:
; CALLING SEQUENCE:
;       rescom, [rfile]
; INPUTS:
;       rfile = Optional res file name.     in
;         If rfile given, it is opened, listed, and closed.
; KEYWORD PARAMETERS:
;       Keywords:
;         FD=fd    Optional file descriptor.  Allows multiple res
;           files to be used at once.
;         FILE=f    RES file to examine (def=one currently open).
;         /NOHEADER skips display of file's header.
;         /NOSTATUS skips display of status (read/write/lun/pointer).
;         /ARRAYS   lists arrays and arrays sizes.
;         TAG=tag   Display only given tag (def=all).
;         GETLUN=lun  Return file unit for current file.
;           Skips listing.  -1 if no res file open.
; OUTPUTS:
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resopen, resput, resget, resclose.
; MODIFICATION HISTORY:
;       R. Sterner, 18 Jun, 1991
;       R. Sterner, 1994 Mar 29 --- added /NOSTATUS, TAG, and FILE keywords.
;       R. Sterner, 2000 Apr 11 --- Handled endian problem.
;       R. Sterner, 2000 Aug 14 --- Ignored r_swap if undefined.
;       R. Sterner, 2004 Mar 02 --- Added keyword GETLUN=lun.
;       R. Sterner, 2004 Sep 27 --- Added FD=fd to give file descriptor.
;       R. Sterner, 2005 Mar 05 --- Added /ARRAYS.
;       R. Sterner, 2005 Nov 15 --- Blanked <Press RETURN to continue> for unix.
;       R. Sterner, 2007 Mar 21 --- Allowed optional res file to list.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro rescom, rfile, $
	  noheader=noheader, nostatus=nostatus, help=hlp, $
	  tag=tag, file=file, getlun=lunout, fd=fd, arrays=arrays
 
        common results_common, r_file, r_lun, r_open, r_hdr, r_swap
        ;----------------------------------------------------
        ;       r_file = Name of results file.
        ;       r_lun  = Unit number of results file.
        ;       r_open = File open flag. 0: not open.
        ;                                1: open for read.
        ;                                2: open for write.
        ;       r_hdr  = String array containing file header.
	;       r_swap = Swap endian if set.
        ;----------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Display values from the results common and also file header.'
	  print,' rescom, [rfile]'
	  print,'   rfile = Optional res file name.     in'
	  print,'     If rfile given, it is opened, listed, and closed.'
	  print,' Keywords:'
	  print,'   FD=fd    Optional file descriptor.  Allows multiple res'
	  print,'     files to be used at once.'
	  print,'   FILE=f    RES file to examine (def=one currently open).'
	  print,"   /NOHEADER skips display of file's header."
	  print,"   /NOSTATUS skips display of status (read/write/lun/pointer)."
	  print,'   /ARRAYS   lists arrays and arrays sizes.'
	  print,'   TAG=tag   Display only given tag (def=all).'
	  print,'   GETLUN=lun  Return file unit for current file.'
	  print,'     Skips listing.  -1 if no res file open.'
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resopen, resput, resget, resclose.'
	  return
	endif
 
	;-------  Process optional rfile  ----------
	if n_elements(rfile) gt 0 then begin
	  resopen,rfile,error=err
	  if err ne 0 then return
	  rescom
	  resclose
	  return
	endif
 
	;-------  Process fd if given  -------------
	if n_elements(fd) gt 0 then begin
	  r_file = fd.r_file
	  r_lun = fd.r_lun
	  r_open = fd.r_open
	  r_hdr = fd.r_hdr
	  r_swap = fd.r_swap
	endif
 
	if n_elements(r_open) eq 0 then r_open = 0
 
	if arg_present(lunout) then begin
	  if r_open GT 0 then lunout=r_lun else lunout=-1
	  return
	endif
 
        ;-------  Set up for screen display  --------
	;#####  Should use openw, ..., /MORE but there seems to
	;#####  be a bug in the old PC version.  Check new version.
        lun = -1
        maxline = 15
        lcount = 1
        txt = ''
	tagflag = 0
	if n_elements(tag) ne 0 then begin
	  tagflag = 1
	  tlen = strlen(tag)
	  utag = strupcase(tag)
	endif
	os = !version.os_family
	if os eq 'unix' then bflag=1 else bflag=0 ; Backspace for unix only.
 
	;-------  If given a file open it.  ---------
	if n_elements(file) ne 0 then resopen,file
 
	;-------  File open?  ----------
	if r_open eq 0 then begin
	  print,' No results file is open.'
	  goto, done
	endif
 
	;-------  List status variables  -------
	if not keyword_set(nostatus) then begin
	  printf,lun,' '
	  if r_open eq 1 then begin
	    printf,lun,' Results file '+r_file+' is open for read.'
	  endif
	  if r_open eq 2 then begin
	    printf,lun,' Results file '+r_file+' is open for write.'
	  endif
	  printf, lun, ' File unit number = ',strtrim(r_lun, 2)
	  fs = fstat(r_lun)
	  printf, lun, ' Current file pointer = ',strtrim(fs.cur_ptr, 2)
	  if n_elements(r_swap) ne 0 then begin
	    if r_swap eq 1 then txt=' Will swap endian' else $
	      txt=' Will not swap endian'
	    txt = txt + ' ('+endian(/text)+')'
	    printf,lun,txt
	  endif
	  printf,lun,' '
;          read, ' <Press RETURN to continue>', txt
          print, ' <Press RETURN to continue>', form='(A,$)'
	  txt = get_kbrd(1)				; Wait for a key.
	  if strupcase(txt) eq 'Q' then begin
	    if bflag then print,spc(27,char=string(8B))+spc(27)+ $
		spc(27,char=string(8B)) else print,''
	    return
	  endif
	  if bflag then print,spc(27,char=string(8B))+spc(27)+ $
	      spc(27,char=string(8B)),format='(A,$)' else print,''
	endif
 
	;--------  Display arrays  ----------
	if keyword_set(arrays) then begin
	  ;---  Find all arrays  -------
	  strfind,r_hdr,'==',index=in,count=cnt,/quiet
	  if cnt eq 0 then begin
	    print,' No arrays in this res file.'
	    return
	  endif
	  aa = r_hdr(in)
	  ;----  Grab tags, types, and sizes  ----
	  n = n_elements(aa)
	  tags = strarr(n)
	  typs = strarr(n)
	  numbyt = ulonarr(n)
	  for i=0,n-1 do begin
	    tags(i) = getwrd(aa(i),0)
	    typs(i) = getwrd(aa(i),2)
	    numbyt(i) = typ2num(typs(i),/bytes)
	  endfor
	  ;---  Deal with res file header  ----
	  htyp = datatype(/desc,byte(r_hdr))
	  tags = ['<HEADER>',tags]
	  typs = [htyp,typs]
	  numbyt = [typ2num(htyp,/bytes),numbyt]
	  n = n+1
	  ;---  Deal with res file front end  ----
	  fbyt = getwrd(aa(0),/last)+0
	  tags = ['<FRONT>',tags]
	  typs = ['LONARR('+strtrim(fbyt/4,2)+')',typs]
	  numbyt = [fbyt,numbyt]
	  n = n+1
	  ;---  Equalize string lengths  -----
	  mxtag = max(strlen(tags))
	  for i=0,n-1 do tags(i)=' '+spc(mxtag,tags(i))+tags(i)
	  mxtyp = max(strlen(typs))
	  for i=0,n-1 do typs(i)=' '+spc(mxtyp,typs(i))+typs(i)
	  ;---  Deal with array sizes  -----
	  cumbyt = string(cumulate(numbyt))
	  mb = numbyt/1E6
	  cmb = string(cumulate(mb))
	  mb = string(mb)
	  numbyt = string(numbyt)
	  ;----  Prepare table and titles  -----
	  aa = tags+' =='+typs+numbyt+cumbyt+mb+cmb
	  tagstxt1 = spc(mxtag,' Tag')+' Tag'
	  tagstxt2 = spc(mxtag,' name')+' name'
	  typstxt1 = spc(mxtyp,' Data')+' Data'
	  typstxt2 = spc(mxtyp,' type')+' type'
	  numbyttxt1 = spc(strlen(numbyt(0)),'Number')+'Number'
	  numbyttxt2 = spc(strlen(numbyt(0)),'bytes')+'bytes'
	  cumbyttxt1 = spc(strlen(cumbyt(0)),'Total')+'Total'
	  cumbyttxt2 = spc(strlen(cumbyt(0)),'bytes')+'bytes'
	  mbtxt1 = spc(strlen(mb(0)),'Number')+'Number'
	  mbtxt2 = spc(strlen(mb(0)),'MB (1E6)')+'MB (1E6)'
	  cmbtxt1 = spc(strlen(cmb(0)),'Total')+'Total'
	  cmbtxt2 = spc(strlen(cmb(0)),'MB (1E6)')+'MB (1E6)'
	  tt1 = tagstxt1+'   '+typstxt1+numbyttxt1+cumbyttxt1+mbtxt1+cmbtxt1
	  tt2 = tagstxt2+'   '+typstxt2+numbyttxt2+cumbyttxt2+mbtxt2+cmbtxt2
	  ;----  List title and table  -------
	  more,[tt1,tt2,' '],lines=200
	  more,aa,lines=200
	  print,' '
	  return
	endif
 
	if keyword_set(noheader) then return
 
        ;--------  Display header  ----------
        printf, lun, ' Results header for file '+r_file+':'
        for i=0, n_elements(r_hdr)-1 do begin
	  if strtrim(r_hdr(i),2) ne '' then begin
	    if tagflag eq 0 then begin
              printf,lun,strtrim(i)+' '+strtrim(r_hdr(i))
              lcount = lcount + 1
	    endif else begin
	      if strupcase(strmid(r_hdr(i),0,tlen)) eq utag then begin
	        printf,lun,strtrim(i)+' '+strtrim(r_hdr(i))
	        lcount = lcount + 1
	      endif
	    endelse
            if (lcount mod maxline) eq 0 then begin
;              read, ' <Press RETURN to continue>', txt
;	      if strupcase(txt) eq 'Q' then return
              print, ' <Press RETURN to continue>', form='(A,$)'
	      txt = get_kbrd(1)				; Wait for a key.
	      if strupcase(txt) eq 'Q' then begin
	        if bflag then print,spc(27,char=string(8B))+spc(27)+ $
		    spc(27,char=string(8B)) else print,''
	        return
	      endif
	      if bflag then print,spc(27,char=string(8B))+spc(27)+ $
	          spc(27,char=string(8B)),format='(A,$)' else print,''
            endif
          endif
        endfor
 
done:   return
 
	end
