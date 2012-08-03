;-------------------------------------------------------------
;+
; NAME:
;       PCON
; PURPOSE:
;       IDL path control utility. May turn libraries on or off.
; CATEGORY:
; CALLING SEQUENCE:
;       pcon, [command]
; INPUTS:
;       command = optional library command.      in
;         Syntax: 'tag on' or 'tag off'.  See notes below.
;         If command not given interactive mode is entered.
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST  lists known libraries.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: pcon refers to IDL libraries using a short tag name
;         instead of a full directory path.  These tags are defined
;         in a pcon setup file pointed to by the env. var. IDL_PCON.
;         If IDL_PCON is not defined, pcon looks for the file
;         .idl_pcon in your home directory.  The file format is:
;         tag full_directory
;          optional library description line
;         where tag must start in the first column and the
;         description must be indented at least one space.
;         Lines starting with * or ;, and null lines, are ignored.
;         An example pcon setup file (with two libraries):
;         *       .idl_pcon = IDL library list for pcon.pro
;         USR     /data_bases/idl_libs/idlusr
;          Local, general interest.
;         STATLIB /usr/local/lib/idl/lib/statlib
;          IDL, statistics routines.
; MODIFICATION HISTORY:
;       R. Sterner, 22 Mar, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pcon, cmd, list=list, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' IDL path control utility. May turn libraries on or off.'
	  print,' pcon, [command]'
	  print,'   command = optional library command.      in'
	  print,"     Syntax: 'tag on' or 'tag off'.  See notes below."
	  print,'     If command not given interactive mode is entered.'
	  print,' Keywords:'
	  print,'   /LIST  lists known libraries.'
	  print,' Notes: pcon refers to IDL libraries using a short tag name'
	  print,'   instead of a full directory path.  These tags are defined'
	  print,'   in a pcon setup file pointed to by the env. var. IDL_PCON.'
	  print,'   If IDL_PCON is not defined, pcon looks for the file'
	  print,'   .idl_pcon in your home directory.  The file format is:'
	  print,'   tag full_directory'
	  print,'    optional library description line'
	  print,'   where tag must start in the first column and the'
	  print,'   description must be indented at least one space.'
	  print,'   Lines starting with * or ;, and null lines, are ignored.'
	  print,'   An example pcon setup file (with two libraries):'
	  print,'   *       .idl_pcon = IDL library list for pcon.pro
	  print,'   USR     /data_bases/idl_libs/idlusr
	  print,'    Local, general interest.
	  print,'   STATLIB /usr/local/lib/idl/lib/statlib
	  print,'    IDL, statistics routines.
	  return	
	endif
 
	;--------  Try to find the pcon setup file  ---------
	f = getenv('IDL_PCON')		; First look for op sys var.
	if f eq '' then begin		; Not found, look for .idl_pcon.
	  d = getenv('HOME')		;   It must be in the home directory.
	  f = filename(d,'.idl_pcon',/nosym)
	  list_txt = ''
	endif else list_txt = '   (defined in IDL_PCON)'
	file = findfile(f,count=c)
	if c eq 0 then begin
	  print,' Error in pcon: pcon setup file not found.'
	  print,'   Setup file may be specified by the environmental variable'
	  print,'   IDL_PCON which contains the file name.  If IDL_PCON is not'
 	  print,'   used pcon looks for the file .idl_pcon in your home'
 	  print,'   directory.  Do pcon,/help for file format.'
	  return
	endif
	file = file(0)
 
	;-------  Read in and preprocess setup file  -----------
	;-------  Drop comments and null lines  ----------------
	txt = getfile(file)		; Read pcon setup file.
	first = strmid(txt,0,1)		; 1st char.
	w = where((first ne '*') and (first ne ';'), c)	   ; Find comments.
	if c gt 0 then begin
	  txt = txt(w)			; Drop comments.
	endif else begin
	  print,' Error in pcon setup file format:'
	  print,'   No non-comment lines found.'
	  return
	endelse
	w = where(txt ne '', c)		; Find null lines.
	if c gt 0 then begin
	  txt = txt(w)			; Drop null lines.
	endif else begin
	  print,' Error in pcon setup file format:'
	  print,'   No setup lines found.'
	endelse
 
	;=======  Make list of known libraries  =========
	;---  Known libraries are those listed in the pcon setup  ----
	;---  file along with any others from the !path variable. ----
	;-------  First pick apart setup file components.  ----------
	tag = ['']			; Tags array.
	dir = ['']			; Directories array.
	des = ['']			; Descriptions array.
	i = 0				; Setup text index.
	last = n_elements(txt)-1	; Last setup text index.
loop:	if i gt last then goto, next	; No more setup text.
	t = txt(i)			; Pick off next line of text.
	if strmid(t,0,1) eq ' ' then begin	; Not a tag line, error.
	  print,'  Format error in pcon setup file:'
 	  print,'  Required format is (other than comments and null lines):'
 	  print,'  tag1 dir1'
 	  print,'   [desc1]'
 	  print,'  tag2 dir2'
 	  print,'   [desc2]'
	  print,'  . . .'
 	  print,'  tagN dirN'
 	  print,'   [descN]'
	  return
	endif
	tag = [tag,getwrd(t)]		; Pick off tag.
	dir = [dir,getwrd('',1)]	; Pick off directory.
	i = i + 1
	if i gt last then goto, next    ; No more setup text.
	t = txt(i)                      ; Pick off next line of text.
	if strmid(t,0,1) eq ' ' then begin	; Description.
	  des = [des,t]
	  i = i + 1			; Step to next line.
	endif else des = [des, ' ']	; No description.
	goto, loop
 
next:	tag = tag(1:*)			; Drop seed elements.
	dir = dir(1:*)
	des = des(1:*)
	act = bytarr(n_elements(dir))	; Active flag: 0=inactive, 1=active.
 
	;------  Next look at path directories  -------
	;------  Break path into components  -------
        os = strupcase(!version.os)	; Find component delimiter.
        case os of
'VMS':  delim = ','
'DOS':  delim = ';'
else:   delim = ':'
        endcase
 
	wordarray, !path, new, ignore=delim	; Put components in text array.
	new = reverse([new])			; Reverse path list.
 
	;-------  Loop through active (!path) libraries  ----------
	ut_num = 0			; Untagged library number.
	for i = 0, n_elements(new)-1 do begin
	  d = new(i)			; Pick off i'th path component.
	  w = where(d eq dir, c)	; Look for it in lib list.
	  ip = w(0)			; Index into pcon list.
	  if c ne 0 then begin		; Found path lib in pcon lib list.
	    act(ip) = 1			; Set pcon lib to active.
            w = where(d ne dir)		; Move matched directory to front.
            tag = [tag(ip),tag(w)]
            dir = [dir(ip),dir(w)]
            des = [des(ip),des(w)]
            act = [act(ip),act(w)]
	  endif else begin		; Add new directory from path.
	    ut_num = ut_num + 1		; Found an unnamed library in !path.
	    tag = ['NOTAG_'+strtrim(ut_num,2),tag]
	    dir = [d,dir]
	    des = [' Library not listed in .idl_pcon file.',des]
	    act = [1,act]
	  endelse
	endfor
 
	;-------  Make an index array  -------
	indx = sindgen(n_elements(tag))		; Index as a string.
	indx0 = indx + 0			; Numeric index.
 
	;=========  Handle list command  ====================
	if keyword_set(list) then begin
	  print,' '
	  txt = [' Known IDL library tags from the file: '+file]
	  txt = [txt,list_txt]
	  tmp = ([' off ','  ON '])(act)
	  for i = 0, n_elements(tag)-1 do begin
	    txt = [txt,tag(i)+'	'+tmp(i)+des(i)]
	  endfor
	  more, txt
	  return
	endif
 
	;=========  Handle a given argument  ================
	if n_elements(cmd) ne 0 then begin	; Have an argument.
	  cmdtag = strupcase(getwrd(cmd))
	  code = strupcase(getwrd('',1))
	  w = where(cmdtag eq strupcase(tag), c)	; New library index.
	  if c eq 0 then begin				; Unknown tag.
	    print,' Error in pcon:'
	    print,' Library tag not found: '+cmdtag
	    return
	  endif
	  ip = w(0)					; New library index.
	  if code eq 'ON' then  act(ip) = 1		; Set status.
	  if code eq 'OFF' then act(ip) = 0
	  w = where(cmdtag ne strupcase(tag), c)	; Find old libraries.
	  if c gt 0 then begin				; Put new at front.
            tag = [tag(ip),tag(w)]
            dir = [dir(ip),dir(w)]
            des = [des(ip),des(w)]
            act = [act(ip),act(w)]
	  endif
	  goto, done
	endif
 
	;=========  Interactive mode  =======================
	;=========  Now have all known libraries  ===========
	;=========  Allow rearranging between active and inactive  =====
	;-------  Set up menu  ------------
	is = 2				; Initial selection.
mloop:	menu = ['|2|2|Path Control Utility||']
	;-------  Active libraries  ----------
	menu = [menu,'|2|4|Active IDL libraries||']
	w = where(act eq 1, ca)	; Pick off active libraries.
	if ca gt 0 then begin
	  tag_a = tag(w)	; Tags of active libs.
	  dir_a = dir(w)	; Directories of active libs.
	  des_a = des(w)	; Descriptions of active libs.
	  ind_a = indx(w)	; Indices of active libs.
	  for i = 0, n_elements(dir_a)-1 do begin
	    menu = [menu,'|2|'+strtrim(i+5,2)+'|'+tag_a(i)+'| |'+$
	      'ACT '+ind_a(i)+'|']
	  endfor
	endif
	;-------  Inactive libraries  ----------
	menu = [menu,'|28|4|Inactive IDL libraries||']
	w = where(act eq 0, ci)
	if ci gt 0 then begin
	  tag_i = tag(w)
	  dir_i = dir(w)
	  des_i = des(w)
	  ind_i = indx(w)
	  for i = 0, n_elements(tag_i)-1 do begin
	    menu = [menu,'|28|'+strtrim(i+5,2)+'|'+tag_i(i)+'| |'+$
	      'INACT '+ind_i(i)+'|']
	  endfor
	endif
	;------  Other commands  -------------
	menu = [menu,'|60|5|Done (Update !path)| |DONE|',$
		'|60|7|Abort (No change)| |ABORT|',$
	        '|60|9|Help| |HELP|']
	;------  Keep default selection in bounds  ------
	if is eq (ca+2) then is = is + 1
 
	txtmenu, init=menu
mloop2:	txtmenu, sel=is, uval=uval
 
	if uval eq 'ABORT' then begin
	  printat,1,22,' '
	  return
	endif
 
	if uval eq 'DONE' then begin
	  printat,1,22,' '
done:	  w = where(act eq 1, c)		; Select active libraries.
	  if c gt 0 then begin
	    dir_a = dir(w)			; Pick out active libs.
	    txt = dir_a(0)			; Start with first.
	    for i=1, n_elements(dir_a)-1 do begin
	      txt = txt + delim + dir_a(i)	; Add active libs.
	    endfor
	    !path = txt				; Update !path.
	  endif
	  return
	endif
 
	if uval eq 'HELP' then begin
	  printat,1,1,/clear
	  print,' '
	  print,' Path Control Utility'
	  print,' '
	  print,' Allows easy control of the IDL !path.'
	  print,' '
	  print,' Use arrow keys to highlight an item .'
	  print,' Press RETURN to choose highlighted item.'
	  print,' If item is an IDL library three options are available:'
	  print,'        S --- will swap the active/inactive status.'
	  print,'        T --- will move library to top of list.'
	  print,'        B --- will move library to bottom of list.'
	  print,' If Done is selected the IDL !path varible will be redefined'
	  print,'   to be the active list of libraries.'
	  print,' Abort quits with no change to !path.'
	  k = get_kbrd(1)
	  goto, mloop
	endif
 
	;-------  Handle selection  -------
	code = getwrd(uval)		; Status of selected library.
	ind = getwrd('',1)+0		; Index of selected library.
 
	printat,2,22,tag(ind)+': '+dir(ind)
	printat,2,23,des(ind)
	printat,1,24,' Enter command: S=switch status  T=top  B=bottom'
	printat,2,21,''
	k = get_kbrd(1)
	k = strupcase(k)
 
	case k of
'S':	  begin
	    act(ind) = 1 - act(ind)	; Toggle active status.
	  end
'B':	  begin
	    w = where(indx ne ind)
	    tag = [tag(w),tag(ind)]
	    dir = [dir(w),dir(ind)]
	    des = [des(w),des(ind)]
	    act = [act(w),act(ind)]
	  end
'T':	  begin
	    w = where(indx ne ind)
	    tag = [tag(ind),tag(w)]
	    dir = [dir(ind),dir(w)]
	    des = [des(ind),des(w)]
	    act = [act(ind),act(w)]
	  end
else:
	endcase
 
	goto, mloop
 
	return
	end
