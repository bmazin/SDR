;+
; NAME:
;        AVG_LC
;
; PURPOSE:
;        Plots the average light curves for a source, customized to
;        the HEAO A-1 data.
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
;   Err:      Array of corresponding uncertainties for each intensity
;             [fltarr( npts )] in units specified by the FLUX_UNITS keyword.
;
;   SrcName:  The name of the source, [string].
;
; OPTIONAL INPUT PARAMETERS:
;
;   FLUX_UNITS:    The units of the given intensities, [string], (''=Default).
;
;   BINSIZE:       Time binsize of the average light curve in DAYS.
;
; OUTPUTS:
;
;        This routine makes light curves of the HEAO A-1 data and sends
;        them to the graphic device if the USER selects it from the widget
;        menu.
;
; MODIFICATION HISTORY:
;   September, 1994          H.C. Wen
;   12-JAN-1995              Added the BINSIZE keyword
;   01-FEB-1995              Implemented XPLOT, XOPLOT
;   08-FEB-1995              Eliminated the HALF keyword for simplicity.
;-
pro AVG_LC, Time, Flux, Err, SrcName, FLUX_UNITS=Flux_units, $
                  BINSIZE=Binsize


         JD_1_1_1977    = 2443145L
         xtitle         = 'Modified Julian Date ( JD - 2443145 )'

         tday = Time/86400.D0

         Pmulti    = !P.MULTI
         !P.MULTI  = [0,1,2]

         units     = ''
         if keyword_set( Flux_units ) then units=Flux_units

         flux1 = flux
         sigF = Err

         avgf = AVG( flux1 )
         siga = sqrt( TOTAL( sigF^2. ) )/N_ELEMENTS( flux1 )
         print,'Avg. Flux: ',arr2str(avgf),plusminus(),arr2str(siga)

;   Plot the fitted intensities or "flux" as a function of time

         MINy = MIN( flux1-sigF )
         MAXy = MAX( flux1+sigF )

         MINy = FLOOR( (0.9*MINy)*100 ) / 100
         MAXy = CEIL( (1.1*MAXy)*100 ) / 100
         yrng1= [ MINy, MAXy ]

         mintd= MIN( tday, MAX=maxtd )
         xrng1= [mintd-0.2,maxtd+0.2]

         xplot,tday,flux1,sigF,psym=3,/xstyle,$
              xrange=xrng1, $
              yrange=yrng1, $
              XTITLE=xtitle,$
              YTITLE='Intensity '+units,$
              TITLE ='Light Curve of '+srcname,$
              /PORTRAIT, WINDOW=i


;   Now do a weighted histogram of these intensities

         wgt       = 1./(sigF^2.)
         hist_wgt  = wgt * flux1
         if N_ELEMENTS(Binsize) eq 0 then $
         binsize   = ((maxtd - mintd)/10.)*1.01
         sumf  = HIST1D( tday, hist_wgt, BINSIZE=Binsize, $
                            MIN=mintd, MAX=maxtd,$
                            OBIN=tdbins, DENSITY=dens )
         wgtf  = HIST1D( tday, wgt, BINSIZE=Binsize, $
                            MIN=mintd, MAX=maxtd)
         igt0 = where( wgtf gt 0, ngt0 )
         avgf       = sumf
         avgf(igt0) = avgf(igt0)/wgtf(igt0)
         sigf       = 0.*avgf
         sigf(igt0) = 1./sqrt( wgtf(igt0) )
         sigtd      = replicate( (binsize/2.)*.95, n_elements( tdbins ))

;   plot results

         xplot,tdbins,avgf,sigf,psym=3,/xstyle,$
              xrange=xrng1,$
              yrange=yrng1,$
              XTITLE=xtitle,$
              YTITLE='Weighted Average Intensity '+units,$
              TITLE ='Average Light Curve of '+srcname,$
              /PORTRAIT
         xoplot,tdbins,avgf,psym=10,/PORTRAIT

         !P.MULTI = Pmulti

end
