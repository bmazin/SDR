;-------------------------------------------------------------
;+
; NAME:
;       PSTERM
; PURPOSE:
;       Terminate postscript plotting and send plots to printer.
; CATEGORY:
; CALLING SEQUENCE:
;       psterm
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOPLOT terminates without plotting.
;         /QUIET turns off psterm messages.
;         /LAST plots existing idl.ps file (usually last plot).
;         /NOSTAMP suppresses default user name and time stamp.
;         /CLEAR_COMMENT  clears comment after listing it.
; OUTPUTS:
; COMMON BLOCKS:
;       ps_com,dname,xthick,ythick,pthick,pfont,defnum,num,comm
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;       R. Sterner, 23 May 1990 --- converted to VMS.
;       R. Sterner, 23 Jul, 1990 --- added /nostamp.
;       R. Sterner, 20 Dec, 1990 --- added comment to time stamp.
;       R. Sterner, 1998 Jun  4 --- Added char size.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro psterm, q, help=hlp, noplot=nop, quiet=qt, last=lst, $
	  nostamp=nostmp, clear_comment=clear
 
	common ps_com,dname,xthick,ythick,pthick,pfont,defnum,num,comm, $
	  pfile,csz0
 
	if keyword_set(hlp) then begin
	  print,' Terminate postscript plotting and send plots to printer.'
	  print,' psterm'
	  print,'   No arguments.  Plots are sent to the printer that'
	  print,'   was selected with psinit.  See psinit.'
	  print,' Keywords:
	  print,'   /NOPLOT terminates without plotting.'
	  print,'   /QUIET turns off psterm messages.'
	  print,'   /LAST plots existing idl.ps file (usually last plot).'
	  print,'   /NOSTAMP suppresses default user name and time stamp.'
	  print,'   /CLEAR_COMMENT  clears comment after listing it.'
	  return
	endif
 
	qflg = not keyword_set(qt)
 
	if keyword_set(lst) then goto, skip	; Repeat last plot.
 
	if !d.name ne 'PS' then begin
	  if qflg then print,' Not in postscript mode.'
	  return
	endif
 
	if keyword_set(nop) then begin
	  if not keyword_set(nostmp) then begin
	    xyouts,-100,0,/dev,orient=90,size=csz0,upcase1(getenv('USER'))+' '+$
	      systime(0) + ' ' + comm
	  endif
	  device, /close
	  if qflg then print,' Postscript output terminated without plot.'
	  goto, reset
	endif
 
skip:	if qflg then print,' Sending plot to postscript printer . . .'
	if not keyword_set(nostmp) then begin
	  xyouts,-100,0,/dev,orient=90,size=csz0,upcase1(getenv('USER'))+$
	    ' '+systime(0)+ ' ' + comm
	endif
	if !d.name eq 'PS' then device, /close
	cd, current=dir			; Should work for both.
	dir = dir(0)
	getsysnams,'IDL_PSPRINTERS',npr,cmds,plist
	if npr le 0 then begin
	  print,' Error in psterm: check that the environmental variable'
	  print,'   or symbol IDL_PSPRINTERS names a file describing the'
	  print,'   postscript printers on the system.'
	  return
	endif
	if (num lt 0) or (num gt npr-1) then begin
	  print,' Error in psterm: selected printer number not available.'
	  return
	endif
	if pfile eq '' then begin		; Use default plot file.
	  fname = filename(dir,'idl.ps',/nosym)	; Sys independent name.
	endif else begin			; Use specified plot file.
	  fname = pfile
	endelse
	spawn, cmds(num) + ' ' + fname
 
	if qflg then print,' Plot sent to ' + plist(num)
 
reset:	set_plot, dname 
	!x.thick = xthick
	!y.thick = ythick
	!p.thick = pthick
	!p.font = pfont
	if keyword_set(clear) then comm = ''
 
	return
	end
