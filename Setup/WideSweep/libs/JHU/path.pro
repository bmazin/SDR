;-------------------------------------------------------------
;+
; NAME:
;       PATH
; PURPOSE:
;       Examine and modify the IDL path.
; CATEGORY:
; CALLING SEQUENCE:
;       path, new
; INPUTS:
;       new = new path name to add to existing path.     in
;         Ignored if already in path.  May be a string array
;         of new paths.  May also give a single path with
;         leading +, this will be expanded to include all
;         subdirectories with *.pro files.
; KEYWORD PARAMETERS:
;       Keywords:
;         /LAST forces new path to be added to end of existing
;            path instead of front which is default.
;         /LIST displays a numbered list of all the paths.
;           path with no arguments is the same as path,/list.
;         /RESET restores initial path (found on first call).
;         /INIT save current path.  /RESET will restore it.
;         FRONT=n move the n'th directory to the front.
;           FRONT may also be a string, a regular expression
;           to match and move to front.  Ex: "abc$" matches
;           abc at end of path. NOTE for Windows: make sure to
;           double any backslashes (for stregex),
;         REMOVE=n remove the n'th directory from the path.
;           n may also be a string, items with it will be dropped.
;           Be careful with the string option.  If given 'map' then
;           any directories with 'map' will be removed, like 'map',
;           'map2',...  Use 'map$' to remove just the one ending in
;           'map', or whatever gives the correct match.
;         PATHARRAY=txt  Return in a text array directories on path.
; OUTPUTS:
; COMMON BLOCKS:
;       path_com
; NOTES:
;       Notes: can use paths like ../xxx or [-.xxx] as a shortcut.
;         Useful to turn on & off libraries of IDL routines.
; MODIFICATION HISTORY:
;       R. Sterner, 20 Sep, 1989
;       R. Sterner, 24 Sep, 1991 --- Added DOS.
;       R. Sterner, 24 Jan, 1994 --- Added MACOS.
;       R. Sterner, 2000 Sep 20 --- Dropped DOS, added WINDOWS.
;       Kristian Kjær (Kristian.Kjaer@risoe.dk) requested WINDOWS
;       and the use of !version.os_family.
;       KK          18 Apr  2001 --- Added patharray=patharray
;       R. Sterner, 2002 Feb 18 --- Added the REMOVE=n keyword.
;       R. Sterner, 2002 Sep 19 --- Allowed FRONT to be a string.  Added /INIT.
;       R. Sterner, 2002 Dec 18 --- Add new only if not there.
;       R. Sterner, 2002 Dec 23 --- Upgraded remove.
;       R. Sterner, 2003 Jan 29 --- Fixed add new, cleaned up some.
;       R. Sterner, 2003 Feb 27 --- Cleaned up some.
;       R. Sterner, 2003 Mar 04 --- Fixed leading : problem.
;       R. Sterner, 2004 Oct 14 --- Allowed array of paths, also leading +.
;       R. Sterner, 2006 Mar 21 --- Noted Windows double backslash for FRONT=.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro path, in0, help=hlp, last=aftr, reset=rst, list=lst, front=front, $
                  patharray=patharray, remove=remove, init=init
 
	common path_com, firstpath
 
	if keyword_set(hlp) then begin
	  print,' Examine and modify the IDL path.'
	  print,' path, new'
	  print,'   new = new path name to add to existing path.     in'
	  print,'     Ignored if already in path.  May be a string array'
	  print,'     of new paths.  May also give a single path with'
	  print,'     leading +, this will be expanded to include all'
	  print,'     subdirectories with *.pro files.'
	  print,' Keywords:'
	  print,'   /LAST forces new path to be added to end of existing'
	  print,'      path instead of front which is default.'
	  print,'   /LIST displays a numbered list of all the paths.'
	  print,'     path with no arguments is the same as path,/list.'
	  print,'   /RESET restores initial path (found on first call).'
	  print,'   /INIT save current path.  /RESET will restore it.'
	  print,"   FRONT=n move the n'th directory to the front."
	  print,'     FRONT may also be a string, a regular expression'
	  print,'     to match and move to front.  Ex: "abc$" matches'
	  print,'     abc at end of path. NOTE for Windows: make sure to'
	  print,'     double any backslashes (for stregex),'
	  print,"   REMOVE=n remove the n'th directory from the path."
	  print,'     n may also be a string, items with it will be dropped.'
	  print,"     Be careful with the string option.  If given 'map' then"
	  print,"     any directories with 'map' will be removed, like 'map',"
	  print,"     'map2',...  Use 'map$' to remove just the one ending in"
	  print,"     'map', or whatever gives the correct match."
	  print,'   PATHARRAY=txt  Return in a text array directories on path.'
	  print,' Notes: can use paths like ../xxx or [-.xxx] as a shortcut.'
	  print,'   Useful to turn on & off libraries of IDL routines.'
	  return
	endif
 
	if n_elements(firstpath) eq 0 then firstpath = !path
 
	os = strupcase(!version.os_family)
	case os of
'VMS':        delim = ','
'WINDOWS':    delim = ';'
'MACOS':      delim = ','
else:	      delim = ':'
	endcase
 
	flag = 0				; Any operations done?
 
	;--------  Add new item to path  ----------
	if n_params(0) gt 0 then begin
	  in1 = in0				; Copy in list.
	  if strmid(in1(0),0,1) eq '+' then begin  ; Include subdirs with *.pro?
	    tmp = expand_path(in1(0))		; Recurse down.
	    wordarray,tmp,in1,del=delim		; Break !path into list.
	  endif
	  wordarray,!path,list,del=delim	; Break !path into list.
	  for i=0,n_elements(in1)-1 do begin
	    in = in1(i)				; i'th new entry.
	    w = where(in eq list, cnt)
	    if cnt eq 0 then begin		; Add only if not there.
	      if keyword_set(aftr) then begin	; Add new to end.
	        !path = !path + delim + in	
	      endif else begin			; Add new at front.
	        !path = in + delim + !path
	      endelse
	    endif
	  endfor
	  flag = 1
	endif
 
	;---------  Reset to original path  ---------
	if keyword_set(rst) then begin
	  !path = firstpath
	   flag= 1
	endif
 
	;---------  Save current path  ---------
	if keyword_set(init) then begin
	  firstpath = !path
	  flag = 1
	endif
 
	;---------  Break path into a text array  -----------
	if arg_present(patharray) then begin
	  wordarray,!path,patharray,del=delim	; Break !path into list.
	  flag = 1
	endif
 
	;--------  Move a path item to front  ----------------
	if n_elements(front) ne 0 then begin
	  ;-----  Break !path into elements  ---------
	  wordarray,!path,new,del=delim,num=nw	; Break !path into list.
	  ;-----  Find which number to move to front  ------
	  if isnumber(front) eq 1 then begin	; front is an index number.
	    n = front - 1
	  endif else begin			; front is a string.
	    strfind,new,front,index=n,/quiet,count=cnt
	    if cnt eq 0 then begin		; No such string.
	      print,' Error in path: could not move to front.'
	      print,'   String not found: '+front
	      return
	    endif
	    if cnt gt 1 then begin
	      print,' Error in path: could not move to front.'
	      print,'   String ambiguous: '+front
	      return
	    endif
	    n = n(0)				; Index # to move.
	  endelse
	  ;-----  Move it  -------------
	  new = [new(n), new(where(indgen(nw) ne n))]
	  txt = new(0)
	  for i = 1, nw-1 do txt = txt + delim + new(i)
	  !path = txt
	  flag = 1
	endif
 
	;---------  Remove an item from path  ----------
	if n_elements(remove) ne 0 then begin
	  ;-----  Break !path into elements  ---------
	  wordarray,!path,arr,del=delim	; Break !path into list.
	  ;-----  Find which items to remove ------
	  if isnumber(remove) eq 1 then begin	; remove is an index number.
	    n = remove-1			; Directory to remove.
	    nw = n_elements(arr)	; # directories.
	    in = indgen(nw)		; Indices of directories.
	    w = where(in ne n, cnt)	; Find all directories to keep.
	  endif else begin		; remove is a substring.
	    strfind,arr,remove,/inverse,index=w,/quiet,count=cnt
	  endelse
	  ;------  Extract elements to keep  --------
	  if cnt gt 0 then begin	; If any to keep ...
	    arr = arr(w)		; Pull out only the ones to keep.
	  endif
	  ;------  Build up new path  ----------
;	  txt = ''			; Start with a null string.
	  txt = arr(0)			; Start with 1st item.
	  for i = 1, cnt-1 do txt = txt + delim + arr(i)
	  !path = txt
	  flag = 1
	endif
 
	;---------  List path  -----------------------
	if (keyword_set(lst)) or (flag eq 0) then begin
	  wordarray,!path,arr,del=delim		; Break !path into list.
	  for i = 0, n_elements(arr)-1 do begin
	    print,i+1,'  ',arr(i)
	  endfor
	endif
 
	return
	end
