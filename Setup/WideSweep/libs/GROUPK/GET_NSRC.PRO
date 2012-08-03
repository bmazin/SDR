;+
; NAME:
;        GET_NSRC
;
; PURPOSE:
;        This function extracts the number of sources in an IDL data file.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        Result = GET_NSRC( File )
;
; INPUTS:
;        File:     Name of the IDL data file.
;
; OUTPUTS:
;        The number of sources in the IDL data file is returned.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        06-AUG-1996    Make File a required input parameter.
;-
function GET_NSRC, File

         NP = N_PARAMS()

         if NP eq 0 then message, $
              'Must be called with 1 parameter: File.'

         hdr_str   = '(#'
         src_str   = 'SOURCE'
         nsrc      = 0

         openr, lun, file, /GET_LUN

         hdr  = ''
         readf, lun, hdr

         i_hdr= strpos( hdr,hdr_str )
         if i_hdr eq -1 then goto, CHK_NUM

;   Loop through each line of the header

         repeat begin

;        Look for the (#SOURCE header line(s)

              i_src  = strpos( hdr, src_str, strlen( hdr_str ) )
              if (i_src ne -1) then nsrc = nsrc + 1

              readf, lun, hdr

         endrep until (strpos(hdr,hdr_str) eq -1 )

CHK_NUM: close, lun
         free_lun, lun

         if nsrc eq 0 then message,'No sources in data file.',/INF

         return, nsrc

end
