;-------------------------------------------------------------
;+
; NAME:
;       RESOPEN
; PURPOSE:
;       Open a results file for reading or writing.
; CATEGORY:
; CALLING SEQUENCE:
;       resopen, file
; INPUTS:
;       file = results data file name.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /WRITE means open file for write.
;         /APPEND used with /WRITE to append to a file.
;         /XDR means use XDR.
;         FD=fd Returned file descriptor if opened successfully.
;           May pass in FD=fd to the other res file routines to
;           allow multiple res files to be in use at once. if FD
;           keyword used resopen will not close any open res files.
;         HEADER=h returned header array on open for read.
;         FSTAT=fst returned file status structure.
;         ERROR=e  error code:
;           0 = OK.
;           1 = File not found.
;           2 = File not a results file.
;           3 = File not opened.
;         TEXT_ERROR=txterr returned error message.
;         /QUIET means don't display any error messages.
;         /SWAP force endian swap.
;         /NOSWAP force no endian swap.
;           Endian should be detected automatically and corrected.
; OUTPUTS:
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resput, resget, rescom, resclose.
;         Using a file descriptor, fd, allows multiple res files
;         to be in use.  Pass fd to a routine through the FD keyword.
;         If FD=fd is not used then the last res file accessed, if
;         any, will be used.  This may cause an error, so if fd is
;         used at all use it for all calls in the idl session.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Jun, 1991
;       R. Sterner, 2 Jan, 1992 --- added def='.' to open*
;       R. Sterner, 1994 Jun 22 --- Added automatic close of an open file.
;       R. Sterner, 1994 Jul 26 --- Modified automatic close.
;       R. Sterner, 1994 Aug 11 --- Made sure r_open was defined.
;       R. Sterner, 1994 Sep 12 --- Added /APPEND.
;       R. Sterner, 1994 Sep 27 --- Fixed /XDR openu problem.
;       R. Sterner, 2000 Mar 08 --- Fixed test for res file to compute expected file size.
;       R. Sterner, 2000 Apr 11 --- Handled endian problem.
;       R. Sterner, 2004 Feb 10 --- Used resclose to close any open res file.
;       R. Sterner, 2004 Feb 10 --- Supported extended file pointer (LONG64).
;       R. Sterner, 2004 Feb 16 --- Fixed to deal with endian before file pntr.
;       R. Sterner, 2004 Sep 27 --- Added FD=fd to return file descriptor.
;       R. Sterner, 2004 Sep 30 --- Fixed r_swap flag on resopen,/write.
;       Also checked if file already open.
;       R. Sterner, 2005 Feb 03 --- Made /QUIET apply to file already open.
;       Also made this case a warning (not error) and returned err=0.
;       R. Sterner, 2007 Sep 12 --- Corrected help text layout.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro resopen, file, header=hdr, error=err, fstat=fst, $
	  write=write, xdr=xdr, help=hlp, quiet=quiet, $
	  text_error=errtxt, append=append, noswap=noswap, $
	  swap=swap, fd=fd
 
        common results_common, r_file, r_lun, r_open, r_hdr, r_swap
        ;----------------------------------------------------
        ;       r_file = Name of results file.
        ;       r_lun  = Unit number of results file.
        ;       r_open = File open flag. 0: not open.
        ;                                1: open for read.
        ;                                2: open for write.
        ;       r_hdr  = String array containing file header.
	;	r_swap = Swap endian if set.
        ;----------------------------------------------------
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
          print,' Open a results file for reading or writing.'
          print,' resopen, file'
          print,'   file = results data file name.    in'
          print,' Keywords:'
	  print,'   /WRITE means open file for write.'
	  print,'   /APPEND used with /WRITE to append to a file.'
	  print,'   /XDR means use XDR.'
	  print,'   FD=fd Returned file descriptor if opened successfully.'
	  print,'     May pass in FD=fd to the other res file routines to'
	  print,'     allow multiple res files to be in use at once. if FD'
	  print,'     keyword used resopen will not close any open res files.'
	  print,'   HEADER=h returned header array on open for read.'
	  print,'   FSTAT=fst returned file status structure.'
          print,'   ERROR=e  error code:'
	  print,'     0 = OK.'
	  print,'     1 = File not found.'
          print,'     2 = File not a results file.'
	  print,'     3 = File not opened.'
	  print,'   TEXT_ERROR=txterr returned error message.'
	  print,"   /QUIET means don't display any error messages."
	  print,'   /SWAP force endian swap.'
	  print,'   /NOSWAP force no endian swap.'
	  print,'     Endian should be detected automatically and corrected.'
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resput, resget, rescom, resclose.'
	  print,'   Using a file descriptor, fd, allows multiple res files'
	  print,'   to be in use.  Pass fd to a routine through the FD keyword.'
	  print,'   If FD=fd is not used then the last res file accessed, if'
	  print,'   any, will be used.  This may cause an error, so if fd is'
	  print,'   used at all use it for all calls in the idl session.'
   	  return
	endif
 
	;-----------  Open file for read or write  --------
	if n_elements(xdr) eq 0 then xdr = 0
	if n_elements(r_open) eq 0 then r_open = 0
	if n_elements(r_file) eq 0 then r_file = ''
	if n_elements(append) eq 0 then append = 0
	if keyword_set(xdr) and keyword_set(append) then begin
	  print,' Error in resopen: IDL does not allow XDR files to be'
	  print,'   opened for both input and output simultaneously.'
	  err = 3
	  return
	endif
	if r_open gt 0 then begin		; Any files open?
	  if file eq r_file then begin		; Make sure not already open.
	    if not keyword_set(quiet) then begin
	      print,' Warning in resopen: File already open:'
	      print,'   '+file
	    endif
	    err = 0
	    return
	  endif
	endif
	aflag = 0				; Append flag.
	if n_elements(r_lun) ne 0 then begin
;	  if r_open ne 0 then free_lun, r_lun	; Close any open file.
	  if r_open ne 0 then begin		; Any files open?
	    if not arg_present(fd) then begin	; Yes. Close if not using FD.
	      resclose
	    endif
	  endif
	endif
        on_ioerror, err
	get_lun, r_lun
	;=============  Open for WRITE  ================
	if keyword_set(write) then begin	; WRITE.
	  f = findfile(file, count=cnt)		; See if file exists.
	  ;------  create new file using openw  ----------
	  if cnt eq 0 then begin
	    if !version.os eq 'vms' then begin	; VAX.
	      openw, r_lun, file, /stream, xdr=xdr, def='.'
	    endif else begin			; Unix.
	      openw, r_lun, file, /stream, xdr=xdr
	    endelse
	    close, r_lun			; File now exists.
	  endif
	  ;------  File exists, open using openu  -------
	  if !version.os eq 'vms' then begin	; VAX.
	    if keyword_set(xdr) then begin	;    XDR
	      openw, r_lun, file, /stream, xdr=xdr, def='.'
	    endif else begin			;    Non-XDR.
	      openu, r_lun, file, /stream, xdr=xdr, def='.'
	    endelse
	  endif else begin			; Unix.
	    if keyword_set(xdr) then begin	;    XDR
	      openw, r_lun, file, /stream, xdr=xdr
	    endif else begin			;    Non-XDR.
	      openu, r_lun, file, /stream, xdr=xdr
	    endelse
	  endelse
	  ;-----------------------------------------------
	  on_ioerror, null
	  r_open = 2				; Set open flag to write.
	  r_file = file				; Set file name in common.
	  if append eq 1 then aflag=1		; Requested append.
	  f = fstat(r_lun)			; Look at opened file.
	  if f.size eq 0 then aflag=0		; New file, no append.
	  if aflag eq 0 then begin		; If no append.
	    r_hdr = ['']			; Initialize header array.
	    test = 3000000000			; Too big for LONG (BLG trick).
	    l64_flag = test gt 0		; LONG64 available? 1=yes,0=no.
	    if l64_flag then begin		; Use extended file pointer.
	      writeu, r_lun, [-1L,0L,0L],0LL	; -1 points to extended fp.
	    endif else begin			; Old short file pointer.
	      writeu, r_lun, [0L,0L,0L]		; For hdr location and size.
	    endelse
	    err = 0
	    fd = {r_file:r_file, r_lun:r_lun, $	; Return file descriptor.
	          r_open:r_open, r_hdr:r_hdr, r_swap:0}
	    return
	  endif
	;=============  Open for READ  ================
	endif else begin			; READ.
	  if !version.os eq 'vms' then begin
	    openr, r_lun, file, xdr=xdr, def='.'
	  endif else begin
	    openr, r_lun, file, xdr=xdr
	  endelse
	  r_open = 1				; Set open flag to read.
	endelse
 
;===================================================================
	;----------  read header  ----------
	front = lonarr(3)			; Header pointer array.
	readu, r_lun, front			; read header pointer.
	;-------  Deal with endian  --------------
	if abs(front(1)+0D0) gt 10000 then r_swap=1 else r_swap=0
	if keyword_set(noswap) then r_swap=0
	if keyword_set(swap)   then r_swap=1
	if r_swap eq 1 then front=swap_endian(front)
	fp = front(0)				; Pointer to header.
	if fp eq -1 then begin			; Get extended pointer.
	  fp = 0LL
	  readu, r_lun, fp			; Read LONG64 pointer.
	endif
 
	if abs(front(1)+0D0) gt 10000 then begin
          if not keyword_set(quiet) then print,' Not a results file.'
          err = 2
          goto, done
	endif
	if fp eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Nothing is in the file '+file
	  err = 2
	  goto, done
	endif
	fs = fstat(r_lun)
	fsize = fs.size
	csize = fp + front(1)*front(2)
	if csize gt fsize then begin          ; Not RES file.
          if not keyword_set(quiet) then print,' Not a results file.'
          err = 2
          goto, done
        endif
	if front(1) gt 2500 then begin		; Not RES file.
	  if not keyword_set(quiet) then print,' Not a results file.'
	  err = 2
	  goto, done
	endif
	b = bytarr(front(1),front(2))		; Set up header byte array.
	point_lun, r_lun, fp			; Set file pointer to header.
	on_ioerror, err2
	readu, r_lun, b				; Read header byte array.
	on_ioerror, null
 
	;----------  Convert byte array to a string array  ---------
	hdr = string(b)
 
	;------  Handle /APPEND  ------------
	if aflag eq 1 then begin
	  hdr = hdr(0:front(2)-2)  		; Drop END from hdr if APPEND.
	  hdr = ['',hdr]			; Add null string to front.
	  point_lun, r_lun, fp			; Set file ptr for next write.
	endif
 
	;-----  Set common values  -------
	r_file = file
	r_hdr = hdr
 
        err = 0
	fst = fstat(r_lun)
	fd = {r_file:r_file, r_lun:r_lun, $	; Return file descriptor.
	      r_open:r_open, r_hdr:r_hdr, r_swap:r_swap}
	return
 
err:    errtxt = ' Error: Results file '+file+' not opened.'
        err = 1
        goto, errex
 
err2:   errtxt = ' Error: file '+file+' not a results file.'
        err = 2
        goto, errex
 
errex:	if not keyword_set(quiet) then print,errtxt
 
done:	free_lun, r_lun
	return
 
	end
