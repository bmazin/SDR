;-------------------------------------------------------------
;+
; NAME:
;       MAP_EMBEDDED_INFO
; PURPOSE:
;       List or modify embedded map info from map_set2.
; CATEGORY:
; CALLING SEQUENCE:
;       map_embedded_info, t
; INPUTS:
;       t = Packed byte array with map info.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=mag Mag factor to resize map (def=none).
;           Will modify scale embedded in t.
;         /EMBED Embed map info in current window.
;           Will embed array t in channel 3 (blue).
;           If mag is given it is applied before embedding.
;         /QUIET do not list embedded info.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful when maps with embedded scaling info
;         (from map_set2) are resized, can use to update
;         embedded info.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Oct 04
;       R. Sterner, 2006 Oct 09 --- Forced modified scale to float.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_embedded_info, t, quiet=quiet, mag=mag, embed=embed, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' List or modify embedded map info from map_set2.'
	  print,' map_embedded_info, t'
	  print,'   t = Packed byte array with map info.   in'
	  print,' Keywords:'
	  print,'   MAG=mag Mag factor to resize map (def=none).'
	  print,'     Will modify scale embedded in t.'
	  print,'   /EMBED Embed map info in current window.'
	  print,'     Will embed array t in channel 3 (blue).'
	  print,'     If mag is given it is applied before embedding.'
	  print,'   /QUIET do not list embedded info.'
	  print,' Notes: Useful when maps with embedded scaling info'
	  print,'   (from map_set2) are resized, can use to update'
	  print,'   embedded info.'
	  return
	endif
 
	;----------------------------------------------------------------
	;  Key to contents of t (embedded info array):
	;----------------------------------------------------------------
;                                         #items lo   hi #bytes typ
;        t = byte(m)                       ; 1    0    9   10   chr
;        t = [t,byte([lat,lng,ang],0,12)]  ; 3   10   21   12   flt
;        t = [t,flag_noborder]             ; 1   22   22    1   byt
;        t = [t,flag_iso]                  ; 1   23   23    1   byt
;        t = [t,flag_col]                  ; 1   24   24    1   byt
;        t = [t,byte(val_col,0,4)]         ; 1   25   28    4   lon
;        t = [t,flag_scale]                ; 1   29   29    1   byt
;        t = [t,byte(val_scale,0,4)]       ; 1   30   33    4   flt
;        t = [t,flag_azi]                  ; 1   34   34    1   byt
;        t = [t,byte(val_azi,0,4)]         ; 1   35   38    4   flt
;        t = [t,flag_lim]                  ; 1   39   39    1   byt
;        t = [t,byte(nlim,0,4)]            ; 1   40   43    4   lon
;        t = [t,byte(val_lim,0,32)]        ; 8   44   75   32   flt
;        t = [t,flag_par]                  ; 1   76   76    1   byt
;        t = [t,byte(val_par,0,8)]         ; 2   77   84    8   flt
;        t = [t,flag_sat]                  ; 1   85   85    1   byt
;        t = [t,byte(val_sat,0,12)]        ; 3   86   97   12   flt
;        t = [t,flag_ell]                  ; 1   98   98    1   byt
;        t = [t,byte(val_ell,0,12)]        ; 3   99  110   12   flt
;        t = [t,byte(pos,0,16)]            ; 4  111  126   16   flt
;        t = [t,byte(proj,0,4)]            ; 1  127  130    4   lon
;        t = [t,flag_clip]                 ; 1  131  131    1   byt
;        t = [t,byte(pxcm,0,8)]            ; 2  132  139    8   flt
;        t = [t,bytarr(20)]                ; Pad a bit extra for 160 bytes.
 
 
	;----------------------------------------------------------------
	;  Pick out info from pack
	;----------------------------------------------------------------
	m = string(t(0:9))                      ; Data available flag.
        if m ne '1234567891' then begin         ; No map scaling info in image.
	  print,' Error in map_embedded_info: Given info array does not'
	  print,'   contain valid embedded map info from map_set2.'
	  return
	endif
 
	;---  Use nlim as an endian indicator  ---
        nlim = long(t,40)       ; This value is always 4 or rarely 8.
        if nlim gt 8 then swap_flag=1 else swap_flag=0  ; Detect endian.
        if swap_flag then nlim=swap_endian(nlim)	; Swap nlim.
 
	;---  lat, lon, ang  ---
        tmp = float(t,10,3) & if swap_flag then tmp=swap_endian(tmp)
        lat=tmp(0) & lon=tmp(1) & ang=tmp(2)
 
	;--- flag_noborder  ---
        flag_noborder = t(22)
 
	;---  flag_iso  ---
        flag_iso = t(23)
 
	;---  flag_col  ---
        flag_col = t(24)
 
	;---  val_col  ---
        if flag_col then begin
          clr = long(t,25) & if swap_flag then clr=swap_endian(clr)
        endif else clr=!p.color
 
	;---  flag_scale  ---
        flag_scale = t(29)
 
	;---  val_scale  ---
        scale = float(t,30) & if swap_flag then scale=swap_endian(scale)
 
	;---  flag_azi  ---
        flag_azi = t(34)
 
	;---  val_azi  ---
        azi = float(t,35) & if swap_flag then azi=swap_endian(azi)
 
	;---  flag_lim  ---
        flag_lim = t(39)
 
	;---  val_lim  ---
        lim = float(t,44,8) & if swap_flag then lim=swap_endian(lim)
        lim = lim(0:nlim-1)
 
	;---  flag_par  ---
        flag_par = t(76)
 
	;---  val_par  ---
        std_par=float(t,77,2) & if swap_flag then std_par=swap_endian(std_par)
 
	;---  flag_sat  ---
        flag_sat = t(85)
 
	;---  val_sat  ---
        sat_p = float(t,86,3) & if swap_flag then sat_p=swap_endian(sat_p)
 
	;---  flag_ell  ---
        flag_ell = t(98)
 
	;---  val_ell  ---
        ellip = float(t,99,3) & if swap_flag then ellip=swap_endian(ellip)
 
	;---  pos  ---
        pos = float(t,111,4) & if swap_flag then pos=swap_endian(pos)
 
	;---  proj  ---
        proj = long(t,127) & if swap_flag then proj=swap_endian(proj)
 
	;---  flag_clip  ---
        flag_clip = t(131)
 
	;---  pxcm  ---
        pxcm=float(t,132,2) & if swap_flag then pxcm=swap_endian(pxcm)
        if pxcm(0) eq 0. then pxcm=[40.,40.]
 
	;----------------------------------------------------------------
	;  Deal with mag factor
	;----------------------------------------------------------------
	if n_elements(mag) ne 0 then begin
	  scale = float(scale/mag)	; Adjust scale value.
	  t(30) = byte(scale,0,4)	; Insert new scale in embedded info.
	endif
 
	;----------------------------------------------------------------
	;  Embed scaling in current image window
	;----------------------------------------------------------------
	if keyword_set(embed) then begin
	  tv,t,0,0,chan=3
	  if not keyword_set(quiet) then $
	    print,' Scaling info embedded in current window.'
	endif
 
	;----------------------------------------------------------------
	;  List
	;----------------------------------------------------------------
	if not keyword_set(quiet) then begin
	  print,' '
	  print,' Embedded info values.  Swap_flag: ',swap_flag
	  print,' '
	  print,' Magic number: ',m
	  print,' lat, lon, ang: ',lat,lon,ang
	  print,' flag_noborder: ',flag_noborder
	  print,' flag_iso: ',flag_iso
	  print,' flag_col: ',flag_col
	  print,' val_col: ',clr
	  print,' flag_scale: ',flag_scale
	  print,' val_scale: ',scale
	  print,' flag_azi: ',flag_azi
	  print,' val_azi: ',azi
	  print,' flag_lim: ',flag_lim
	  print,' nlim: ',nlim
	  print,' val_lim: ',lim
	  print,' flag_par: ',flag_par
	  print,' val_par: ',std_par
	  print,' flag_sat: ',flag_sat
	  print,' val_sat: ',sat_p
	  print,' flag_ell: ',flag_ell
	  print,' val_ell: ',ellip
	  print,' pos: ',pos
	  print,' proj: ',proj
	  print,' flag_clip: ',flag_clip
	  print,' pxcm: ',pxcm
	endif
 
	end
