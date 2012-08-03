;-------------------------------------------------------------
;+
; NAME:
;       HLP2
; PURPOSE:
;       Variant of HELP.  Gives array min, max.
; CATEGORY:
; CALLING SEQUENCE:
;       hlp, a1, [a2, ..., a9]
; INPUTS:
;       a1, [...] = input variables.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         NP=np # arguments sent (def=automatic).
;         OUT=out Returned name and description text.
;         DES=des Returned description text.
;         /QUIET  Do not print anything.
;         /STRUCT Expand structures.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Must use IDL 6.1 or later.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Apr 27
;       R. Sterner, 2005 Apr 29 --- Made callable from hlp.
;       R. Sterner, 2005 Apr 29 --- Added /QUIET, OUT=out.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hlp2, a1, a2, a3, a4, a5, a6, a7, a8, a9, np=np, $
	  quiet=quiet, out=out, des=des, structure=struct, help=hlp
 
        if (n_params(0) lt 1) or keyword_set(hlp) then begin
          print,' Variant of HELP.  Gives array min, max.'
          print,' hlp, a1, [a2, ..., a9]'
          print,'   a1, [...] = input variables.    in'
	  print,' Keywords:'
	  print,'   NP=np # arguments sent (def=automatic).'
	  print,'   OUT=out Returned name and description text.'
	  print,'   DES=des Returned description text.'
	  print,'   /QUIET  Do not print anything.'
	  print,'   /STRUCT Expand structures.'
	  print,' Note: Must use IDL 6.1 or later.'
          return
        endif
 
	lv = -2
	if n_elements(np) eq 0 then begin
	  np = n_params(0)<9 ; How many args?
	  lv = -1
	endif
 
	out = ['']
 
        for k = 1, np do begin		; Loop through all args.
 
	  out = [out,' ']		; Blank before new var. 
	  des = 'Undefined'		; Assume this.
 
	  ;============================================
	  ;  Version 6.1 or later
	  ;============================================
	  case k of
1:	  begin
	    nam = scope_varname(a1,lev=lv,count=c)
	    if n_elements(a1) eq 0 then goto, skip
	    a = a1
	  end
2:	  begin
	    nam = scope_varname(a2,lev=lv,count=c)
	    if n_elements(a2) eq 0 then goto, skip
	    a = a2
	  end
3:	  begin
	    nam = scope_varname(a3,lev=lv,count=c)
	    if n_elements(a3) eq 0 then goto, skip
	    a = a3
	  end
4:	  begin
	    nam = scope_varname(a4,lev=lv,count=c)
	    if n_elements(a4) eq 0 then goto, skip
	    a = a4
	  end
5:	  begin
	    nam = scope_varname(a5,lev=lv,count=c)
	    if n_elements(a5) eq 0 then goto, skip
	    a = a5
	  end
6:	  begin
	    nam = scope_varname(a6,lev=lv,count=c)
	    if n_elements(a6) eq 0 then goto, skip
	    a = a6
	  end
7:	  begin
	    nam = scope_varname(a7,lev=lv,count=c)
	    if n_elements(a7) eq 0 then goto, skip
	    a = a7
	  end
8:	  begin
	    nam = scope_varname(a8,lev=lv,count=c)
	    if n_elements(a8) eq 0 then goto, skip
	    a = a8
	  end
9:	  begin
	    nam = scope_varname(a9,lev=lv,count=c)
	    if n_elements(a9) eq 0 then goto, skip
	    a = a9
	  end
	  endcase
	 
	  if nam eq '' then nam='Expression'
	  t = datatype(a,1)
 
	  if keyword_set(struct) and (t eq 'Structure') then begin
	    hlpst, a, out=txt, /quiet, tag=nam(0)
	    out = [out,txt]
	    goto, skip2
	  endif
 
	  des = datatype(a,/desc)
	  if strlen(des) lt 15 then des=string(des,form='(A-15)')
	  if isarray(a) then begin
            if (t ne 'String') and (t ne 'Complex') and $
	       (t ne 'Pointer') and (t ne 'Object') and $
	       (t ne 'Structure') then begin
              if t eq 'Byte' then begin
                mn = min(fix(a),max=mx)
              endif else begin
                mn = min(a,max=mx)
              endelse
              mn = strtrim(mn,2)
              mx = strtrim(mx,2)
              des = des + '   Min = '+mn+',  Max = '+mx
            endif
	  endif
 
skip:	  vnam = nam
	  if strlen(nam) lt 10 then vnam=string(nam,form='(A10)')  
	  out = [out,' '+vnam+':  '+des]
skip2:
 
	endfor
 
	out = out(1:*)
	if not keyword_set(quiet) then more,out, lines=100
 
	end
