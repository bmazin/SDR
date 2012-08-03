;-------------------------------------------------------------
;+
; NAME:
;       ELL_TRACK_REDUCE_POINTS
; PURPOSE:
;       Reduce the number of points along a track.
; CATEGORY:
; CALLING SEQUENCE:
;       lon1 = Longitude array of points along track (deg).  in
; INPUTS:
;       lat1 = Latitude array of points along track  (deg).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIST=dmx Max allowed distance off original track (m).
;           Default = 1 meter
;         INDEX=ind Return index array of input points used
;           in output array.
; OUTPUTS:
;       lon2 = Selected subset of Longitude array.           out
;       lat2 = Selected subset of Latitude array.            out
; COMMON BLOCKS:
; NOTES:
;       Notes: Not intended for tracks over large areas of the
;         globe.  Converts to Transverse Mercator coordinates
;         in meters and finds subset in that coordinate system.
;         So track is not very limited north-south.
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Aug 22
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_track_reduce_points, lon1, lat1, lon2, lat2, $
	  dist=dmx, index=in2, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Reduce the number of points along a track.'
	  print,'   lon1 = Longitude array of points along track (deg).  in'
	  print,'   lat1 = Latitude array of points along track  (deg).  in'
	  print,'   lon2 = Selected subset of Longitude array.           out'
	  print,'   lat2 = Selected subset of Latitude array.            out'
	  print,' Keywords:'
	  print,'   DIST=dmx Max allowed distance off original track (m).'
	  print,'     Default = 1 meter'
	  print,'   INDEX=ind Return index array of input points used'
	  print,'     in output array.'
	  print,' Notes: Not intended for tracks over large areas of the'
	  print,'   globe.  Converts to Transverse Mercator coordinates'
	  print,'   in meters and finds subset in that coordinate system.'
	  print,'   So track is not very limited north-south.'
	  return
	endif
 
	;---  Convert input to Transverse Mercator meters ---
	ell_ll2tm, lon1, lat1, x1, y1
 
	;---  Reduce number of path points  ---
	path_reduce_points, x1,y1, x2, y2, dist=dmx, index=in2
 
	;---  Really want lon, lat subsets  ---
	lon2 = lon1[in2]
	lat2 = lat1[in2]
 
	end
