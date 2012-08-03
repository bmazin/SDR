;+
; NAME:
;        MAKEDBS
;
; PURPOSE:
;        This function extracts the (#MJF header line of each major frame
;        in an IDL data file an writes it out to a "database" file.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        MAKEDBS [, Datafile, Dbsfile]
;
; OPTIONAL INPUTS:
;
;        Datafile: Name (including path) of the IDL data file.
;
;        Dbsfile:  Name (including path) of the output database file.
;
; OUTPUTS:
;        Creates a .dbs file that may be used by XFiducial to determine
;        various scan buffer parameters.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;        06-AUG-1996    Check if !DATA_PATH system variable is defined.
;-
pro MAKEDBS, Datafile, Dbsfile

         NP=N_PARAMS()

         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         if NP eq 0 then $
              dataFile = pickfile(path=!DATA_PATH,filter='*.idl',$
                             TITLE='Select IDL Data File')
         if dataFile eq '' then goto, ABORT

         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(dataFile,'\')
              if (delim eq -1) then delim = RSTRPOS(dataFile,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(dataFile,0,delim+1)
         endif

         pos    = strpos( datafile , !DATA_PATH )
         len    = strlen( datafile  ) - strlen(!DATA_PATH) -pos -strlen('.idl')
         filen  = strmid( datafile, pos+strlen(!DATA_PATH), len ) + '.dbs'

         if NP le 1 then $
              dbsfile  = pickfile(path=!DATA_PATH,filter='*.dbs',$
                                  FILE=!DATA_PATH+Filen, $
                                  TITLE='Select OUTPUT Database File' )
         if dbsfile eq '' then goto, ABORT

         hdr_str   = '(#'
         mjf_str   = 'MJF'

         openr, lun_data, datafile, /GET_LUN
         openw, lun_dbs,  dbsfile, /GET_LUN

         hdr  = ''
         readf, lun_data, hdr

         i_hdr= strpos( hdr,hdr_str )
         if i_hdr eq -1 then goto, CHK_FMT

;   Loop through each line of the data file

         if NP lt 2 then widget_control, /hourglass
         repeat begin

;        Look for the (#MJF header line;

              i_src  = strpos( hdr, mjf_str, strlen( hdr_str ) )
              if (i_src ne -1) then printf, lun_dbs, hdr
              readf, lun_data, hdr

         endrep until EOF( lun_data )

CHK_FMT: close, lun_data, lun_dbs
         free_lun, lun_data, lun_dbs
         msgstr = 'Database file:'+dbsfile+' written.'
         if NP lt 2 then xmsg, msgstr,TITLE='MakeDBS Message' $
         else print,msgstr
         return

ABORT:   msgstr = 'MakeDBS Aborted.'
         if NP lt 2 then xmsg,msgstr,TITLE='MakeDBS Message' $
         else print,msgstr
end
