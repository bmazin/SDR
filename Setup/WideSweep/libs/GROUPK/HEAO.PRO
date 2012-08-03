;+
; NAME:
;        HEAO
;
; PURPOSE:
;        This is the main driver routine for all data analysis routines
;        related to the HEAO A-1 scanning data.  From its widget button
;        menu, you may select various types of analysis like looking
;        at light curves, selecting good scans, etc.
;
; CATEGORY:
;        HEAO A-1 Scanning.
;
; CALLING SEQUENCE:
;        HEAO
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;-
pro HEAO


;   Define Help text

         HelpTitle = 'HEAO Help'

         Topics = [$
              'Deadtime corrections',$
              'Transmission regions',$
              'Degree of background polynomial',$
              'Help']

         Note   = [$
              '',$
              'NOTE: The .idl file must be in the format defined by the ',$
              'FMT_IDL or FMT_SRCDATA routines.' $
              ]

         Descrs = [$
              'Routine: LCU',$
              '',$
              'Plot the light curves for any scan in a HEAO A-1 IDL data',$
              'file (.idl). Using this routine you may look at each scan',$
              'sequentially, search for a particular scan, print the scan, etc.',$
              Note, $

              'Routine: MakeDBS',$
              '',$
              'Creates a database file of all the (#MJF header lines in an',$
              'HEAO A-1 IDL data file (.idl).  The database file may serve',$
              'as a useful summary of the data, and is used by the Fidcuts1',$
              'routine to determine the number of scans in the data file.',$
              Note, $

              'Routine: FFindsrc',$
              '',$
              'Find additional sources that are present in a HEAO A-1 IDL',$
              'data file (.idl). This routine is used principally to create',$
              'the .add file used in the FIDCUTS1 routine (See Select Good',$
              'Scans (Fidcuts1) help topic).',$
              Note,$

              'Routine: Fidcuts1',$
              '',$
              'Select scans in a HEAO A-1 IDL data file (.idl) that pass',$
              'various fiducial cuts and/or USER inspection of its light',$
              'curve.  Data and fit results from these ''GOOD'' scans may',$
              'be saved to an IDL session file (.sav).  In addition, the',$
              'first MJF numbers for all ''BAD'' scans may also be saved',$
              'to file (.bad) to be used in recurring calls to this routine.',$
              Note,$

              'Routine: Mk_AvgLC',$
              '',$
              'Plot the light curves of the fitted intensities/scan from an',$
              'IDL save session file (.sav) created by the FIDCUTS1 routine,',$
              '(See Select Good Scans (Fidcuts1) help topic).  These plots',$
              'may be directed to your display or to the printer.',$

              'Routine: Mk_LPGM',$
              '',$
              'Create and plot the normalized Lomb periodograms of the fitted',$
              'intensities/scan vs. time data found in an IDL save session',$
              'file (.sav) created by the FIDCUTS1 routine, (See Select Good',$
              'Scans (Fidcuts1) help topic).  These plots may be directed to',$
              'your display or to the printer.',$

              'Routine: Mk_FoldLC',$
              '',$
              'Fold the light curves of the fitted intensities/scan from an',$
              'IDL save session file (.sav) created by the FIDCUTS1 routine,',$
              '(See Select Good Scans (Fidcuts1) help topic).  These plots',$
              'may be directed to your display or to the printer.',$

              'Quit HEAO and return to the IDL command line.',$

              'Display this Help menu.' ]

         Nlines= [ 8, 9, 9, 11, 6, 7, 6, 1, 1 ]


         buttons   = [  'Plot Scan Light Curves',$
                        'Make database file',$
                        'Find Additional Sources',$
                        'Select Good Scans', $
                        'Create Average Intensity Light Curves',$
                        'Create Normalized Lomb Periodograms',$
                        'Create Folded Light Curves',$
                        'Quit', $
                        'Help'  ]
         values    = [  'LCU',$
                        'MakeDBS',$
                        'FFindsrc', $
                        'Fidcuts1', $
                        'Mk_AvgLC', $
                        'Mk_LPGM', $
                        'Mk_FoldLC',$
                        'Quit', $
                        'Help'  ]
         title     = 'HEAO A-1 Data Analysis Main Menu'

         repeat begin
              Action    = XBUTTON( buttons, values, TITLE=title, $
                                  /COLUMN, /CENTER)
              case Action of
                   'LCU'       : LCU
                   'MakeDBS'   : MakeDBS
                   'FFindsrc'  : FFindsrc
                   'Fidcuts1'  : Fidcuts1
                   'Mk_AvgLC'  : Mk_AvgLC
                   'Mk_LPGM'   : Mk_LPGM
                   'Mk_FoldLC' : Mk_FoldLC
                   'Quit'      : print,'Quitting HEAO...'
                   'Help'      : XHELPMSG, Buttons, Descrs, Nlines, $
                                            TITLE=HelpTitle
              endcase
         endrep until Action eq 'Quit'

         xmsg,['May the Force Be With You','Always...'],$
              TITLE='Quitting HEAO...'
end
