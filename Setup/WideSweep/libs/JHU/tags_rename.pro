;-------------------------------------------------------------
;+
; NAME:
;       TAGS_RENAME
; PURPOSE:
;       Rename tags in a structure.
; CATEGORY:
; CALLING SEQUENCE:
;       s2 = tags_rename(s1,list)
; INPUTS:
;       s1 = Input structure.                       in
;       list = List of old and new tag names.       in
;         Text array or name of text file with list.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag: 0=ok.
; OUTPUTS:
;       s2 = Returned structure with new tag names. out
; COMMON BLOCKS:
; NOTES:
;       Notes: The text array given in list must have as
;       many elements as tags in the structure.
;       There are two allowed forms for the list:
;         1. Just give the new tag names.  In this case
;            the order must match the order in the structure.
;         2. Give the old name followed by the new.  In this
;            case the order need not be known but this
;            is slightly less efficient.
;       May give in list the name of a text file containing
;       one of the two allowed forms of the list instead of
;       giving the list itself.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 14
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tags_rename, s1, list0, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Rename tags in a structure.'
	  print,' s2 = tags_rename(s1,list)'
	  print,'   s1 = Input structure.                       in'
	  print,'   list = List of old and new tag names.       in'
	  print,'     Text array or name of text file with list.'
	  print,'   s2 = Returned structure with new tag names. out'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag: 0=ok.'
	  print,' Notes: The text array given in list must have as'
	  print,' many elements as tags in the structure.'
	  print,' There are two allowed forms for the list:'
	  print,'   1. Just give the new tag names.  In this case'
	  print,'      the order must match the order in the structure.'
	  print,'   2. Give the old name followed by the new.  In this'
	  print,'      case the order need not be known but this'
	  print,'      is slightly less efficient.'
	  print,' May give in list the name of a text file containing'
	  print,' one of the two allowed forms of the list instead of'
	  print,' giving the list itself.'
	  return,''
	endif
 
	err = 0
 
	;----------------------------------------------
	;  Get list of old new name pairs
	;
	;  May read from a file or just give list.
	;  List may be just the new names, or the
	;  old and new (if order not known).
	;  Below, flag=1 for just NEW,
	;  flag=2 for OLD NEW pairs.
	;----------------------------------------------
	if n_elements(list0) eq 1 then begin	; Was list a file name?
	  list = getfile(list0)			; Yes, read list from file.
	endif else begin
	  list = list0				; No, just copy list.
	endelse
	list = strupcase(list)			; Work in uppercase.
	nlist = n_elements(list)		; Length of list.
	flag = nwrds(list(0))			; OLD & NEW or just OLD?
	if (flag lt 1) or (flag gt 2) then begin
	  print,' Error in tags_rename: The given list must'
	  print,' have 1 or 2 names on each line.  Each line'
	  print,' must have the same number of names.'
	  err = 1
	  return,''
	endif
	if flag eq 2 then begin			; Gave OLD NEW pairs.
	  old = strarr(nlist)			; Space for old and new tags.
	  new = strarr(nlist)
	  for i=0,nlist-1 do begin		; Grab old and new tags.
	    old(i) = getwrd(list(i),0)
	    new(i) = getwrd(list(i),1)
	  endfor
	endif else new=list			; Gave only new tag names.
 
	;----------------------------------------------
	;  Get structure tag names
	;----------------------------------------------
	tags = tag_names(s1)
	ntags = n_elements(tags)
	if ntags ne nlist then begin
	  print,' Error in tags_rename: Must give a list with as many'
	  print,'   old new name pairs as tags in structure.  Given'
	  print,'   structure has '+strtrim(ntags,2)+' tag'+plural(ntags)+','
	  print,'   given list has '+strtrim(nlist,2)+' pair'+plural(nlist)+'.'
	  err = 1
	  return, ''
	endif
 
	;----------------------------------------------
	;  Copy items to a new structure
	;----------------------------------------------
	case flag of
1:	begin					; NEW only given.
	  s2 = create_struct(new(0),s1.(0))	; Start output structure.
	  for i=1,ntags-1 do begin		; Add each item.
	    s2 = create_struct(s2,new(i),s1.(i))
	  endfor
	end
2:	begin					; Both OLD and NEW given.
	  w = where(tags eq old(0),cnt)		; Find tag name.
	  if cnt eq 0 then begin
	    print,' Error in tags_rename: Old tag name not found: '+old(0)
	    err = 1
	    return, ''
	  endif
	  j = w(0)
	  s2 = create_struct(new(0),s1.(j))	; Start output structure.
	  for i=1,ntags-1 do begin		; Add each item.
	    w = where(tags eq old(i),cnt)	; Find tag name.
	    if cnt eq 0 then begin
	      print,' Error in tags_rename: Old tag name not found: '+old(i)
	      err = 1
	      return, ''
	    endif
	    j = w(0)
	    s2 = create_struct(s2,new(i),s1.(j))
	  endfor
	end
	endcase
	return, s2
 
	end
