;+
; NAME:
;        FOLD_LC
;
; PURPOSE:
;        Folds the light curves for a source using a USER provided
;        period and plots the resulting folded light curves.
;
; CATEGORY:
;        Plotting.
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
;   Period:   Folding period in HOURS.
;
;   SrcName:  The name of the source, [string].
;
; OPTIONAL INPUT PARAMETERS:
;
;   FLUX_UNITS:    The units of the given intensities, [string], (''=Default).
;
; OUTPUTS:
;
;        This routine makes light curves of the HEAO A-1 data and sends
;        them to the graphic device if the USER selects it from the widget
;        menu.
;
; MODIFICATION HISTORY:
;   September, 1994          H.C. Wen
;   02-FEB-1995              Implemented XPLOT, XOPLOT
;   08-FEB-1995              Eliminated the HALF keyword for simplicity.
;-
pro FOLD_LC, Time, Flux, Err, SrcName, Period, $
              FLUX_UNITS=Flux_units


         JD_1_1_1977    = 2443145L
         xtitle         = 'Folded Time [Hours]'

         thr       = Time/3600.D0

         Pmulti    = !P.MULTI
         !P.MULTI  = [0,1,2]

         units     = ''
         if keyword_set( Flux_units ) then units=Flux_units

         tfold = thr MOD Period
         flux1 = flux
         sigF  = Err

         avgf = AVG( flux1 )
         siga = sqrt( TOTAL( sigF^2. ) )/N_ELEMENTS( flux1 )
         print,'Avg. Flux:',arr2str(avgf),plusminus(),arr2str(siga)

;   Plot the fitted intensities or "flux" as a function of time


         MINy = MIN( flux1-sigF )
         MAXy = MAX( flux1+sigF )

         MINy = FLOOR( (0.9*MINy)*100 ) / 100
         MAXy = CEIL( (1.1*MAXy)*100 ) / 100
         yrng1= [ MINy, MAXy ]

         mint = 0.0
         maxt = Period
         xrng1= [mint-0.2,maxt+0.2]

         xplot,tfold,flux1,sigF,psym=3,/xstyle,/ynozero,$
              xrange=xrng1, $
              yrange=yrng1, $
              XTITLE=xtitle,$
              YTITLE='Intensity '+units,$
              TITLE ='Folded Light Curve of '+srcname,$
              /PORTRAIT, WINDOW=i


;   Now do a weighted histogram of these intensities

         wgt       = 1./(sigF^2.)
         hist_wgt  = wgt * flux1
         binsize   = ((maxt - mint)/10.)*1.01
         sumf  = HIST1D( tfold, hist_wgt, BINSIZE=Binsize, $
                            MIN=mint, MAX=maxt,$
                            OBIN=tbins, DENSITY=dens )
         wgtf  = HIST1D( tfold, wgt, BINSIZE=Binsize, $
                            MIN=mint, MAX=maxt)
         igt0 = where( wgtf gt 0, ngt0 )
         avgf       = sumf
         avgf(igt0) = avgf(igt0)/wgtf(igt0)
         sigf       = 0.*avgf
         sigf(igt0) = 1./sqrt( wgtf(igt0) )
         sigt       = replicate( (binsize/2.)*.95, n_elements( tbins ))

;   plot results

         t0        = strtrim(long(thr(0)/24. + JD_1_1_1977),2)
         subtitle  = 'Folding Period [hrs]: '+arr2str(Period,4)+$
                     ' , Start of data [JD]: '+t0
         xplot,tbins,avgf,sigf,psym=3,/xstyle,/ynozero,$
              xrange=xrng1,$
              yrange=yrng1,$
              XTITLE=xtitle,$
              YTITLE='Weighted Average Intensity '+units,$
              TITLE ='Average Folded Light Curve of '+srcname,$
              SUBTITLE=subtitle,$
              /PORTRAIT
         xoplot,tbins,avgf,psym=10,/PORTRAIT

         !P.MULTI = Pmulti

end
