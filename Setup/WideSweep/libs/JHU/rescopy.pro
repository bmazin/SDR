;-------------------------------------------------------------
;+
; NAME:
;       RESCOPY
; PURPOSE:
;       Copy a res file to another res file, may drop items.
; CATEGORY:
; CALLING SEQUENCE:
;       rescopy, resfile, resfile2
; INPUTS:
;       resfile  = name of existing input RES file. in
;       resfile2 = name of new output RES file.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         IGNORE=ignore Optional string array of tags to be ignored.
;         /NOCOMMENTS means do not copy RES file comments.
;         FRONT=txt Optional text array of comments to add to
;           front of output res file.
;         /TIME_TAG adds 2 comments at very front of output file
;           giving the copy time, user, and directory.
;         /DEBUG list what is happening.
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Sep 28
;       R. Sterner, 2004 Oct 12 --- Fixed to not read ignored items.
;       R. Sterner, 2004 Oct 12 --- Comments with = were broke, fixed.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro rescopy, resfile, resfile2, error=err, $
	  nocomments=nocom, ignore=ignore0, front=front, $
	  time_tag=time_tag, debug=debug, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Copy a res file to another res file, may drop items.'
	  print,' rescopy, resfile, resfile2'
	  print,'   resfile  = name of existing input RES file. in'
	  print,'   resfile2 = name of new output RES file.     in'
	  print,' Keywords:'
	  print,'   IGNORE=ignore Optional string array of tags to be ignored.'
	  print,'   /NOCOMMENTS means do not copy RES file comments.'
	  print,'   FRONT=txt Optional text array of comments to add to'
	  print,'     front of output res file.'
	  print,'   /TIME_TAG adds 2 comments at very front of output file'
	  print,'     giving the copy time, user, and directory.'
	  print,'   /DEBUG list what is happening.'
	  print,'   ERROR=err error flag: 0=ok.'
	  return
	endif
 
	;-----  Open input RES file  -----------
	resopen,fd=fd1,resfile,err=err,header=h
	if err ne 0 then return
 
	;-----  Open output RES file  -----------
	resopen,fd=fd2,resfile2,err=err,/write
	if err ne 0 then return
 
	;-----  Set ignore list flag --------
	if n_elements(ignore0) gt 0 then begin
	  iflag = 1
	  ignore = strupcase(ignore0)
	endif else iflag=0
 
	;------  Time tag  -------------
	if keyword_set(time_tag) then begin
	  resput,fd=fd2,comm=created(verb='Copied')
	  resput,fd=fd2,comm=created(by=2)
	endif
 
	;------  Add any front end comments to output file  -----
	if n_elements(front) ne 0 then begin
	  for i=0,n_elements(front)-1 do begin
	    resput,fd=fd2,comm=front(i)			; Write out comment.
	  endfor
	endif
 
	;-----  Loop through res file entries  --------
	n = n_elements(h)-1			; # header items (ignore end)
	for i=0,n-1 do begin
;	  resget,fd=fd1,tag,val,number=i		; Grab i'th file item.
	  tag = getwrd(h(i),del='=')
	  if strmid(tag,0,1) eq '*' then cflag=1 $	; Check if comment.
	    else cflag=0
	  ;----  Comment  ------
	  if cflag then begin				; Deal with a comment.
	    if keyword_set(nocom) then continue		; Ignore.
;	    val = strmid(tag,1,999)			; Drop leading *.
	    val = strmid(h(i),1,999)			; Drop leading *.
	    resput,fd=fd2,comm=val			; Write out comment.
	    continue					; Next loop.
	  endif
	  ;----  Ignore specified tags  ------
	  if iflag then begin				; Any ignore list?
	    w = where(strupcase(tag) eq ignore,cnt)	; Ignore this tag?
	    if cnt gt 0 then continue			; If so skip next.
	  endif
	  ;----  write tag/value pair  ---------
	  if keyword_set(debug) then begin
	    print,' Reading '+tag+'...'
	  endif
	  resget,fd=fd1,tag,val				; Grab i'th file item.
	  resput,fd=fd2,tag,val				; Copy to new file.
	endfor
 
	resclose, fd=fd2				; Close output file.
	resclose, fd=fd1				; Close input file.
	
	end
