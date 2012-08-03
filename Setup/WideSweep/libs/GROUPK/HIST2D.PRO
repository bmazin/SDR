;+
; NAME:
;        HIST2D
;
; PURPOSE:
;        Return the weighted density function (histogram) of two variables.
;
; CATEGORY:
;        Image processing, statistics, probability.
;
; CALLING SEQUENCE:
;        Result = hist2d(V1, V2 [,Weight, ...histogram keywords])
; INPUTS:
;        V1 and V2 = arrays containing the variables.  They MAY be
;             of ANY type, and MAY contain negative elements.
;
; OPTIONAL INPUTS:
;       Weight:    1D array of the same dimension as V1 and V2 which holds the
;             weighted values associated with each V1 and V2 element.
;
; INPUT KEYWORD PARAMETERS:
;     BINSIZEn:    The size of the bin to use for the Vn array. If this
;             keyword is not specified, a bin size of 1 is used. (n = 1,2)
;
;        INPUT:    2D array to be added to the output of HIST2D.
;
;         MAXn:    The maximum value to consider in the histogram of the Vn
;             array.  If this keyword is not specified, Vn is searched for
;             its largest value. (n = 1,2)
;
;         MINn:    The minimum value to consider in the histogram of the Vn
;             array.  If this keyword is not specified, and Vn is of type
;             byte, 0 is used. If this keyword is not specified and Vn is
;             not of byte type, Vn is searched for its smallest value. (n=1,2)
;
;     BINEDGEn:    This keyword specfies the location of the bin values returned
;             by OBINn. The values are:
;
;                  0 : Center of each bin, [DEFAULT].
;                 -1 : Left  or lower edge of each bin.
;                  1 : Right or upper edge of each bin.
;
; OUTPUTS:
;        The two dimensional weighted density function of the two variables.
;        If Weight is not specified, then the usual, unweighted 2D histogram
;        is returned.
;
; OUTPUT KEYWORD PARAMETERS:
;
;      DENSITY:    Density function of V1 and V2; i.e. the unweighted 2D histogram.
;
;        OBINn:    An array holding the bin values of the histogram of Vn. (n=1,2)
;
;        OMAXn:    A named variable that, upon exit, contains the maximum data
;             value used in constructing the histogram of Vn. (n=1,2)
;
;        OMINn:    A named variable that, upon exit, contains the minimum data
;             value used in constructing the histogram of Vn. (n=1,2)
;
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
;        None.
; RESTRICTIONS:
;        None.
;
; EXAMPLE:
;        Return the 2D histogram of two byte images:
;             R = HIST_2D(image1, image2)
;        Return the 2D histogram made from two floating point images
;        with range of -1 to +1, and with 100 bins:
;             R = HIST_2D(f1,f2)
;
; MODIFICATION HISTORY:
;        Written by:
;        DMS, Sept, 1992     Written, IDL
;        28-JUL-1994         H.C. Wen, Formerly, HIST_2D, Expanded input
;                            array types, added weight option and added
;                            HISTOGRAM keywords
;        28-FEB-1996         Added the BINEDGE1, BINEDGE2 keywords.
;-
function HIST2D, V1, V2, Weight, BINSIZE1=Binsize1, BINSIZE2=Binsize2, $
                 INPUT=Input, MAX1=Max1, MAX2=Max2, MIN1=Min1, MIN2=Min2,$
                 OMAX1=Omax1, OMAX2=Omax2, OMIN1=Omin1, OMIN2=Omin2, $
                 OBIN1=Obin1, OBIN2=Obin2, DENSITY=Density, $
                 BINEDGE1=Binedge1, BINEDGE2=Binedge2

         ON_ERROR, 2          ; on error, return control to caller

;   Check dimensions
         s1   = size(V1)
         s2   = size(V2)
         if (s1(1) ne s2(1)) then $
              message,'Array sizes of histogram variables incompatible.'

         wh   = N_ELEMENTS( Weight )   ;Check/initialize weighting option
         if wh gt 0 then begin
              sw   = size(weight)
              if (sw(1) ne s1(1)) then $
                   message,'Array size of weighted variables incompatible.'
              wgtc = weight
         endif else $
              wgtc = replicate( 1.,s1(1) )

         m1   = max(V1, min=mm1)
         m2   = max(V2, min=mm2)

;   Take care of INPUT KEYWORDS
         if not keyword_set( MAX1 ) then Max1 = m1
         if not keyword_set( MAX2 ) then Max2 = m2
         if not keyword_set( MIN1 ) then Min1 = mm1
         if not keyword_set( MIN2 ) then Min2 = mm2
         if not keyword_set( BINSIZE1 ) then Binsize1 = 1.0
         if not keyword_set( BINSIZE2 ) then Binsize2 = 1.0

;   Remove data points outside MAX/MIN range
         iout = WHERE( (V1 gt Max1) or (V1 lt Min1) or $
                       (V2 gt Max2) or (V2 lt Min2), nout )

         if nout gt 0 then begin
              V1c  = V1(iout)
              V2c  = V2(iout)
              Wgtc = Wgtc(iout)
         endif else begin
              V1c  = V1
              V2c  = V2
         endelse

;   Define histogram parameters
         d1   = double(Binsize1)
         d2   = double(Binsize2)
         w1   = double(Max1 - Min1)
         w2   = double(Max2 - Min2)
         I1m  = floor(w1/d1)
         I2m  = floor(w2/d2)
         n1   = I1m + 1L
         n2   = I2m + 1L

;   Take care of OUTPUT KEYWORDS
         Omax1 = Max1 & Omax2 = Max2
         Omin1 = Min1 & Omin2 = Min2

         if (N_ELEMENTS( Binedge1 ) eq 0) then Binedge1 = 0
         if (N_ELEMENTS( Binedge2 ) eq 0) then Binedge2 = 0
         offset1   = (Binedge1+1)*0.5
         offset2   = (Binedge2+1)*0.5
         Obin1     = Omin1 + (lindgen(n1)+offset1)*binsize1
         Obin2     = Omin2 + (lindgen(n2)+offset2)*binsize2

;   Scale V1c, V2c arrays into longword integer arrays
         I1   = floor( I1m*( V1c - Min1 )/w1 )
         I2   = floor( I2m*( V2c - Min2 )/w2 )

;   Fold into 1D histogram and unfold back into 2D histogram
         sum  = n1 * I2 + I1
         h  = HIST1D(sum, Wgtc, MIN=0, MAX= n1 * n2 -1, DENSITY=Density )
         h  = REFORM(h, n1, n2, /overwrite )
         Density = REFORM(Density, n1, n2, /overwrite )

         if keyword_set( INPUT ) then h = h + input
         return, h

end
