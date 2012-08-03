;-------------------------------------------------------------
;+
; NAME:
;       ARG_PARSE
; PURPOSE:
;       Parse an argument list into positional and keyword args.
; CATEGORY:
; CALLING SEQUENCE:
;       arg_parse, txt, out
; INPUTS:
;       txt = Argument list in a scalar text string.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         KEYABB=abb  Array of minimum allowed length keyword names.
;         KEYDEF=def  Array of keyword default values.
;         KEYFULL=ful Array of full keyword names.
;           These 3 optional arrays must be the same size.
;         /KEYMERGE Merge repeated keywords, concatenate values.
;         /UNSORT   Return keyword names and values in original
;           unsorted order given.  Not allowed with /KEYMERGE.
;         NPARAMS=n  Number of positional parameters to expect.
;           This is an input value to allow additional checking.
;         ERROR=err  Error flag: 0=ok.
;         Keywords given in KEYABB and KEYDEF are added to the
;         returned list if they were not in the arg list.
;         If KEYFULL is given the names there are used for keytag.
;         This allows names to be forced to known values.
;         Arg list keywords not in these lists are not renamed.
;         KEYABB and KEYDEF must be given to use KEYFULL.
;         All arguments should be constants, not variables or
;         expressions, and be separated by commas.  Returned values
;         (positional or keyword) are strings.  Multiword string
;         values may be given, don't use quotes.  For example:
;         txt = '10,20,a b c,30,x=1,y=2,t=oct 16,z=3'
; OUTPUTS:
;       out = Returned args in a structure.           out
;          out = { npos:npos, pos:posval, nkeys:nkeys, $
;                  keytag:ktag, keyval:kval }
;            npos = Number of positional args.
;            posval = List of positional arg values.
;            nkeys = Number of keyword args.
;            ktag = List of keyword names.  Sorted by name.
;            kval = List of keyword values. Sorted by name.
;              pos, keytag, and kayval are all string arrays.
; COMMON BLOCKS:
; NOTES:
;       Notes: Flags are considered keywords (with value=1).
;         Example input arg list:
;         txt = '0, 100, 50, /int, frame=2, color=255'
;         In the returned structure out, pos would be the
;         text array ['0','100','50'].  keytag would be the
;         text array ['color','frame','int'].  keyval would be the
;         text array ['255','2','1'].
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Oct 18
;       R. Sterner, 2006 Oct 20 --- Added NPARAMS=np, ERROR=err.
;       R. Sterner, 2006 Oct 24 --- Fixed error in processing keywords.
;       R. Sterner, 2006 Dec 05 --- Repeated keywords now forced to full name.
;       R. Sterner, 2006 Dec 05 --- Keyword values now not trimmed, so leading
;       or trailing spaces are kept.
;       R. Sterner, 2006 Dec 05 --- Repeated keywords may be merged.
;       R. Sterner, 2007 Jun 12 --- Added /UNSORT (not allowed with /keymerge).
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro arg_parse, txt,out,keyabb=abb0,keydef=def,keyfull=ful0, $
	  nparams=nparams, error=err, keymerge=keymerge, $
	  unsort=unsort, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Parse an argument list into positional and keyword args.'
	  print,' arg_parse, txt, out'
	  print,'   txt = Argument list in a scalar text string.  in'
	  print,'   out = Returned args in a structure.           out'
	  print,'      out = { npos:npos, pos:posval, nkeys:nkeys, $'
	  print,'              keytag:ktag, keyval:kval }'
	  print,'        npos = Number of positional args.'
	  print,'        posval = List of positional arg values.'
	  print,'        nkeys = Number of keyword args.'
	  print,'        ktag = List of keyword names.  Sorted by name.'
	  print,'        kval = List of keyword values. Sorted by name.'
	  print,'          pos, keytag, and kayval are all string arrays.'
	  print,' Keywords:'
	  print,'   KEYABB=abb  Array of minimum allowed length keyword names.'
	  print,'   KEYDEF=def  Array of keyword default values.'
	  print,'   KEYFULL=ful Array of full keyword names.'
	  print,'     These 3 optional arrays must be the same size.'
	  print,'   /KEYMERGE Merge repeated keywords, concatenate values.'
	  print,'   /UNSORT   Return keyword names and values in original'
	  print,'     unsorted order given.  Not allowed with /KEYMERGE.'
	  print,'   NPARAMS=n  Number of positional parameters to expect.'
	  print,'     This is an input value to allow additional checking.'
	  print,'   ERROR=err  Error flag: 0=ok.'
	  print,' Notes: Flags are considered keywords (with value=1).'
	  print,'   Example input arg list:'
	  print,"   txt = '0, 100, 50, /int, frame=2, color=255'"
	  print,"   In the returned structure out, pos would be the"
	  print,"   text array ['0','100','50'].  keytag would be the"
	  print,"   text array ['color','frame','int'].  keyval would be the"
	  print,"   text array ['255','2','1']."
	  print,'   Keywords given in KEYABB and KEYDEF are added to the'
	  print,'   returned list if they were not in the arg list.'
	  print,'   If KEYFULL is given the names there are used for keytag.'
	  print,'   This allows names to be forced to known values.'
	  print,'   Arg list keywords not in these lists are not renamed.'
	  print,'   KEYABB and KEYDEF must be given to use KEYFULL.'
	  print,'   All arguments should be constants, not variables or'
	  print,'   expressions, and be separated by commas.  Returned values'
	  print,'   (positional or keyword) are strings.  Multiword string'
	  print,"   values may be given, don't use quotes.  For example:"
	  print,"   txt = '10,20,a b c,30,x=1,y=2,t=oct 16,z=3'"
	  return
	endif
 
	;----------------------------------------------------
	;  Split input into args
	;----------------------------------------------------
	wordarray,txt,t,del=','		; Args delimited by commas.
	t = strtrim(t,2)		; Drop any leading and trailing space.
	t = drop_comments(t,/q)		; Drop any null lines.
	n_flg = 0			; Assume none to start.
	n_key = 0
	n_pos = 0
	if (n_elements(t) eq 1) and (t(0) eq '') then begin  ; NULL string in.
	  out = {npos:0, pos:[0], nkeys:0, kaytag:[''], keyval:[0]}
	  return
	endif
	ktag = ['']			; Start arrays.
	kval = ['']
 
	;----------------------------------------------------
	;  Separate any flags
	;----------------------------------------------------
	strfind, t, '^/', $             ; Find / at front of string.
	  ind=w, count=n_flg, $         ; Indices and count.
	  iind=iw, icount=n, /q		; Indices and count of what's left.
	if n_flg gt 0 then begin        ; Extract flags if any.
	  flags = t(w)                  ; Flag keywords.
	  ktag = [ktag,strmid(flags,1,99)]  ; Flag keywords.
	  kval = [kval,strarr(n_flg)+'1']   ; Flag keyword values.
	endif
	if n gt 0 then t=t(iw)		; Drop from list.
 
	;----------------------------------------------------
	;  Separate any keywords and positional args
	;----------------------------------------------------
	err = 0
	if n gt 0 then begin
	  strfind, t, '.*=.*', $          ; Find = inside item.
	    ind=w, count=n_key, $         ; Indices and count.
	    iind=iw, icount=n_pos, /q     ; Indices and count of what's left.
	  if n_key gt 0 then begin        ; Extract keywords if any.
	    keys = t(w)                   ; Keywords.
	    for i=0,n_key-1 do begin	  ; Pick apart tags and values.
	      ktag = [ktag,getwrd(keys(i),0,del='=')]
	      kval = [kval,getwrd(keys(i),1,del='=',/notrim)]
	    endfor
	  endif
	  if n_pos gt 0 then begin        ; What's left is positional args.
	    posval = t(iw)                ; Positional args.
	  endif else begin
	    posval = ''
	  endelse
	  if n_elements(nparams) gt 0 then begin
	    if n_pos lt nparams then begin
	      print,' Error in arg_parse: Too few positional args.'
	      print,'   Check input text, look for missing commas.'
	      err = 1
	    endif
	    if n_pos gt nparams then begin
	      print,' Error in arg_parse: Too many positional args.'
	      print,'   Check input text.'
	      err = 1
	    endif
	  endif
	endif
 
	;----------------------------------------------------
	;  Fix keyword names and add defaults
	;
	;  Can specify a list of abbreviated keywords,
	;  KEYABB=abb, a list of default values, KEYDEF=def,
	;  and a list of full keywords, KEYFULL=ful.
	;  If abb and def are given (must be same length)
	;  any keywords not in arg list are added with their
	;  default values.  If ful is also given the keyword
	;  names are changed to the full names.
	;----------------------------------------------------
	ktag = strupcase(ktag)			; Force keywords uppercase.
	n_abb = n_elements(abb0)		; Array sizes.
	n_def = n_elements(def)
	n_ful = n_elements(ful0)
	if n_ful gt 0 then ful=strupcase(ful0)	; Force uppercase if exists.
	if (n_abb eq n_def) and (n_abb gt 0) then begin
	  abb = strupcase(abb0)			; Force uppercase.
	  for i=0, n_abb-1 do begin		; Search for each tag in abb.
	    abbi = abb(i)
	    len = strlen(abbi)
	    ktst = strmid(ktag,0,len)
	    w = where(abbi eq ktst, cnt)
	    if cnt gt 0 then begin		; Have abb tag in current list.
	      if n_ful gt 0 then begin
	        for j=0,cnt-1 do begin		; Allow repeated keywords.
	          ktag(w(j)) = ful(i)		; Use full keyword if given.
	        endfor
	      endif
	    endif else begin			; Abb tag not in current list.
	      if n_ful gt 0 then $		; Add using full keyword if
	        new=ful(i) else new=abbi	; given, else min keyword.
	      ktag = [ktag, new]		; Add new tag.
	      kval = [kval, def(i)]		; and default value.
	    endelse
	  endfor ; i
	endif
 
	;----------------------------------------------------
	;  Sort and optionally merge keywords
	;----------------------------------------------------
	if n_elements(ktag) gt 1 then begin
	  ktag = ktag[1:*]			; Drop initial null string.
	  kval = kval[1:*]
	  is = sort(ktag)			; Sort by keyword name.
	  ktag = ktag(is)
	  kval = kval(is)
	  n_key = n_elements(kval)		; Number of keywords.
	  if keyword_set(keymerge) then begin	; Merge repeated keywords.
	    ktag1 = [ktag,'']			; Copy with a null added.
	    ktag2 = ['']			; Start merged keywords.
	    kval2 = ['']			; Start merged values.
	    vlst = ''				; Last value, start NULL.
	    for i=0, n_key-1 do begin		; Loop through keywords.
	      t = ktag[i]			; Next keyword.
	      v = vlst + kval[i]		; Next value.
	      if t ne ktag1[i+1] then begin	; NOT REPEATED keyword.
	        ktag2 = [ktag2,t]		; Output keyword.
	        kval2 = [kval2,v]		; Output value.
	        vlst = ''			; Clear last value.
	      endif else begin			; REPEATED keyword.
	        vlst = v			; Update last value.
	      endelse
	    endfor ; i
	    ktag = ktag2[1:*]			; Drop initial null string.
	    kval = kval2[1:*]
	    n_key = n_elements(kval)		; Update number of keywords.
	  endif
	endif
 
	;----------------------------------------------------
	;  Optionally unsort keywords
	;----------------------------------------------------
	if keyword_set(unsort) then begin
	  if keyword_set(keymerge) then begin
	    print,' Error in arg_parse: /UNSORT not allowed with /KEYMERGE.'
	    print,'   /UNSORT ignored.'
	    err = 1
	  endif else begin	; Unsort.
	    ktag2 = ktag	; Copy.
	    kval2 = kval
	    ktag[is] = ktag2	; Insert in unsorted order.
	    kval[is] = kval2
	  endelse
	endif
 
	;----------------------------------------------------
	;  Pack up returned structure
	;----------------------------------------------------
	out = { npos:n_pos, pos:posval, nkeys:n_key, keytag:ktag, keyval:kval }
 
	end
