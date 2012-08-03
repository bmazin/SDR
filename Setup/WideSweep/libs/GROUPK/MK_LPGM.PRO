;+
; NAME:
;        MK_LPGM
;
; PURPOSE:
;        Processes the data structure returned by FIDUCIAL to generate
;        plots of the Lomb Normalized Periodogram of the HEAO A-1 data.
;
; CATEGORY:
;        HEAO A-1 Scanning.
;
; CALLING SEQUENCE:
;
;        MK_LPGM
;
; OUTPUTS:
;
;        This routines generates periodograms and sends the output to
;        either the display or to a postscript file.  If the postscript
;        output is chosen, then the USER may additional choose to send
;        the postscript file to the printer defined by the PRINTER
;        environment variable.
;
; COMMON:
;        MK_LPGM:  For internal use only.
;
; MODIFICATION HISTORY:
;   January, 1995            H.C. Wen
;   03-FEB-1995              Bugfix: Start of date correction.
;   06-FEB-1995              Implemented GET_DATA, added TRN_CUT option,
;                            subtracted out average before calculating the
;                            periodogram.
;   08-FEB-1995              Adopted changes in MK_AVGLC and MK_FOLDLC
;-
pro MK_LPGM_

         common MK_LPGM, MKLPGM_

;   Unpack common

         Data      = MKLPGM_.data
         trn_cut   = MKLPGM_.trn_cut
         srcnum    = MKLPGM_.srcnum
         here      = MKLPGM_.here
         ofac      = MKLPGM_.ofac
         hifac     = MKLPGM_.hifac

;   Extract relevant tags

         t77i      = data.t77i(here,Srcnum)
         t77f      = data.t77f(here,Srcnum)
         tcorr     = data.tcorr(*,here,Srcnum)
         intensity = data.intensity(here,Srcnum)
         sigma     = data.sigma(here,Srcnum)
         Name      = data.name( Srcnum )

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

         tc0  = tcorr(0, *)
         tc1  = tcorr(1, *)
         tcorr= (tc0+tc1)*0.5
         time = double(t77i)+double(t77f)+double(tcorr)

         Flux = Intensity

;   Determine the periodogram

         flux = flux - AVG(flux)            ;subtract out the average

         LPGM_LC, Time, Flux, Name, OFAC=Ofac, HIFAC=Hifac
end

pro MK_LPGM

         common MK_LPGM, MKLPGM_

         d_display = !D.NAME

;   Define all widget texts

         pro_title = 'Mk_LPGM'
         err_title = pro_title+' ERROR'
         ret_title = 'Return to '+pro_title+' Main Menu'

         main      = [$
                   'File',$
                   'Options',$
                   'Create Periodogram',$
                   'Quit']

         options   = [$
                   'Display settings',$
                   'Periodogram parameters',$
                   'Transmission cutoff',$
                   'Source number',$
                   'Data region',$
                   ret_title]

         lpgmparm  = [$
                   'Oversampling factor:',$
                   'Highest freqency to be examined [Nyquist]:']

;   Define option defaults

         ofac      = 4                 ;Oversampling factor
         hifac     = 1                 ;Highest freq. to be examined
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
                                      'Oversampling factor:'+strtrim(ofac,2),$
                                      'Highest frequency [Nyquist]:'+strtrim(hifac,2),$
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
                        'Periodogram parameters':BEGIN
                             ans= XQUERY(lpgmparm, $
                                       DEFAULT=[arr2str(ofac,2),$
                                                arr2str(hifac,2)], $
                                       TITLE=pro_title+' Options',$
                                       XSIZE=[5,5])
                             ofac=float(ans(0))
                             hifac=float(ans(1))
                             END
                        ret_title:
                        ENDCASE
                   endrep until rpopt eq ret_title
                   END

              'Create Periodogram': BEGIN
                   if N_ELEMENTS( Data ) eq 0 then $
                        xmsg,'No IDL Save Session file selected.',$
                              TITLE=err_title $
                   else if (here(0) eq -1) then $
                        xmsg,'No data within USER selected region.',$
                             TITLE=err_title $
                   else begin

                       MKLPGM_ = { $
                                  Data      : data, $
                                  trn_cut   : trn_cut,$
                                  srcnum    : srcnum,$
                                  here      : here, $
                                  ofac      : ofac, $
                                  hifac     : hifac  }
                       MK_LPGM_
                   endelse
                   END
              'Quit'    :
              ENDCASE

         ENDREP Until rp eq 'Quit'

         print,'Quitting '+pro_title+'...'
end
