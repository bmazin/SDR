;-------------------------------------------------------------
;+
; NAME:
;       FUTIL
; PURPOSE:
;       A system independent file utility (copy, move, delete, chmod...).
; CATEGORY:
; CALLING SEQUENCE:
;       futil, filename
; INPUTS:
;       filename = input file.   in
; KEYWORD PARAMETERS:
;       Keyword:
;          TO=dest  Name of destination file if needed.
;          /MOVE    Move file
;          /COPY    Copy file
;          /DELETE  Delete file
;          /CHMOD   Chmod file
;          OCTSTR=octstr,  Octal string with file permissions.
;          /QUIET   Print no messages while processing.
;          ERR=err  Error flag: 0=ok, 1=no such file,
;             2=no action given, 3=no octal string specified for chmod.
;       
;       
;       Copying 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Frank Monaldo  2003 Nov 7
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
pro futil, filename, move=move, copy=copy, delete=delete, $
           chmod=chmod, octstr=octstr, to=to, err=err, quiet=quiet,help=hlp
 
if keyword_set(hlp) or n_params(0) eq 0 then begin
  print, ' A system independent file utility (copy, move, delete, chmod...).'
  print, ' futil, filename'
  print, '   filename = input file.   in'
  print, ' Keyword:'
  print, '    TO=dest  Name of destination file if needed.'
  print, '    /MOVE    Move file'
  print, '    /COPY    Copy file'
  print, '    /DELETE  Delete file'
  print, '    /CHMOD   Chmod file'
  print, '    OCTSTR=octstr,  Octal string with file permissions.'
  print, '    /QUIET   Print no messages while processing.'
  print, '    ERR=err  Error flag: 0=ok, 1=no such file,'
  print,'       2=no action given, 3=no octal string specified for chmod.'
  return
endif
 
printflag=               1
if keyword_set(quiet)   then printflag=0
;
; Determine System Arch'
;
release=               !version.release
os_family = strupcase( !version.os_family )
err=     0
;
; Copy filename to to
;
if keyword_set(copy) then begin
  if release ge 5.6 then begin
    result= file_search(filename)
    if result(0) ne '' then  begin
       if printflag then print, 'Copying ' + filename + ' to ' + to
       file_copy, filename,  to,  /overwrite, /allow_same
       err=0
    endif else begin
       err=1
       if printflag then print, 'File ' + filename + ' does not exist.'
    endelse
  endif else begin
    ;
    ; For earlier IDL release 5.5 or less revert to Unix/Windows system command
    ;
    case os_family of
    'UNIX': begin
            cmd= 'cp ' + filename + ' ' + to
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    'WINDOWS': begin
            cmd= 'copy ' + filename + ' ' + to
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    else:  begin
            print,'Cannot copy. Pre IDL 5.6 and unsupported OS operating system family.'
	    err=1
	    end
    endcase
  endelse
  return
endif
;
; Move filename to to
;
if keyword_set(move) then begin
  if release ge 5.6 then begin
    result= file_search(filename)
    if result(0) ne '' then  begin
       if printflag then print, 'Moving ' + filename + ' to ' + to
       file_move, filename,  to,  /overwrite
       err=0
    endif else begin
       err=1
       if printflag then print, 'File ' + filename + ' does not exist.'
    endelse
  endif else begin
    ;
    ; For earlier IDL release 5.5 or less revert to Unix system command
    ;
    case os_family of
    'UNIX': begin
            cmd= 'mv ' + filename + ' ' + to
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    'WINDOWS': begin
            cmd= 'move ' + filename + ' ' + to
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    else:  begin
            print,'Cannot move. Pre IDL 5.6 and unsupported OS operating system family.'
	    err=1
	    end
    endcase
  endelse
  return
endif
 
;
; Delete file
;
if keyword_set(delete) then begin
  if release ge 5.6 then begin
     file_delete, filename, /allow_nonexistent
     err=0
  endif else begin
    ;
    ; For earlier IDL release 5.5 or less revert to Unix system command
    ;
    case os_family of
    'UNIX': begin
            cmd= 'rm -f ' + filename
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    'WINDOWS': begin
            cmd= 'del ' + filename + ' ' + to
            if printflag then print, cmd
            spawn, cmd
            err=0
	    end
    else:  begin
            print,'Cannot delete. Pre IDL 5.6 and unsupported OS operating system family.'
	    err=1
	    end
    endcase
  endelse
  return
endif
 
;
; Chmod file, i.e. change file permissions
;
if keyword_set(chmod) then begin
  if release ge 5.6 then begin
    if octstr ne '' then begin
      value = basecon(octstr, from=8)
      file_chmod,  filename, value
      err=0
    endif else begin
      if printflag then print, 'Octstr does not exist'
      err=3 ; octstr does not exist
    endelse
    return
  endif else begin
    ;
    ; For earlier IDL release 5.5 or less revert to Unix system command
    ;
    if octstr ne '' then begin
      cmd= 'chmod ' + octstr + ' ' + filename
      if printflag then print, cmd
      spawn, cmd
      err=0
    endif else begin
      err=3 ; octstr does not exist
       if printflag then print, 'Octstr does not exist'
    endelse
  endelse
  return
endif
 
err=2
;
print, 'No copy, move, delete or chmod action for "' + filename + '" given.'
end
