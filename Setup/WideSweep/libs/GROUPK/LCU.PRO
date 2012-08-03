;+
; NAME:
;        LCU
;
; PURPOSE:
;        Interactively displays the light curves of an IDL data file for
;        each scan.  Other light curve utilities include: searching for a
;        particular scan; printing the displayed light curves; and creating
;        a list of major frame numbers by individually marking each scan.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        LCU
;
; RESTRICTIONS:
;        Assumes that the data file is in the proper IDL format as defined by
;        the FMT_IDL or FMT_SRCDATA program.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, April, 1994.
;        06-MAY-1994    Absorbed the fitting calculations previously
;                       done in LIGHT_CURVE.  Off-loaded these calculations
;                       onto the CT_RATE routine which is called in this routine.
;        10-MAY-1994    Off-loaded all buffering of data into separate routines,
;                       READ_BUF, INIT_BUF, OPEN_BUF, CLOSE_BUF, CLEAR_BUF. The
;                       buffering is much more sophisticated: can open multiple files;
;                       concatenate ANY number of sequential major frames.
;        14-MAY-1994    Added a print option to plot the graph with a white background.
;        19-MAY-1994    Fit background and signal simultaneously, INTENSITY().
;        23-MAY-1994    Display light curve in [counts/sec] instead of [counts/bin].
;        13-JUN-1994    Load default B-W IDL color table when exiting routine.
;                       Expose plotting window; delete plotting window when exiting routine.
;        26-JUN-1994    Changed READ_BUF -> GET_BUf.
;        18-JUL-1994    Change output of outfile to all fitted mjf data params.
;        01-AUG-1994    Changed GET_BUF -> GET_SCAN.
;        19-AUG-1994    Added Window to define a large plotting region
;        14-SEP-1994    Added a print to PCL file option.
;        15-NOV-1994    Changed PCL -> PS => LANDSCAPE
;        18-NOV-1994    Changed 'WIN' -> !D.NAME, only WSHOW for 'WIN'
;        13-DEC-1994    Used WIDED to make LCU into a widget application => LCU
;        07-JAN-1994    Added message box when clicking Mark button
;        22-JAN-1995    Moved LCU -> OBSOLETE directory, Renamed XLCU->LCU
;        06-AUG-1996    Check if !DATA_PATH system variable is defined.
;-

pro LCU_INIT

         common LCU_COM, xstruc, xdata, xadd

;
;   Initialize the static structures used throughout this routine
;

         xstruc = { $
                   fmt       : '', $
                   datafile  : '', $
                   dataunit  : 0 , $
                   move      : 1 , $
                   pickmjf   : 0L, $
                   mjf_list  : lonarr( 1000 ), $
                   nlist     : 0 , $
                   eofb      : 0 , $
                   plot_win  : 1 , $
                   print_file: 0 , $
                   nmjf      : 0 , $
                   mjf       : 0L, $
                   dbxxx     : 0,  $
                   bof       : 0,  $   ;beginning of file pointer
                   ID        : 0   $

                 }

         xdata  = { nsrc     : 0 }
         xadd   = { nsrc     : 0 }

end

;*
;   Called if Next, Previous or Find buttons are pushed.
;*
pro LCU_NEXT
;
;   Get the next scan from the data file, or the scan specified by
;   the pickmjf variable.  Fit the resulting data to a polynomial
;   background and source transmissions.  Once the source intensities
;   have been fitted, a light curve is plotted to the display.
;

         common LCU_COM, xstruc, xdata, xadd

         move      = xstruc.move
         pickmjf   = xstruc.pickmjf
         FORMAT    = xstruc.fmt

;   Read in next scan

         WIDGET_CONTROL,/HOURGLASS
         xstruc.eofb = GET_SCAN( Move, DATA=Data, PICKMJF=Pickmjf )
         if xstruc.eofb then RETURN

         if pickmjf ne 0 then begin
              WIDGET_CONTROL, xstruc.ID, /DESTROY
              xstruc.pickmjf = 0
         endif

         nmjf      = N_ELEMENTS( Data )
         mjf       = Data.mjf
         nbin      = nmjf*data(0).nbin
         nsrc      = data(0).nsrc
         nsrc_tot  = nsrc + xadd.nsrc
         names     = strarr( nsrc )
         names(*)  = data(0).srcnam
         mode      = data(0).mode
         module    = data(0).module
         cts       = reform( Data.cts, nbin )
         trns      = reform( Data.trns, nsrc, nbin )

         xstruc.nmjf    = nmjf
         xstruc.mjf     = mjf(0)


;   Determine the transmissions of any additional sources

         if FORMAT eq 'ASPECTS' then begin
              RAY  = REFORM( data.sat.aspects.y(0,*), nbin )
              DEY  = REFORM( data.sat.aspects.y(1,*), nbin )
              RAZ  = REFORM( data.sat.aspects.z(0,*), nbin )
              DEZ  = REFORM( data.sat.aspects.z(1,*), nbin )

         endif else begin
              RAY  = data.RAY*!dtor
              DEY  = data.DEY*!dtor
              RAZ  = data.RAZ*!dtor
              DEZ  = data.DEZ*!dtor
         endelse

         if xadd.nsrc gt 0 then begin ;   USER-defined sources

              ddtor     = !dpi/180.d0
              srcRA     = xadd.RA*ddtor
              srcDEC    = xadd.DEC*ddtor
              trns1     = fltarr( nsrc_tot, nbin )
              trns1(0:nsrc-1,*)    = trns
              trns      = trns1
              names     = [names,xadd.name]

              if FORMAT eq 'ASPECTS' then begin
                   for i=0,xadd.nsrc-1 do $
                        trns(nsrc+i,*) = COLLF( module, srcRA(i), $
                                         srcDEC(i), RAY, DEY, RAZ, DEZ )

              endif else begin
                   if nmjf gt 1 then begin
                        for i=0,xadd.nsrc-1 do begin
                             trns(nsrc+i,*) = $
                                  GET_TRNS( module, nbin, srcRA(i), $
                                           srcDEC(i), RAY, DEY, RAZ, DEZ )
                        endfor
                   endif else begin
                        xerrmsg, [ $
                                  'WARNING: Only ONE MJF in this scan ', $
                                  '-> Cannot determine transmissions for '+$
                                  'extra sources.' $
                                 ]
                        trns(nsrc:nsrc_tot-1,*) = $
                                  REPLICATE(0.,xadd.nsrc,nbin)
                   endelse
              endelse

         endif

;   Make deadtime correction to the data

         if keyword_set( DEADTIME ) then $
              cts  = DEADCORR( mode,cts, EXTENDED=( Deadtime-1 ) )

;   Determine the fit parameters for this scan

         FITSCAN, Cts, Trns, 1, OCOEFF=Ocoeff, OSIGMA=Osigma, $
                   OFIT=Ofit, ORCHISQ=Orchisq

         fluxes  = Ocoeff.intensity
         sigFs   = Osigma.intensity
         fit     = Ofit.data

         chisq   = Orchisq.data
         chisq_pk= Orchisq.sig
         chisq_bk= Orchisq.bkd

         tbin    = mode/1000.
         cts     = cts/tbin
         fit     = fit/tbin
         title   = LCTITLE( data.mjf )
         subtitle= LCSUBTITLE( chisq, chisq_pk, chisq_bk )
         legend  = LCLEGEND( names, fluxes, sigFs )
         xdata   = { $
                   nsrc: nsrc_tot, $
                   cts : cts, $
                   trns: trns, $
                   fit : fit, $
                   title : title, $
                   subtitle : subtitle, $
                   legend : legend, $
                   names  : names $
                   }

;   Plot the light curve for this scan

         LCU_PLOT

end

pro LCU_PLOT, HARDCOPY=Hardcopy
;
;   Plot the light curve to the display or to the printer output
;

         common LCU_COM, xstruc, xdata, xadd

;   Extract the relevant data for the light curve

         WIDGET_CONTROL,/HOURGLASS
         cts       = xdata.cts
         trns      = xdata.trns
         fit       = xdata.fit
         title     = xdata.title
         subtitle  = xdata.subtitle
         legend    = xdata.legend

         if keyword_set( HARDCOPY ) then $
              white_bkd = 1 $
         else white_bkd = 0

;   Plot the light curve

         LIGHT_CURVE, cts, trns, fit, $
                      TITLE=title, $
                      SUBTITLE=subtitle, $
                      YTITLE='Counts/sec', $
                      LEGEND=legend, $
                      WHITE_BKD=white_bkd

end

pro LCU_END
;
;   Close files, clean up common variables and structures
;   to free up memory, restore B-W LINEAR color table, etc.
;

         common LCU_COM, xstruc, xdata, xadd

;   Set color table back to B-W LINEAR

         LCLOADCT, /UNLOAD

;   Clear the buffer

         if xstruc.dataunit ne 0 then begin
              END_SCAN
              CLEAR_SCAN
         endif

;   Display & write out any marked major frames

         nlist     = xstruc.nlist
         if nlist gt 0 then begin
              mjf_list  = xstruc.mjf_list
              LCU_MJF, mjf_list(0:nlist-1)
         endif

         xstruc = 0 & xdata = 0
end

;========= BEGIN LCU_ADDFILE routines ================================

PRO LCU_ADDFILE, GROUP=Group
;
;   Open an additional source(s) file and read in the source
;   information into the common structure variables
;
         common LCU_COM, xstruc, xdata, xadd

;   Get the name of the additional source(s) file

         WIDGET_CONTROL,/HOURGLASS
         ; Get Additional Sources file

         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.add', $
                TITLE='Select Additional Source(s) File', $
                GROUP=Group )

         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif

         WIDGET_CONTROL,/HOURGLASS
         openr, in, File, /get_lun
         name = '' & RA = 0.0 & DEC = 0.0
         while NOT eof(in) do begin
              readf,in,format='(A15,2(F15.7))',$
                    name,RA,DEC

              if N_ELEMENTS( names ) eq 0 then begin
                   names     = name
                   RAs       = RA
                   DECs      = DEC
              endif else begin
                   names     = [names,name]
                   RAs       = [RAs,RA]
                   DECs      = [DECs,DEC]
              endelse
         endwhile

         close, in
         free_lun, in


;   See if any of the additional sources already
;   exist in the current list

            nadd = N_ELEMENTS( names )

            if xdata.nsrc gt 0 then begin
                 nsrc = N_ELEMENTS( xdata.names )
                 for i=0,nsrc-1 do begin
                      here = where( xdata.names(i) ne names, nunique )
                      if nunique eq 0 then return $
                      else begin
                           if nunique ne nadd then begin
                                nadd      = nunique
                                names     = names(here)
                                RAs       = RAs( here )
                                DECs      = DECs( here )
                           endif
                      endelse
                 endfor
            endif

            xadd = { $
                      nsrc : nadd, $
                      name : names,$
                      RA   : RAs,  $
                      DEC  : DECs  $
                   }

;   Plot the additional sources on the current light curve

            if xdata.nsrc gt 0 then xstruc.move = 0

END

;========= END LCU_ADDFILE routines ==================================

;========= BEGIN LCU_FIND routines ===================================

PRO LCU_FIND, GROUP=Group
;
;   Prompt the USER for the major frame number of the scan he/she
;   would like to find
;
         common LCU_COM, xstruc, xdata, xadd

         Question  = 'Enter major frame number to search for:'

         mjfstr    = XQUERY( Question, $
                             Title='Scan Search',$
                             GROUP=Group )

         xstruc.pickmjf = long( mjfstr(0) )
         if xstruc.pickmjf eq 0 then xstruc.move = 0 $
         else begin
              xmsg,'Searching...   Please Wait...',$
                   /NOBUTTON, MSG_ID=search_ID, TITLE='LCU Message'
              xstruc.ID = search_ID
              WIDGET_CONTROL, /HOURGLASS
         endelse

END

;========= END LCU_FIND routines =====================================

;========= BEGIN LCU_MJF routines ====================================

PRO LCU_MJF, MJF_list, GROUP=Group
;
;   Write out the list of MJFs marked to the display and to
;   a TMP file
;


;   Write out MJF list to TMP file

         filen  = TMPFILE('mjfs','txt' )
         openw, out, filen, /get_lun
         print,'Writing these major frames to TMP file:',filen
         nlist  = N_ELEMENTS( MJF_list )
         for i=0,nlist-1 do $
           printf,out,mjf_list(i)
         close, out
         free_lun, out

         max_row = 20.
         nwin    = CEIL( nlist/max_row )

         for i=0,nwin-1 do begin
              j0   = i*max_row
              j1   = j0 + (max_row-1)
              j1   = j1 < (nlist-1)
              List = [ $
                        'List of MJF numbers marked:',$
                        '',$
                        strtrim(MJF_list(j0:j1),2),$
                        '',$
                        'List written to TMP file:',$
                        filen ]

              xmsg, List, TITLE='Marked MJFs', GROUP=Group
         endfor
END

;========= END LCU_MJF routines =======================================

;========= BEGIN LCU_FILE routines ====================================

PRO LCU_FILE, GROUP=Group
;
;   Prompt USER to open an IDL data file. Do initial bookkeeping
;   to link the IDL data file to the scan buffers
;

         common LCU_COM, xstruc, xdata, xadd

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

;   Get the name of the IDL data file

         WIDGET_CONTROL, /HOURGLASS
         ; Get IDL data file

         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.idl',$
                          TITLE='Select IDL Data File', $
                          GROUP=Group )

         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif

         Fmt  = GET_FMT( File )
         if Fmt eq '' then begin
              xmsg,'Format of data file not recognized.',$
                   TITLE='XFiducial Error',$
                   GROUP=Group
              File = ''
              return
         endif

         xstruc.fmt      = Fmt
         xstruc.datafile = File
         xadd.nsrc = 0  ; Reset the number of additional sources

         if xstruc.dataunit ne 0 then END_SCAN

;   Load the light curve color table.

         LCLOADCT

;   Read the first scan into the scan buffer

         if xstruc.fmt eq '' then xstruc.fmt = 'ASPECTS'
         lunit = INIT_SCAN( File, FORMAT=xstruc.fmt )
         xstruc.dataunit = lunit

END

;========= END LCU_FILE routines ======================================

;========= BEGIN LCU_HELP_ABOUT routines ==============================

pro MAIN_HELP_ABOUT_Event, Event
         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF

         'DRAW_DEMO':
         'BUTTON_OK': dummy=EXECUTE('WIDGET_CONTROL,Event.Top,/DESTROY')
         ENDCASE
end

pro LCU_HELP_ABOUT, GROUP=Group
;
;   Display the LCU logo
;

         if N_ELEMENTS(Group) eq 0 then Group=0

         Title = 'About LCU'
         MAIN_HELP_ABOUT = WIDGET_BASE(GROUP_LEADER=Group, $
             TITLE=Title, $
             /COLUMN, $
             MAP=0, $
             UVALUE='MAIN_HELP_ABOUT')

         LABEL60 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL60', $
             VALUE=' ')

         OS  = STRUPCASE(!VERSION.OS)
         OS  = STRMID(OS,0,3)
         if OS eq 'WIN' then font = 25 $
         else font = '-adobe-courier-*-*-*-*-25-*-*-*-*-*-*-*'
         LABEL5 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             FONT=font, $
             UVALUE='LABEL5', $
             VALUE='LCU')

         LABEL62 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL62', $
             VALUE=' ')

         BASE54 = WIDGET_BASE(MAIN_HELP_ABOUT, $
             COLUMN=1, $
             XPAD=50, $
             MAP=1, $
             UVALUE='BASE54')

         DRAW_DEMO = WIDGET_DRAW( BASE54, $
             RETAIN=2, $
             UVALUE='DRAW_DEMO', $
             XSIZE=150, $
             YSIZE=110 )


         LABEL64 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL64', $
             VALUE=' ')

         LABEL15 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL15', $
             VALUE='Version 7.4')

         LABEL66 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL66', $
             VALUE=' ')

         LABEL16 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL16', $
             VALUE='Han Wen')

         LABEL68 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL68', $
             VALUE=' ')

         LABEL70 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL70', $
             VALUE=' ')

         BASE28 = WIDGET_BASE(MAIN_HELP_ABOUT, $
             ROW=1, $
             XPAD=110, $
             MAP=1, $
             UVALUE='BASE28')

         BUTTON_OK = WIDGET_BUTTON( BASE28, $
             UVALUE='BUTTON_OK', $
             VALUE='OK')

         WIDGET_POSITION, MAIN_HELP_ABOUT, /CENTER, MAP=0

;   Plot an example light curve

         y1=[$
             63, 55, 47, 62, 44, 50, 68, 45, 48, 51, 48, 53, 43, 59, 52, $
             50, 53, 55, 50, 42, 51, 57, 63, 56, 59, 63, 36, 52, 38, 42, $
             56, 62, 53, 47, 45, 45, 44, 50, 55, 43, 41, 56, 50, 44, 45, $
             46, 55, 44, 47, 56, 51, 55, 55, 53, 62, 72, 69, 85, 93, 112 $
            ]
         y2=[$
             145,123,136,179,141,154,167,135,123,110,106,82, 83, 86, 85, $
             69, 61, 58, 50, 47, 40, 55, 42, 49, 46, 46, 54, 53, 59, 48, $
             50, 46, 53, 53, 47, 55, 44, 40, 52, 43, 46, 51, 46, 45, 46, $
             46, 58, 48, 41, 52, 43, 50, 58, 47, 52, 40, 55, 45, 46, 55, $
             46, 53, 51, 54, 53, 54, 46, 52 $
            ]
         y=[y1,y2]
         plot,y, xmargin=[ 4,3 ], ymargin=[3,2], charsize=0.5, $
                psym=10, /xstyle

         WIDGET_CONTROL, MAIN_HELP_ABOUT, /MAP

         XMANAGER, 'MAIN_HELP_ABOUT', MAIN_HELP_ABOUT, /JUST_REG, /MODAL
end

;========= END LCU_HELP_ABOUT routines ===============================


;========= BEGIN LCU_HELP routines ===================================

pro LCU_HELP, Ev, GROUP=Group
;
;   LCU Help facility
;

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         help_event = 0
         CASE Ev OF
         'Help.Online Help': BEGIN
              Title  = 'LCU Help [Topic: MAIN MENU]'
              Topics = [$
                   'File',$
                   'Next',$
                   'Previous',$
                   'Find',$
                   'Mark',$
                   'Help']

              Descrs = [$
                   '    This is a pulldown menu from which you may select ',$
                   'to open various files to make light curves, print the',$
                   'current light curve, or quit LCU.',$
                   '',$
                   '    For additional help on a subtopic select Help',$
                   'from its submenu.',$

                   '    Select this button to display the light curve of ',$
                   'the Next scan in the IDL data file.',$
                   '',$
                   '    You must open an IDL data file before making this',$
                   'selection. (Select Open IDL data file from the File menu).',$

                   '    Select this button to display the light curve of ',$
                   'the Previous scan in the IDL data file.',$
                   '',$
                   '    You must open an IDL data file before making this',$
                   'selection. (Select Open IDL data file from the File menu).',$

                   '    This button allows you to find a particular scan ',$
                   'in the current IDL data file.  You will be prompted for ',$
                   'the major frame number corresponding to the first major',$
                   'frame of the scan you are interested in finding.  If the',$
                   'scan is found, then its light curve will be displayed.',$
                   '',$
                   '    Currently this Find utility only searches in the forward',$
                   'direction.  Namely, you must search for scans with major frame',$
                   'numbers greater than those of the current scan being displayed.',$
                   '',$
                   '    You must open an IDL data file before making this',$
                   'selection. (Select Open IDL data file from the File menu).',$

                   '    Pressing this button saves the major frame numbers of',$
                   'the scan currrently being displayed.  When you Quit LCU,',$
                   'a list of all the MJFs you marked will be displayed and',$
                   'written to a TMP file.',$
                   '',$
                   '    You must open an IDL data file before making this',$
                   'selection. (Select Open IDL data file from the File menu).',$

                   '    The purpose of the LCU routine is to provide a simple',$
                   'and interactive way of viewing the light curves of an IDL',$
                   'data file.  Many times during analysis of the HEAO A-1 ',$
                   'scanning data, there may be a few "problem" or "interesting"',$
                   'scans you would like to view the light curves of. LCU ',$
                   'provides a simple Find utility to facilitate this task.',$
                   '',$
                   '    All of the routines I''ve written that start with an',$
                   '"X" are X-windows or IDL widget routines.  They are the',$
                   'ultimate end state of an IDL routine.  The LCU stands for',$
                   'Light Curve Utility.  Happy scanning.']

              Nlines = [ 6, 5, 5, 12, 7, 11 ]

              END

         'File.Help': BEGIN
              Title = 'LCU Help [Topic: FILE]'
              Topics = [$
                   'Open IDL data file',$
                   'Open Additional Source(s) file', $
                   'Print Light Curve',$
                   'Quit', $
                   'Help']

              Descrs = [$
                   'Open an IDL HEAO A-1 data file.  The file must be in the',$
                   'format defined by the FMD_IDL or FMT_SRCDATA routines.',$

                   'Open a text file containing information about sources not',$
                   'listed in the IDL data file which you would like to include',$
                   'in your light curves.', $
                   '', $
                   '    Each line of the file must specify a different source', $
                   'with the following format:',$
                   '',  $
                   'Name of source     RA             DEC',$
                   'Format = (A15)     ( F15.7 )      ( F15.7 )',$
                   'Units  = [ N/A ]     [Degrees]      [Degrees]',$
                   '',$
                   'For example:',$
                   '',$
                   '1H1608-522         242.217        -52.2953',$
                   '1H1624-490         246.074        -49.0794',$

                   'Print the currently displayed light curve.',$

                   'Quit this LCU routine.',$

                   'Sorry, no other additional Help available for this topic.']
              Nlines= [ 2, 15, 1, 1, 1 ]
              END

         ENDCASE
         XHELPMSG, Topics, Descrs, Nlines, TITLE=Title, GROUP=Group
end

;========= END LCU_HELP routines ======================================

;========= BEGIN LCU routines =========================================

PRO PDMENU3_Event, Event

         common LCU_COM, xstruc, xdata, xadd

         if xstruc.eofb then Event.Value = 'File.Quit'

         help_event = 0

         CASE Event.Value OF

         'File.Open IDL data file': LCU_FILE, GROUP=Event.Top
         'File.Open Additional Source(s) File': LCU_ADDFILE, GROUP=Event.Top
         'File.Quit': BEGIN
           dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
           LCU_END
           END
         'File.Help': help_event = 1
         'Help.Online Help': help_event = 1
         'Help.About LCU':BEGIN
           LCU_HELP_ABOUT, GROUP=Event.Top
           END
         ELSE: goto, ACTION
         ENDCASE

         if help_event then begin
              LCU_HELP, Event.Value, GROUP=Event.Top
              return
         endif
         return

ACTION:  if xstruc.datafile eq '' then begin
            xmsg, 'No IDL data file opened.', $
                 TITLE='LCU Error',$
                 GROUP=Event.Top
            return
         endif

         CASE Event.Value OF

         'File.Print Light Curve': BEGIN
           landscape,'ps'
           LCU_PLOT, /hardcopy
           landscape, /close, /hardcopy
           return
           END
         'Next': BEGIN
           xstruc.Move  = 1
           xstruc.bof    = xstruc.bof + 1
           END
         'Previous': BEGIN
           if xstruc.bof eq 0 then begin
              xmsg,'At beginning of IDL data file',$
                   TITLE='LCU Error',$
                   GROUP=Event.Top
              return
           endif else begin
              xstruc.Move    = -1
              xstruc.bof     = xstruc.bof - 1
           endelse
           END
         'Find': BEGIN
           xstruc.Move =  1
           LCU_FIND, GROUP=Event.Top
           END
         'Mark': BEGIN
           nmjf = xstruc.nmjf
           mjf  = xstruc.mjf
           nlist= xstruc.nlist
           if nlist gt 0 then begin
                mmjfs= xstruc.mjf_list( 0:nlist-1 )
                here = where( mmjfs eq mjf, nexist )
           endif else nexist = 0
           if nexist eq 0 then begin
                xstruc.mjf_list( nlist:nlist+nmjf-1 ) = mjf + lindgen(nmjf)
                xstruc.nlist = nlist + nmjf
           endif
           xmsg,'MJF(s) marked.',TITLE='LCU Message'
           return
           END
         ENDCASE

         LCU_NEXT      ;Display the light curve for the scan determined
                        ;by the xstruc.move and xstruc.pickmjf parameters.
END

PRO MAIN13_Event, Event


         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF

         'DRAW_LC':
         ; Event for PDMENU3
         'PDMENU3': PDMENU3_Event, Event
         ENDCASE
END

PRO LCU


         LCU_INIT
         LCU_HELP_ABOUT

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         junk   = { CW_PDMENU_S, flags:0, name:'' }


         MAIN13 = WIDGET_BASE(GROUP_LEADER=Group, $
             COLUMN=1, $
             MAP=0, $
             TITLE='Light Curve Utility, Version 7.4', $
             UVALUE='MAIN13')

         DEVICE, GET_SCREEN_SIZE=win_sz
         DRAW_LC = WIDGET_DRAW( MAIN13, $
             RETAIN=2, $
             UVALUE='DRAW_LC', $
             XSIZE=win_sz(0)-50, $
             YSIZE=win_sz(1)-100)

         BASE2 = WIDGET_BASE(MAIN13, $
             COLUMN=1, $
             MAP=1, $
             UVALUE='BASE2')

         MenuDesc228 = [ $
             { CW_PDMENU_S,       1, 'File' }, $ ;                   0
               { CW_PDMENU_S,       0, 'Open IDL data file' }, $ ;   1
               { CW_PDMENU_S,       0, 'Open Additional Source(s) File' }, $ ;2
               { CW_PDMENU_S,       0, 'Print Light Curve' }, $ ;    3
               { CW_PDMENU_S,       0, 'Quit' }, $ ;                 4
               { CW_PDMENU_S,       2, 'Help' }, $ ;                 5
             { CW_PDMENU_S,       0, 'Next' }, $ ;                   6
             { CW_PDMENU_S,       0, 'Previous' }, $ ;               7
             { CW_PDMENU_S,       0, 'Find' }, $ ;                   8
             { CW_PDMENU_S,       0, 'Mark' }, $ ;                   9
             { CW_PDMENU_S,       3, 'Help' }, $ ;                   10
               { CW_PDMENU_S,       0, 'Online Help' }, $ ;          11
               { CW_PDMENU_S,       2, 'About LCU' } $  ;           12

         ]


         PDMENU3 = CW_PDMENU( BASE2, MenuDesc228, /RETURN_FULL_NAME, $
             UVALUE='PDMENU3')

         WIDGET_POSITION, MAIN13, /CENTER

         XMANAGER, 'MAIN13', MAIN13
END

;========= END LCU routines =========================================
