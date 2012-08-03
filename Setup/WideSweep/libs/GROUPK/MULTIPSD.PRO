;+
; NAME:
;        MULTIPSD
;
; PURPOSE:
;        Given an array of times, ts divide the data into equal time segments,
;        calculate the FFT power spectra of these segments and average
;        the power spectra.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = MULTIPSD( Ts, Bin, Nbin, Npsd, Mean, Sigma )
;
; INPUTS:
;        Ts:       An array of times with starting time, Ts(0)=0.
;
;        Bin:      The length of one time bin in the same UNITS as the Ts array.
;
;        Nbin:     The number of time bins in each time segment.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        VERBOSE:  Setting the keyword will display messages updating the user
;                  on which time segment the routine is currently processing.
;
; OUTPUTS:
;        This function returns the average FFT power spectra and the standard
;        deviations about each average in an array, FLTARR((nbin/2), 2). The
;        first column, (*,0) holds the power spectra
;        averaged over Npsd time segments and the second column (*,1) holds the
;        standard deviations about those averages.
;
; OPTIONAL OUTPUTS:
;
;        Npsd:     The number of equal time segments the data was divided into.
;
;        Mean:     Average number of counts/bin over all times FFTed.
;
;        Sigma:    Sqrt of the variance of the counts/bin about the Mean over
;                  all times FFTed.
;
; PROCEDURE:
;
;        The average power spectra is usually normalized in one of two ways:
;        Leahy or fractional RMS amplitude.  The Leahy normalized power is
;        determined by multiplying (2/<Ncts>) with the results of this function:
;
;        Pwrarray  = MULTIPSD( Ts, Bin, Nbin, Npsd, Mean, Sigma )
;        Ncts      = Mean*Nbin
;        Pleahy    = (2/Ncts)*Pwrarry(*,0)
;
;        where Ncts is the average total number of counts in one time segment.
;
;        The fractional RMS amplitude is a dimensionaless quantity defined as
;        the square root of the variance of the counts/bin divided by the
;        average counts/bin. Its normalization can be determined by dividing
;        the Leahy normalized power by the average intensity, <I>:
;
;        Iavg      = Mean/Bin
;        Prms      = Pleahy/Iavg
;
;        To relate Prms to the actual fractional RMS amplitude, (Sigma/Mean):
;
;        rms       = Sigma/Mean
;        dFreq     = 1/(Bin*Nbin)
;        TOTAL(Prms)= rms^2/dFreq
;
; EXAMPLE:
;
;        The input parameters, nbin and bin are related to the limits of the FFT
;        frequencies in the following manner:
;
;        1/(nbin*bin)   = Minimum frequency
;        1/(2*bin)      = Nyquist frequency
;
;        Given a time array, ts=LONARR(500000)=[0,1000000], determine the average
;        power spectra if Bin = 50 and Nbin = 4096.
;
;        Bin  = 50
;        Nbin = 1024    -> Npsd = 19 time segments
;
;        pwr_result = MULTIPSD( Ts, Bin, Nbin, Npsd, RMS, /VERB )
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;        14-AUG-1996    Eliminated LEAHY, RMS keywords, added RMS output parameter,
;                       check number of parameters.
;        15-AUG-1996    Removed RMS parameter, added Mean and Sigma parameters.
;        30-AUG-1996    Bugfix: return sigma instead of variance.
;
;-
function MULTIPSD, Ts, Bin, Nbin, Npsd, MeanCts, SigmaCts, VERBOSE=Verbose

         NP   = N_PARAMS()
         if (NP lt 3) then message, $
              'Must be called with 3-5 parameters: Ts, Bin, Nbin [, Npsd, RMS ]'

;   Determine the number of data points that will be truncated past
;   the last time segment

         nts       = LONG(N_ELEMENTS(ts))
         tPSD      = bin*LONG(nbin)
         nexac     = ts(nts-1)/DOUBLE(tPSD)
         nPSD      = FLOOR(nexac + 0.01)
         if (nexac ne nPSD) then begin
              hbad      = WHERE(ts gt nPSD*tPSD,ntrunc)
              percent   = 100*FLOAT(ntrunc)/nts
              if (percent gt 0) then $
                   print,'Number of data points truncated: ', $
                         STRTRIM(ntrunc,2),'/',STRTRIM(nts,2),$
                         ', ',STRING(percent,FORMAT='(F6.2)'),'%'
         endif

;   Loop over each time segment

         j    = 0L
         mu   =( mu2 = 0d0 )
         pj   = FLTARR( nbin/2, 2 )
         for i=0,nPSD-1 do begin

              if (KEYWORD_SET(Verbose)) then begin
                   print,SYSTIME()+'// Calculating PSD: ', $
                        STRTRIM(i+1,2),'/',STRTRIM(nPSD,2)
              endif

              cts       = FIX(HIST1D(ts,MIN=j,MAX=j+tPSD-1,BINSIZE=bin))
              ncts      = TOTAL(cts,/DOUBLE)
              mu        = mu  + ncts
              mu2       = mu2 + TOTAL(DOUBLE(cts)^2)
              avg_cts   = ncts/nbin

              coeffs    = FFT(cts-avg_cts,1)
              fft_pwr   = ABS(coeffs(1:nbin/2))^2

              pj(*,0)   = pj(*,0) + fft_pwr
              pj(*,1)   = pj(*,1) + fft_pwr^2

              j         = j + tPSD
         endfor

;   Average over all time segments

         avgpwr    = REFORM(pj(*,0))/nPSD
         avgpwr2   = REFORM(pj(*,1))/nPSD
         pj        =( coeffs = 0 )

         var_pwr   = (nPSD/(nPSD-1d0))*(avgpwr2 - avgpwr^2)
         sigpwr    = SQRT(var_pwr/nPSD)

;   Determine parameters needed for normalization

         nbin_tot  = nPSD*nbin
         mu        = mu /nbin_tot
         mu2       = mu2/nbin_tot
         var_mu    = (nbin_tot/(nbin_tot-1d0))*(mu2 - mu^2)

         MeanCts   = mu
         SigmaCts  = SQRT(var_mu)

         return, REFORM([avgpwr,sigpwr],nbin/2,2)
end
