;-------------------------------------------------------------
;+
; NAME:
;       DATATYPE
; PURPOSE:
;       Datatype of variable as a string (3 char or spelled out).
; CATEGORY:
; CALLING SEQUENCE:
;       typ = datatype(var, [flag])
; INPUTS:
;       var = variable to examine.         in
;       flag = output format flag (def=0). in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMERIC=num returns a code indicating numeric type:
;           0=non-numeric, 1=integer, 2=float, 3=complex.
;         INTEGER_BITS=bits returns number of bits if numeric:
;           0=Not Integer, 8=Byte, 16=Int, 32=Long, 64=Long 64.
;           Also for floating and complex.  For a single element.
;         NUMBYTES=numbtyes Returned total number of bytes in var.
;         /DESCRIPTOR returns a descriptor for the given variable.
;           If the variable is a scalar the value is returned as
;           a string.  If it is an array a description is return
;           just like the HELP command gives.  Ex:
;           datatype(fltarr(2,3,5),/desc) gives
;             FLTARR(2,3,5)  (flag always defaults to 3 for /DESC).
; OUTPUTS:
;       typ = datatype string or number.   out
;          flag=0    flag=1      flag=2    flag=3
;          UND       Undefined   0         UND
;          BYT       Byte        1         BYT
;          INT       Integer     2         INT
;          LON       Long        3         LON
;          FLO       Float       4         FLT
;          DOU       Double      5         DBL
;          COM       Complex     6         COMPLEX
;          STR       String      7         STR
;          STC       Structure   8         STC
;          DCO       DComplex    9         DCOMPLEX
;          PTR       Pointer    10         PTR
;          OBJ       Object     11         OBJ
;          UIN       U_Integer  12         UINT
;          ULO       U_Long     13         ULON
;          LLO       Long_64    14         LON64
;          ULL       U_Long_64  15         ULON64
; COMMON BLOCKS:
; NOTES:
;       Notes: For a tag, val pair:
;         print, tag+' = '+datatype(val,/desc)
;         will give a nice description of the item.  Could loop
;         through the tags and values of a structure this way.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 24 Oct, 1985.
;       RES 29 June, 1988 --- added spelled out TYPE.
;       R. Sterner, 13 Dec 1990 --- Added strings and structures.
;       R. Sterner, 19 Jun, 1991 --- Added format 3.
;       R. Sterner, 18 Mar, 1993 --- Added /DESCRIPTOR.
;       R. Sterner, 1995 Jul 24 --- Added DCOMPLEX for data type 9.
;       R. Sterner, 1999 Jun  4 --- Added types 10 on, also numeric and bits.
;       R. Sterner, 2002 Oct 10 --- Now returns #bits for non-int numeric.
;       R. Sterner, 2004 May 18 --- Handled object descriptor.
;       R. Sterner, 2004 Sep 21 --- Made scalar /DESCRIPTOR type dependent.
;       R. Sterner, 2005 Apr 27 --- Fixed for scalar pointer with /DESCRIPTOR.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function datatype,var, flag0, descriptor=desc, $
	  numeric=num, integer_bits=bits, numbytes=numbytes, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Datatype of variable as a string (3 char or spelled out).'
	  print,' typ = datatype(var, [flag])'
	  print,'   var = variable to examine.         in'
	  print,'   flag = output format flag (def=0). in'
	  print,'   typ = datatype string or number.   out'
	  print,'      flag=0    flag=1      flag=2    flag=3'
	  print,'      UND       Undefined   0         UND'
	  print,'      BYT       Byte        1         BYT'
	  print,'      INT       Integer     2         INT'
	  print,'      LON       Long        3         LON'
	  print,'      FLO       Float       4         FLT'
	  print,'      DOU       Double      5         DBL'
	  print,'      COM       Complex     6         COMPLEX'
	  print,'      STR       String      7         STR'
	  print,'      STC       Structure   8         STC'
	  print,'      DCO       DComplex    9         DCOMPLEX'
	  print,'      PTR       Pointer    10         PTR'
	  print,'      OBJ       Object     11         OBJ'
	  print,'      UIN       U_Integer  12         UINT'
	  print,'      ULO       U_Long     13         ULON'
	  print,'      LLO       Long_64    14         LON64'
	  print,'      ULL       U_Long_64  15         ULON64'
	  print,' Keywords:'
	  print,'   NUMERIC=num returns a code indicating numeric type:'
	  print,'     0=non-numeric, 1=integer, 2=float, 3=complex.'
	  print,'   INTEGER_BITS=bits returns number of bits if numeric:'
	  print,'     0=Not Integer, 8=Byte, 16=Int, 32=Long, 64=Long 64.'
	  print,'     Also for floating and complex.  For a single element.'
	  print,'   NUMBYTES=numbtyes Returned total number of bytes in var.'
	  print,'   /DESCRIPTOR returns a descriptor for the given variable.'
 	  print,'     If the variable is a scalar the value is returned as'
 	  print,'     a string.  If it is an array a description is return'
 	  print,'     just like the HELP command gives.  Ex:'
 	  print,'     datatype(fltarr(2,3,5),/desc) gives'
 	  print,'       FLTARR(2,3,5)  (flag always defaults to 3 for /DESC).'
	  print,' Notes: For a tag, val pair:'
	  print,"   print, tag+' = '+datatype(val,/desc)"
	  print,'   will give a nice description of the item.  Could loop'
	  print,'   through the tags and values of a structure this way.'
	  return, -1
	endif 
 
	;-------  Find data type  -------------------
	if n_elements(var) eq 0 then begin
	  s = [0,0]
	endif else begin
	  s = size(var)
	endelse
	styp = s(s(0)+1)
 
	;--------  Codes  ---------------------------
	num = ([0,1,1,1,2,2,3,0,0,3,0,0,1,1,1,1])(styp)
	bits = ([0,8,16,32,32,64,64,0,0,128,0,0,16,32,64,64])(styp)
 
	;--------  Number of bytes in var  ----------
	p = 1L
	for i=1, s[0] do p=p*s[i]		; Total elements in var.
	numbytes = p*bits/8			; Total bytes in var.
 
	;--------  Set return type flag  ------------
	if n_params(0) lt 2 then flag0 = 0	; Default flag.
	flag = flag0				; Make a copy.
	if keyword_set(desc) then flag = 3
	if flag eq 2 then typ = styp
 
	;---------  Set return values  --------------
	if flag eq 0 then begin
	  case styp of
   0:	    typ = 'UND'
   1:       typ = 'BYT'
   2:       typ = 'INT'
   4:       typ = 'FLO'
   3:       typ = 'LON'
   5:       typ = 'DOU'
   6:       typ = 'COM'
   7:       typ = 'STR'
   8:       typ = 'STC'
   9:       typ = 'DCO'
  10:       typ = 'PTR'
  11:       typ = 'OBJ'
  12:       typ = 'UIN'
  13:       typ = 'ULO'
  14:       typ = 'LLO'
  15:       typ = 'ULL'
else:       print,'Error in datatype'
	  endcase
	endif else if flag eq 1 then begin
	  case styp of
   0:	    typ = 'Undefined'
   1:       typ = 'Byte'
   2:       typ = 'Integer'
   4:       typ = 'Float'
   3:       typ = 'Long'
   5:       typ = 'Double'
   6:       typ = 'Complex'
   7:       typ = 'String'
   8:       typ = 'Structure'
   9:       typ = 'DComplex'
  10:       typ = 'Pointer'
  11:       typ = 'Object'
  12:       typ = 'U_Integer'
  13:       typ = 'U_Long'
  14:       typ = 'Long_64'
  15:       typ = 'U_Long_64'
else:       print,'Error in datatype'
	  endcase
	endif else if flag eq 3 then begin
	  case styp of
   0:	    typ = 'UND'
   1:       typ = 'BYT'
   2:       typ = 'INT'
   4:       typ = 'FLT'
   3:       typ = 'LON'
   5:       typ = 'DBL'
   6:       typ = 'COMPLEX'
   7:       typ = 'STR'
   8:       typ = 'STC'
   9:       typ = 'DCOMPLEX'
  10:       typ = 'PTR'
  11:       typ = 'OBJ'
  12:       typ = 'UINT'
  13:       typ = 'ULON'
  14:       typ = 'LON64'
  15:       typ = 'ULON64'
else:       print,'Error in datatype'
	  endcase
	endif
 
	;-------  Handle /DECRIPTOR  -------------
	if not keyword_set(desc) then begin
	  return, typ					; Return data type.
	endif else begin
	  if s(0) eq 0 then begin			; Scalar item.
	    if styp eq 11 then return,'Object '+obj_class(var)  ; Object class.
	    if styp eq 10 then return,'Pointer'		; Pointer.
	    val2 = var					; Copy, may be modified.
	    if styp eq 1 then val2 = fix(var)  		; Scalar byte -> int.
	    if styp eq 4 then val2 = string(var,form='(G16.8)')
	    if styp eq 5 then val2 = string(var,form='(G26.17)')
	    return,typ+' =  '+strtrim(val2,2)		; Return scalar desc.
	  endif
	  aa = typ+'ARR('				; Array item.
          for i = 1, s(0) do begin                      
            aa = aa + strtrim(s(i),2)                 
            if i lt s(0) then aa = aa + ','          
            endfor                                     
          aa = aa+')'                                   
	  return, aa
	endelse
 
	end
