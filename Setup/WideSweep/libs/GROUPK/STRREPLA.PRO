;+
; NAME:
;        STRREPLACE
;
; PURPOSE:
;        The STRREPLACE procedure replaces the contents of one string
;        with another.  The first occurrence of the search substring, Find
;        within the source string, String is replaced by the string,
;        Replacement.
;
; CATEGORY:
;        String Processing.
;
; CALLING SEQUENCE:
;
;        STRREPLACE, String, Find, Replacement
;
; INPUTS:
;        String:   The string to have substring(s) replaced.  If String is
;                  an array, Find is replaced by Replacement in the first
;                  occurrence of Find of every element of the array.
;
;        Find:     The scalar substring to be replaced. If this argument is
;                  not a string, it is converted using IDL's default
;                  formatting rules.
;
;        Replacement:   A scalar string to replace the Find substring. If
;                  this argument is not a string, it is converted using IDL's
;                  default formattting rules.
;
; EXAMPLE:
;
;        If the variable A contains the string "IBM is fun", the
;        substring "IBM" can be replaced with the string "Microsoft"
;        by entering:
;
;        STRREPLACE, A, 'IBM', 'Microsoft'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;-
pro STRREPLACE, Strings, Find1, Replacement1

;   Check integrity of input parameter

         NP        = N_PARAMS()
         if (NP ne 3) then message,'Must be called with 3 parameters, '+$
                   'Strings, Find, Replacement'

         sz        = SIZE(Strings)
         ns        = n_elements(sz)
         if (sz(ns-2) ne 7) then message,'Parameter must be of string type.'

         Find      = STRING(Find1)
         pos       = STRPOS(Strings,Find)
         here      = WHERE(pos ne -1, nreplace)

         if (nreplace eq 0) then return

         Replacement=STRING(Replacement1)
         Flen      = strlen(Find)
         for i=0,nreplace-1 do begin

              j         = here(i)
              prefix    = STRMID(Strings(j),0,pos(j))
              suffix    = STRMID(Strings(j),pos(j)+Flen,$
                                       strlen(Strings(j))-(pos(j)+Flen))
              Strings(j) = prefix + replacement + suffix
         endfor
end
