;+
; NAME:
;        GET_TRNS
;
; PURPOSE:
;        Calculates the collimator transmission function given the aspects
;        of the satellite at the beginning of two or more sequential major
;        frames and the aspect of the source.
;
; CATEGORY:
;        Collimator.
;
; CALLING SEQUENCE:
;        Result = GET_TRNS(Module, Nbin, RAs, DECs, RAY, DEY, RAZ, DEZ)
;
; INPUTS:
;       Module:    The module number in range 1 to 7, [integer].
;
;         Nbin:    The total number of bins for all the sequential major
;             frames, [integer].
;
;     RAs,DECs:    The RA,DEC of the source in RADIANS, [float].
;
;      RAY,DEY:    The RA,DEC of the satellite's Y-axis in RADIANS
;             at the beginning of each sequential major frame, [float(nmjf)].
;
;      RAZ,DEZ:    The RA,DEC of the satellite's Z-axis in RADIANS
;             at the beginning of each sequential major frame, [float(nmjf)].
;
; OPTIONAL INPUT KEYWORDS:
;       OFFSET:    The number of bins from the bin edge where the aspects
;             are calculated.  The default is 0.5 bin, namely, the center
;             of each bin, [float].
;
; OUTPUTS:
;        This function returns the collimator response function of the source
;        for the specified collimator module over all the bins of the
;        sequential major frames, [float(nbin)].
;
; RESTRICTIONS:
;        You must provide at least two or more major frames;
;        i.e. N_ELEMENTS( RAY ) > 1.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;-
function GET_TRNS, Module, Nbin, RAs, DECs, RAY, DEY, RAZ, DEZ, OFFSET=Offset


         nmjf = N_ELEMENTS( RAY )
         if nmjf eq 1 then $
              message,'Must supply 2 or more major frames.'

         nbin_mjf  = nbin/nmjf
         Y_asp     = fltarr( 2, nbin )
         Z_asp     = fltarr( 2, nbin )

;   Interpolate the satellite's aspects for the first nmjf-1 major frames
         for k=0,nmjf-2 do begin
              Ry = [ray(k),ray(k+1)]
              Dy = [dey(k),dey(k+1)]
              Rz = [raz(k),raz(k+1)]
              Dz = [dez(k),dez(k+1)]

              GET_ASPECTS, 0, nbin_mjf, Ry,Dy, Rz,Dz, Y_int,Z_int,OFFSET=Offset
              Y_asp(*,k*nbin_mjf:(k+1)*nbin_mjf-1) = Y_int
              Z_asp(*,k*nbin_mjf:(k+1)*nbin_mjf-1) = Z_int
         endfor

;   Extrapolate the aspects for the remaining major frame.
         k=nmjf-1
         GET_ASPECTS, 1, nbin_mjf, Ry,Dy, Rz,Dz, Y_ext,Z_ext,OFFSET=Offset
         Y_asp(*,k*nbin_mjf:(k+1)*nbin_mjf-1) = Y_ext
         Z_asp(*,k*nbin_mjf:(k+1)*nbin_mjf-1) = Z_ext


;   Determine the transmission function for this major frame buffer
         Trans = COLLF( Module,RAs,DECs, Y_asp(0,*),Y_asp(1,*),$
                        Z_asp(0,*),Z_asp(1,*))

         return, Trans
end

