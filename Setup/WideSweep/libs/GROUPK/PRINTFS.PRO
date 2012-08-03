;+
; NAME:
;        PRINTFS
;
; PURPOSE:
;        Print to multiple devices with multiple formats. This is essentially
;        an extension to the PRINTF routine.
;
; CATEGORY:
;        IO.
;
; CALLING SEQUENCE:
;
;        PRINTFS, luns [, v1,  v2, .... etc ]
;
; INPUTS:
;        luns:     An array of logical units, (-1 = display).
;
; OPTIONAL INPUTS:
;
;        v1, v2, etc:   Usual parameters passed to the PRINT or PRINTF routine,
;                  (i.e. strings, floats, integers, arrays, etc.)
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        FORMAT:   An array of format specifications for each logical unit
;                  of the luns array. If scalar, then this format is assumed
;                  for all logical units specified.
;
;        PROMPT:   Set the prompt to the string value of the v1 parameter.
;
;        WAIT:     Number of seconds to wait after printing [0=Default]
;
; OUTPUTS:
;        Prints to the devices of each logical unit specified by the luns array.
;
; OPTIONAL OUTPUTS:
;
;        If the PROMPT keyword is set then the prompt is set to the string
;        value of the first optional input parameter.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November 1994.
;        16-APR-1995    Bugfix: FORMAT does not work properly, tacked on nA0
;        01-JUN-1995    Eliminated call to PROMPT routine.
;        04-JUN-1995    Added the WAIT keyword.
;        20-JUL-1995    Simplified routine: pass variable number of pars to printf
;                       instead of fixed number with variable number of null strings.
;-
pro PRINTFS, luns,  v1,  v2,  v3,  v4,  v5, $
                    v6,  v7,  v8,  v9, v10, $
                   v11, v12, v13, v14, v15, $
                   v16, v17, v18, v19, v20, $
                   FORMAT=Format, PROMPT=Prompt, WAIT=Wait_sec

         NP   = N_PARAMS()

         n    = N_ELEMENTS( luns )
         Fmt  = strarr(n)
         if keyword_set( FORMAT ) then begin

              ;    Check number of FORMAT elements

              nF = N_ELEMENTS( FORMAT )
              if (nF ne 1) and (nF ne n) then $
                   message,'FORMAT and LUNS arrays incompatible.'

              Fmt(*) = Format
              endif

         if keyword_set( PROMPT ) then !prompt = string(w1)

         nV   = NP-1
         CASE nV OF
              0    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i)
              1    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1
              2    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2
              3    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3
              4    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4
              5    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5
              6    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6
              7    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7
              8    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8
              9    : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9
              10   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10
              11   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10, v11
              12   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9,v10,v11,v12
              13   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9,v10,v11,v12,v13
              14   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9,v10,v11,v12,v13,v14
              15   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15
              16   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15,v16
              17   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15,v16,v17
              18   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15,v16,v17,v18
              19   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15,v16,v17,v18,v19
              20   : for i=0,n-1 do printf,luns(i),FORMAT=Fmt(i), v1, v2, v3, v4, v5, $
                         v6, v7, v8, v9, v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
              else : message,'Too many parameters.'

         ENDCASE

         if keyword_set(WAIT_SEC) then WAIT, Wait_sec
end
