;+
; NAME:
;        PK_TRNS
;
; PURPOSE:
;        Extracts the peak transmissions for each scan stored in the DATA
;        structure.
;
; CATEGORY:
;        HEAO A-1.
;
; CALLING SEQUENCE:
;
;        Result = PK_TRNS( Data [,SrcIndex] )
;
; INPUTS:
;        Data:     The DATA structure created by FIDUCIAL version 3.0 or later.
;
; OPTIONAL INPUTS:
;        SrcIndex: The index number of the source you want peak transmissions
;                  for, (0=Default).
;
; OUTPUTS:
;        This function returns an 1-D array of NSCAN elements, where NSCAN
;        is the number of scans in the DATA structure.  Each element contains
;        the corresponding peak transmission for that scan and source index
;        specified by the SrcIndex parameter.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;        08-FEB-1995:   Bugfix:incorrectly extracted pk_bins for srcindex>0
;-
function PK_TRNS, Data, SrcIndex


         NP=N_PARAMS()
         if (NP lt 1) or (NP gt 2) then $
              message,'Must be called with 1-2 parameters: Data [,SrcIndex]'

         if NOT ck_ver( Data ) then return, -1

         if NP eq 1 then SrcIndex = 0
         if SrcIndex ge data.nsrc then $
              message,'SrcIndex out of range'

         npass     = data.npass
         nsig      = data.nsig
         pk_bins   = data.pk_bins(*,SrcIndex)
         trns      = data.trns(*,SrcIndex)


         i0        = 0L
         trns_max  = fltarr( npass )
         for i=0L,npass-1L do begin

              trns_scan      = trns(i0:i0+nsig(i)-1L)
              trns_max(i)    = trns_scan( pk_bins(i) )
              i0             = i0 + nsig(i)
         endfor

         return, trns_max
end

