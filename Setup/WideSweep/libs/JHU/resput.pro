;-------------------------------------------------------------
;+
; NAME:
;       RESPUT
; PURPOSE:
;       Put values into a results file.
; CATEGORY:
; CALLING SEQUENCE:
;       resput, [name, val]
; INPUTS:
;       name = string with name to use as tag.            in
;         May mix upper and lower case for better
;         readability but readback is case
;         insensitive.  No white space allowed in name.
;       val  = variable to save.                          in
;         Name and val are not needed if writing a comment.
; KEYWORD PARAMETERS:
;       Keywords:
;         FD=fd    Optional file descriptor.  Allows multiple res
;           files to be used at once.
;         COMMENT=c give a string or string array to
;           place in the results header as comments.
;         /SCALAR means convert one element arrays to scalars.
;         ERROR=e  error code:
;           0 = OK, data written.
;           1 = File not changed.
; OUTPUTS:
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resopen, resget, rescom, resclose.
;         Must use resopen to open the file for write before
;         using resput. Also must use resclose to close file.
; MODIFICATION HISTORY:
;       R. Sterner, 19 Jun, 1991
;       R. Sterner, 13 Dec, 1992 --- increased the precision for
;       floating and double scalars.
;       R. Sterner, 1994 Mar 29 --- Made case sensitive for write.
;       R. Sterner, 1994 May 16 --- Added /SCALAR keyword.
;       R. Sterner, 1994 Jul 12 --- Added tag name check.
;       R. Sterner, 2004 Sep 27 --- Added FD=fd to give file descriptor.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro resput, name, val, comments=cmt, error=err, $
	  scalar=scalar, fd=fd, help=hlp
 
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
	  print,' Put values into a results file.'
	  print,' resput, [name, val]'
	  print,'   name = string with name to use as tag.            in'
	  print,'     May mix upper and lower case for better'
	  print,'     readability but readback is case'
	  print,'     insensitive.  No white space allowed in name.'
	  print,'   val  = variable to save.                          in'
	  print,'     Name and val are not needed if writing a comment.'
	  print,' Keywords:'
	  print,'   FD=fd    Optional file descriptor.  Allows multiple res'
	  print,'     files to be used at once.'
	  print,'   COMMENT=c give a string or string array to'
	  print,'     place in the results header as comments.'
	  print,'   /SCALAR means convert one element arrays to scalars.'
	  print,'   ERROR=e  error code:'
	  print,'     0 = OK, data written.'
	  print,'     1 = File not changed.'
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resopen, resget, rescom, resclose.'
	  print,'   Must use resopen to open the file for write before'
	  print,'   using resput. Also must use resclose to close file.'
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
 
	err = 1
	 
        ;-------  File open?  ----------
        if n_elements(r_open) eq 0 then r_open = 0
        if r_open eq 0 then begin
          print,' Error in resput: No results file is open.'
          return
        endif
        if r_open eq 1 then begin
	  bell
          print,' Error in resput: Results file '+r_file+' is open for read.'
          return
        endif
 
	;--------  Check args  ---------------
	np = n_params(0)
	if np eq 1 then begin
	  print,' Error in resput: must give both name and value.'
	  return
	endif
	if np eq 2 then begin
	  if nwrds(name) ne 1 then begin
	    print,' Error in resput: No white space allowed in name.'
	    print,'   Name must be a single item (use _ instead of space).'
	    return
	  endif
	endif
	if n_elements(r_swap) eq 0 then r_swap=0
 
	;-------  Added comment(s) to header  ---------
	if n_elements(cmt) ne 0 then begin
	  r_hdr = [r_hdr, '*'+cmt]
	  if arg_present(fd) then $
	    fd = {r_file:r_file, r_lun:r_lun, $     ; Rebuild file descriptor.
                  r_open:r_open, r_hdr:r_hdr, r_swap:r_swap}
	endif
	err = 0
	if np eq 0 then return
 
	;------  Process a scalar value  --------
	;--- Scalar values are stored in the header  ----
	if keyword_set(scalar) and n_elements(val) eq 1 then val = val(0)
	if (size(val))(0) eq 0 then begin	; Process a scalar.
	  val2 = val		; Copy a scalar since it may be modified.
	  dtyp = datatype(val)
	  if dtyp eq 'BYT' then val2 = fix(val)  ; Scalar byte -> int.
	  if dtyp eq 'FLO' then val2 = string(val,form='(G16.8)')
	  if dtyp eq 'DOU' then val2 = string(val,form='(G26.17)')
	  t = strtrim(name,2)+' = '+strtrim(val2,2)
	  r_hdr = [r_hdr, t]
	  if arg_present(fd) then $
	    fd = {r_file:r_file, r_lun:r_lun, $     ; Rebuild file descriptor.
                  r_open:r_open, r_hdr:r_hdr, r_swap:r_swap}
	  err = 0
	  return
	endif
 
	;------  Process an array value  -------
	type = datatype(val,3)		; Find data type of array.
	if type eq 'STR' then begin	; String is special case.
	  b = byte(val)			; Convert string to byte array.
	  sz = size(b)			; Want size.
	  type = 'CHR'			; Also set data type to CHR.
	endif else begin
	  sz = size(val)		; Non-string, get size.
	endelse
	lst = sz(0)			; Index in sz of last dimension.
	t = ''
	for i = 1, lst do begin		; Loop through dimensions.
	  t = t + strtrim(sz(i),2)	; Put in list.
	  if i ne lst then t = t+','	; Add comma.
	endfor
	t = '('+t+')'			; Add parens.
	t = type+'ARR'+t		; Add array type.
;------------------------------------------------------------------
;	Dropping the longword alignment for now.
;------------------------------------------------------------------
;	fs = fstat(r_lun)		; Get file status.
;	fp = fs.cur_ptr			; Want file pointer.
;	fp4 = 4L*ceil(fp/4.d0)		; Force to a multiple of 4 bytes.
;	point_lun, r_lun, fp4		; Set file pointer.
;------------------------------------------------------------------
	point_lun, -r_lun, fp4		; Get file pointer.
;------------------------------------------------------------------
	;---  setup header record for array  ------
	t = strtrim(name,2)+' == '+t+' at '+strtrim(fp4,2)
	r_hdr = [r_hdr, t]		; Put array descriptor in header.
	if arg_present(fd) then $
	  fd = {r_file:r_file, r_lun:r_lun, $     ; Rebuild file descriptor.
                r_open:r_open, r_hdr:r_hdr, r_swap:r_swap}
	;---  Write array to file  -------
	if type eq 'CHR' then begin	; For string arrays write byte array.
	  writeu, r_lun, b
	endif else begin		; Write actual array for all else.
	  writeu, r_lun, val
	endelse
	err = 0				; No errors.
	return
 
	end
