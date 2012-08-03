;+
; NAME:
;        GET_ASPECTS
;
; PURPOSE:
;        Subroutine interpolates, or extrapolates, the aspect angles, right
;        ascension and declination (alpha, delta), for the Y- and Z-axes
;        given the initial and final value for these angles.  The Z-axis is
;        assumed to be the spin axis.
;
;        The interpolation (or extrapolation) is done by first converting
;        alpha,delta to celestial cartesian coordinates, then cartesian
;        coordinates to Euler angles.  The Euler angles are interpolated to
;        the desired number of intermediate points, then converted back to
;        cartesian coordinates, and finally to alphas and deltas.
;
;        Note that the aspects are interpolated, or extrapolated, to the
;        middle of each bin, and that the initial and final aspects
;        supplied in the input arguments bound the beginning of the first
;        bin and the end of the last bin, respectively.
;
;
; CATEGORY:
;        Interpolation
;
; CALLING SEQUENCE:
;
;        GET_ASPECTS, Mode, Bins, Ry,Dy, Rz,Dz, Y_asp, Z_asp
;
; INPUTS:
;         Mode:    The interpolation "mode", [integer].
;             If MODE=0, aspects are INTERPOLATED for values between
;             the initial and final aspects.
;             If MODE=1, aspects are EXTRAPOLATED beyond the final
;             aspects given.
;
;         Bins:    The number of intermediate or extrapolated bins
;             between the initial and final aspects, [integer].
;
;           Ry:    The initial and final values of the Y-axis
;             right ascension, [float(2)].
;
;           Dy:    The initial and final values of the Y-axis
;             declination, [float(2)].
;
;           Rz:    The initial and final values of the Z-axis
;             right ascension, [float(2)].
;
;           Dz:    The initial and final values of the Z-axis
;             declination, [float(2)].
;
; OPTIONAL INPUT KEYWORDS:
;       OFFSET:    The number of bins from the bin edge where the aspects
;             are calculated.  The default is 0.5 bin, namely, the center
;             of each bin, [float].
;
; OUTPUTS:
;        Y_asp:    The interpolated (or extrapolated) Y-axis right
;             ascension and declination for each of BINS points, [float(2,Bins)].
;
;        Z_asp:    The interpolated (or extrapolated) Z-axis right
;             ascension and declination for each of BINS points, [float(2,Bins)].
;
; MODIFICATION HISTORY:
;        Written by:    K.H. Fairfield,  02-DEC-1992.
;        09-FEB-93:     Changed the meaning of the BINS input argument to be
;                  the actual number of bins between the bounding aspects,
;                  rather than the number of intermediate points, so as to
;                  calculate the returned aspects at the center of each bin
;                  rather than the bin edge.
;
;                  N.B. Because of these changes, calling programs must be
;                       modified accordingly.
;        06-JUN-1994:   Adapted routine into an IDL procedure, H.C. Wen.
;        22-JUN-1994:   Vectorized routine to eliminate for loops.
;                       Added the OFFSET keyword.
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
pro GET_ASPECTS, Mode, Bins, Ry,Dy, Rz,Dz, Y_asp, Z_asp, OFFSET=Offset

         Y_asp = fltarr(2,Bins)
         Z_asp = fltarr(2,Bins)

;
;  Get the X-, Y- and Z-axis unit vectors for the initial aspect.
;
         slaCS2C, Ry(0),Dy(0), Yvec
         slaCS2C, Rz(0),Dz(0), Zvec
         slaVXV,  Yvec, Zvec, Xvec

;
;  Form the rotation matrix from the X-, Y-, and Z-axis direction cosines.
;
         rotmat = fltarr(3,3)
         rotmat(0,*) = xvec
         rotmat(1,*) = yvec
         rotmat(2,*) = zvec
;
;  Calculate the Euler angles for this rotation matrix.
;
         MTOEA, rotmat, theta_0, phi_0, psi_0

;
;  Get the X-, Y- and Z-axis unit vectors for the final aspect.
;
         slaCS2C, Ry(1),Dy(1), Yvec
         slaCS2C, Rz(1),Dz(1), Zvec
         slaVXV,  Yvec, Zvec, Xvec

;
;  Form the rotation matrix from the X-, Y-, and Z-axis direction cosines.
;
         rotmat(0,*) = xvec
         rotmat(1,*) = yvec
         rotmat(2,*) = zvec
;
;  Calculate the Euler angles for this rotation matrix.
;
         MTOEA, rotmat, theta_1, phi_1, psi_1
         IF (psi_1 LT 0.0) AND (psi_0 GT 0.0) then $
          psi_1 = psi_1 + 2.*!dpi

;
;  Calculate the delta-Euler angles.
;
         dth = (theta_1 - theta_0) / bins
         dph = (phi_1 - phi_0  ) / bins
         dps = (psi_1 - psi_0  ) / bins

;
;  Loop over then number of bins, interpolating/extroplating to the
;  "next" set of Euler angles, and for each set, convert back to rotation
;  matrix, then to aspect angles.  Initial theta, phi and psi are adjusted
;  to the middle of the preceding bin.
;
         if not keyword_set( OFFSET ) then Offset = 0.5
         IF (Mode EQ 0) then begin
           th1 = theta_0 - (Offset * dth)
           ph1 = phi_0   - (Offset * dph)
           ps1 = psi_0   - (Offset * dps)
         endif else begin
           th1 = theta_1 - (Offset * dth)
           ph1 = phi_1   - (Offset * dph)
           ps1 = psi_1   - (Offset * dps)
         endelse

         range = findgen(Bins)+1.0
         EATOM, th1+range*dth, ph1+range*dph, ps1+range*dps, rotmat

         yvec = REFORM( rotmat(1,*,*) )
         zvec = REFORM( rotmat(2,*,*) )
         slaCC2S, yvec, y_asp_RA, y_asp_DEC
         slaCC2S, zvec, z_asp_RA, z_asp_DEC

         Y_asp(0,*) = y_asp_RA
         Y_asp(1,*) = y_asp_DEC

         Z_asp(0,*) = z_asp_RA
         Z_asp(1,*) = z_asp_DEC

end
