;-------------------------------------------------------------
;+
; NAME:
;       RESGET
; PURPOSE:
;       Get a variable from a results files.
; CATEGORY:
; CALLING SEQUENCE:
;       resget, [name, val]
; INPUTS:
;       name = string with name of value to get.         in
;         May be truncated but will return first match.
;         Case insensitive.
; KEYWORD PARAMETERS:
;       Keywords:
;         FD=fd    Optional file descriptor.  Allows multiple res
;           files to be used at once.
;         /EXACT   Only exact name will match.
;         FOUND=i  Returned header index where match was found.
;         FROM=s   Header index to start searching for name (def=0).
;         HEADER=h Returned header as a string array.
;         NUMBER=n Return both name and val for header
;           entry number n.  In this case name must be a variable.
;         FULL_NAME=txt  Returned full name.
;         ADDRESS=pntr  Byte address in file (first is 0) for
;           start of array (scalars have no address, return -1).
;         ERROR = e error code:
;           0 = OK. Value returned normally.
;           1 = Given index (NUMBER) references a comment line.
;               Comment line is returned in name.
;           2 = Given index (NUMBER) references last header line.
;           3 = Given index (NUMBER) is out of range.
;           4 = Header line contained no = or ==.
;           5 = Name not found.
;           6 = Invalid array type specified in header.
;           7 = No results file open.
; OUTPUTS:
;       val = variable to contain results.               out
; COMMON BLOCKS:
;       results_common
;       resget_com
; NOTES:
;       Notes: one of the results file utilities.
;         See also resopen, resput, rescom, resclose.
;         Must use resopen to open the file for read before
;         using resget. Also must use resclose to close file.
; MODIFICATION HISTORY:
;       R. Sterner, 18 Jun, 1991
;       R. Sterner, 10 Dec, 1991 added HEADER=h and NUMBER=num.
;       R. Sterner,  3 Jun, 1993 added FROM=s and FOUND=i.
;       R. Sterner, 2000 Apr 11 --- Handled endian problem.
;       R. Sterner, 2001 Mar 22 --- Added new IDL data types a few weeks
;       ago, but added a bug that was just fixed for CHR type.
;       R. Sterner, 2004 Feb 10 --- Supported extended file pointer (LONG64).
;       R. Sterner, 2004 Sep 27 --- Added FD=fd to give file descriptor.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	pro resget, name, val, error=err, help=hlp, $
	  header=head, number=num, from=from, found=found, $
	  full_name=full, exact=exact, address=pntr, fd=fd
 
 
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
 
	common resget_com, typtab
 
	if keyword_set(hlp) then begin
	  print,' Get a variable from a results files.'
	  print,' resget, [name, val]'
	  print,'   name = string with name of value to get.         in'
	  print,'     May be truncated but will return first match.'
	  print,'     Case insensitive.'
	  print,'   val = variable to contain results.               out'
	  print,' Keywords:'
	  print,'   FD=fd    Optional file descriptor.  Allows multiple res'
	  print,'     files to be used at once.'
	  print,'   /EXACT   Only exact name will match.'
	  print,'   FOUND=i  Returned header index where match was found.'
	  print,'   FROM=s   Header index to start searching for name (def=0).'
	  print,'   HEADER=h Returned header as a string array.'
	  print,'   NUMBER=n Return both name and val for header'
	  print,'     entry number n.  In this case name must be a variable.'
	  print,'   FULL_NAME=txt  Returned full name.'
	  print,'   ADDRESS=pntr  Byte address in file (first is 0) for'
	  print,'     start of array (scalars have no address, return -1).'
	  print,'   ERROR = e error code:'
	  print,'     0 = OK. Value returned normally.'
	  print,'     1 = Given index (NUMBER) references a comment line.'
	  print,'         Comment line is returned in name.'
	  print,'     2 = Given index (NUMBER) references last header line.'
	  print,'     3 = Given index (NUMBER) is out of range.'
	  print,'     4 = Header line contained no = or ==.'
	  print,'     5 = Name not found.'
	  print,'     6 = Invalid array type specified in header.'
	  print,'     7 = No results file open.'
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resopen, resput, rescom, resclose.'
          print,'   Must use resopen to open the file for read before'
          print,'   using resget. Also must use resclose to close file.'
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
 
	err = 0
	top = 1
	if keyword_set(exact) then top = 0
 
	if n_elements(typtab) eq 0 then begin
	  typtab = ['UND','BYT','INT','LON','FLT','DBL','COMPLEX','CHR',$
	            'STC','DCOMPLEX','PTR','OBJ','UINT','ULON','LON64','ULON64']
	endif
 
        ;-------  File open?  ----------
        if n_elements(r_open) eq 0 then r_open = 0
        if r_open eq 0 then begin
          print,' No results file is open.'
	  err = 7
          return
        endif
 
	;-------  Return header  ---------
	head = r_hdr
	if n_elements(name) eq 0 then name = ''
	if (name eq '') and (n_elements(num) eq 0) then return
 
	;-------  Retrieve by header index number  ---------
	n = n_elements(r_hdr)
	if n_elements(num) ne 0 then begin
	  ;-------  Check that requested header line is in range  ----
	  if (num lt 0) or (num gt n-1) then begin
	    err = 3
	    return
	  endif
	  ;-------  Extract requested header line  -------------
	  t = r_hdr(num)
	  ;-------  Return a comment line  -----------
	  if strmid(t,0,1) eq '*' then begin
	    val = ''					; Set val to null.
	    name = t					; Put comment in name.
	    err = 1					; Means comment line.
	    return
	  endif
	  name = strupcase(getwrd(t))			; Return name.
	  if getwrd('',1) eq '=' then goto, scalar	; Scalar value.
	  if getwrd('',1) eq '==' then goto, vector	; Array value.
	  if num eq n-1 then begin			; Last line?
	    val = ''
	    err = 2
	    return
	  endif
	  err = 4					; No = or ==.
	  return
	endif
 
	;------- search header for name (= keyword) -----
	if n_elements(from) eq 0 then from = 0L		; Search start index.
	namu = strupcase(name)				; Ignore case.
	len = strlen(namu)				; Length of name.
	for flag = 0, top do begin			; Exact & trunc. match.
	  for i = from, n-1 do begin			; Loop through hdr.
	    t = r_hdr(i)				; Pull i'th enrty.
	    if strmid(t,0,1) ne '*' then begin		; Is KEY = ...
	      full = strupcase(getwrd(t))		; Get full tag name.
	      if flag eq 0 then begin			; Exact match flag.
	        w = full
	      endif else begin				; Allow truncated match.
		w = strmid(full,0,len)			; Match request length.
	      endelse
	      if w eq namu then begin			; Found requested name.
	        found = i				; Return index.
	        if getwrd('',1) eq '=' then goto, scalar  ; Scalar value.
	        if getwrd('',1) eq '==' then goto, vector ; Array value.
	        err = 4					; No = or ==.
	        return
	      endif  ; w eq.
	    endif  ; strmid.
	  endfor  ; i
	endfor  ; flag.
 
	err = 5		; Name not found.
	return
 
;----------  Process scalar value  -------------
scalar: pntr = -1				; No address for header values.
	val = getwrd('',2,99)
	return
 
;---------- Process array value  ---------------
vector:	w = strupcase(getwrd('',2))		; Get array definition.
;	type = strupcase(strmid(w,0,3))		; Get array type (like BYT).
	p = strpos(w,'ARR')
	type = strmid(w,0,p)
	tval = where(type eq typtab, count)	; Find it in type table.
	if count eq 0 then begin		; Not there.
	  err = 6				; Invalid array type.
	  return
	endif
;	tval = (tval(0) mod 6) + 1		; Convert to type number.
	tval = tval(0)				; Convert to type number.
	if tval eq 7 then tval=1		; CHR (7) is really BYTE (1).
	pntr = getwrd('',/last)+0LL		; Data start pointer.
	d = getwrd(t,/last,delim='(')		; Pick off dimension list.
	d = getwrd(d,delim=')')
	dm = ['']				; Array to hold dimensions.
	i = 0					; Dimension counter.
	repeat begin				; Pick off each dimension.
	  t = getwrd(d,i,delim=',')		; They are separated by commas.
	  dm = [dm,t]				; Add to list.
	  i = i + 1				; Count.
	endrep until t eq ''			; Was that all?
	dm = dm(1:(n_elements(dm)-2))+0L	; Drop leading/trailing nulls.
	val=make_array(dimension=dm,type=tval)	; Make array.
	point_lun, r_lun, pntr			; Point to data start.
	readu, r_lun, val			; Read data.
	if type eq 'CHR' then val = string(val)	; Want string array.
	if r_swap eq 1 then val=swap_endian(val)
 
	return
 
	end
