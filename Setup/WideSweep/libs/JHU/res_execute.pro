;-------------------------------------------------------------
;+
; NAME:
;       RES_EXECUTE
; PURPOSE:
;       Process an executable res file.
; CATEGORY:
; CALLING SEQUENCE:
;       res_execute, res
; INPUTS:
;       res = Name of executable res file.  in
;         An executable res file contains data and also one or
;         more blocks of IDL code that may be executed.  The IDL
;         code can access and use the data from the res file.
;         By default the first code block to be found, if any,
;         will be executed.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEBUG list each command that is executed.
;         /LIST means list res file contents and code to execute.
;           Code will not be executed.
;         SET=set specify a code set name if other than IDLCODE.
;           Any other name is added to IDLCODE_. Examples
;           SET='image' gives IDLCODE_IMAGE,
;           SET='plot' gives IDLCODE_PLOT
;           This specifies the code block to execute, /LIST,
;           /UPDATE, or /DROP.
;         /UPDATE means update the specified code block with new
;           code.  The new may be pasted into a text area.
;         NEW=new May give new code for /UPDATE instead of pasting.
;         /DROP drop the specified code set from the res file.
;         CODE=code Returned code (/LIST or execute only).
;         Values may be passed in as keywords.  The executed
;           code must deal with undefined values.  This allows
;           some run-time control of the code execution.
;           Any such values are available under the variable name
;           used as the keyword, so do not abbreviate, the names
;           must match those used in the code.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Code may be added to a res file using /UPDATE.
;           The IDL code is in a text array and saved under
;           the tag IDLCODE or IDLCODE_set where set is a name as
;           described above.  It must be a set of IDL statements
;           (not a procedure).  Data may be read from the res file
;           using resget, the code should assume it is already open.
;           The code in a set may call another code set:
;             code_block: set
;           where set is the full set name. May nest such calls
;           but do not recurse or do a closed loop of blocks.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Feb 03
;       R. Sterner, 2005 Feb 07 --- Added more keywords.
;       R. Sterner, 2005 Feb 08 --- Can pass variables in by keyword.
;       Also allow nested calls to code blocks.
;       R. Sterner, 2007 Feb 06 --- Merged continued code lines.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-------------------------------------------------------------
;	res_execute_merge = Merge continued lines in code
;-------------------------------------------------------------
	pro res_execute_merge, in, out
 
	out = ['']		; Output array.
	n = n_elements(in)	; Lines in input array.
	mode = 0		; Mode: 0=copy, 1=continue.
 
	for i=0,n-1 do begin			; Loop over input lines.
	  t = in[i]				; Next input line.
	  if mode eq 0 then begin		; Copy mode.
	    lst = strmid(t,0,1,/rev)		; Look for trailing $.
	    if lst eq '$' then begin		; Found trailing $.
	      t = strmid(t,0,strlen(t)-1)	; Trim it off.
	      mode = 1				; Set mode to continue.
	    endif
	    bld = t				; Start building command.
	  endif else begin			; Continue mode.
	    lst = strmid(t,0,1,/rev)		; Look for trailing $.
	    if lst eq '$' then begin		; Found trailing $.
	      t = strmid(t,0,strlen(t)-1)	; Trim it off.
	    endif else mode=0			; Continue mode done.
	    bld = bld + t			; Start building command.
	  endelse
	  if mode eq 0 then out = [out,bld]  
	endfor
 
	out = out[1:*]
 
	end
 
 
;-------------------------------------------------------------
;	res_execute_addcode = Build a complete code list
;
;	Before any code is executed it is copied to a code
;	list.  This allows other code blocks to be dropped
;	into the code stream.  Using a routine to copy
;	the code allows nested references to code blocks
;	to any depth (deep enough).  Don't try recursive
;	calls, that won't work since nothing is being
;	executed yet (IDL may lock up).  For the same reason
;	two blocks may not call each other or any other kind
;	of closed loop.  The intention is to allow setup, or
;	anything more than one code block could share.
;-------------------------------------------------------------
	pro res_execute_addcode, code, clist
 
	for i=0, n_elements(code)-1 do begin		; Loop through lines.
	  cmd = code(i)					; Next line of code.
	  w1 = strupcase(getwrd(cmd, del=':'))		; Check first word.
	  if w1 eq 'CODE_BLOCK' then begin		; Was it a code block?
	    set = strupcase(getwrd(cmd, 1, del=':'))	; Yes, get block name.
	    tag = 'IDLCODE_'+set			; RES file tag name.
	    resget,tag,code2,err=err			; Try to read block.
	    if err ne 0 then begin			; Block not found.
	      print,' Error in res_execute: Tried to call an unknown'
	      print,'   code block: '+set
	      stop
	    endif
	    res_execute_merge, code2, code3		; Merge any continued.
	    res_execute_addcode, code3, clist		; Add new block to list.
	  endif else begin
	    clist = [clist, cmd]			; Add next line of code.
	  endelse
	endfor
 
	end
 
 
;-------------------------------------------------------------
;	res_execute = main routine
;-------------------------------------------------------------
	pro res_execute, res, list=list, help=hlp, $
	    update=update, drop=drop, set=set, new=new, code=code, $
	    debug=debug, _extra=extra
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Process an executable res file.'
	  print,' res_execute, res'
	  print,'   res = Name of executable res file.  in'
	  print,'     An executable res file contains data and also one or'
	  print,'     more blocks of IDL code that may be executed.  The IDL'
	  print,'     code can access and use the data from the res file.'
	  print,'     By default the first code block to be found, if any,'
	  print,'     will be executed.'
	  print,' Keywords:'
	  print,'   /DEBUG list each command that is executed.'
	  print,'   /LIST means list res file contents and code to execute.'
	  print,'     Code will not be executed.'
	  print,'   SET=set specify a code set name if other than IDLCODE.'
	  print,'     Any other name is added to IDLCODE_. Examples'
	  print,"     SET='image' gives IDLCODE_IMAGE,"
	  print,"     SET='plot' gives IDLCODE_PLOT"
	  print,'     This specifies the code block to execute, /LIST,'
	  print,'     /UPDATE, or /DROP.'
	  print,'   /UPDATE means update the specified code block with new'
	  print,'     code.  The new may be pasted into a text area.'
	  print,'   NEW=new May give new code for /UPDATE instead of pasting.'
	  print,'   /DROP drop the specified code set from the res file.'
	  print,'   CODE=code Returned code (/LIST or execute only).'
	  print,'   Values may be passed in as keywords.  The executed'
	  print,'     code must deal with undefined values.  This allows'
	  print,'     some run-time control of the code execution.'
	  print,'     Any such values are available under the variable name'
	  print,'     used as the keyword, so do not abbreviate, the names'
	  print,'     must match those used in the code.'
	  print,' Notes: Code may be added to a res file using /UPDATE.'
	  print,'     The IDL code is in a text array and saved under'
	  print,'     the tag IDLCODE or IDLCODE_set where set is a name as'
	  print,'     described above.  It must be a set of IDL statements'
	  print,'     (not a procedure).  Data may be read from the res file'
	  print,'     using resget, the code should assume it is already open.'
	  print,'     The code in a set may call another code set:'
	  print,'       code_block: set'
	  print,'     where set is the full set name. May nest such calls'
	  print,'     but do not recurse or do a closed loop of blocks.'
	  return
	endif
 
	;---------------------------------------
	;  Update or Drop an IDL code section
	;---------------------------------------
	if keyword_set(update) or keyword_set(drop) then begin
	  ;---------------------------------------
	  ;  Get new code block
	  ;---------------------------------------
	  if keyword_set(update) then begin	; If /UPDATE get new.
	    if n_elements(new) eq 0 then begin	; Allow pasted in text.
	      xtxtin,new,xsize=80,ysize=20,title='Enter new IDL code below:'
	      if new(0) eq '' then begin	; Canceled, quit.
	        print,' No update to res file.'
	        return
	      endif
	    endif
	  endif
	  ;---------------------------------------
	  ;  Find an unused tmp file name
	  ;---------------------------------------
	  f = file_search('tmp*.res',count=c)	; Look for tmp*.res.
	  if c eq 0 then begin			; None.
	    tmp='tmp.res'			; Use tmp.res as tmp.
	  endif else begin			; Make an unused name.
	    len = strlen(f)			; Lengths of found names.
	    tmp = (f(where(len eq max(len))))(0)  ; Pick longest name.
	    filebreak, tmp, noext=nam		; Pick off file name.
	    tmp = nam+'_1.res'			; Add a bit to name.
	  endelse
	  ;---------------------------------------
	  ;  Open res file and get tags
	  ;---------------------------------------
	  resopen,res,fd=fdin,head=h		; Open and return header.
	  h = h(0:n_elements(h)-2)		; Drop trailing END.
	  tags = h				; Copy.
	  for i=0,n_elements(tags)-1 do begin	; Grab 1st word and make upper.
	    tags(i) = getwrd(tags(i))
	    utags = strupcase(tags)		; Upper case tags.
	  endfor
	  ;---------------------------------------
	  ;  Deal with set
	  ;---------------------------------------
	  if n_elements(set) eq 0 then begin
	    set2 = 'IDLCODE'			; No SET keyword given.
	  endif else begin
	    if set eq '' then begin		; SET=''.
	      set2 = 'IDLCODE'
	    endif else begin			; SET=set.
	      set2 = 'IDLCODE_'+strupcase(set)
	    endelse
	  endelse
	  ;---------------------------------------
	  ;  Tags to copy
	  ;---------------------------------------
	  w = where(utags ne set2)	; Tags to keep (test on uppercase).
	  tags = tags(w)		; But use original tags.
	  h = h(w)			; Or maybe comment lines.
	  ;---------------------------------------
	  ;  Open tmp file and copy to it
	  ;---------------------------------------
	  resopen,tmp,fd=fdtmp,/write			; Open temp file.
	  for i=0,n_elements(tags)-1 do begin		; Loop through tags.
;	    t = tags(i)
	    t = strmid(tags(i),0,1)
	    if t eq '*' then begin			; Was a comment.
;	      resput,fd=fdtmp,comm=' '+getwrd(h(i),1,999) ; Copy comment.
	      resput,fd=fdtmp,comm=strmid(h(i),1,999)	; Copy comment.
	    endif else begin				; Was a tag/value pair.
	      resget,fd=fdin,tags(i),val		; Grab value.
	      resput,fd=fdtmp,tags(i),val		; Copy value.
	    endelse
	  endfor
	  resclose, fd=fdin				; Done with input file.
	  ;---------------------------------------
	  ;  Write new code block
	  ;---------------------------------------
	  if keyword_set(update) then begin		; Only write if update.
	    resput,fd=fdtmp,set2,new			; New code block.
	    action = 'updated'
	  endif else action='dropped'
	  resclose,fd=fdtmp
	  file_move, tmp, res, /overwrite	; Rename copy.
	  print,' Code block '+action+': '+set2+' in '+res
	  return
	endif
 
	;---------------------------------------
	;  Open res file
	;---------------------------------------
	resclose,/quiet				; In case it was open.
	resopen, res, err=err, head=h, /quiet	; Open and get the header.
	if err ne 0 then return			; Abort if open error.
 
	;---------------------------------------
	;  Deal with set
	;---------------------------------------
	if n_elements(set) eq 0 then begin	; SET was not specified.
	  set2 = 'IDLCODE'			; Default set name.
	endif else begin			; SET was specified.
	  if set eq '' then begin		; As a null string, use def.
	    set2 = 'IDLCODE'
	  endif else begin			; Actual set name.
	    set2 = 'IDLCODE_'+strupcase(set)	; Add tag front end.
	  endelse
	endelse
 
	;---------------------------------------
	;  Get IDL code
	;---------------------------------------
	resget,set2,code,full=full,err=err	; Try to read the code block.
	if err ne 0 then code_flag=0 else code_flag=1	; Did it exist?
 
	;---------------------------------------
	;  List
	;---------------------------------------
	if keyword_set(list) then begin
	  resclose				; Nothing more needed from file.
	  more,h,/n,lines=100			; List file contents.
	  print,' '
	  print,' IDL code ('+full+'):'		; List code to be executed.
	  if code_flag eq 0 then begin
	    print,' No code block found.'
	  endif else begin
	    more,' '+code,lines=100
	  endelse
	  return
	endif
 
	;---------------------------------------
	;  Set any keywords passed in
	;---------------------------------------
	nvar = n_tags(extra)		; How many values passed in?
	if nvar gt 0 then begin		; There were some.
	  etags=tag_names(extra)	; Grab variable names, then set values.
	  for _i=0,nvar-1 do err=execute(etags(_i)+'=extra.(_i)')
	endif
 
	;---------------------------------------
	;  Build complete code list
	;---------------------------------------
	clist = ''				; Complete code list.
	res_execute_merge, code, code2		; Merge any continued lines.
	res_execute_addcode, code2, clist	; Add code to clist.
 
	;---------------------------------------
	;  Execute IDL code
	;---------------------------------------
	for _i=0, n_elements(clist)-1 do begin	; Execute complete code list.
	  if keyword_set(debug) then print,clist(_i)
	  err = execute(clist(_i))
	  if err eq 0 then begin
	    stop,' STOP: Error executing '+clist(_i)
	  endif
	endfor
 
	resclose
 
	end
