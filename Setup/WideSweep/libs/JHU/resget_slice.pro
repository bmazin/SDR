;-------------------------------------------------------------
;+
; NAME:
;       RESGET_SLICE
; PURPOSE:
;       Get 2D slices from a results files and return as a 3D array.
; CATEGORY:
; CALLING SEQUENCE:
;       resget_slice, name, val
; INPUTS:
;       name = string with name of slices to get.         in
;         May be truncated but will return first match.
;         Case insensitive.  Do not include the slice index.
;         Example: For items named ustk_000, ustk_001, ustk_002,
; KEYWORD PARAMETERS:
;       Keywords:
;         XRAN=xran, YRAN=yran, ZRAN=zran  Indices in X,Y,Z.
;           2-D array like XRAN=[ixlo,ixhi]. Default is full range.
;           Any out of range indices are clipped to be in range.
;         FD=fd    Optional file descriptor.  Allows multiple res
;           files to be used at once.
;         ERROR = e error code:
;           0 = OK. Value returned normally.
;           5 = Name not found.
;           6 = Invalid array type specified in header.
;           7 = No results file open.
; OUTPUTS:
;       ustk_003 access by resget_slice, 'ustk', out
;       val = variable to contain results.               out
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resopen, resput, rescom, resclose.
;         Must use resopen to open the file for read before
;         using resget. Also must use resclose to close file.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jul 19
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro resget_slice, name, val, error=err, fd=fd, help=hlp, $
	  xran=xran, yran=yran, zran=zran  
 
 
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
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Get 2D slices from a results files and return as a 3D array.'
	  print,' resget_slice, name, val'
	  print,'   name = string with name of slices to get.         in'
	  print,'     May be truncated but will return first match.'
	  print,'     Case insensitive.  Do not include the slice index.'
	  print,'     Example: For items named ustk_000, ustk_001, ustk_002,'
	  print,"     ustk_003 access by resget_slice, 'ustk', out"
	  print,'   val = variable to contain results.               out'
	  print,' Keywords:'
	  print,'   XRAN=xran, YRAN=yran, ZRAN=zran  Indices in X,Y,Z.'
	  print,'     2-D array like XRAN=[ixlo,ixhi]. Default is full range.'
	  print,'     Any out of range indices are clipped to be in range.'
	  print,'   FD=fd    Optional file descriptor.  Allows multiple res'
	  print,'     files to be used at once.'
	  print,'   ERROR = e error code:'
	  print,'     0 = OK. Value returned normally.'
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
 
	;-------  Get res file header  --------------
	resget,head=h,err=err
	if err ne 0 then return
 
	;-------  Find requested slices  ------------
	strfind, h, '^'+name, /quiet, count=cnt, index=ind
	if cnt eq 0 then begin
	  err = 5
	  print,' Error in resget_slice: name not found - '+name
	  return
	endif
 
	;-------  Check that all slices match  --------
	name_slice = strarr(cnt)
	typ_slice = strarr(cnt)
	add_slice = strarr(cnt)
	for i=0,cnt-1 do begin
	  t = h(ind(i))
	  name_slice(i) = getwrd(t,0)
	  typ_slice(i) = getwrd('',2)
	  add_slice(i) = getwrd('',4)
	endfor
	w = where(typ_slice ne typ_slice(0),nw)
	if nw ne 0 then begin
	  err = 6
	  print,' Error in resget_slice: '+strtrim(nw,2)+$
	    'slice type mismatch'+plural(nw,'.','es.')
	  print,'   First slice type = '+typ_slice(0)
	  print,'   Mismatch at '+strtrim(w(0),2)+' = '+typ_slice(w(0))
	  return
	endif
 
	;--------  Set up array and read slices  --------
	resget,name_slice(0),a
	nx = dimsz(a,1)
	ny = dimsz(a,2)
	nz = cnt
	if n_elements(xran) eq 0 then xran=[0,nx-1]
	if n_elements(yran) eq 0 then yran=[0,ny-1]
	if n_elements(zran) eq 0 then zran=[0,nz-1]
	xran = xran>0<(nx-1)
	yran = yran>0<(ny-1)
	zran = zran>0<(nz-1)
	nx2 = xran(1)-xran(0)+1
	ny2 = yran(1)-yran(0)+1
	nz2 = zran(1)-zran(0)+1
	ix1=xran(0) & ix2=xran(1)
	iy1=yran(0) & iy2=yran(1)
	iz1=zran(0) & iz2=zran(1)
	val = make_array(dim=[nx2,ny2,nz2],val=zero_int(a(0)))
	print,' '+string(ix1,form='(I4.4)')+' / '+ $
	  string(cnt,form='(I4.4)')+string(13B),form='(A,$)'
	for i=iz1,iz2 do begin
	  print,' '+string(i,form='(I4.4)')+' / '+ $
	    string(cnt,form='(I4.4)')+string(13B),form='(A,$)'
	  resget,name_slice(i),a
	  val(0,0,i-iz1) = a(ix1:ix2,iy1:iy2)
	endfor
	print,'            '+string(13B),form='(A,$)'
	err = 0
 
	return
 
	end
