;-------------------------------------------------------------
;+
; NAME:
;       DATA_BLOCK
; PURPOSE:
;       Read the block of data following data_block call.
; CATEGORY:
; CALLING SEQUENCE:
;       data_block, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /CHECK  means just list data block lines without
;           interpreting them.
;         ERROR=err  Error flag: 0=ok, 1=error.
; OUTPUTS:
;       out = returned array of data.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Block of data must directly follow call to data_block.
;       Examples:
;         data_block, x
;         ; 11,23,26.5, 34.7 42 EOD
;       
;              data_block, t
;       ;        1, 2, 3      ; Line 1.
;       ;       11,22,33      ; Line 2.
;       ;       eod
;        
;        <> Values may be separated by commas, spaces, and/or tabs.
;        <> The string EOD indicates the End Of Data and may be at
;             the end of a line or on a separate line (but only once).
;        <> Multiple data lines are allowed.
;        <> Data always comes back as a floating 1-d array.
;        <> Data lines must be commented out so IDL will ignore them.
;        <> Anything following a second comment char is ignored.
;       
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 23
;       R. Sterner, 2000 Aug 01 --- Fixed chnage in returned calling line #.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro data_block, out, check=check, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read the block of data following data_block call.'
	  print,' data_block, out'
	  print,'   out = returned array of data.   out'
	  print,' Keywords:'
	  print,'   /CHECK  means just list data block lines without'
	  print,'     interpreting them.'
	  print,'   ERROR=err  Error flag: 0=ok, 1=error.'
	  print,' Notes: Block of data must directly follow call to data_block.'
	  print,' Examples:'
	  print,'   data_block, x'
	  print,'   ; 11,23,26.5, 34.7 42 EOD'
	  print,' '
	  print,'        data_block, t'
	  print,';        1, 2, 3      ; Line 1.'
	  print,';       11,22,33      ; Line 2.'
	  print,';       eod'
	  print,' '
	  print,' <> Values may be separated by commas, spaces, and/or tabs.'
	  print,' <> The string EOD indicates the End Of Data and may be at'
	  print,'      the end of a line or on a separate line (but only once).'
	  print,' <> Multiple data lines are allowed.''
	  print,' <> Data always comes back as a floating 1-d array.'
	  print,' <> Data lines must be commented out so IDL will ignore them.'
	  print,' <> Anything following a second comment char is ignored.'
	  return
	end
 
	whocalledme, dir, file, line=n		; Find who called data_block.
	name = filename(dir,file,/nosym)
	txt = getfile(name)			; read in calling routine.
 
	out = [0.]				; Start output array.
 
	;-------  Used to work, changed somehow  ----------
;	i = n-1					; First line of data block.
	i = n					; First line of data block.
loop:	t = txt(i)
	eod_pos = strpos(strupcase(t),'EOD')	; Look for EOD.
	if keyword_set(check) then begin
	  print,t
	endif else begin
	  if eod_pos ge 0 then t = strmid(t,0,eod_pos)	; Drop any EOD.
	  p = strpos(t,';')			; Finding leading comment char.
	  t = strmid(t,p+1,999)			; Drop it.
	  p = strpos(t,';')			; Finding leading comment char.
	  if p ge 0 then t=strmid(t,0,p)	; Drop any trailing comment.
	  t = repchr(t,',')			; Drop any commas.
	  n = nwrds(t)				; Have many numbers?
	  if n gt 0 then begin			; More than 0.
	    tmp = fltarr(n)			; Array to read them into.
	    on_ioerror,err
	    reads,t,tmp				; Read them.
	    on_ioerror,null
	    out = [out,tmp]			; Add to output array.
	    goto, skip
err:	    bell
	    print,' '
	    print,' Error: data_block ignoring the following line:'
	    print,t
	    print,' Line '+strtrim(i+1,2)+' in '+name
	    print,' Use a double comment, ;;, to skip over lines in data blocks.
skip:
	  endif
	endelse
	if eod_pos ge 0 then goto, done		; Was last data block line.
	i = i+1					; Read another line.
	goto, loop
 
done:	out = out(1:*)				; Drop seed value.
	err = 0
	return
 
	end
