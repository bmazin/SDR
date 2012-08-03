;+
; NAME:
;        SYSTEM
;
; PURPOSE:
;        This is an alternative to the SPAWN routine.  It is similar in both
;        inputs and keywords as SPAWN, except that it returns ONLY after the
;        spawned process has been completed.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        SYSTEM [, Commands]
;
; INPUTS:
;        Commands: A string or ARRAY of strings of DOS commands..
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        DT:  The time interval in SECONDS to wait for before checking whether
;             the spawned process is complete, (Number of Commands=Default).
;
;        TIMEOUT:  The maximum time to wait in SECONDS for the specified DOS
;             command(s) to be completed, (inf=Default).
;
; PROCEDURE:
;
;        A batch file is created containing the specified DOS command(s).
;        An additional command is added at the end of this file that deletes
;        the batch file.  This serves as "clean up" housekeeping as well as a
;        signature that the batch process is complete.  The batch file is then
;        executed using the spawn command. This routine returns control to the
;        USER when the batch file has been deleted or,  if the TIMEOUT keyword
;        is set, when the process time has has exceed the timed out period.
;
; RESTRICTIONS:
;
;        This routine may be currently used ONLY on Windows or Unix.
;        Calls to batch files in Windows must have the CALL batch command
;        preceeding the name of the batch file, (e.g. CALL dothis.bat).
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995.
;        14-JUL-1995    The string(13b), i.e. carriage return characters is to
;                       counter a IDL 4.0 bug has writing out text files.
;        04-AUG-1995    Put command to delete batch file in the batch file itself.
;        14-AUG-1995    Bugfix: Suppress newline (CR-LF) characters for last batch
;                       command, 'del batchfile' to prevent "batch file not found"
;                       error.
;        15-AUG-1995    Eliminated the need for a Signature File (SYSTEM.TXT) by
;                       searching instead, for the deletion of the batch file.
;        15-AUG-1995    Added ability to run on Unix.
;        06-DEC-1995    Eliminated the CALL prefix.
;        07-AUG-1996    Use TMPFILE() to generate batch file name, eliminate
;                       calls to VERSION().
;-
pro SYSTEM, Commands, DT=DT, _EXTRA=Spawn_keys, ANONYMOUS_=Dummy, TIMEOUT=Timeout

         nc   = N_ELEMENTS(Commands)
         if N_ELEMENTS(DT) eq 0 then DT = nc


         VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
         case VERSION_OS of
           'win'   :
           'vms'   : print,'vms platform not supported.'
           'mac'   : print,'MacOS platform not supported.'
           else    :
         endcase

         CR   =''

;   Check length of DOS commands

         if (VERSION_OS eq 'win') then begin
              maxlen= 127
              lens  = strlen(Commands)
              here  = where( lens gt maxlen, nbad )
              if (nbad gt 0) then begin
                   message,'Specified DOS command(s) > '+strtrim(maxlen,2)+$
                             ' characters:',/INF
                   for i=0,nbad-2 do $
                        message,Commands(here(i)),/INF
                   message,Commands(here(nbad-1))
              endif
         endif

;   Create a batch file or shell script of the desired spawn Commands with
;   a self-delete command at the end to signify its completion.

         batchfile= TMPFILE('~sys','bat',SEED=Seed)

         openw,lu,batchfile,/GET_LUN
         for i=0,nc-1 do $
              printf,lu,Commands(i)+CR
         if (VERSION_OS eq 'win') then begin
              printf,lu,'@echo OFF'
              printf,lu,'del '+batchfile,FORMAT='(A,$)'
         endif else printf,lu,'rm '+batchfile
         close,lu
         free_lun,lu

         if (VERSION_OS ne 'win') then spawn,'chmod +x '+batchfile

         spawn, batchfile

;   Wait until the ~SYSnnnn.BAT file is deleted, signifying
;   the completion of the spawned process

         t0   = SYSTIME(1)
         repeat begin
              wait, DT
              f = findfile(batchfile,COUNT=n)
              if keyword_set(Timeout) then begin
                   dt = SYSTIME(1) - t0
                   if (dt gt Timeout) and (n eq 1) then begin
                        message,'Timeout - '+STRTRIM(Timeout,2)+' Seconds',/INF
                        return
                   endif
              endif
         endrep until (n eq 0)
end
