;-------------------------------------------------------------
;+
; NAME:
;       WAV_PLAY
; PURPOSE:
;       Play a wave file.
; CATEGORY:
; CALLING SEQUENCE:
;       wav_play, file
; INPUTS:
;       file = Name of wave file to play.  in
;         May be an array of wave files.
; KEYWORD PARAMETERS:
;       Keywords:
;         PAUSE=sec Seconds to pause bewteen files (def=0).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 26
;       R. Sterner, 2006 May 03 --- Allowed arrays, fixed wait.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
        pro wav_play, file, pause=psec, help=hlp
 
        if (n_params(0) lt 1) or keyword_set(hlp) then begin
          print,' Play a wave file.'
          print,' wav_play, file'
          print,'   file = Name of wave file to play.  in'
	  print,'     May be an array of wave files.'
	  print,' Keywords:'
	  print,'   PAUSE=sec Seconds to pause bewteen files (def=0).'
          return
        endif
 
	n = n_elements(file)
	if n_elements(psec) eq 0 then psec=0.
 
	for i=0, n-1 do begin
          a = read_wav(file(i), rate)
          sec = dimsz(a,dimsz(a,0))/float(rate)
          pre = ''
          if !version.os_family eq 'unix' then pre='play '
          spawn, pre + file(i)
          if !version.os_family ne 'unix' then wait, sec + psec
	endfor
 
        end
