;-------------------------------------------------------------
;+
; NAME:
;       GET_COUNT
; PURPOSE:
;       Get next count value, from 1 up.
; CATEGORY:
; CALLING SEQUENCE:
;       c = get_count(tag)
; INPUTS:
;       tag = Any text string (optional).      in
; KEYWORD PARAMETERS:
;       Keywords:
;         FILE=file  Name of count file to use (def=count_file.txt
;           in current directory.
;         /LAST return last count without incrementing.
;         /ZERO  zero counter for given tag.  Does not return
;           a count.  Count for next normal call will be 1.
;         SET=c  set counter to given value for given tag.  Does not
;           return a count. Count for next normal call will be c+1.
;         DIGITS=n  Return an n digit string value (0 padded on left).
;         /ZREF  initial count returned starts at 0.
; OUTPUTS:
;       c = Count corresponding to given tag.  out
;         Returned as a string.
; COMMON BLOCKS:
; NOTES:
;       Notes: this routine returns the number of times it has
;         been called with the given tag.  The counts are saved
;         in a count file which defaults to count_file.txt in
;         current directory.  This is a simple text file and
;         may be modifed.  Useful for creating a series of
;         related file names.  Could use date2dn to generate
;         a tag value.  Use a unique tag for each purpose.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Jul 6
;       R. Sterner, 2002 Sep 25 --- Allowed set for new tags.  Added DIGITS.
;       R. Sterner, 2002 Dec 03 --- Was returning unformatted value for new.
;       R. Sterner, 2002 Dec 03 --- Made tag optional.
;       R. Sterner, 2003 Jan 06 --- Used file_search for IDL 5.5 on.
;       R. Sterner, 2003 Mar 20 --- New keyword /LAST.
;       H. Taylor,  2004 Jun 29 --- New keyword /ZEROREF
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function get_count, tag, file=file, zero=zero, set=set, $
	  digits=digits, last=last, zref=zref, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Get next count value, from 1 up.'
	  print,' c = get_count(tag)'
	  print,'   tag = Any text string (optional).      in'
	  print,'   c = Count corresponding to given tag.  out'
	  print,'     Returned as a string.'
	  print,' Keywords:'
	  print,'   FILE=file  Name of count file to use (def=count_file.txt'
	  print,'     in current directory.'
	  print,'   /LAST return last count without incrementing.'
	  print,'   /ZERO  zero counter for given tag.  Does not return'
	  print,'     a count.  Count for next normal call will be 1.'
	  print,'   SET=c  set counter to given value for given tag.  Does not'
	  print,'     return a count. Count for next normal call will be c+1.'
	  print,'   DIGITS=n  Return an n digit string value (0 padded on left).'
	  print,'   /ZREF  initial count returned starts at 0.'
	  print,' Notes: this routine returns the number of times it has'
	  print,'   been called with the given tag.  The counts are saved'
	  print,'   in a count file which defaults to count_file.txt in'
          print,'   current directory.  This is a simple text file and'
	  print,'   may be modifed.  Useful for creating a series of'
	  print,'   related file names.  Could use date2dn to generate'
	  print,'   a tag value.  Use a unique tag for each purpose.'
	  return,''
	endif
 
	if n_elements(tag) eq 0 then tag = '$'
	if n_elements(file) eq 0 then file = 'count_file.txt'
	if keyword_set(zref) eq 0 then zref=0
 
	;------  Create count file if it does not exist  -----------
	if !version.release ge 5.5 then begin
	  f = file_search(file,count=c)	; Does count file exists?
	endif else begin
	  f = findfile(file,count=c)	; Does count file exists?
	endelse
	if c eq 0 then begin		; No, create it.
	  if (zref ne 0) then val=0 else val=1
	  t = [tag+'      '+strtrim(string(val),2)]  ; Add new tag line.
	  putfile,file,t		; Update count file.
	  goto, fmt
	endif
 
	;------  Read in count file  ------------
	t = getfile(file, err=err)
	if err ne 0 then begin
	  print,' Error in get_count: no such count file:'
	  print,'   '+file
	  return,'0'		; Error value.
	endif
 
	;-------  Zero a count  ------------------
	if keyword_set(zero) then begin
	  val = txtgetkey(init=t,del=' ',tag,index=i)	; Find tag.
	  if val eq '' then begin			; No such tag.
	    print,' Error in get_count: no such tag: '+tag
            return,'0'                    		; Return 0 for error.
          endif
	  if (zref ne 0) then txt='     -1' else txt='      0'
	  t(i) = tag + txt				; Clear counter to 0.
	  putfile,file,t				; Save changes.
	  return,''					; Nothing to return.
	endif
 
	;-------  Set a count  ------------------
	if n_elements(set) ne 0 then begin
	  val = txtgetkey(init=t,del=' ',tag,index=i)	; Find tag.
	  if val eq '' then begin			; No such tag.
	    t = [t,tag+'      '+strtrim(set,2)]		; Tag is new.
          endif else begin
	    t(i) = tag+'      '+strtrim(set,2)		; Set counter.
	  endelse
	  putfile,file,t				; Save changes.
	  return,''					; Nothing to return.
	endif
 
	;-------  Get value from count file  -------
	val = txtgetkey(init=t,del=' ',tag,index=i)	; Find tag.
 
	;-------  Add tag if new  ----------------
	if val eq '' then begin			; Handle new tag.
	  if (zref ne 0) then val=0 else val=1
	  t = [t,tag+'      '+strtrim(string(val),2)]  ; Add new tag line.
	  putfile,file,t			; Update count file.
	  goto, fmt
	endif
 
	;--------  Find and update tag count  ----------
	if not keyword_set(last) then begin	; Don't inc for /LAST.
	  val = string(val+1,form='(I8)')	; Increment count.
	  t(i) = tag+val  	               	; Add new tag line.
          putfile,file,t			; Update count file.
	endif
fmt:	if n_elements(digits) eq 0 then begin
          return, strtrim(val,2)		; And return count for tag.
	endif else begin
	  d = strtrim(digits,2)			; Specified # digits.
	  fmt = '(I'+d+'.'+d+')'		; Needed format.
	  return, string(val,form=fmt)		; Return value.
	endelse
 
	end
