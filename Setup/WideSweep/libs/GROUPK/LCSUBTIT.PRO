;
; NAME:
;        LCSUBTITLE
;
; PURPOSE:
;        Returns the Standard Light Curve subtitle.
;
; CATEGORY:
;        String manipulation.
;
; CALLING SEQUENCE:
;
;        Result = LCSUBTITLE( Srcname, Bin_pk, Trn_pk, Cts_pk, Bkd_pk )
;
; INPUTS:
;       Srcname:   The name of the source, [string].
;
;        Bin_pk:   The bin where the transmission is a max. for this source, [integer].
;
;        Trn_pk:   The transmission max. for this source, [float].
;
;        Cts_pk:   The counts in bin, Bin_pk, [float].
;
;        Bkd_pk:   The fitted background value at bin, Bin_pk, [float].
;
; OUTPUTS:
;        A subtitle string summarizing the characteristics of a source.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May, 1994.
;        19-MAY-1994:   Change source#1 info summary to fit summary
;
function LCSUBTITLE, Chisq, Chisq_pk, Chisq_bk

         chi2_str  = ' Tot:'+ string( format='(F5.2)',Chisq )
         chi2pk_str= ' Pks:'+ string( format='(F5.2)',Chisq_pk)
         chi2bk_str= ' Bkd:'+ string( format='(F5.2)',Chisq_bk)
         subtitle  = 'Reduced Chi-Squared,'+chi2_str+chi2pk_str+chi2bk_str

;function LCSUBTITLE, Srcname, Bin_pk, Trn_pk, Cts_pk, Bkd_pk
;
;        ct_str    = ' Cts:'+string( format='(F5.1)',Cts_pk )
;        tr_str    = ' Trn:'+string( format='(F4.2)',Trn_pk )
;        bk_str    = ' Bkd:'+string( format='(F5.1)',Bkd_pk )
;        bin_str   = ' at Bin:'+string( format='(I4)',Bin_pk )
;        subtitle  = 'Peak of '+Srcname+bin_str+tr_str+ct_str+bk_str

         return, subtitle
end
