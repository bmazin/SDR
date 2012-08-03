;+
; NAME:
;        PRINT_FILE
;
; PURPOSE:
;        Spawns a print command to print a file.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        PRINT_FILE, File
;
; INPUTS:
;        File:     Name of the file you want to print.
;
; OPTIONAL INPUT KEYWORDS:
;
;        PRINTER:  String defining the printer device name, (e.g. 'ek_ps').
;                  [Default=GETENV('PRINTER')]
;
;        SILENT:        Set this keyword if you do not want any informational
;                  messages printed to the display. (0=Default)
;
; PROCEDURE:
;        The spawned print command is:
;             lpr -Pprinter file            ;UNIX and Windows
;             print/queue=printer file      ;VMS
;
; EXAMPLE:
;
;        SET_PLOT,'PS'
;        DEVICE,FILENAME='/tmp/junk.ps'
;        PLOT,indgen(100),TITLE='This is a test'
;        DEVICE,/CLOSE
;        PRINT_FILE,'/tmp/junk.ps'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1995.
;        12-JUN-1995    Define default PRINTER environment variable.
;        07-AUG-1996    Eliminate call to VERSION()
;-
pro PRINT_FILE, file, PRINTER=Printer, SILENT=Silent

         NP  = N_PARAMS()
         if (NP eq 0) then message,'No file specified.'

         VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))

         if keyword_set(Printer) then prn = Printer $
         else begin
              prn = GETENV('PRINTER')
              if (prn eq '') then begin
                   case VERSION_OS of
                     'win'   : prn='ek_ps -Slpd01'
                     'vms'   : prn='ekhpl'
                     'mac'   : message,'MacOS platform not supported.'
                     else    : prn='ek_ps'
                   endcase
                   setenv,'PRINTER='+prn
              endif
         endelse

         if prn ne '' then begin
              case VERSION_OS of
                'win'   : prn_command = 'lpr -P'+prn+' '+file
                'vms'   : prn_command = 'print/queue='+prn+' '+file
                'mac'   : message,'MacOS platform not supported.'
                else    : prn_command = 'lpr -P'+prn+' '+file
              endcase
              if NOT keyword_set( SILENT ) then begin
                  print,'Sending file to printer.'
                  print,prn_command
              endif
              SPAWN, prn_command
         endif else $
             message,'PRINTER environment '+$
                     'variable NOT defined',/INF
end
