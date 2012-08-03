
;+
; NAME:
;        DIR_EXIST
;
; PURPOSE:
;        This function tests for the presence of a directory.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        Result = DIR_EXIST( Dir )
;
; INPUTS:
;        Dir       String holding the name of the directory you want to
;                  test the existence of.
;
; OUTPUTS:
;        This function returns 1 if the specified directory exists or
;        0 if the specified directory does NOT exist.
;
; EXAMPLE:
;        To check the existence of a '\TMP' directory type:
;
;        iss = DIR_EXIST('\TMP')
;        if (iss eq 1) then print,'TMP directory EXISTs.' $
;        else print,'TMP directory does NOT exist.'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;                       Copied from !News TECH TIPS.
;-
function DIR_EXIST, dir

;   Save the current directory:
         CD, CUR=cur

;   An error will occur if we try to CD to a directory
;   that doesn't exist:
         CATCH, error_status
         if (error_status NE 0) then begin
              ;    Directory does NOT exist so:
              return, 0
         endif

;   Try to go to the directory. If it doesn't exist,
;   the error handler code above gets executed:
         CD, dir

;   If the directory does exist, we need to change back
;   to the original directory and return true:
         CD, cur
         return, 1
end
