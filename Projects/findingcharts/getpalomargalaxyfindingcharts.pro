PRO getPalomarGalaxyFindingCharts, inputfile, size=size, save=save, gstarmagrange=gstarmagrange, $
    namesonly=namesonly, nods9=nods9, separations=seps
  ;
  ;Reads in a comma-separated-value (.csv) target list and pulls up finding charts
  ;for all of them in DS9 using GETFINDINGCHART routine.
  ;
  ;INPUTS:
  ;   INPUTFILE - name of input .csv file
  ;   SIZE - size of field requested in arcmin, as per GETFINDINGCHART
  ;   /SAVE - Set to save each chart to a jpeg file, as per GETFINDINGCHART.
  ;         Except that doesn't work on my computer for unknown reasons....
  ;   GSTARMAGRANGE = [min,max] - override default guide star magnitude range (as per GETFINDINGCHART)
  ;   /NAMESONLY - If set, implies that the input file is a list of target names *only*, one per line (no columns for coordinates)
  ;   /NODS9 - optional to suppress ds9 output, as for procedure GETFINDINGCHART
  ;
  ;OUTPUTS:
  ;   A bunch of finding charts in ds9.
  ;   
  ;   Optional:
  ;   SEPARATIONS - if supplied, returns a list of separations between target and nearest guidestar (in arcsec)
  ;                 corresponding to each input target.
  ;
  ;Input file should be in format:
  ;
  ;Target name, HH:MM:SS, DD:MM:SS
  ;
  ;E.g.:
  ; OSA2008 NB570-W-55371,   02:16:40.680,    -05:01:29.53
  ; OSA2008 NB503-N-80475,   02:17:41.987,    -04:31:30.55
  ; OSA2008 NB503-N-42377,   02:17:42.495,    -04:41:08.65
  ; ... etc.
    
  ;(Or if /NAMESONLY is set, just a plain text list of target names, one per line,
  ;that will be looked up in the SIMBAD database.
    
  if keyword_set(namesonly) then begin
    readcol, inputfile, targetname, format='A', delimiter='¶'   ;Use a weird delimiter so that it just reads in the whole line (hopefully this delimiter shouldn't show up in a name!)
    target = targetname
  endif else begin
    readcol, inputfile, targetname, RA, dec, format='A,A,A', delimiter=','
    targetname=strtrim(targetname,2)
    RA=strtrim(RA,2)
    dec=strtrim(dec,2)
    target = [[RA,dec]]
  endelse
  
  
  seps = dblarr(n_elements(targetname))    ;To hold a list of separations between target and nearest guidestar (in arcsec)
  for i=0, n_elements(targetname)-1 do begin
    getfindingchart, target[i], targetname=targetname[i], size=size, save=save, $
      gstarmagrange=gstarmagrange, nods9=nods9, gstarseps=gstarseps
      seps[i] = gstarseps[0]
  endfor
  
  
  
END
