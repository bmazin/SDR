;+
; NAME:
;        MK_AVGLC
;
; PURPOSE:
;        Processes the data structure returned by FIDUCIAL to generate
;        plots of the average & weighted average light curves of
;        the HEAO A-1 data.
;
; CATEGORY:
;        HEAO A-1.
;
; OUTPUTS:
;
;        This routine generates postscript files of light curve plots of
;        the HEAO A-1 data and then sends these files to the printer
;        defined by the PRINTER environment variable.
;
; COMMON:
;        MK_AVGLC:  For internal use only.
;
; MODIFICATION HISTORY:
;   September, 1994          H.C. Wen
;   20-JAN-1995              Made compatible with .SAV format of XFiducial 3.1
;   22-JAN-1995              Widgetized all options.
;   01-FEB-1995              Implemented XPLOT, XOPLOT
;   06-FEB-1995              Implemented GET_DATA, added TRN_CUT option
;   07-FEB-1995              Bugfix: didn't find lc for source index > 0 properly
;                            Also moved restore of DATA structure to File.
;                            Units of error bars incorrect
;   08-FEB-1995              Got rid of GETHALVES, simplified to using WHEREGION
;-

pro MK_AVGLC_

         common MK_AVGLC, MKLC_

         LASS2JY   = 230          ;LASS to microJy at 5 keV
                                  ;0.001 LASS flux units = 0.23E-6 Jy at 5 keV
         pro_title = 'Mk_AvgLC'

;   Unpack common

         Data      = MKLC_.data
         trn_cut   = MKLC_.trn_cut
         srcnum    = MKLC_.srcnum
         here      = MKLC_.here

;   Extract relevant tags

         t77i      = data.t77i(here,Srcnum)
         t77f      = data.t77f(here,Srcnum)
         tcorr     = data.tcorr(*,here,Srcnum)
         intensity = data.intensity(here,Srcnum)
         sigma     = data.sigma(here,Srcnum)
         Name      = data.name( Srcnum )

         mode      = data.mode
         sec       = mode/1000.   ;seconds in a bin

         module    = data.module
         CASE module OF
              1    : cm2 = 1650   ;Area of HEAO A-1 module
              2    : cm2 = 1650   ;in CM^2
              3    : cm2 = 1650
              5    : cm2 = 1350
              6    : cm2 = 1350
              7    : cm2 = 1900
              else : message,'Invalid module number:'+string(module)
         ENDCASE

;   Further restrict range of data by transmission cut

         trn_max   = PK_TRNS( Data )
         trn_max   = trn_max( here )
         here_cut  = where( trn_max ge trn_cut, n_ge )
         if n_ge eq 0 then begin
              xmsg, 'No scans have a transmission peak > cutoff',$
                   TITLE=pro_title
              return
         endif

         t77i      = t77i(here_cut)
         t77f      = t77f(here_cut)
         tcorr     = tcorr(*,here_cut)
         intensity = intensity(here_cut)
         sigma     = sigma(here_cut)

;   Make average light curves

         Units= '[!4l!XJy at 5 keV]'
         tc0  = tcorr(0, *)
         tc1  = tcorr(1, *)
         tcorr= (tc0+tc1)*0.5
         time = double(t77i)+double(t77f)+double(tcorr)

         Flux = (Intensity/cm2/sec)*LASS2JY
         Err  = (Sigma/cm2/sec)*LASS2JY
         AVG_LC, time, flux, err, name, FLUX_UNITS=units
end


pro MK_AVGLC


         common MK_AVGLC, MKLC_

         d_display = !D.NAME

;   Define all widget texts

         pro_title = 'Mk_AvgLC'
         err_title = pro_title+' ERROR'
         ret_title = 'Return to '+pro_title+' Main Menu'

         main      = [$
                   'File',$
                   'Options',$
                   'Create Light Curves',$
                   'Quit']

         options   = [$
                   'Display settings',$
                   'Transmission cutoff',$
                   'Source number',$
                   'Data region',$
                   ret_title]

;   Define option defaults

         srcnum    = 0                 ;source number
         trn_cut   = 0                 ;Lowest acceptable transmission peak.
         here      = -1                ;data region indices

         YN        = ['No','Yes']
         file      = ''

;   Bring up Main Menu

         REPEAT BEGIN

              rp = XBUTTON(Main,Main,/ROW,$
                           TITLE=pro_title+' Main Menu')

              CASE rp OF
              'File'   : BEGIN
                   ; Restore IDL save session file

                   data1= GET_DATA(OFILE=File1,TITLE=pro_title+' Message')
                   here_NULL = where( TAG_NAMES(data1) eq 'NULL', nNULL )
                   if nNULL eq 0 then begin
                        File=File1
                        data=data1
                        here= lindgen( data.npass )
                   endif
                   END
              'Options': BEGIN
                   repeat begin
                        rpopt = XBUTTON(options,options,/COLUMN,$
                                  TITLE=pro_title+' Options Menu')
                        CASE rpopt OF
                        'Display settings': BEGIN
                                 if here(0) eq -1 then begin
                                       t0   = 'N/A'
                                       t1   = 'N/A'
                                 endif else begin
                                       nh   = n_elements(here)
                                       i0   = here(0)
                                       i1   = here(nh-1)
                                       t0   = data.t77i(i0,srcnum)/86400.
                                       t1   = data.t77i(i1,srcnum)/86400.
                                       t0   = arr2str(t0,4)
                                       t1   = arr2str(t1,4)
                                 endelse
                                 setstrs = [$
                                      'IDL .sav file: '+file,$
                                      'Transmission cutoff: '+arr2str(trn_cut,3),$
                                      'Source number: '+strtrim(srcnum,2),$
                                      'Data region: '+t0+' , '+t1+' [days]']
                                 xmsg,setstrs,TITLE=pro_title+' Settings',/ALIGN
                                 END
                        'Transmission cutoff':BEGIN
                             qy_trn    = 'Enter lowest acceptable tranmission '+$
                                         'peak value:'
                             trn_cut   = XQUERY(qy_trn,default=trn_cut,$
                                                 TITLE=pro_title+' Settings')
                             trn_cut   = trn_cut(0)
                             END
                        'Source number': BEGIN
                             srcnum= XQUERY('Enter source number:',$
                                       DEFAULT=srcnum,$
                                       TITLE=pro_title+' Options',XSIZE=3,$
                                       /LEFT, /TOP)
                             srcnum=fix(srcnum)
                             END
                        'Data region':BEGIN
                             if N_ELEMENTS( Data ) eq 0 then begin
                                  xmsg,['An IDL SAVE session file must first',$
                                        'be selected. (Select the File button',$
                                        'in the Main Menu.)'],$
                                        TITLE=err_title
                             endif else begin
                                  here = WHEREGION( Data.t77i(*,srcnum)/86400.,$
                                            PK_TRNS( Data, srcnum), $
                                            XTITLE='Time [Days]',$
                                            YTITLE='Peak Transmission/Scan for '+$
                                                   Data.name(srcnum), $
                                            TITLE='Distribution of Times' )
                             endelse
                             END
                        ret_title:
                        ENDCASE
                   endrep until rpopt eq ret_title
                   END

              'Create Light Curves':BEGIN

                   if N_ELEMENTS( Data ) eq 0 then $
                        xmsg,'No IDL Save Session file selected.',$
                              TITLE=err_title $
                   else if (here(0) eq -1) then $
                        xmsg,'No data within USER selected region.',$
                             TITLE=err_title $
                   else begin

                        MKLC_ = { $
                                  Data      : data, $
                                  trn_cut   : trn_cut, $
                                  srcnum    : srcnum,$
                                  here      : here }
                        MK_AVGLC_
                   endelse
                   END
              'Quit'    : print,'Quitting '+pro_title+'...'
              ENDCASE

         ENDREP Until rp eq 'Quit'
         MKLC_     = 0
end
