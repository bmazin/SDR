;+
; NAME:
;        GRPKPATH
;
; PURPOSE:
;        This function returns the path to a Group K library.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        Result = GRPKPATH()
;
; OUTPUTS:
;        Returns a string containing the path to the specified Group K
;        Library.
;
; COMMON BLOCKS:
;        GRPKPATH: For internal use only.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;-
function GRPKPATH

         common GRPKPATH, grpKpath_

;   See if Group K path system variable is defined

         if (N_ELEMENTS(grpKpath_) gt 0) then return, grpKpath_

;   Determine platform dependent tokens and separators

         VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
         case VERSION_OS of
            'win'  : begin
                       sep=';'
                       tok='\'
                     end
            'vms'  : message,'vms platform not supported.'
            'mac'  : message,'MacOS platform not supported.'
            else   : begin
                       sep=':'
                       tok='/'
                     end
         endcase


         sstr      = 'groupk'
         pos       = STRPOS(!path,sstr)
         if (pos eq -1) then begin
              sstr = 'lib'+tok+'hanwen'
              pos  = STRPOS(!path,sstr)
         endif
         hpath     = STRMID(!path,0,pos+STRLEN(sstr))
         pos       = RSTRPOS(hpath,sep)
         grpKpath_ = STRMID(hpath,pos+1,1000)+tok

         return, grpKpath_
end
