;-------------------------------------------------------------
;+
; NAME:
;       AARR
; PURPOSE:
;       Simulate an associative array (key / value pairs).
; CATEGORY:
; CALLING SEQUENCE:
;       val = aarr(arr, key)
; INPUTS:
;       arr = Input array.                   in
;             See notes below.
;       key = Key into array.                in
; KEYWORD PARAMETERS:
;       Keywords:
;         INDEX=in  Index of key for given operation.
;           For /ADD in is the index of the added or updated key.
;           For /DROP in is the index where the dropped key was.
;           For Value by Key, in is the index of the Key.
;           For Key by Value, in is the index of the Key.
;         VALUE=val  For this keyword the corresponding key
;           is returned as the function value (only arg is arr).
;         /ADD add a new key/value pair to the array.
;            Give both the key and value with this keyword:
;            arr2 = aarr(arr,key,value=val,/add)
;            If new, the key and value are added to the array.
;            For an exising key the value is updated unless
;            /NO_UPDATE is used.
;         /NO_UPDATE means do not update the value when adding a key
;            that was already there.
;         /DROP drop the specified key/value pair from the array.
;            Give either the key or value with this keyword:
;            arr = aarr(arr,key,/drop) or
;            arr = aarr(arr,value=val,/drop)
;            The updated array is returned or original if error.
;         COUNT=cnt Number of elements in modified array for a
;            successful /drop (Only returned for /DROP). If all
;            elements dropped a null string is returned, check cnt.
;            COUNT is 2 times the number of entries in the array.
;         ERROR=err  Error flag: 0=ok.
;         /QUIET do not give error message.
;         VERR=verr Value to return on an error (def='').
; OUTPUTS:
;       val = Returned value for given key.  out
;         Reverse lookup, do not give key for this case.
; COMMON BLOCKS:
; NOTES:
;       Notes: The keys and values for a given array will all be the
;       same data type, probably text.  They must be in the array
;       as adjacent elements with key first.  Keys should be unique,
;       if not, the first found will be used.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Jul 06
;       R. Sterner, 2006 Dec 15 --- Now defines arr for first /add.
;       R. Sterner, 2006 Dec 15 --- Added /UPDATE, /QUIET, ERROR=err.
;       R. Sterner, 2006 Dec 18 --- Dropped /UPDATE, /ADD now updates.
;       R. Sterner, 2006 Dec 18 --- Made INDEX always be for key.
;       R. Sterner, 2007 May 14 --- Added VERR.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function aarr, arr, key, value=val, $
	  add=add, drop=drop, count=cnt, index=in, $
	  quiet=quiet, error=err, no_update=nup, help=hlp, $
	  verr=verr
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Simulate an associative array (key / value pairs).'
	  print,' val = aarr(arr, key)'
	  print,'   arr = Input array.                   in'
	  print,'         See notes below.'
	  print,'   key = Key into array.                in'
	  print,'   val = Returned value for given key.  out'
	  print,'     Reverse lookup, do not give key for this case.'
	  print,' Keywords:'
	  print,'   INDEX=in  Index of key for given operation.'
	  print,'     For /ADD in is the index of the added or updated key.'
	  print,'     For /DROP in is the index where the dropped key was.'
	  print,'     For Value by Key, in is the index of the Key.'
	  print,'     For Key by Value, in is the index of the Key.'
	  print,'   VALUE=val  For this keyword the corresponding key'
	  print,'     is returned as the function value (only arg is arr).'
	  print,'   /ADD add a new key/value pair to the array.'
	  print,'      Give both the key and value with this keyword:'
	  print,'      arr2 = aarr(arr,key,value=val,/add)'
	  print,'      If new, the key and value are added to the array.'
	  print,'      For an exising key the value is updated unless'
	  print,'      /NO_UPDATE is used.'
	  print,'   /NO_UPDATE means do not update the value when adding a key'
	  print,'      that was already there.'
	  print,'   /DROP drop the specified key/value pair from the array.'
	  print,'      Give either the key or value with this keyword:'
	  print,'      arr = aarr(arr,key,/drop) or'
	  print,'      arr = aarr(arr,value=val,/drop)'
	  print,'      The updated array is returned or original if error.'
	  print,'   COUNT=cnt Number of elements in modified array for a'
	  print,'      successful /drop (Only returned for /DROP). If all'
	  print,'      elements dropped a null string is returned, check cnt.'
	  print,'      COUNT is 2 times the number of entries in the array.'
	  print,'   ERROR=err  Error flag: 0=ok.'
	  print,'   /QUIET do not give error message.'
	  print,"   VERR=verr Value to return on an error (def='')."
	  print,' Notes: The keys and values for a given array will all be the'
	  print,' same data type, probably text.  They must be in the array'
	  print,' as adjacent elements with key first.  Keys should be unique,'
	  print,' if not, the first found will be used.'
	  return, ''
	endif
 
	err = 0
	in = -1
 
	;-------------------------------------------------
	;  Add or Update
	;-------------------------------------------------
	if keyword_set(add) then begin
	  if n_elements(key) eq 0 then begin	; Must include key.
	    if not keyword_set(quiet) then $
	      print,' Error in aarr: Must give a key for /ADD.'
	    err = 1
	    return,arr				; Error, no change.
	  endif
	  if n_elements(val) eq 0 then begin	; Must include value.
	    if not keyword_set(quiet) then $
	      print,' Error in aarr: Must give a value for /ADD.'
	    err = 1
	    return,arr				; Error, no change.
	  endif
	  if n_elements(arr) eq 0 then return,[key,val]
	  w = where(arr eq key, cnt)		; See if already there.
	  if cnt eq 0 then begin		; Not there, add it.
	    in = n_elements(arr)		; Index of newly added key.
	    return,[arr,key,val]
	  endif else begin			; Was there, update it.
	    in = w[0]				; Key found in arr at index in.
	    if not keyword_set(nup) then arr[in+1]=val	; Insert new value.
	    return, arr				; Return updated array.
	  endelse
	endif
 
	;-------------------------------------------------
	;  Drop
	;-------------------------------------------------
	if keyword_set(drop) then begin
	  flag = bytarr(n_elements(arr)) + 1B	; Flag array, all 1s.
	  ;---  KEY  ---
	  if n_elements(key) ne 0 then begin	; Key was given.
	    w = where(arr eq key, cnt)		; Find it in array.
	    if cnt eq 0 then begin		; Not there, error.
	      if not keyword_set(quiet) then begin
	        print,' Error in aarr: Given key not found'
	        print,'   Key = ',key
	      endif
	      err = 1
	      return, arr			; No change.
	    endif
	    in = w(0)				; Key found in arr at index in.
	    flag([in,in+1]) = 0			; Clear flags for dropped pair.
	  endif
	  ;---  VAL  ---
	  if n_elements(val) ne 0 then begin
	    w = where(arr eq val, cnt)		; Find it in array.
	    if cnt eq 0 then begin		; Not there, error.
	      if not keyword_set(quiet) then begin
	        print,' Error in aarr: Given value not found'
	        print,'   Val = ',val
	      endif
	      err = 1
	      return, arr			; No change.
	    endif
	    in = w[0]-1				; Val found at index in+1.
	    flag([in,in+1]) = 0			; Clear flags for dropped pair.
	  endif
	  w = where(flag, cnt)			; Find all uncleared flags.
	  if cnt eq 0 then return,''		; None, return null string.
	  return, arr(w)			; Returned array subset.
	endif
 
	if n_elements(verr) eq 0 then verr=''	; Default error value.
 
	;-------------------------------------------------
	;  Given Key, return Value
	;-------------------------------------------------
	if n_elements(key) ne 0 then begin	; Key was given.
	  w = where(arr eq key, cnt)		; Find it in array.
	  if cnt eq 0 then begin		; Not there, error.
	    if not keyword_set(quiet) then begin
	      print,' Error in aarr: Given key not found'
	      print,'   Key = ',key
	    endif
	    err = 1
;	    return, arr				; No change.
	    return, verr			; Return error value.
	  endif
	  in = w[0]				; Key found in arr at index in.
	  return, arr(in+1)			; Return value.
	endif
 
	;-------------------------------------------------
	;  Given Value, return Key
	;-------------------------------------------------
	if n_elements(val) ne 0 then begin
	  w = where(arr eq val, cnt)		; Find it in array.
	  if cnt eq 0 then begin		; Not there, error.
	    if not keyword_set(quiet) then begin
	      print,' Error in aarr: Given value not found'
	      print,'   Val = ',val
	    endif
	    err = 1
;	    return, arr				; No change.
	    return, verr			; Return error value.
	  endif
	  in = w[0]-1				; Val found at index in+1.
	  return, arr(in+1)			; Return key.
	endif
 
	end
