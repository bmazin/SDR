;-------------------------------------------------------------
;+
; NAME:
;       IMGOPEN
; PURPOSE:
;       Prepare a large image to be read.
; CATEGORY:
; CALLING SEQUENCE:
;       imgopen, filename, nx, ny
; INPUTS:
;       filename = name of image file.         in
;       nx = number of pixels per image line.  in
;       ny = number of image lines.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         TYPE=t  image data type (def = byte).
;           1: byte,  2: integer, 3: long integer,
;           4: float, 5: double,  6: complex.
;           Strings and structures not allowed.
;         OFFSET=off offset in bytes to skip over a header (def=0).
;         ERROR=err  error flag.  0: OK, -1: file not found,
;           -2: parameter value error.
;         /LIST list name and size of a currently open image.
; OUTPUTS:
; COMMON BLOCKS:
;       img_com
; NOTES:
;       Notes: TYPE is the same numeric value as returned
;         by the SIZE function (see manual).
;         Image is read by IMGREAD.
;         Image must have fixed length records.
; MODIFICATION HISTORY:
;       Ray Sterner, 12 Mar, 1991
;       R. Sterner, 17 Sep, 1991 --- modified common.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro imgopen, name, nx, ny, type=typ, offset=offset, $
	  error=err, list=list, help=hlp
 
	common img_com, name0, nx0, ny0, typ0, lun, off0
 
        ;---------------------------------------------------------------;
        ;                        Help                                   ;
        ;---------------------------------------------------------------;
	if keyword_set(hlp) then begin
	  print,' Prepare a large image to be read.'
	  print,' imgopen, filename, nx, ny'
	  print,'   filename = name of image file.         in'
	  print,'   nx = number of pixels per image line.  in'
	  print,'   ny = number of image lines.            in'
	  print,' Keywords:'
	  print,'   TYPE=t  image data type (def = byte).
	  print,'     1: byte,  2: integer, 3: long integer,'
	  print,'     4: float, 5: double,  6: complex.'
	  print,'     Strings and structures not allowed.'
	  print,'   OFFSET=off offset in bytes to skip over a header (def=0).'
	  print,'   ERROR=err  error flag.  0: OK, -1: file not found,'
	  print,'     -2: parameter value error.'
	  print,'   /LIST list name and size of a currently open image.'
	  print,' Notes: TYPE is the same numeric value as returned'
	  print,'   by the SIZE function (see manual).'
	  print,'   Image is read by IMGREAD.'
	  print,'   Image must have fixed length records.'
	  return
	endif
 
        ;---------------------------------------------------------------;
        ;                 Show file currently open                      ;
        ;---------------------------------------------------------------;
	if keyword_set(list) then begin
	  print,' '
	  if n_elements(name0) eq 0 then begin
	    print,' No image has been opened.'
	  endif else begin
	    print,' '+(['Undefined','Byte','Integer','Long integer',$
	      'Float','Double','Complex'])(typ0)+$
              ' image '+name0+' has '+strtrim(ny0,2)+$
	      ' lines of '+strtrim(nx0,2)+' pixels.'
	  endelse
	  print,' '
	  return
	endif
 
        ;---------------------------------------------------------------;
        ;                    Interactive input                          ;
        ;---------------------------------------------------------------;
	err = 0
	np = n_params(0)
 
	if np lt 1 then begin		; Get image file name.
	  print,' '
	  print,' Open an image to be read by IMGREAD.'
	  name = ''
getname:  print,' '
	  read,' Image name: ',name
	  if name eq '' then return
	  f = findfile(name, count=c)
	  if c eq 0 then begin
	    print,' Image file '+name+' not found.  Re-enter name.'
	    goto, getname
	  endif
	endif
 
	if np lt 2 then begin		; Get pixels/line.
labnx:	  print,' '
	  nx = ''
	  read, ' Number of pixels per image line: ',nx
	  if nx eq '' then return
	  on_ioerror, labnx
	  nx = nx + 0
	endif
 
	if np lt 3 then begin		; Get lines.
labny:	  print,' '
	  ny = ''
	  read, ' Number of image lines: ',ny
	  if ny eq '' then return
	  on_ioerror, labny
	  ny = ny + 0
	endif
 
	if (np lt 3) and (not keyword_set(typ)) then begin	; Data type.
labtyp:	  print,' '
	  typ = ''
	  print,' Number,  data type'
	  print,'   1        byte'
	  print,'   2        integer'
	  print,'   3        long integer'
	  print,'   4        float'
	  print,'   5        double'
	  print,'   6        complex'
	  print,' '
	  read,' Data type (def = 1): ',typ
	  if typ eq '' then typ = '1'
	  on_ioerror, labtyp
	  typ = typ + 0
	endif
 
	if (np lt 3) and (not keyword_set(off)) then begin	; Offset.
laboff:	  print,' '
	  off = ''
	  read,' Offset in bytes (def = 0): ',off
	  if off eq '' then off = '0'
	  on_ioerror, laboff
	  off = off + 0
	endif
 
	on_ioerror, null
 
        ;---------------------------------------------------------------;
        ;                       Look for file                           ;
        ;---------------------------------------------------------------;
	if np gt 1 then begin
	  f = findfile(name, count=c)
	  if c eq 0 then begin
	    print,' Error in imgopen: image file '+name+' not found.'
	    err = -1
	    return
	  endif
	endif
 
        ;---------------------------------------------------------------;
        ;                         Set defaults                          ;
        ;---------------------------------------------------------------;
	if n_elements(typ) eq 0 then typ = 1
	if n_elements(off) eq 0 then off = 0
 
        ;---------------------------------------------------------------;
        ;                     Check numeric values                      ;
        ;---------------------------------------------------------------;
	on_ioerror, numerr
	x = typ + 0
	x = off + 0
	x = nx + 0
	x = ny + 0
	on_ioerror, null
 
        ;---------------------------------------------------------------;
        ;                    Save values in common                      ;
        ;---------------------------------------------------------------;
	name0 = name
	nx0 = nx
	ny0 = ny
	typ0 = typ
	off0 = off
 
        ;---------------------------------------------------------------;
        ;                    Get Lun                                    ;
        ;---------------------------------------------------------------;
	if n_elements(lun) eq 0 then get_lun, lun
	err = 0
	return
 
        ;---------------------------------------------------------------;
        ;                     Was a numeric error                       ;
        ;---------------------------------------------------------------;
numerr:	print,' Error in imgopen: a non-numeric parameter was given.'
	err = -2
	on_ioerror, null
	return	
 
	end
