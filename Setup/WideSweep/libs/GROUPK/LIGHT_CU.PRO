;+
; NAME:
;        LIGHT_CURVE
;
; PURPOSE:
;        Generates a light curve of the data along with the transmission
;        function(s) normalized to the area under the light curve.
;
; CATEGORY:
;        Data Analysis.
;
; CALLING SEQUENCE:
;
;        LIGHT_CURVE, Cts, [ Trns, Trn_fit, LEGEND=legend, ..other plotting keywords ]
;
; INPUTS:
;          Cts:    Array holding the counts for the current major frame, [float( nbin )].
;
; OPTIONAL INPUTS
;
;         Trns:    A nsrc x nbin array of transmission functions, [float( nsrc, nbin )].
;
;      Trn_fit:    An array containing the total transmission function fitted
;             to the counts of the the light curve, float(nbins).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;       LEGEND:    Adds a legend to the plot, [string(nsrc)].
;
;       LTITLE:    A string array specifying the text to include
;             in the legend, [string()].
;
;        TITLE:    Specifies a title to the plot, [string].
;
;     SUBTITLE:    Subtitle below the x-axis title, [string].
;
;       XTITLE:    Title along the x-axis,[string].
;
;       YTITLE:    Title along the y-axis,[string].
;
;       XRANGE:    Specifies an range along the x-axis for the plot,[float(2)].
;
;         PSYM:    Specifies the symbol type for plotting the counts,[integer].
;
;    WHITE_BKD:    Plot graph with a white background instead of black.
;
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;        LCLOADCT must be called once before calling this routine
;        to load the appropriate color table.
;        If you want a legend to be plotted you must include the Trns
;        array input.
;
; EXAMPLE:
;        Let's say our current major frame is in 320ms mode and we have
;        two sources within the field of view.  Let's plot the light curve
;        for this major frame onto the screen.
;
;        nbin = 128
;        cutoff = 0.05
;        A    = [0.8, 0.5]
;        ctr  = [60., 80.]
;        sig  = [5. , 10.]
;
;        Cts  = 10 * abs(randomn( seed, nbin )) + 50
;        Trns = fltarr( 2, nbin )
;
;        Let's generate two "gaussian" transmission functions
;
;        for i=0, nbin-1 do begin
;
;             for j=0,1 do begin
;                  trns(j,i) = A(j) * exp( -((i-ctr(j))/sig(j) )^2. )
;                  if trns(j,i) lt cutoff then trns(j,i) = 0.
;                  cts(i) = cts(i) + 100. * trns(j,i)
;             endfor
;
;        endfor
;
;        LIGHT_CURVE, Cts, Trns, /PLOT, /LEGEND
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, April 1994.
;        28-APR-1994    Added the LEGEND keyword.
;        01-MAY-1994    Added overlaying transmission functions
;                       normalized to lie underneath the light curve.
;        02-MAY-1994    Overlayed transmission functions now plotted
;                       with different colors.
;        05-MAY-1994    Reduced/simplified the scope of LIGHT_CURVE;
;                       off-loaded all fitting calculations to a
;                       separate routine, CT_RATE.
;        10-MAY-1994    Removed zeroing of the y-axis for counts.
;                       Scaled transmission to full range;
;                       plot its axis on the right side.
;        15-MAY-1994    Define color table in LCLOADCT procedure. Added
;                       WHITE_BKD keyword to generate printable plot.
;-

pro LIGHT_CURVE, Cts, Trns, Trn_fit, LEGEND=legend, TITLE=title, $
                 SUBTITLE=subtitle, XTITLE=xtitle, YTITLE=ytitle,$
                 PSYM=psym, XRANGE=xrange, WHITE_BKD=white_bkd

         common lc_colors, ncolors, linecolors, black, cyan, white


         ON_ERROR,2              ; Return to caller if an error occurs

         NP = N_PARAMS()
         if (NP lt 1) or (NP gt 3) then $
            message, 'Must be called with 1-3 parameters: '+$
                     'Cts [, Trns, Trn_fit]'

;  Let's determine the length of these arrays and the number of sources

         SCts      = SIZE( Cts )
         nbin      = SCts(1)

         if NP ge 2 then begin
              STrns     = SIZE( Trns )
              nsrc      = STrns(1)

              IF (STrns(0) ne 2) or (STrns(2) ne nbin) then $
                   message,'Size of Cts and Trns arrays are incompatible.'
         endif

         if not keyword_set( PSYM  ) then psym=10
         if not keyword_set( TITLE ) then title='Light Curve'
         if not keyword_set( SUBTITLE ) then subtitle = ''
         if not keyword_set( XTITLE ) then xtitle='Bin'
         if not keyword_set( YTITLE ) then ytitle='Counts'
         if not keyword_set( XRANGE ) then xrange = [0.,nbin]
         if not keyword_set( WHITE_BKD ) then begin
              fgdcolor=white
              bkdcolor=black
              trncolors=linecolors
              fitcolor =cyan
         endif else begin
              fgdcolor=black
              bkdcolor=white
              trncolors=REPLICATE(black,ncolors)
              fitcolor =black
         endelse

; Plot out the counts in a "histogram" format
         if NP ge 2 then begin
              ystyle =8
              xmargin=[8,8]
         endif else begin
              ystyle =0
              xmargin=0
         endelse

         PLOT,indgen(nbin),cts, PSYM=psym,  /YNOZERO, $
              COLOR=fgdcolor, BACKGROUND=bkdcolor,$
              TITLE=title,   $
              SUBTITLE=subtitle, $
              XTITLE=xtitle, $
              YTITLE=ytitle, $
              /XSTYLE,YSTYLE=ystyle,XMARGIN=xmargin,XRANGE=xrange


; then overlay the transmission curve(s)
         if NP ge 2 then begin

; graph the legend if requested
              if keyword_set( LEGEND ) then begin

                      v1 = [0,0,0]
                      v2 = [!D.X_CH_SIZE,!D.Y_CH_SIZE,0]
                      x1 = CONVERT_COORD( v1, /DEVICE, /TO_DATA )
                      x2 = CONVERT_COORD( v2, /DEVICE, /TO_DATA )
                      xtick = abs( x2(0) - x1(0) )
                      ytick = abs( x2(1) - x1(1) )
                      for i=0,nsrc-1 do XYOUTS,2*xtick,$
                                    !Y.CRANGE(1)-(i+1.5)*ytick,$
                                    legend(i), color=trncolors(i)
              endif

            offset = 0.02
            scale = !Y.CRANGE(1) - !Y.CRANGE(0)
            AXIS, /YAXIS, yrange = [-offset,1.], /YSTYLE, $
                   ytitle = 'Transmission' , color=fgdcolor
            ymin  = !Y.CRANGE(0)
            otrn = ymin + scale*(trns+offset)
            for i=nsrc-1,0,-1 do oplot,otrn(i,*),color=trncolors(i)

            if NP eq 3 then oplot, Trn_fit, color=fitcolor

         endif


end


