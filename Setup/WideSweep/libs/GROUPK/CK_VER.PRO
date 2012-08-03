;+
; NAME:
;        CK_VER
;
; PURPOSE:
;        This function checks the validity of the Version number of a DATA
;        structure created by the FIDUCIAL routine.
;
; CATEGORY:
;        HEAO A-1.
;
; CALLING SEQUENCE:
;
;        Result = CK_VER( Data )
;
; INPUTS:
;        Data:     Structure created by the FIDUCIAL routine and saved to
;                  an IDL SAVE session file (*.sav).
;
; OPTINOAL INPUT KEYWORD PARAMETERS:
;
;        VERSION:  The version number of the Data structure must be greater
;                  than or equal to this value (3=Default).
;
; OUTPUTS:
;        Returns a 1 if the structure is a valid DATA structure created by
;        FIDUCIAL version=VERSION or later, or a 0 otherwise.
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;-
function CK_VER, Data, VERSION=Version

         NP = N_PARAMS()

         if NP ne 1 then $
              message,'Must be called with 1 parameter: Data'

         if NOT keyword_set(Version) then Version=3.0

         sz   = SIZE( Data )
         Nsz  = N_ELEMENTS(sz)
         if sz(Nsz-2) ne 8 then $
              message,'Parameter must be a STRUCTURE type.'

         tags = TAG_NAMES(Data)
         here = where( tags eq 'VERSION', n )

         invalid = 0
         if (n eq 0) then invalid = 1 $
         else if Data.Version lt Version then invalid = 1

         if invalid then begin
              xmsg,['Input parameter NOT recognized as a valid',$
                    'DATA structure created by FIDUCIAL',$
                    'version '+arr2str(Version,2)+' or later.'],$
                    TITLE='CK_Ver ERROR'
              return, 0
         endif else return, 1

end
