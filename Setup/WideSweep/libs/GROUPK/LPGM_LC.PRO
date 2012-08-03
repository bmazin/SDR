;+
; NAME:
;        LPGM_LC
;
; PURPOSE:
;        Calculates the Lomb Normalized Periodogram of the light curves
;        for a source, customized to the HEAO A-1 data.
;
; CATEGORY:
;        HEAO A-1.
;
; INPUTS:
;
;   Time:     Array of times in SECONDS since 1/1/77, [dblarr( npts )].
;
;   Flux:     Array of corresponding intensities for the source,
;             [fltarr( npts )] in units specified by the FLUX_UNITS keyword.
;
;   SrcName:  The name of the source, [string].
;
; OPTIONAL INPUT PARAMETERS:
;
;   OFAC:          Oversampling factor of the periodogram, (4=Default).
;
;   HIFAC:         Hifac * "average" Nyquist frequency = highest frequency
;                  for which values of the Lomb normalized periodogram will
;                  be calculated, (1=Default)
; OUTPUTS:
;
;        This routine makes periodograms of the light curves of the HEAO A-1
;        data and sends them to the graphic device if the USER selects it from the widget
;        menu.
;
; MODIFICATION HISTORY:
;   February, 1994          H.C. Wen
;        06-AUG-1996    Check if !SAVE_PATH system variable is defined.
;-
pro LPGM_LC, Time, Flux, SrcName, OFAC=Ofac, HIFAC=Hifac


         JD_1_1_1977    = 2443145L

;   Define all widget texts

         modstr    = ['Add FAP line',$
                      'Mark a Peak',$
                      'Information about a Peak',$
                      'Cancel',$
                      'Done' ]

         pro_title = 'LPGM_LC'
         err_title = pro_title+' ERROR'
         ret_title = 'Return to '+pro_title+' Main Menu'

         thr       = Time/3600.D0
         flux1     = flux - AVG(flux)   ;subtract out the average

         Pmulti    = !P.MULTI
         !P.MULTI  = 0

         units     = ''
         if keyword_set( Flux_units ) then units=Flux_units
         if NOT keyword_set( Ofac ) then Ofac=4.
         if NOT keyword_set( Hifac) then Hifac=1.

;   Calculate periodogram

         xmsg,'Calculating Periodogram...',$
              TITLE=pro_title+' Message',$
              /NOBUTTON, MSG_ID=Msg_ID_begin
         WIDGET_CONTROL, /HOURGLASS

         NR_PERIOD, thr, flux1, ofac, hifac, px, py, nout, jmax, prob
         effm=2.0*nout/ofac

         xmsg,'Calculating Periodogram...completed.',$
              TITLE=pro_title+' Message',$
              /NOBUTTON, MSG_ID=Msg_ID_end
         WIDGET_CONTROL, Msg_ID_begin, /DESTROY
         WAIT,0.5
         WIDGET_CONTROL, Msg_ID_end  , /DESTROY

;   Store results for possible write out to save session file

         lpgm = { freq:px, power:py, jmax:jmax, prob:prob }

;   First plot the periodogram

         nt     = n_elements( time )
         t0     = strtrim(long(time(0)/86400. + JD_1_1_1977),2)
         tlen   = arr2str((time(nt-1) - time(0))/86400.,4)
         subtitle = 'Length of data [Days]: '+tlen+$
                    ' , Start of data [JD]: '+t0

UNDO:    xplot, px, py, /xstyle, $
              yrange=[0,(1.05*max(py))],$
              xtitle='Frequency [Cycles/hr]',$
              ytitle='Power', $
              title ='Lomb Normalized Periodogram of '+srcname,$
              subtitle=subtitle,$
              WINDOW=i

;   and then overplot the FAP lines

         nline     = 0
         REPEAT BEGIN
              rp = XBUTTON( modstr, modstr, /COLUMN, /LEFT, /TOP,$
                             TITLE=pro_title+' Edit')

              CASE rp OF
              'Add FAP line': BEGIN
                   xmsg,['Position mouse cursor within plot area',$
                         'where you wish the FAP line to be drawn',$
                         'and click mouse button 1.'],$
                         TITLE=pro_title+' Instruction',/NOBUTTON, $
                         /LEFT, /TOP, MSG_ID=Msg_ID
                   cursor, x0, y0, /DATA, /DOWN
                   WIDGET_CONTROL,Msg_ID,/DESTROY

                   xoplot, [px(0),px(0)+0.86*(px(nout-1)-px(0))],[y0,y0], $
                           LINESTYLE = (nline + 1) MOD 5, /NO_MENU

                   expy= exp(-y0)
                   FAP = effm * expy
                   if FAP gt 0.01 then FAP = 1.D0 - (1.D0-expy)^effm
                   sigP = (1.D0 - FAP)*100.
                   CASE 1 OF
                        sigP lt 1      : xystr = '< 1%'
                        sigP gt 99.9   : xystr = '> 99.9%'
                        else           : xystr = arr2str( sigP,3 )+'%'
                   ENDCASE
                   xxyouts,px(0)+0.88*(px(nout-1)-px(0)),y0,xystr,/DATA

                   nline = nline + 1
                   END
              'Mark a Peak': BEGIN

                   xxyouts, '!95!X',TEXT_OBJECT='the mark'       ;plot the down arrow

                   rp_mk = XQUERY('Enter Text to be drawn above mark:',$
                                TITLE=pro_title+' Edit',/TOP,/LEFT )
                   markstr = rp_mk(0)
                   if markstr ne '' then xxyouts, markstr, ALIGNMENT=0.5, /DATA
                   END
              'Information about a Peak': BEGIN
                   xmsg,['Position mouse cursor within plot area',$
                         'on the peak you want information on',$
                         'and click mouse button 1.'],$
                         TITLE=pro_title+' Instruction',/NOBUTTON, $
                         /LEFT, /TOP, MSG_ID=Msg_ID

                   cursor, x0, y0, /DATA, /DOWN
                   WIDGET_CONTROL,Msg_ID,/DESTROY

                   here = WHERE( px ge x0, nx_gt )
                   if nx_gt eq 0 then begin
                      xmsg, 'No peaks found around area you clicked.',$
                             TITLE=err_title
                   endif else begin
                      i0 = (here(0) - 5) > 0
                      in = (here(0) + 5) < (nout-1)
                      pk = MAX( py(i0:in), ipk )
                      ipk= ipk + i0
                      expy= exp(-py(ipk))
                      Ppk = effm * expy
                      if Ppk gt 0.01 then Ppk = 1. - (1.-expy)^effm
                      xmsg, [$
                         'Lomb normalized periodogram value:'+$
                                           arr2str(py(ipk),5),$
                         'at Period [Hours]:'+arr2str(1/px(ipk),4),$
                         'with False Alarm Probability (FAP):'+$
                                            arr2str(Ppk,4) ], $
                         TITLE='Lomb_PGM Results',/LEFT,/BOTTOM,/ALIGN
                   endelse
                   END
              'Cancel':goto, UNDO
              'Done':
              ENDCASE
         ENDREP until rp eq 'Done'
         xoplot, [px(0),px(nout-1)], [py(0),py(nout-1)],PSYM=3

;   Ask USER whether or not to save the results to an IDL session file

         rp = YNCANCEL('Write out results to IDL session file?', $
                        TITLE=pro_title+' Output')
         if rp eq 1 then begin

              defsysv,'!SAVE_PATH',EXISTS=defined
              if (NOT defined) then defsysv,'!SAVE_PATH',''
              file=pickfile(PATH=!SAVE_PATH,FILTER='*.sav',$
                             FILE=!SAVE_PATH+'lpgm.sav')
              if (file eq '') $
              then xmsg,'No filename specified.', TITLE=pro_title+' Output' $
              else begin
                   delim = RSTRPOS(file,'\')
                   if (delim eq -1) then delim = RSTRPOS(file,'/')
                   if (delim ne -1) $
                   then defsysv,'!SAVE_PATH',STRMID(file,0,delim+1)
                   save,lpgm,filename=file
                   xmsg,['IDL save session file:',file,'Saved.'],$
                        TITLE=pro_title+' Output'
              endelse
         endif

         !P.MULTI = Pmulti

end
