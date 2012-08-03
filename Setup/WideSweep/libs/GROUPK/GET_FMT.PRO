;+
; NAME:
;        GET_FMT
;
; PURPOSE:
;        This function extracts the name of the format of an IDL data file.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        Result = GET_FMT( File )
;
; INPUTS:
;        File:     Name of the IDL data file. If none is provided, the
;                  USER will be prompted for it via PICKFILE().
;
; OUTPUTS:
;        The format name is returned.  If the format of the IDL data file
;        is not among the currently recognized data formats, then a
;        null string, '' is returned. The list of currently recognized
;        data format is a follows:
;
;                       'ASPECTS'
;                       'STANDARD'
;                       'NOBARY'
;
; EXAMPLE:
;        ;Let's say we have the IDL data file, 1755-33.IDL and we would
;        ;like to determine the format of this file:
;
;        fmt = GET_FMT( !DATA_PATH+'1755-33.IDL' )
;
;        ;The value of fmt will be: 'ASPECTS'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        06-AUG-1996    Make File a required input parameter.
;-
function GET_FMT, File

         NP = N_PARAMS()

         if NP eq 0 then message, $
              'Must be called with 1 parameter: File.'


         hdr_str   = '(#'
         fmt_str   = 'FMT'
         src_str   = 'SOURCE'
         fmt_type  = ''

         known_fmts= [ 'ASPECTS', $    ;Names of data formats
                       'STANDARD',$    ;currently recognized
                       'NOBARY'   ]

         openr, lun, file, /GET_LUN

         hdr  = ''
         readf, lun, hdr

         i_hdr= strpos( hdr,hdr_str )
         if i_hdr eq -1 then goto, CHK_FMT

;   Loop through each line of the header

         repeat begin

;        Look for the third number in the (#SOURCE header line;
;        this would be one of the barycentric time corrections.

              i_src  = strpos( hdr, src_str, strlen( hdr_str ) )
              if (i_src ne -1) then begin
                   nper = 0
                   per  = strpos( hdr, '.' )
                   while (per ne -1) do begin
                        nper = nper + 1
                        per  = strpos( hdr, '.', per+1 )
                   endwhile
                   if nper gt 2 then fmt_type = 'STANDARD' $
                   else fmt_type = 'NOBARY'
              endif

;        Look for the (#FMT header line

              i_fmt  = strpos( hdr, fmt_str, strlen( hdr_str ) )
              if (i_fmt ne -1) then begin
                   i_off     = i_fmt + strlen( fmt_str )
                   fmt_type  = strmid( hdr, i_off, strlen( hdr ) - i_off )
                   fmt_type  = strtrim( fmt_type,2 )
              endif
              readf, lun, hdr

         endrep until (strpos(hdr,hdr_str) eq -1 )

CHK_FMT: close, lun
         free_lun, lun

;   Make sure the name of the format matches the data formats
;   currently recognized.

         match = where( fmt_type eq known_fmts, nmatch )
         if nmatch eq 0 then begin
              message,'Format of data file not recognized.',/INF
              return, ''
         endif

         return, fmt_type

end
