;-------------------------------------------------------------
;+
; NAME:
;       TXTGETFILE
; PURPOSE:
;       Select a file name.
; CATEGORY:
; CALLING SEQUENCE:
;       txtgetfile, name
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE_TEXT=txt text for title.
;           Def = Select file option.
;         QUIT_TEXT=txt text for quit option.
;           If specified QUIT_TEXT replaces the Accept file
;           option and supresses the abort file selection
;           option if ABORT_TEXT not given.
;         ABORT_TEXT=txt text to replace abort file selection.
;         /NOCHECK means don't check if file exists.
;         /MULTIPLE means allow multiple files to be selected.
;           When /MULT is in effect /NOCHECK automatically is too.
;         DIRECTORY=dd set default directory.  May change.
;           New directory returned on exit.
;         WILDCARD=ww set default filename wildcard for searches.
;           May change, new value is returned on exit.
;         DEF_EXTENSION=def_ex  Default file extension to add if
;           none given in an entered file name.
;         NUMDEF=n on input sets item number to highlight as default.
;           On output returns item number selected.
;         OPTION1=[title_text, routine]
;           title_text = the text describing the action of
;             the optional user supplied file processing procedure.
;           routine = name of an optional user supplied
;             procedure that takes as its one argument the file
;             currently specified.  This routine will process
;             the file in some way, like list it.  The specified
;             procedure must handle errors such as missing files.
;         OPTION2 through OPTION5 are also allowed and work same.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 13 Mar, 1992
;       R. Sterner, 18 May, 1993 --- Added multiple options.
;       R. Sterner, 19 May, 1993 --- Added DEF_EXTENSION keyword.
;       R. Sterner,  1 Jun, 1993 --- Added ABORT_TEXT keyword.
;       R. Sterner,  2 Sep, 1993 --- Added option 5.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtgetfile, name, help=hlp, multiple=mult, abort_text=abrt_txt,$
	  title_text=tttxt, nocheck=nocheck, def_extension=def_exten, $
	  quit_text=qttxt, directory=directory, wildcard=wild, $
	  numdef=numdef, option1=opt1, option2=opt2, option3=opt3, $
	  option4=opt4, option5=opt5
 
	if keyword_set(hlp) then begin
	  print,' Select a file name.'
	  print,' txtgetfile, name'
	  print,'   name = selected file name.    in,out'
	  print,'     If name = "none" then no file was selected.'
	  print,'     If defined on input it is the default.'
	  print,' Keywords:'
	  print,'   TITLE_TEXT=txt text for title.'
	  print,'     Def = Select file option.'
	  print,'   QUIT_TEXT=txt text for quit option.'
	  print,'     If specified QUIT_TEXT replaces the Accept file'
	  print,'     option and supresses the abort file selection'
	  print,'     option if ABORT_TEXT not given.' 
	  print,'   ABORT_TEXT=txt text to replace abort file selection.'
	  print,"   /NOCHECK means don't check if file exists."
	  print,'   /MULTIPLE means allow multiple files to be selected.'
	  print,'     When /MULT is in effect /NOCHECK automatically is too.'
	  print,'   DIRECTORY=dd set default directory.  May change.'
	  print,'     New directory returned on exit.'
	  print,'   WILDCARD=ww set default filename wildcard for searches.'
	  print,'     May change, new value is returned on exit.'
	  print,'   DEF_EXTENSION=def_ex  Default file extension to add if'
	  print,'     none given in an entered file name.'
	  print,'   NUMDEF=n on input sets item number to highlight as default.'
	  print,'     On output returns item number selected.'
	  print,'   OPTION1=[title_text, routine]
	  print,'     title_text = the text describing the action of'
	  print,'       the optional user supplied file processing procedure.
	  print,'     routine = name of an optional user supplied'
	  print,'       procedure that takes as its one argument the file' 
	  print,'       currently specified.  This routine will process'
	  print,'       the file in some way, like list it.  The specified'
	  print,'       procedure must handle errors such as missing files.'
	  print,'   OPTION2 through OPTION5 are also allowed and work same.'
	  return
	endif
 
	if n_elements(mult) eq 0 then mult = 0	; Assume single file.
	if n_elements(directory) eq 0 then directory = ''
  	if n_elements(wild) eq 0 then wild = '*'
	if n_elements(optxt) eq 0 then optxt = 'User option'
 
	;--------  Handle initial file name  ----------
	if n_elements(name) eq 0 then name = ''
	if name(0) eq '' then name = 'none'
	name0 = name
	if name0(0) ne 'none' then begin
	  fname = name0				; Used to list header.
	  filebreak, name0, dir=dd, nvfile=ff	; Look for a directory.
	  if directory eq '' then begin		; Don't change a given dir.
	    if dd(0) ne '' then directory = dd(0)  ; Split it off.
	  endif
	  name0 = ff				; Bare file name.
	endif
 
	if n_elements(tttxt) eq 0 then begin
	   tttxt = 'Select file option'
	endif
	if n_elements(qttxt) eq 0 then begin
	  actxt = 'Accept current file'
	  if keyword_set(mult) then actxt = actxt+'s'
	  abtxt = 'Abort file selection'
	  if n_elements(abrt_txt) ne 0 then abtxt = abrt_txt
	  accact = 0	; Force accept active? No.
	endif else begin
	  actxt = qttxt
	  abtxt = ' '
	  if n_elements(abrt_txt) ne 0 then abtxt = abrt_txt
	  accact = 1	; Force QUIT active? Yes.
	endelse
        cd, current=curr
	is = 1				; initial selection is accept file.
 
floop:	defdir = directory
        if directory eq '' then defdir='current = '+curr
	if directory eq '' then directory = curr
	accval = ' '
	if name0(0) eq 'none' then accval = ''
	namtxt = name0(0)
	if n_elements(name0) gt 1 then namtxt = strtrim(n_elements(name0),2)+$
	  ' files in list.'
	if accact then accval = ' '	; Keep QUIT option active.
	tmen = ['|5|3|'+tttxt+'||',$
	  '|20|7|'+actxt+'|'+accval+'|',$
	  '|5|11|Directory|'+defdir+'|',$
	  '|5|10|File name wildcard pattern|'+wild+'|',$
	  '|5|9|Search for files matching the pattern below| |',$
	  '|5|5|Enter file name. Now|'+namtxt+'|', $
	  '|5|13|Help| |',$
	  '|50|7|'+abtxt+'| |']
	if n_elements(opt1) ne 0 then begin
	  tmen = [tmen,'|20|13|'+opt1(0)+'| |']
	endif
	if n_elements(opt2) ne 0 then begin
	  tmen = [tmen,'|20|15|'+opt2(0)+'| |']
	endif
	if n_elements(opt3) ne 0 then begin
	  tmen = [tmen,'|20|17|'+opt3(0)+'| |']
	endif
	if n_elements(opt4) ne 0 then begin
	  tmen = [tmen,'|20|19|'+opt4(0)+'| |']
	endif
	if n_elements(opt5) ne 0 then begin
	  tmen = [tmen,'|20|21|'+opt5(0)+'| |']
	endif
	if name0(0) eq 'none' then is = 4 ; Unless file undefined, then search.
	txtmenu, init=tmen
	txtmenu, select=is
 
	case is of
	;------  Accept  ----------
1:	begin
	  name = name0
	  if name(0) eq 'none' then return
	  name = filename(directory, name0, /nosym)
	  f = findfile(name)
	  if f(0) eq '' then begin
	    txtmess,'No files found'
	    goto, floop
	  endif
	  printat, 1, 1, /clear
	  return
	end
	;------  Enter directory  -------
2:	begin
	  txtin, ['Change Directory.',$
		'Select one of three choices:',$
		'(1) Type in a new directory name,',$
		'(2) Type a period (.) to switch to current directory,',$
		'(3) Press RETURN to keep same directory.'],$
		txt, def=directory
	  if txt eq '.' then txt = curr
	  directory = txt
	  txtmenu,update='|5|7|Directory|'+directory+'|'
	  is = 4	; Make search be default.
	  numdef = 1	; New search, start at 1.
	end
	;-------  Enter Wildcard  ----------
3:	begin
	  txtin, ['Change file name name wildcard pattern.',$
	  	'Enter new pattern or RETURN to keep same pattern.'], $
		txt, def=wild
	  wild = txt
	  txtmenu,update='|5|9|File name wildcard pattern|'+wild+'|'
	  is = 4	; Make search be default.
	  numdef = 1	; New search, start at 1.
	end
	;-------  Search  ---------
4:	begin
	  name = filename(directory, wild, /nosym)
	  printat,1,1,/clear
	  f = findfile(name)
	  if f(0) eq '' then begin
	    txtmess,'No files found'
	    goto, floop
	  endif
	  is4 = 2
	  if n_elements(numdef) ne 0 then is4 = numdef
	  txtpick, f, fname, abort='Go back to '+tttxt, select=is4,mult=mult
	  numdef = is4
	  filebreak, fname, nvfile=name0
	  is = 1
	  goto, floop
	end
	;---------  Enter a file name  --------
5:	begin
	  txtin,['Change file name.', $
	  	'Enter new file name or RETURN to keep same.'],$
		txt, def=name0
	  filebreak, txt, dir=dd, nvfile=txt2, exten=exten
	  if (n_elements(def_exten) ne 0) and (exten eq '') then $
	    txt2 = txt2+'.'+def_exten
	  if dd(0) ne '' then begin
	    directory = dd(0)
	    txtmenu,update= '|5|11|Directory|'+directory+'|'
	  endif
	  fname = filename(directory, txt2, /nosym)
	  if (not keyword_set(nocheck)) and (not keyword_set(mult)) then begin	
	    ;----  check  -------
	    if txt2 ne 'none' then begin
	      f = findfile(fname)
	      if f(0) eq '' then begin
	        txtmess,'File not found: '+fname
	        goto, floop
	      endif  ; ''
	    endif  ; 'none'
	  endif  ; nocheck
	  name0 = txt2
	  is = 1
	  goto, floop
	 end
	;-------  Help  -------------
6:	begin
	  txtmess,[$
	    'How to select a file.',$
	    ' ',$
	    'There are two ways to select a file:',$
	    '1. You may enter the file name using the ENTER option.',$
	    '2. You may search for files matching the specified wildcard',$
	    '   pattern in the specified directory using the SEARCH option.',$
	    '   The directory and wildcard may both be changed.',$
	    ' ',$
	    'After a file has been selected you may go ahead and accept',$
	    'it using the ACCEPT option, or reject it using the ABORT option.']
	  is = 1
	  if name0(0) eq 'none' then is = 4
	end
	;-------  Abort selection  -------
7:	begin
	  name = 'none'
	  return
	end
	;-------  Optional user specified processing  -------
8:	begin
	  name = name0
	  if name(0) eq 'none' then begin
	    txtmess,'No file specified'
	    goto, floop
	  endif
	  name = filename(directory, name0, /nosym)
	  call_procedure, opt1(1), name
	  goto, floop
	end
9:	begin
	  name = name0
	  if name(0) eq 'none' then begin
	    txtmess,'No file specified'
	    goto, floop
	  endif
	  name = filename(directory, name0, /nosym)
	  call_procedure, opt2(1), name
	  goto, floop
	end
10:	begin
	  name = name0
	  if name(0) eq 'none' then begin
	    txtmess,'No file specified'
	    goto, floop
	  endif
	  name = filename(directory, name0, /nosym)
	  call_procedure, opt3(1), name
	  goto, floop
	end
11:	begin
	  name = name0
	  if name(0) eq 'none' then begin
	    txtmess,'No file specified'
	    goto, floop
	  endif
	  name = filename(directory, name0, /nosym)
	  call_procedure, opt4(1), name
	  goto, floop
	end
12:	begin
	  name = name0
	  if name(0) eq 'none' then begin
	    txtmess,'No file specified'
	    goto, floop
	  endif
	  name = filename(directory, name0, /nosym)
	  call_procedure, opt5(1), name
	  goto, floop
	end
else:	txtmess,'Invalid option'
	endcase
 
	goto, floop
 
	end
