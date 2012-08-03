;-------------------------------------------------------------
;+
; NAME:
;       RESCLOSE
; PURPOSE:
;       Close results file.
; CATEGORY:
; CALLING SEQUENCE:
;       resclose
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FD=fd    Optional file descriptor.  Allows multiple res
;           files to be used at once.
;         /QUIET suppresses error messages.
;         /EXTENDED Keep file pointer as long64 if it already is.
;         /FORCE Force file pointer to long64.  This might
;           overwrite first array unless file was opened in IDL
;           with long64 data type.  Also will give an error if
;           current IDL version does not have long64 data type.
;       
;           If the file has been opened for WRITE with XDR then
;           it must use the short file pointer (XDR open for write
;           cannot be read to determine the pointer type).
; OUTPUTS:
; COMMON BLOCKS:
;       results_common
; NOTES:
;       Notes: one of the results file utilities.
;         See also resopen, resput, resget, rescom.
; MODIFICATION HISTORY:
;       R. Sterner, 19 Jun, 1991
;       R. Sterner, 14 Feb, 1992 --- added /QUIET.
;       R. Sterner, 2004 Feb 10 --- Supported extended file pointer (LONG64).
;       R. Sterner, 2004 Feb 19 --- Default to short fp, keyword overrides.
;       R. Sterner, 2004 Apr 07 --- Only short file pointer for XDR.
;       (Cannot read XDR file if open for write).
;       R. Sterner, 2004 Sep 27 --- Added FD=fd to give file descriptor.
;       R. Sterner, 2006 Mar 08 --- Handled files closed outside resclose.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro resclose, help=hlp, quiet=quiet, extended=extended, $
	  force=force, fd=fd
 
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
 
	if keyword_set(hlp) then begin
	  print,' Close results file.'
	  print,' resclose'
	  print,'   No arguments.'
	  print,' Keywords:'
	  print,'   FD=fd    Optional file descriptor.  Allows multiple res'
	  print,'     files to be used at once.'
	  print,'   /QUIET suppresses error messages.'
	  print,'   /EXTENDED Keep file pointer as long64 if it already is.'
	  print,'   /FORCE Force file pointer to long64.  This might'
	  print,'     overwrite first array unless file was opened in IDL'
	  print,'     with long64 data type.  Also will give an error if'
	  print,'     current IDL version does not have long64 data type.'
	  print,' '
	  print,'     If the file has been opened for WRITE with XDR then'
	  print,'     it must use the short file pointer (XDR open for write'
	  print,'     cannot be read to determine the pointer type).'
	  print,' Notes: one of the results file utilities.'
	  print,'   See also resopen, resput, resget, rescom.'
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
 
	if n_elements(r_open) eq 0 then r_open = 0
	;-------  File open?  ----------
	if r_open eq 0 then begin
	  if not keyword_set(quiet) then print,' No results file is open.'
	  return
	endif
 
	;------  Close file that was open for reading  -----
	if r_open eq 1 then begin
	  close, r_lun
	  free_lun, r_lun
	  r_open = 0
	  if arg_present(fd) then fd.r_open=r_open
	  return
	endif
 
	;------  Close file that was open for writing  ------
	;---  Must first write header at end of file  -------
	if n_elements(r_hdr) eq 1 then begin	; NULL file.
	  if not keyword_set(quiet) then print,' Nothing written to file.'
	  goto, skip
	endif
 
	;-----  Get file pointer (after last write)  -----
	fs = fstat(r_lun)		; Get file status.
	if fs.open eq 0 then goto, skip	; Was not really open.
	fp = fs.cur_ptr			; Get file pointer.
;	fp = 4L*ceil(fp/4.)		; Force to multiple of 4.
 
	;-----  Read previous pointer to see if extended  -----
	front = lonarr(3)		; Set up first thing in file.
	if fs.xdr ne 1 then begin	; Can only write to XDR file (if openw).
	  point_lun, r_lun, 0		; Set file pointer to file start.
	  readu, r_lun, front		; Get current header pointer.
	endif
 
	;------  Prepare header  ------------------
;	front(0) = fp			; Item 1 is header position.
	r_hdr = r_hdr(1:*)		; Trim leading null.
	r_hdr = [r_hdr,'END']		; Add END.
	b = byte(r_hdr)			; Convert header to a byte array.
	sz = size(b)			; Get size.
	front(1) = sz(1:2)		; Move header size to FRONT array.
 
	;-------  Write out new header pointer  ------
	point_lun, r_lun, 0		; Set file pointer to file start.
	fp0 = front(0)			; Current pointer to header.
	maxlong = 2L^31-1		; Max long int.
	if (fp gt maxlong) or (fp lt 0) then flag=1 else flag=0	; Long or short?
	if keyword_set(extended) then flag=1	; Want long (extended).
	if fs.xdr eq 1 then flag=0	; XDR only allows short pointer.
 
	;  ---- Use short file pointer  ----
	if flag eq 0 then begin		; Use short file pointer.
	  front(0) = fp			; Header pointer, old (short) style.
	  writeu, r_lun, front		; Write header pointer and size.
	;  ---- Use extended file pointer  ----
	endif else begin		; Use extended file pointer.
	  if fp0 eq -1 then begin	; OK to use extended.
	    writeu,r_lun,front,long64(fp) ; Write front and extended ptr.
	  endif else begin		; Was not using extended file pointer.
	    if keyword_set(force) then begin  ; Force extended.
	      front(0) = -1		      ; Point to extended file pointer.
	      writeu,r_lun,front,long64(fp)   ; Write front and fp.
	    endif else begin
	      if not keyword_set(quiet) then begin
	        print,' Error in resclose. File too big.  Need extended'
	        print,'   file pointer.'
	        print,'   Do .con to attempt to save file (may clobber 1st'
	        print,'   array), or retall to abort.'
	        stop
	        print,' Forcing extended file pointer.  May or may not lose'
	        print,' first array in file.'
	        front(0) = -1
	        writeu,r_lun,front,long64(fp)
	      endif
	    endelse ; force.
	  endelse ; fp0.
	endelse ; flag.
 
	;-------  Write out new header  ---------
	point_lun, r_lun, fp		; Set file pointer to header position.
	writeu, r_lun, b		; Write header as byte array.
 
	;-------  Close file and free lun  ------
skip:	close, r_lun			; Close file.
	free_lun, r_lun
	r_open = 0			; Flag as closed.
	if arg_present(fd) then fd.r_open=r_open
	return
 
	end
