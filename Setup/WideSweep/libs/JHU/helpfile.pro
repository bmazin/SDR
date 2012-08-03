;-------------------------------------------------------------
;+
; NAME:
;       HELPFILE
; PURPOSE:
;       Display a file of help text.
; CATEGORY:
; CALLING SEQUENCE:
;       helpfile, file
; INPUTS:
;       file = name of help text file.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIRECTORY=d  give help text file directory.
;           Default is the current directory.
;         EXIT_CODE=excode.  Exit code.  If excode is 'QUIT'
;           then do a return.  Meant to exit recursively.
;         /TXTMENU use TXTMENU type screen menus.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: the simplest help text file is simply an
;         ordinary text file.  It will be displayed to the screen
;         using the /MORE option.  Lines must not start with *
;         in column 1, such lines are not displayed (see below).
;         Help text files may also have optional comment lines
;         and setup a menu used to display other help text files.
;         A help text file has the following format:
;         There are 4 types of lines:
;         1. Comment lines: have * in column 1.  Not displayed.
;         2. Text to display: must not have * in column 1.
;         3. Menu control lines: must start in column 1.
;            There are 2 menu control lines:
;            .menu_start
;            .menu_end
;            Menus are optional.
;         4. Menu lines: must be between .menu_start and .menu_end
;            lines and have the following format:
;            menu text | action code
;            The menu text may be any text and will be displayed
;            in a menu.  The action code must be one of 5 options:
;            title --- means use as menu title,
;            noop --- no operation when selected,
;            link filename --- means display filename as help text,
;            back --- means go back to calling routine,
;            quit --- means recursively exit all levels.
;         Example:
;       *----  This is an example help text file  ------
;       *----  These two lines are comments and not displayed.
;       A line of text to display.
;        . . . any number of lines . . .
;       .menu_start
;       Example menu | title
;       Go back to last menu | back
;       Quit help | quit
;       Overview | link overview.hlp
;       Setting up defaults | link defaults.hlp
;        . . . any number of menu lines . . .
;       .menu_end
;        May display more lines of text after returning from a
;        menu call. . . .
; MODIFICATION HISTORY:
;       R. Sterner, 10 jan, 1992
;       R. Sterner, 15 Jan, 1992 --- added DIRECTORY=
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro helpfile, filenam, exit_code=excode, directory=dir, help=hlp, $
	  txtmenu=txtmenu
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a file of help text.'
	  print,' helpfile, file'
	  print,'   file = name of help text file.   in'
	  print,' Keywords:'
	  print,'   DIRECTORY=d  give help text file directory.'
	  print,'     Default is the current directory.'
	  print,"   EXIT_CODE=excode.  Exit code.  If excode is 'QUIT'"
	  print,'     then do a return.  Meant to exit recursively.'
	  print,'   /TXTMENU use TXTMENU type screen menus.'
	  print,' Notes: the simplest help text file is simply an'
	  print,'   ordinary text file.  It will be displayed to the screen'
	  print,'   using the /MORE option.  Lines must not start with *'
	  print,'   in column 1, such lines are not displayed (see below).'
	  print,'   Help text files may also have optional comment lines'
	  print,'   and setup a menu used to display other help text files.'
	  print,'   A help text file has the following format:'
	  print,'   There are 4 types of lines:'
	  print,'   1. Comment lines: have * in column 1.  Not displayed.'
	  print,'   2. Text to display: must not have * in column 1.
	  print,'   3. Menu control lines: must start in column 1.'
	  print,'      There are 2 menu control lines:'
	  print,'      .menu_start'
	  print,'      .menu_end'
	  print,'      Menus are optional.'
	  print,'   4. Menu lines: must be between .menu_start and .menu_end'
	  print,'      lines and have the following format:'
	  print,'      menu text | action code
	  print,'      The menu text may be any text and will be displayed'
	  print,'      in a menu.  The action code must be one of 5 options:'
	  print,'      title --- means use as menu title,'
	  print,'      noop --- no operation when selected,'
	  print,'      link filename --- means display filename as help text,'
	  print,'      back --- means go back to calling routine,'
	  print,'      quit --- means recursively exit all levels.'
	  print,'   Example:'
	  print,'*----  This is an example help text file  ------'
	  print,'*----  These two lines are comments and not displayed.'
	  print,'A line of text to display.'
	  print,' . . . any number of lines . . .'
	  print,'.menu_start
	  print,'Example menu | title'
	  print,'Go back to last menu | back'
	  print,'Quit help | quit'
	  print,'Overview | link overview.hlp'
	  print,'Setting up defaults | link defaults.hlp'
	  print,' . . . any number of menu lines . . .'
	  print,'.menu_end
	  print,' May display more lines of text after returning from a'
	  print,' menu call. . . .'
	  return
	endif
 
	if n_elements(dir) eq 0 then dir = ''
	if dir eq '' then cd, current=dir
 
	;-------  Open files  ---------
	file = filename(dir, filenam, /nosym)
	excode = ''			; Define exit code.
	on_ioerror, ioerr
	openr, lunin, file, /get_lun	; Input help text file.
	on_ioerror, null
	screen = filepath(/terminal)	; Get file name of screen.
	openw, lunout, screen, /more, /get_lun
 
	;-------  Loop through help text file  ---------
	if keyword_set(txtmenu) then printat,1,1,/clear
	txt = ''
	mode = 'text'					; Start in text mode.
	count = 0					; File lines displayed.
	while not eof(lunin) do begin			; Loop through file.
	  readf, lunin, txt				; Read next line.
	  if strmid(txt,0,1) ne '*' then begin		; Not a comment?
	    if strupcase(txt) eq '.MENU_START' then mode = 'menu_start'
	    if strupcase(txt) eq '.MENU_END' then mode = 'menu_end'
 
	    case mode of 
'text':	      begin
		printf, lunout, txt			; Just display text.
		count = count + 1
	      end
'menu':	      begin
	        mtxt = [mtxt,getwrd(txt,delim='|',/notr)] ; Add to menu text.
	        atxt = [atxt,getwrd('',1)]		; Add to action code.
	      end
'menu_start': begin
	        mtxt = ['']				; Start menu text.
	        atxt = ['']				; Start action codes.
		mode = 'menu'
	      end
'menu_end':   begin
	        if mode eq 'text' then goto, merr	; Not in menu mode.
		;-------  Pause before next menu  --------
		if keyword_set(txtmenu) then begin
		  print,' < Press Spacebar to continue >'
		  txt = get_kbrd(1)
		endif
		;-------  Now do next menu  -------- 
		count = 0				; Menu clears count.
	        mtxt = mtxt(1:*)			; Trim dummy front.
	        atxt = atxt(1:*)
	        w = where(strupcase(atxt) eq 'TITLE')	; Look for a title.
	        repeat begin				; Loop until exit code.
		  if keyword_set(txtmenu) then begin	; Use TXTMENU menu.
		    nmen = n_elements(mtxt)
		    if nmen le 12 then begin		; Set up line.
		      y = strtrim(1+2*indgen(nmen),2)
		    endif else begin
		      y = strtrim([1,3+indgen(nmen-1)],2)
		    endelse
		    tt = mtxt
		    for i = 1, nmen do begin
		      tt(i-1) = '|5|'+y(i-1)+'|'+mtxt(i-1)+'|'+spc(i gt 1)+'|'
		    endfor
		    txtmenu, init=tt
		    if n_elements(in) eq 0 then in = 1
		    txtmenu, selection=in
		  endif else begin
	            in = wmenu2(mtxt, title=w(0))	; Select menu option.
		  endelse
		  ;-------  Pop back out of all recursion levels  -----
		  if strupcase(atxt(in)) eq 'QUIT' then begin
		    excode = 'QUIT'
		    goto, done
		  endif
		  ;-------  Recursively call another help text file ----
		  if strupcase(getwrd(atxt(in))) eq 'LINK' then begin
		    file = getwrd('',1)			; New help text file.
		    helpfile, file, dir=dir, exit_code=excode,$	; Recurse.
		      txtmenu=txtmenu
		    if strupcase(excode) eq 'QUIT' then goto, done
		  endif
	        endrep until strupcase(atxt(in)) eq 'BACK'  ; Go back to caller.
	        mode = 'text'				; Was menu_end.
	      end
	    endcase
 
	  endif  ; '*'
	endwhile
 
	;-------  Pause --------
	if keyword_set(txtmenu) and (count gt 0) then begin
	  printat,1,23,''
	  print,' < Press Spacebar to continue >'
	  txt = get_kbrd(1)
	endif
 
	goto, done			; OK.
 
	;----------  Errors  -----------
ioerr:	if keyword_set(txtmenu) then begin
	  txtmess, 'Could not open help text file '+file
	endif else begin
	  print,' Could not open help text file '+file
	  bell
	endelse
	return
 
merr:  if keyword_set(txtmenu) then begin
	  txtmess,'Found a .menu_end without a .menu_start'
	endif else begin
	  print,' Found a .menu_end without a .menu_start'
	  bell
	endelse
 
	;----------  Done  -------------
done:	free_lun, lunin, lunout		; Close files
	if keyword_set(txtmenu) then printat,1,1,/clear
	return
 
	end
