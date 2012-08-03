;-------------------------------------------------------------
;+
; NAME:
;       HEXDUMP
; PURPOSE:
;       Display a file in hex.
; CATEGORY:
; CALLING SEQUENCE:
;       hexdump, file
; INPUTS:
;       file = File to display.  in
;          File may optionally be a byte array to dump.
; KEYWORD PARAMETERS:
;       Keywords:
;         NBYTES=n Bytes to display on each line (def=10).
;         LINES=lns Lines in group (def=20).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Enter ? when --- more --- is displayed
;         to get a list of commands.
;         Unprintable characters are translated to be
;         visible as follows:     Ascii  Hex
;            Carriage Return: ©    13    0D
;            Line Feed:       £    10    0A
;            Tab:             »     9    09
;            Other:           °
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Nov 22
;       R. Sterner, 2002 Mar 25 --- Added more help text.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hexdump, file, nbytes=nbytes, lines=lines, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a file in hex.'
	  print,' hexdump, file'
	  print,'   file = File to display.  in'
	  print,'      File may optionally be a byte array to dump.'
	  print,' Keywords:'
	  print,'   NBYTES=n Bytes to display on each line (def=10).'
	  print,'   LINES=lns Lines in group (def=20).'
	  print,' Notes: Enter ? when --- more --- is displayed
	  print,'   to get a list of commands.'
	  print,'   Unprintable characters are translated to be'
	  print,'   visible as follows:     Ascii  Hex'
	  print,'      Carriage Return: ©    13    0D'
	  print,'      Line Feed:       £    10    0A'
	  print,'      Tab:             »     9    09'
	  print,'      Other:           °'
	  return
	endif
 
	if n_elements(nbytes) eq 0 then nbytes=10
 
	if n_elements(lines) eq 0 then lines=20L
	lines = long(lines)
 
	buff = bytarr(nbytes,lines)
 
	fmt = '(I10.10,3x,'+strtrim(nbytes/2,2)+'(2Z2.2,x),3x,a)'
 
	offset = 0L
	step = lines*nbytes
 
	if datatype(file) eq 'STR' then begin
	  openr,lun,file,/get_lun
	  dump_flag = 'F'
	  print,' '
	  print,' Hex dump of file '+file
	endif else begin
	  if datatype(file) ne 'BYT' then begin
	    print,' Error in hexdump: Must give a file name or byte array.'
	    return
	  endif
	  lst = n_elements(file)-1	; Last available byte number.
	  dump_flag = 'B'
	  print,' '
	  print,' Hex dump of byte array of size '+ $
	    strtrim(n_elements(file),2)+' bytes'
	endelse
 
	on_ioerror, errex
	flag = 0		; Last read flag.
 
	print,' ? for help'
loop:	if dump_flag eq 'F' then begin
	  readu,lun,buff
	endif else begin
	  lo = offset
	  hi = lo+step-1
	  if hi ge lst then flag=1
	  hi = hi<lst
	  buff(*) = 0
	  buff(0) = file(lo:hi)
	endelse
last:	for i=0L,lines-1 do begin
	  add = offset + i*nbytes
	  b = buff(*,i)
	  t = b
	  w9 = where(t eq 9,c9)
	  w10 = where(t eq 10,c10)
	  w13 = where(t eq 13,c13)
	  w = where((t lt 32) or (t gt 126),c)
	  if c gt 0 then t(w) = 176B			; Non-printing.
	  if c9 gt 0 then t(w9) = 187B			; Tab
	  if c10 gt 0 then t(w10) = 163B		; LF
	  if c13 gt 0 then t(w13) = 169B		; CR
	  spc = bytarr(nbytes)+32B
	  ss = string((transpose([[spc],[t]]))(0:*))
	  print,add,b,ss,form=fmt
	endfor
	if flag eq 1 then begin
	  print,' --- EOF ---'
	  goto, quit
	endif
	print,' --- more --- '
	k = get_kbrd(1)
	if strupcase(k) eq 'Q' then goto, quit
	if strupcase(k) eq 'S' then stop
	if strupcase(k) eq 'J' then begin
	  jmp = ''
	  read,' Enter byte address: ',jmp
	  if jmp ne '' then begin
	    jmp = jmp + 0L
	    point_lun, lun, jmp
	    offset = jmp
	    goto, loop
	  endif
	endif
	if k eq '?' then begin
	  print,' Q - Quit'
	  print,' S - Debug stop'
	  print,' J - Jump to byte address in file'
	  print,' ? - Commands'
	  print,' Special characters: '+$
	    string(187B)+'=Tab, '+string(163B)+'=LF, '+$
	    string(169B)+'=CR, '+string(176B)+'=non-printing'
	  tmp = ''
	  read,' Return to continue ',tmp
	endif
	offset = offset + step
	goto, loop
 
errex:	flag = 1
	goto, last
 
quit:	if dump_flag eq 'F' then free_lun, lun
	
	end
