;+
; NAME:
;        DEVICE_MGR
;
; PURPOSE:
;
;        Manages the graphics device for two "standard" orientations,
;        LANDSCAPE (default) and PORTRAIT.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        DEVICE_MGR [, Dev]
;
; OPTIONAL INPUTS:
;
;        Dev:      Name of the graphics device,[string]. If this argument
;           is not provided then the graphics device defaults to
;           'WIN' or 'X' depending on the OS.  Devices currently
;           supported are: 'WIN','X','PS','PCL'
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        ORIENTATION:    Orientation of the graphics device output, either
;                  'LANDSCAPE' (default) or 'PORTRAIT', [string].
;
;        WINDOW:   If the graphics device is 'WIN' or 'X', this
;                  keyword specifies the window number, 0=Default.
;
;        CLOSE:    Set this keyword to close the current graphics
;                  device.  If the curent graphics device is non-display,
;                  then setting this keyword = 2 will additionally delete
;                  the output file.
;
;        PRINT:    Set this keyword to close the current output file and
;                  send it to the printer as defined by the environment
;                  variable, PRINTER.  Setting this keyword to 2 will
;                  additionally delete the output file.
;
;        QUERY:    If the graphics device is 'WIN' or 'X' and
;                  the CLOSE keyword is set, then setting this keyword
;                  will cause the USER to be queried for the deletion
;                  of each open window.
;
;        FILENAME: Filename and path of the output file for non-display
;                  graphics devices.  If this keyword is not specified then
;                  a TMP file is created in the appropriate tmp directory,
;                  idl##### where ##### is a random number between 00000-99999.
;
;        APPEND:   Appends the graphics device output to the current
;                  output file.  The graphics device cannot be 'X' nor 'WIN'.
;
;        SILENT:   Set this keyword if you do not want any informational
;                  messages printed to the display. (0=Default)
;
;        QUEUE:    String defining the printer device name, (e.g. 'ek_ps').
;                  [Default=GETENV('PRINTER')]
;
;        OTHER_KEYWORDS: Any other additional keywords are passed via
;                  the _EXTRA keyword to either the WINDOW or the DEVICE
;                  routine depending upon the graphics device.
;
; OUTPUTS:
;        Output of the graphics device is either sent to the screen
;        in a LANDSCAPE or PORTRAIT window, or to an output file depending
;        upon the graphics device.
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;
;        OFILENAME:     Filename and path of the output file for non-display
;                  graphics devices.  This is useful if you did not specify
;                  the FILENAME keyword and would like to know the name of the
;                  TMP file created.
;
; COMMON BLOCKS:
;        DEVMGR_COM:    This common block holds the filename of the
;                       graphics output, dvmgr_fn.
;
; RESTRICTIONS:
;        Currently the only OS platforms supported by this routine
;        are: Windows/DOS and Unix.
;
; EXAMPLE:
;        Create a simple plot and output it to both a window and an
;        output file.
;
;             x    = findgen(100)
;             y    = 100.*exp(-((x-50.)/20.)^2. )
;             DEVICE_MGR,'WIN'
;             plot,x,y
;             DEVICE_MGR,'PS'
;             plot,x,y
;             DEVICE_MGR,'PS',/close
;             DEVICE_MGR,'WIN',/close
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November 1994.
;        03-JAN-1995    Replaced INQUIRE with XQUERY.
;        21-JAN-1995    Replaced XQUERY with YNCANCEL. (Added WSHOW before
;                       and after YNCANCEL).
;        23-JAN-1995    Added the RESET keyword
;        25-JAN-1995    Renamed the common block variable names to more
;                       obscure names (i.e. unlikely to be used by the USER).
;        28-JAN-1995    Fixed a few minor bugs when closing multiple Windows.
;        30-JAN-1995    Added the SILENT keyword, and CLOSE=2 option.
;        08-FEB-1995    Changed default output filename from idltmpnn.ps to
;                       idlnnnnn.ps
;        29-APR-1995    Added the OFILENAME keyword.  I could have passed this
;                       value to the FILENAME keyword, but I did not want to
;                       overload its functionality.
;        03-MAY-1995    >Added the ANONYMOUS_ keyword to avoid a very subtle/
;                       rare bug with _EXTRA keyword. (Has no functionality
;                       for the USER -> Internal user only.)
;                       >Moved spawn print command to PRINT_FILE
;        02-JUN-1995    Implemented VERSION routine.
;        14-JUN-1995    Use WINDOW_STATE keyword to keep track of open
;                       windows instead of devmgr_com.
;        21-JUN-1995    Do NOT use SET_PLOT,dev if dev is the current device.
;        19-OCT-1995    Added the PRINTER keyword.
;        29-JUL-1996    Changed PRINTER keyword name to QUEUE. Added the PRINT
;                       keyword.  HARDCOPY keyword now obsolete; although it
;                       will still work to maintain backward compatibility.
;        07-AUG-1996    Remove calls to VERSION(). Check OS platform.
;-
pro DEVICE_MGR, dev1, ORIENTATION=Orientation, WINDOW=Window, $
               QUERY=Query, CLOSE=Close, APPEND=Append, HARDCOPY=Hardcopy, $
               FILENAME=File1, SILENT=Silent, OFILENAME=Ofilename, $
               _EXTRA=Other_keywords, ANONYMOUS_=Dummy_, QUEUE=Queue, $
               PRINT=Print_flag

         common devmgr_com, dvmgr_fn

         VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
         case VERSION_OS of
           'win'   :
           'vms'   : message,'vms platform not supported.'
           'mac'   : message,'MacOS platform not supported.'
           else    :
         endcase

         Orient    = 'LANDSCAPE'                 ;default orientation
         if KEYWORD_SET( Orientation ) $
         then Orient = STRUPCASE( Orientation )
         if (Orient ne 'LANDSCAPE') and $
            (Orient ne 'PORTRAIT' ) $
         then message,'Invalid orientation:'+Orient
         Ofilename = ''

         nW   = 0
         if (N_ELEMENTS( Window )      eq 1) then nW    = Window
         if (N_ELEMENTS( Close  )      eq 0) then Close = 0
         if (N_ELEMENTS( Print_flag )  eq 0) then Print_flag = 0
         if (N_ELEMENTS( dev1 )        eq 0) then dev1 = !D.NAME

         dev  = STRUPCASE( dev1 )
         if (dev ne !D.NAME) then SET_PLOT, dev       ;Bugfix, 6/21/95, do not need
                                                      ; to SET_PLOT,dev if dev is the
                                                      ; current device!  Avoids
                                                      ; unnecessary resetting of
                                                      ; system variables.

;   Open graphics device

         OPEN_flag = 1 -(KEYWORD_SET( Close ) or (KEYWORD_SET( Print_flag )))
         if (OPEN_flag) then begin

              CASE 1 OF

                 (dev eq 'PS') or $
                 (dev eq 'PCL')   : begin

                      if NOT KEYWORD_SET( APPEND ) then begin
                         if KEYWORD_SET( File1 ) then $
                             dvmgr_fn = File1  $
                         else begin
                             prefix   = 'idl'
                             suffix   = strlowcase( dev )
                             dvmgr_fn = TMPFILE(prefix,suffix,5)
                         endelse
                         if (NOT KEYWORD_SET( SILENT )) then $
                             print,'Creating file:',dvmgr_fn

                         DEVICE,filename=dvmgr_fn, _EXTRA=Other_keywords
                      endif
                      Ofilename   = dvmgr_fn

                      if Orient eq 'LANDSCAPE' then $
                         DEVICE,/landscape,_EXTRA=Other_keywords $
                      else begin
                         if dev eq 'PS' then begin
                            xsize  =7.5
                            ysize  =9.5
                            xoffset=0.25
                            yoffset=0.75
                         endif else begin
                            xsize  =7.5
                            ysize  =10
                            xoffset=-0.25
                            yoffset=0.5
                         endelse

                         DEVICE,/inches,xsize=xsize,ysize=ysize,$
                                xoffset=xoffset,yoffset=yoffset,$
                                /portrait,_EXTRA=Other_keywords
                      endelse
                 end

                 (dev eq 'WIN') or $
                 (dev eq 'X')      : begin

                      odim   = [700,500]                   ; landscape in PIXELS
                      if Orient eq 'PORTRAIT' $
                      then odim= REVERSE( odim )

                      window,nW,xsize=odim(0),ysize=odim(1),$
                          _EXTRA=Other_keywords

                 end
                 else              : message,'Invalid device name: '+dev

              ENDCASE

;   Close graphics device

         endif else begin

              CASE 1 OF

           (dev eq 'PS' ) $
                or        $
           (dev eq 'PCL') : begin
                    if (N_ELEMENTS(dvmgr_fn) eq 0) then goto, RESET_DISP
                    if (dvmgr_fn eq '') then goto, RESET_DISP

                    DEVICE,/CLOSE_FILE
                    if VERSION_OS eq 'win' then begin
                       if STRMID( Dvmgr_fn, 1, 1) ne ':' then begin
                             drive    = STRMID(!dir,0,2)
                             dvmgr_fn = drive+dvmgr_fn
                       endif
                    endif
                    if KEYWORD_SET( Hardcopy ) or KEYWORD_SET( Print_flag ) then $
                       PRINT_FILE, dvmgr_fn, SILENT=Silent, PRINTER=Queue
                    if (Close eq 2) or (Print_flag eq 2) then begin
                        if VERSION_OS eq 'win' then rm='del ' else rm='rm '
                        SPAWN, rm+dvmgr_fn
                        dvmgr_fn = '' ;Reset the output filename
                    endif
                end
           (dev eq 'WIN') $
                or        $
           (dev eq 'X')   : begin
                    DEVICE, WINDOW_STATE=wstate
                    here     = where(wstate eq 1,nopen)
                    for i=0,nopen-1 do begin
                      if KEYWORD_SET(QUERY) then begin
                         wshow, here(i)
                         nWstr    = strtrim( here(i),2 )
                         querystr = 'Delete Window '+$
                                    nWstr+'?'
                         rp = YNCANCEL( querystr, $
                              TITLE='Device_MGR Query')
                         qdel     = (rp eq 1)
                      endif else $
                         qdel     = 1

                      if qdel then WDELETE, here(i) $
                      else wshow, here(i)
                    endfor

                    DEVICE, WINDOW_STATE=wstate
                    here     = where(wstate eq 1,nopen)
                    if (nopen eq 0) and (!D.WINDOW eq 0) then begin
                        retall
                        xmanager
                        wdelete,0
                    endif
                end
              else        : message,'Invalid device name: '+dev
              ENDCASE

;   Reset graphics device

RESET_DISP:   if (!D.NAME ne 'WIN') and (!D.NAME ne 'X') $
              then begin
                 if (VERSION_OS eq 'win') $
                 then SET_PLOT,'WIN' $
                 else SET_PLOT,'X'
              endif
         endelse
end
