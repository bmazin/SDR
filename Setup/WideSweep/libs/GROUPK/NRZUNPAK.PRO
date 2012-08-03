;+
; NAME:
;        NRZUNPAK
;
; PURPOSE:
;        This function "unpacks" the raw 6.4 kbps NRZ data by extracting
;        its 2.1 kbps HEAO A-1 component and storing it into a structure
;        variable.
;
; CATEGORY:
;        HEAO.
;
; CALLING SEQUENCE:
;
;        Result = NRZUNPAK( NRZblock, Mode )
;
; INPUTS:
;        NRZblock: An array holding a block of NRZ data, intarr(128,nMNF).
;                  Each Minor Frame (MNF) of NRZ data contains 128 bytes.
;
;        Mode:     An integer describing the telemetry mode of the data in
;                  MILLISECONDS, (=5 or 320).
;
; OUTPUTS:
;        This function returns a structure containing the HEAO A-1 component
;        of the NRZ data.  Its tags depends on the Mode specified and are
;        defined as follows:
;
;        Mode = 320 ms
;
;             nMNFs     :    Number of Minor Frames
;             MNFs      :    Minor frame numbers, intarr(nMNFs)
;             TCnt1_6   :    Total counts for Modules 1-6, intarr(6,nMNFs)
;             TCnt7     :    Total counts for Module 7, intarr(nMNFs)
;             SChT      :    Counts in 16-Channels for Mods 1-4, intarr(16,nMNFs)
;             SCh5      :    Counts in 16-Channels for Mod 5, intarr(16,nMNFs)
;             SCh6      :    Counts in 16-Channels for Mod 6, intarr(16,nMNFs)
;             SCh7      :    Counts in 16-Channels for Mod 7, intarr(16,nMNFs/8)
;             FCh       :    Counts in 40-Channels, intarr(40,nMNFs/2)
;             Chmask    :    16-Channel MASKS, intarr(16,no. MNF #s = 119)
;             AGC       :    Auto Gain Control structure:
;                            HV   :    Monitor HV/Module, fltarr(7,nMJFs)
;                            Loop :    Loop setting/Module, fltarr(7,nMJFs)
;                            Gain :    Gain/Module, fltarr(7,nMJFs)
;             Data      :    HEAO A-1 2.1 kbps data, intarr(256,nMNFs)
;
;        Mode = 5 ms
;
;             nMNFs     :    Number of Minor Frames
;             MNFs      :    Minor frame numbers, intarr(nMNFs)
;             PtMd      :    Counts for Modules 1-4, intarr(64,nMNFs)
;             FCh       :    Counts in 40-Channels, intarr(40,nMNFs/2)
;             Data      :    HEAO A-1 2.1 kbps data, intarr(256,nMNFs)
;
; RESTRICTIONS:
;        This routines assumes that the block of NRZ data is contiguous in
;        time. Namely, there are no MISSING MNFs.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;        21-SEP-1995    Added comments; replaced POINT and SCAN keywords
;                       with Mode parameter.
;        22-SEP-1995    Changed Chmask tag to MskS and added Msk7 tag.
;-
function NRZUNPAK, NRZs1, Mode

         NP   = N_PARAMS()
         if (NP ne 2) then message,'Must be called with 2 parameters: '+$
                   'NRZblock, Mode'

         Scan_mode = 0
         Point_mode= 0
         case Mode of
              320  : Scan_mode = 1
                5  : Point_mode= 1
              else : message,'Invalid Telemetry Mode: '+strtrim(Mode,2)
         endcase

;    Define all BYTE offsets to all HEAO A-1 NRZ Data

         ;    Scan Mode Telemetry Format

         iSChT = 4*indgen(16)+7                                  ;16-Channels Mods 1-4
         iTCnt = [4*indgen(4) +71,159,227,251]                   ;Tot. Count Mods 1-7
         iFCh  = [  5, 21, 26, 37, 53, 69, 85, 90,101,117,$      ;40-Channels
                  133,149,154,165,181,197,213,218,229,245 ]
         iSCh5 = [4*indgen(10)+91,4*indgen(6)+135]               ;16-Channels Mod 5
         iSCh6 = [4*indgen(16)+163]                              ;16-Channels Mod 6
         iSCh7 = [231,247]                                       ;16-Channels Mod 7

         ;    Point Mode Telemetry Format

         iFCh  = [  5, 21, 26, 37, 53, 69, 85, 90,101,117,$      ;40-Channels
                  133,149,154,165,181,197,213,218,229,245 ]
         iPtMd = 4*indgen(64)+3                                  ;5ms MODs 1-4

         if keyword_set( Scan_mode ) then Sarr = [iSChT, iTCnt, iFCh, iSCh5, iSCh6, iSCh7 ]
         if keyword_set( Point_mode) then Sarr = [iFCh, iPtMd]
         Type      = strarr(256)
         Type(Sarr)= 'S'

;    Convert to byte array

         nMNFs     = n_elements(NRZs1)/128
         NRZs      = REFORM( NRZs1, nMNFs*128 )

         i         = 0
         j         = 2*indgen(128)
         k         = j+1
         NRZb      = bytarr(256,nMNFs)

         NRZb(j,*) = ISHFT(NRZs,-8)         ;Upper 8 bits fill the "first" bytes
         NRZb(k,*) = NRZs and '377'O        ;Lower 8 bits fill the "second" bytes

;   Convert quasi-logarithmic numbers for Science data

         Data      = fix(NRZb)
         here      = where(Type eq 'S')
         Data(here,*)= ACNVRT(Data(here,*))

;   Extract MNF numbers (Taken from HBRSYNC)

         AC1  = REFORM(NRZs1(65,*))                        ; CELLS  130 AND 131
         here = WHERE((AC1 and -32768) ne 0,nCARRY)        ; Shift bit 15 into the CARRY
         if (nCARRY gt 0) then AC1(here) = AC1(here) xor -32768
         AC1  = ISHFT(AC1,-8)                              ; Get rid of garbage CELL 131.
         MNFs = AC1
         h0   = WHERE(MNFs eq MNFs(0),nMJFs)

;   Extract NRZ depending on USER specified telemetry mode

         i0   = 0
         if (MNFs(0) and 1) eq 1 then i0=1     ;Odd MNF
         CASE 1 OF
              keyword_set(Scan_mode): BEGIN                     ; A-1 Scan Telemetry Mode

          ;    Extract the COUNTS

                   TCnt1_6   = Data(iTCnt(0:5),*)               ; Total Cts, Mods 1-6
                   SChT      = Data(iSChT,*)                    ; 16-Channels, Mods 1-4
                   SCh5      = Data(iSCh5,*)                    ; 16-Channels, Mod  5
                   SCh6      = Data(iSCh6,*)                    ; 16-Channels, Mod  6
                   Fch       = Data(iFch,*)                     ; 40-channel counts collected
                                                                ;    every 640 ms.
                   if (MNFs(0) and 1) eq 1 then begin           ; If first MNF is Odd then
                        Fch  = TRANSPOSE(Fch)                   ;    fill first 20 channels
                        Fch  = [intarr(1,20),Fch]               ;    with 0's
                        Fch  = TRANSPOSE(Fch)
                   endif
                   if (MNFs(nMNFs-1) and 1) eq 0 then begin     ; If last MNF is Even then
                        Fch  = TRANSPOSE(Fch)                   ;    fill last 20 channels
                        Fch  = [Fch,intarr(1,20)]               ;    with 0's
                        Fch  = TRANSPOSE(Fch)
                   endif
                   Fch       = REFORM( Fch, 40,n_elements(Fch)/40,/OVERWRITE)

                   j0   = MNFs(0)  MOD 8
                   j0   = (8 - j0) MOD 8

                   j1   = MNFs(nMNFs-1) MOD 8
                   if (j1 eq 7) then j1 = nMNFs-1 $
                   else              j1 = (nMNFs-1) - (j1+1)

                   nk        = (j1 - j0)/8 + 1
                   i         = j0 + 8*indgen(nk)
                   TCnt7     = Data(iTCnt(6),i+7)               ; Total Cts, Mod 7
                   TCnt7     = REFORM(TCnt7,/OVERWRITE)

                   SCh7      = intarr(16,nk)                    ; 16-Channels, Mod 7
                   for j=0,15 do begin                          ; Module 7 data collected
                        k    = (j gt 7)                         ;    every 2.56 ms
                        SCh7(j,*) = Data(iSCh7(k),i+j)
                   endfor


          ;   See which energy channels are masked off for Modules 1-4

                   imsk_MNF  = 119               ; MNF index
                   imsk_word = 255               ; NRZ word index

                   hmask     = where(MNFs eq imsk_MNF)
                   MSBs      = Data(imsk_word,hmask)
                   LSBs      = Data(imsk_word,hmask+1)
                   masks     = ISHFT(MSBs,8) + LSBs
                   MskS      = intarr(16,n_elements(hmask))
                   for i=0,15 do MskS(i,*) = (masks and 2^i)/2^i

          ;   See which energy channels are masked off for Module 7

                   imsk_MNF  = 117               ; MNF index
                   imsk_word = 255               ; NRZ word index

                   hmask     = where(MNFs eq imsk_MNF)
                   MSBs      = Data(imsk_word,hmask)
                   LSBs      = Data(imsk_word,hmask+1)
                   masks     = ISHFT(MSBs,8) + LSBs
                   Msk7      = intarr(16,n_elements(hmask))
                   for i=0,15 do Msk7(i,*) = (masks and 2^i)/2^i


          ;   See what the AGC MONITOR, LOOP and GAIN is for each module

                   iAGC_word = [87, 87, 87, 87,  255, 255, 255]      ; NRZ word index for
                                                                     ;    each module
                   iHV_MNF   = [16, 48, 80, 112,  16,  48,  80]      ; MNF index for
                   iAGC_MNF  = [27, 59, 91, 123,  27,  59,  91]      ;    each module
                   iAGC_Lbit = 1                                     ; LOOP Bit index of
                                                                     ;    the NRZ word
                   iAGC_Gbit  = 2                                    ; GAIN Bit index of
                                                                     ;    the NRZ word

                   AGC_Vmin  = -1.56                                 ; min. Voltage [V]
                   AGC_Vmax  = 1700.00                               ; max. Voltage [V]

                   HV   = fltarr(7,nMJFs)
                   Loop = fltarr(7,nMJFs)
                   Gain = fltarr(7,nMJFs)

                   for i=0,6 do begin
                        here = where(MNFs eq iHV_MNF(i),nh)
                        AGCwords  = REFORM( Data(iAGC_word(i),here))
                        AGCvolts  = (AGC_Vmax-AGC_Vmin)*(AGCwords/255.) + AGC_Vmin
                        HV(i,0:nh-1)   = AGCvolts

                        here = where(MNFs eq iAGC_MNF(i),nh)
                        AGCwords  = REFORM( Data(iAGC_word(i),here))
                        AGCbits   = (AGCwords and 2^iAGC_Lbit)/2^iAGC_Lbit
                        Loop(i,0:nh-1) = AGCbits

                        AGCbits   = (AGCwords and 2^iAGC_Gbit)/2^iAGC_Gbit
                        Gain(i,0:nh-1) = AGCbits
                   endfor

                   result={  nMNFs     :nMNFs,  $               ; Number of Minor Frames
                             MNFs      :MNFs,   $               ; Minor frame numbers
                             TCnt1_6   :TCnt1_6,$               ; Total Cts, Mods 1-6
                             TCnt7     :TCnt7,  $               ; Total Cts, Mod 7
                             SChT      :SChT,   $               ; 16-Channels, Mods 1-4
                             SCh5      :SCh5,   $               ; 16-Channels, Mod  5
                             SCh6      :SCh6,   $               ; 16-Channels, Mod  6
                             SCh7      :SCh7,   $               ; 16-Channels, Mod 7
                             FCh       :FCh,    $               ; 40-Channels
                             MskS      :MskS,   $               ; 16-Channel MASKS for Mods 1-4
                             Msk7      :Msk7,   $               ; 16-Channel MASKS for Mod 7
                             AGC       :{       $               ; Auto Gain Control parms:
                                       HV:HV,     $             ;    Monitor HV/Module
                                       Loop:loop, $             ;    Loop setting/Module
                                       Gain:Gain},$             ;    Gain/Module
                             Data      :Data    }
                   return, result
                   END
              keyword_set(Point_mode):BEGIN                     ; A-1 Point Telemetry Mode

                   Fch       = Data(iFch,*)                     ; 40-channel counts collected
                                                                ;    every 640 ms
                   if (MNFs(0) and 1) eq 1 then begin           ; If first MNF is Odd then
                        Fch  = TRANSPOSE(Fch)                   ;    fill first 20 channels
                        Fch  = [intarr(1,20),Fch]               ;    with 0's
                        Fch  = TRANSPOSE(Fch)
                   endif
                   if (MNFs(nMNFs-1) and 1) eq 0 then begin     ; If last MNF is Even then
                        Fch  = TRANSPOSE(Fch)                   ;    fill last 20 channels
                        Fch  = [Fch,intarr(1,20)]               ;    with 0's
                        Fch  = TRANSPOSE(Fch)
                   endif
                   Fch       = REFORM( Fch, 40,n_elements(Fch)/40,/OVERWRITE)

                   PtMd      = Data(iPtMd,*)                    ; 5ms, Mods 1-4

                   result= { nMNFs     :nMNFs,  $               ; Number of Minor Frames
                             MNFs      :MNFs,   $               ; Minor frame numbers
                             PtMd      :PtMd,   $               ; 5ms, Mods 1-4
                             FCh       :FCh,    $               ; 40-Channels
                             Data      :Data    }
                   return, result
                   END
              ELSE:     message,/INF,'No Telemetry Mode specified.'
         ENDCASE

end
