;+
; NAME:
;        GET_DATA
;
; PURPOSE:
;        This function restores an IDL SAVE Session file created by the
;        FIDUCIAL routine and returns the saved DATA structure.
;
; CATEGORY:
;        I/O
;
; CALLING SEQUENCE:
;
;        Result = GET_DATA( [Filename] )
;
; OPTIONAL INPUTS:
;        Filename: The filename (including path) of the IDL save session file.
;                  If this parameter is not provided by the USER, then the
;                  USER will be prompted to select the desired file from a
;                  widget menu.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;        TITLE:    The title of the widget window that displays information
;                  to the USER ('Get_DATA'=Default)
;
;        VERSION:  The Version number that the DATA structure must be greater
;                  than or equal to. (3=Default)
;
; OUTPUTS:
;        The DATA structure saved in the IDL SAVE session file is returned.
;        If the DATA structure is invalid or the USER aborts selecting a
;        file by pressing the Cancel button, then a 'NULL' structure is
;        returned {NULL:0}
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;
;        OFILE:    The filename (including path) of the IDL save session file
;                  restored.
;
; RESTRICTIONS:
;        The IDL SAVE session file must have been created by the FIDUCIAL
;        routine.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;        08-FEB-1995    Added the OFILE keyword.
;        06-AUG-1996    Check if !SAVE_PATH system variable is defined.
;-
function GET_DATA, File, OFILE=Ofile, TITLE=TITLE, VERSION=Version

         NP = N_PARAMS()

         if NP eq 0 then begin
              defsysv,'!SAVE_PATH',EXISTS=defined
              if (NOT defined) then defsysv,'!SAVE_PATH',''
              File = PICKFILE( PATH=!SAVE_PATH, FILTER='*.sav',$
                               TITLE='Select IDL SAVE Session File' )
              if (File ne '') then begin
                   delim = RSTRPOS(File,'\')
                   if (delim eq -1) then delim = RSTRPOS(File,'/')
                   if (delim ne -1) $
                   then defsysv,'!SAVE_PATH',STRMID(File,0,delim+1)
              endif
         endif

         if File eq '' then return, {NULL:0}

         if N_ELEMENTS(TITLE) eq 0 then TITLE='Get_DATA'

;   Restore IDL save session file

         xmsg,'Restoring IDL SAVE session file...',$
               TITLE=TITLE, $
              /NOBUTTON, MSG_ID=Msg_ID_begin
         WIDGET_CONTROL, /HOURGLASS

         restore, file

         xmsg,'Restoring IDL SAVE session file...completed',$
              TITLE=TITLE,$
              /NOBUTTON, MSG_ID=Msg_ID_end
         WIDGET_CONTROL, Msg_ID_begin, /DESTROY
         WAIT, 0.5
         WIDGET_CONTROL, Msg_ID_end, /DESTROY

         if NOT ck_ver( Data, VERSION=Version ) then return, {NULL:0}

         OFile = file

         return, data
end
