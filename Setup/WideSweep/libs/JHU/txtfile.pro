;-------------------------------------------------------------
;+
; NAME:
;       TXTFILE
; PURPOSE:
;       Enter a (new) file name.
; CATEGORY:
; CALLING SEQUENCE:
;       txtfile, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DIRECTORY=dd directory name (def=current directory).
;           May send a directory.  A change will be returned.
;         TITLE=tt menu title (def=Enter a file name).
;         ERROR_TEXT=etxt Text to display if file does not exist
;           and /CHECK is turned on (def=nothing).
;         /CHECK means check if file exists.  If not
;           set returned file name to "none".
; OUTPUTS:
;       file = file name.            in, out
;         If file defined on entry it is used as default.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 26 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtfile, file, help=hlp, directory=dir, title=title, $
	  check=check, error_text=etxt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Enter a (new) file name.'
	  print,' txtfile, file'
	  print,'   file = file name.            in, out'
	  print,'     If file defined on entry it is used as default.'
	  print,' Keywords:'
	  print,'   DIRECTORY=dd directory name (def=current directory).'
	  print,'     May send a directory.  A change will be returned.'
	  print,'   TITLE=tt menu title (def=Enter a file name).'
	  print,'   ERROR_TEXT=etxt Text to display if file does not exist'
	  print,'     and /CHECK is turned on (def=nothing).'
	  print,'   /CHECK means check if file exists.  If not'
	  print,'     set returned file name to "none".'
	  return
	endif
 
	cd, curr=curr
	if n_elements(dir) eq 0 then dir = curr
	if n_elements(title) eq 0 then title = 'Enter a file name'
	if n_elements(etxt) eq 0 then etxt = ''
	if n_elements(file) eq 0 then file = ''
	if file eq '' then file = 'none'
	filebreak, file, nvfile=file2, dir=dir2
	file = file2
	if dir2 ne '' then dir = dir2
 
	menu = ['|5|3|'+title+'||',$
	  '|5|5|Enter file name. Now|'+file+'|',$
	  '|5|7|Change directory. Now|'+dir+'|']
 
	is = 1
	txtmenu, init=menu
 
loop:	txtmenu, select=is
 
	case is of
	;----  File name  -------
1:	begin
	  txtin,'Enter file name. Enter none for none.',txt,def=file
	  if txt eq 'none' then begin
	    file = txt
	    return
	  endif
	  file = filename(dir,txt,/nosym)
	  if keyword_set(check) then begin
	    tmp = findfile(file,count=cnt)
	    if cnt eq 0 then begin
	      bell
	      txtmess,['File not found: ',file+'.',etxt] 
	      file = 'none'
	    end
	  endif
	  return
	end
	;-----  Directory  -----
2:	begin
          txtin, ['Change Directory.',$
                'Select one of three choices:',$
                '(1) Type in a new directory name,',$
                '(2) Type a period (.) to switch to current directory,',$
                '(3) Press RETURN to keep same directory.'],$
                txt, def=dir
          if txt eq '.' then txt = curr
          dir = txt
          txtmenu,update='|5|7|Change directory. Now|'+dir+'|'
          is = 1        ; Make file name entry be default.
	  goto, loop
	end
	endcase
 
	end
