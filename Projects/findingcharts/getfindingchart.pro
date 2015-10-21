  ;GETFINDINGCHART
  ;
  ;Julian van Eyken, Dec 5 2012.
  ;
  ;Calling sequence:
  ;
  ; GETFINDINGCHART, target, targetname=targetname, size=size, gstarmagrange=gstarmagrange, $
  ;       currentframe=currentframe, savetojpeg=savetojpeg, verbose=verbose
  ;
  ;
  ;Creates a finding chart for any given target. Uses DS9 to produce the output, using the
  ;XPA communication system. Assumes DS9 and XPA are both already up and running. Note that
  ;error trapping is minimal at the moment, so non-standard inputs may give strange results.
  ;
  ;Also marks guidestars in the chosen magnitude range, and locates the nearest few
  ;and calculates a matrix of pointing offsets between them and the target (output to the
  ;IDL console).
  ;
  ;Guidestars are marked in green. Those included in the table are also marked with red circles,
  ;and labeled with their respective magnitudes.
  ;
  ;The panda at the target coordinates is 1arcmin in radius, for reference.
  ;
  ;Info about the single nearest guidestar (only) is listed on the plot itself.
  ;
  ;
  ;
  ;EXAMPLES:
  ;
  ;   getfindingchart, 'zCOSMOS 819124'
  ;   getfindingchart, 'zCOSMOS 819124', /currentframe, /verbose
  ;   getfindingchart, ['02:18:31.379','-04:43:54.77'], /currentframe, gstarmagrange=[0,20]
  ;   getfindingchart, ['02:18:31.379','-04:43:54.77'], targetname='Some Galaxy or Other'
  ;   getfindingchart, [34.630746D, -4.7318806]
  ;
  ;
  ;INPUTS:
  ;
  ;   TARGET - 1) A single string giving a target name that will be resolved by SIMBAD,
  ;            2) Two element string array giving coordinates in the format ['HH:MM:SS.SS','DD:MM:SS.SS'] or
  ;               something similar to that; OR:
  ;            3) Two element (pref. double precision) float array, [RA, dec], with RA and dec both in DEGREES.
  ;
  ;
  ;   Optional (sensible defaults are chosen for all these if not specified):
  ;
  ;   TARGETNAME = string:  if provided, this is used for the plot and table titles. Otherwise a default
  ;              is chosen using whatever is in 'TARGET'
  ;   NEARESTN : Calculate a matrix of offsets between targets and the nearest 'NEARESTN' guidestars (default 3).
  ;   SIZE = float:  size of field in arcminutes (length of one side of square field).
  ;   GSTARMAGRANGE = [min,max]  : Min and max magnitudes for the guidstars to be chosen for the output.
  ;   /CURRENTFRAME : Set this flag to cause ds9 to overwrite the current viewing frame;
  ;                   otherwise a new one is created.
  ;   /SAVETOJPEG : In an ideal world, does what it sounds like. But there seems to be a bug in ds9
  ;                 at the moment that stops this working....
  ;   /VERBOSE : Set to provide a little extra diagnostic output as the program churns through.
  ;   /NODS9   : Set to prevent from trying to output anything to ds9. In this case, only the console output
  ;              is performed.
  ;
  ;OUTPUTS:
  ;
  ;   If ds9 and xpa are up and running, should output a pretty image in ds9, and a table of
  ;   coordinates and offsets in the IDL console.
  ;
  ;   Optional:
  ;
  ;   NRSGSTRSEP = array of separations of the nearest n guidestars from the target (in arcseconds)
  ;
  ;DEPENDENCIES:
  ;
  ;  - SAO DS9 must be up and running (http://hea-www.harvard.edu/RD/ds9/site/Home.html)
  ;  - XPA must be installed and entered in the unix PATH. (http://hea-www.harvard.edu/saord/xpa/)
  ;  - IDL astronomy users library must be present and in the IDL path (http://idlastro.gsfc.nasa.gov/)
  ;
  ;NOTES:
  ;
  ;In principle, if XPA is in the path, then DS9 will start the 'xpans' server running automatically (this
  ;manages communication with DS9). If not, in DS9 try selecting File->XPA->Connect. If no luck, you can
  ;try starting the xpans server manually -- check that it's not already running using ps (or Activity Monitor
  ;on Mac), and assuming not, just type 'xpans &'. That should get it running in the background. You can
  ;also check to see if there is a connection by typing 'xpaget xpans'. If all is well and ds9 is connected
  ;to xpans, you should get a message something like:
  ;
  ;    DS9 ds9 gs 806f17df:60550 username
  ;
  ;
  ;
  ;HISTORY
  ;
  ;Dec 5 2012 - updated so that offsets are in terms of the actual RA/dec coordinate system
  ;             (albeit arcseconds on both axes, i.e., not seconds in RA). (Previously seconds
  ;             of arc on the sky were reported along orthogonal great circles aligned with North/South
  ;             and E/W at the point of interest. So you would get very different answers near the pole...
  ;             caveat emptor....)
  ;
  ;
  
  
  
  
  ;----------------------------------------------------------------------------------------------------
  ;SMALL HELPER FUNCTIONS/PROCS....
  ;----------------------------------------------------------------------------------------------------
  
  
  PRO xpasetds9, command
    ;Spawns a command to send XPA commands to an already-open ds9 session.
    ;
    ;INPUTS:
    ;     COMMAND - a string containing the command to be sent (see ds9 reference manual).
    ;               Only the ds9 command itself should be included here (i.e. "xpaset -p ds9 "
    ;               is all added by this routine).
    ;
    ;OUTPUTS:
    ;     None except for what ds9 does as a result.
    ;
    ;E.g.:
    ;     xpaset -p ds9 file new fits myfitsfile.fits
    ;
    ;     - should load image myfitsfile.fits into the currently open ds9 session.
    ;
    ;Note - assumes XPA commands are installed and in the UNIX path.
    ;Assumes ds9 and xpans are running, that ds9 is connected to XPA,
    ;and that commands xpaget and xpaset are available to the shell.
    ;
    ;To check, on the UNIX command line, you should be able to run:
    ;
    ;     xpaget xpans
    ;
    ;and get output that looks something like:
    ;
    ;     DS9 ds9 gs 806f17c8:33174 username
    ;
    ;or something similar....
    ;
  
    spawn, /noshell, strsplit(/extract, " xpaset -p ds9 "+command)
    
  END
  
  
  
  FUNCTION sixtyString, x, forcesign=forcesign
    ;Returns a formatted string along the lines of 'hh:mm:ss.ss' (or 'dd:mm:ss')
    ;for a decimal input number
    ;
    ;INPUTS:
    ;   X - a decimal number
    ;
    ;OPTIONAL INPUTS:
    ;   /FORCESIGN - set this to force a +/- sign to be included whether
    ;                X is negative or positive.
    ;OUTPUTS:
    ;   - A formatted string for X converted into sexagesimal notation.
    ;
    ;Dependencies: Calls IDL astro library routine SIXTY()
  
    a = sixty(x)
    if keyword_set(forcesign) then format = '(I+0,":",I2.2,":",F05.2)' $
    else format = '(I0,":",I2.2,":",F05.2)
    output = string(a[0],a[1],a[2], format=format)
    return, output
  END
  
  
  
  
  
  FUNCTION strreplace, substring, replacement, string, regexp=regexp
    ;Returns STRING with all instances of SUBSTRING replaced with REPLACEMENT
    ;Updated 16 Nov '09 to work if STRING is an array of strings (operates on all elements).
    ;5 Apr '10 - optimised speed a bit.
    ;13 Apr '10 - added /REGEXP keyword: set this so that 'substring' is taken to be a regular expression
    ;             instead of a regular string.
    ;           - USE /REGEXP CAREFULLY! It's possible to accidentally try and replace all the occurrences of the empty
    ;             string, which appears to hang things quite nicely.... (e.g. using '?')
    ;             ALSO - note, be careful using '.' - spaces are temporarily added internally at beginning and end of
    ;                     string, and these may be matched.... All needs a bit of work, but there's some basic functionality
    ;                     there for now.
  
    result = string
    ;hassubstring = where(strpos(string,substring) gt -1, count)
    if keyword_set(regexp) then substringrx=strjoin(strmid(substring, lindgen(strlen(substring)), 1)) $
    else substringrx = strjoin('\'+strmid(substring, lindgen(strlen(substring)), 1))
    hassubstring = where(stregex(string,substringrx,/boolean), count)
    for i=0L,count-1 do begin
      done = strjoin(strsplit(' '+string[hassubstring[i]]+' ',substringrx,/extract,/regex,/preserve_null), replacement)
      result[hassubstring[i]] = strmid(done,1,strlen(done)-2)
    endfor
    return, result
  END
  
  
  
  PRO ds9mark, fitsfilename, ra, dec, marksize=marksize, color=color, $
      noimageload=noimageload, imagecoords=imagecoords, zoom=zoom, apsize=apsize, $
      bold=bold, label=label
      
    ;Marks RA and dec positions on a fits file view in ds9.
    ;INPUTS:
    ;  RA, dec: RA and dec (in degrees) of point(s) to mark on the view.
    ;           May be scalars or vectors of multiple points.
    ;  MARKSIZE: optional, to set the radius of the circles used to mark
    ;           the supplied points (can be scalar or array -- if array, then must
    ;           contain one element for each coordinate pair, same size as RA and DEC).
    ;           (Note - never actually confirmed that this works okay with multiple different
    ;           radius values, but should in principle....). In degrees.
    ;  COLOR: String, one of: white, black, red, green, blue, cyan, magenta, yellow
    ;          (default is yellow).
    ;  /NOIMAGELOAD: To prevent from loading a new image before adding the marks.
    ;  /IMAGECOORDS: To plot in image coordinates (x,y) instead of J2000 RA and dec. (Also implies
    ;            MARKSIZE is in pixels instead of degrees.)
    ;  /ZOOM to zoom in on the first data point in the list provided.
    ;  /SHOWSKYANNULUS to the sky annulus according to the
    ;                photo.opt file in the current working directory.  ****REDUNDANT IN THIS APPLICATION***
    ;  /BOLD to make thicker marks on the image.
    ;  LABEL: set equal to a string to use this string to label the marked position.
      
    tempfilename = 'tempregions.reg'
    innerskyradname = 'IS'            ;(In photo.opt file, if needed)
    outerskyradname = 'OS'            ;(ditto)
    cd, current=cwd     ;Get current working directory
    
    
    if ~keyword_set(label) then label=replicate('',n_elements(ra))
    
    if n_elements(marksize) eq 0 then begin
      if keyword_set(imagecoords) then marksize = 6. $
      else marksize=6./60./60.  ;Size of marks (in deg!) to put on each source.
    endif
    
    if n_elements(marksize) eq 1 then marksizes = replicate(marksize,n_elements(ra)) $
    else marksizes=marksize
    
    ;if keyword_set(showskyannulus) then begin
    ;  if file_test((ptforiparams()).AP_OPT_FILE) then begin
    ;    readcol, (ptforiparams()).AP_OPT_FILE, apname, dummy, aprad, format='A,A,F'
    ;    innerskyrad = aprad(where(trim(apname) eq innerskyradname))
    ;   outerskyrad = aprad(where(trim(apname) eq outerskyradname))
    ;  endif else begin
    ;    print, 'Unable to find file '+(ptforiparams()).AP_OPT_FILE+' - not displaying sky annulus.'
    ;    showskyannulus=0
    ;  endelse
    ;endif
    
    if n_elements(color) eq 0 then color = 'yellow'
    color=strlowcase(color)
    if total(color eq ['white','black','red','green','blue','cyan','magenta','yellow']) eq 0 $
      then begin
      color='yellow'
      print, 'Warning: Unrecognised color requested. Using default.'
    endif
    
    if n_elements(ra) ne n_elements(dec) then $
      message, 'Sizes of RA and dec inputs do not match.'
      
    ;Load the image into ds9:
    if ~keyword_set(noimageload) then begin
      spawn, /noshell, strsplit(/extract,"xpaset -p ds9 cd "+cwd)
      spawn, /noshell, strsplit(/extract,"xpaset -p ds9 file new fits "+fitsfilename)
      spawn, /noshell, strsplit(/extract,"xpaset -p ds9 scale mode 99.5")
    endif
    
    ;Make temporary regions file:
    openw, unit, tempfilename, /get_lun
    if keyword_set(imagecoords) then printf, unit, 'image' $
    else printf, unit, 'j2000'
    for i=0L, n_elements(ra)-1 do begin
      if finite(ra[i]) and finite(dec[i]) then begin
        printf, unit, "circle " + strtrim(ra[i]+ (keyword_set(imagecoords)?1:0) ,2 )+" " $
          +strtrim(dec[i]+(keyword_set(imagecoords)?1:0),2)+" " $
          + strtrim(marksizes[i],2) $
          + " # color=" + color + (keyword_set(bold)?" width=2":"") $
          + (keyword_set(showskyannulus)?"":" text = {" + label[i] + "}")
        if keyword_set(showskyannulus) then begin
          printf, unit, "panda " + trim(ra[i]+ (keyword_set(imagecoords)?1:0) )+" " $
            +strtrim(dec[i]+(keyword_set(imagecoords)?1:0),2)+" 0 360 4 " $
            +strtrim(innerskyrad,2) + " " + strtrim(outerskyrad,2) + " 1 " $
            + " # color = " + color + (keyword_set(bold)?" width=2":"") $
            + " text = {" + label[i] + "}"
        endif
      endif
    endfor
    free_lun, unit
    
    ;Load the regions file into ds9:
    spawn, /noshell, strsplit(/extract,'xpaset -p ds9 regions load '+file_expand_path(tempfilename))
    ;file_delete, tempfilename
    
    ;Zoom to first coordinates if requested
    if keyword_set(zoom) then begin
      spawn, /noshell, strsplit(/extract,'xpaset -p ds9 zoom to 2')
      spawn, /noshell, strsplit(/extract, 'xpaset -p ds9 pan to '+trim(ra[0]+(keyword_set(imagecoords)?1:0)) + ' ' + $
        trim(dec[0]+(keyword_set(imagecoords)?1:0)) + ' ' + (keyword_set(imagecoords)?'physical':'j2000'))
    endif
    
  END
  
  
  
  
  ;----------------------------------------------------------------------------------------------------------------
  ;MAIN ROUTINE
  ;-----------------------------------------------------------------------------------------------------------------
  
  PRO getFindingChart, target, targetname=targetname, size=size, gstarmagrange=gstarmagrange, $
      currentframe=currentframe, savetojpeg=savetojpeg, verbose=verbose, $
      gstarseps=nrstgstrssep, nods9=nods9
      
    ;****DOCUMENTATION MOVED TO THE TOP OF THIS FILE -- SEE ABOVE!****
      
      
    if ~keyword_set(size) then size=6.0    ;Default size of field (one side of square) in arcmin
    if ~keyword_set(gstarmagrange) then gstarmagrange=[10.0,23.0] ;Default magnitude range for guide stars.12-18
    if ~keyword_set(nearestn) then   nearestn = 3 ;Calculate separations for nearest 'nearestn' guidestars
    
    
    catalog = 'USNO-B1'   ;Vizier code for the guide star catalogue to use
    vmagtag = 'R1mag'     ;Name of the field in the Vizier-returned structure which contains the magnitudes
    band = 'R'            ;Band of chosen magnitude (used in labelling the output chart).
    
    fieldsize=strtrim(size,2)+' '+strtrim(size,2)+' arcmin';  In format as per ds9 XPA protocol for dsssao: [<width> <height> degrees|arcmin|arcsec]
    ylegoffset=size/2./60.*0.7    ;Y coordinate offset from field center for legend (in degrees)
    linespacing=size/60.*0.02       ;legend line spacing.
    degformat = 'degrees'       ;For specifying coordinate format to pass to dsssao command in ds9/XPA.
    
    
    ;Interpret the input variables
    if size(target, /tname) eq 'STRING' && n_elements(target) eq 1 && n_elements(targetcoords) eq 0 then begin
      ;Assume 'target' must contain the target name. Find the target with SIMBAD/NED/Vizier - ra and dec are returned in degrees.
      QuerySimbad, target, targetra, targetdec, id, found=found, verbose=verbose
      ;if errmsg ne '' then begin
      ;  print, 'Simbad name look-up failed'
      ;  return
      ;endif
      if ~keyword_set(targetname) then targetname=target
    endif else if size(target, /tname) eq 'STRING' && n_elements(target) eq 2 then begin
      ;Assume that the input 'target' must be RA and dec, as strings, in format ['HH:MM:SS.SS', '(-)DD:MM:SS.SS]'] (or similar).
      GET_COORDS, coords, instring=target[0]+' '+target[1]
      targetra = coords[0]/24.D*360.D     ;Convert hours to degrees
      targetdec = coords[1]             ;Should already be in degrees
      if ~keyword_set(targetname) then targetname=strjoin(strtrim(target,2),', ')
    endif else if (size(target, /tname) eq 'FLOAT' || size(target,/tname) eq 'DOUBLE') $
      && n_elements(target) eq 2 then begin
      ;In this case assume input 'target' is a two element float (or double) vector, in degrees, [ra, dec]
      targetra = target[0]
      targetdec = target[1]
      if ~keyword_set(targetname) then targetname=strjoin(strtrim(target,2),', ')
    endif else begin
      print, 'Target input format not recognised...'
    endelse
    
    radecstring = strtrim(string(targetra),2)+' '+strtrim(string(targetdec),2)    ;String version of the coordinates in degrees, used later
    coordformat=degformat     ;Used later to tell ds9 we're talking in degrees
    
    
    
    ;Look up nearby guidstars
    if keyword_set(verbose) then print, 'Finding guidestars...'
    gstrs = QueryVizier(catalog, [targetra,targetdec], size/2.)
    vmagtag_ind = where(tag_names(gstrs) eq strupcase(vmagtag))
    vmags = gstrs[*].(vmagtag_ind)
    if keyword_set(verbose) then print, 'Done'
    
    ;Find which stars are of suitable magnitudes and chop out the rest.
    good = where(vmags lt gstarmagrange[1] and vmags gt gstarmagrange[0], goodcount)
    gstrs = gstrs[good]
    vmags = vmags[good]
    
    if goodcount lt nearestn then message, 'Only '+strtrim(goodcount,2)+' nearby guidestar(s) found...', /continue
    
    ;Calculate all the remaining stars' angular separations from the target
    ; - results go into vector array 'sep' (in arcseconds).
    gcirc, 2, targetra, targetdec, gstrs[*].raj2000, gstrs[*].dej2000, sep  ;Code '2' implies input in degrees, output in arcsec
    
    ;Get the indices of the nearest n guide stars
    minnind = (sort(sep))[0:nearestn-1]
    nrstgstrs = gstrs[minnind]
    nrstvmags = vmags[minnind]
    nrstgstrssep = sep[minnind]
    
    ;Calculate the matrix of offsets between the nearest n guidestars and the target itself, $
    ;  and the angular separations between each.
    minsepras   = dblarr(nearestn+1,nearestn+1) ;To take separations in RA
    minsepdecs  = dblarr(nearestn+1,nearestn+1) ;To take separations in dec
    minseps = dblarr(nearestn+1,nearestn+1)     ;To take angular distances.
    ras = [targetra, nrstgstrs[*].raj2000]
    decs = [targetdec, nrstgstrs[*].dej2000]
    nrstnnames = ['Target', 'Gd.star #'+strtrim(lindgen(nearestn)+1, 2)]   ;Vector of names for the output table
    nrstnmags = [!values.f_nan, nrstvmags]
    nrstnsep2target = [0.0, nrstgstrssep]     ;0.0 is separation from target to itself.
    for i=0L, n_elements(ras)-1 do begin
      minsepras[*,i] = ras-ras[i]
      minsepdecs[*,i] = decs-decs[i]
      gcirc, 2, ras, decs, ras[i], decs[i], x ;x is just a temp variable to load into minseps (next line)
      minseps[*,i] = x    ;Already in arcseconds
    endfor
    minsepras*=3600.D     ;Convert to arcsec (of DEGREES, not hours!)
    minsepdecs*=3600.D    ;Ditto.
    
    
    
    ;Get the smallest guidestar-target separation, and then the separation broken out into separation along RA
    ;and separation along dec (all in arcsec). (Kind of redundant given the matrix calculation above, but this
    ;is older and better tested code, so keep it for a cross comparison for now).
    minsep = min(sep, nearestindex, /nan)
    nearestgstr = gstrs[nearestindex]
    nrstgstrra = nearestgstr.raj2000
    nrstgstrdec = nearestgstr.dej2000
    minsepra = (targetra - nrstgstrra) * 3600.D    ;RA separation in seconds of DEGREES (along RA coordinate axis)
    minsepdec = (targetdec - nrstgstrdec) * 3600.D      ;Dec separation in seconds of degrees (along dec coordinate axis)
    
    
    ;------------------OLD CALCULATION OF SEPARATIONS, NOT QUITE WHAT WE WANT---------------------
    ;Calculate separation in RA and dec directions in units of TRUE seconds of arc on sky (ie along orthogonal great circles intersecting at the point of reference on the sky)
    ;gcirc, 2, targetra, targetdec, nearestgstr.raj2000, targetdec, minsepra
    ;gcirc, 2, targetra, targetdec, targetra, nearestgstr.dej2000, minsepdec
    ;Sort out sign for the 'true seconds of arc' definition of separation
    ;if targetra lt nearestgstr.raj2000 then rasign=-1 else rasign=+1
    ;if targetdec lt nearestgstr.dej2000 then decsign=-1 else decsign=+1
    ;minsepra*=rasign      ;gcirc always returns positive, so ensure that the signs make sense (offsets are *from* guide star *to* target)
    ;minsepdec*=decsign
    ;-----------------------------------------------------------------------------------------------
    
    
    ;Start telling ds9 what to do:
    
    if ~keyword_set(nods9) then begin
      ;Open a new ds9 frame unless explicitly asked not to.
      if ~keyword_set(currentframe) then begin
        xpasetds9, 'frame new'
      endif
      
      ;Prepare to get the DSS image from the STSCI image server
      xpasetds9, 'dssstsci size ' + fieldsize   ;Set field size
      xpasetds9, 'dssstsci frame current'     ;Open in the (now) current ds9 frame.
      xpasetds9, 'dssstsci survey all'
      ;Actually retrieve the image
      if keyword_set(verbose) then print, 'Getting image...'
      xpasetds9, 'dssstsci coord ' + radecstring + coordformat
      xpasetds9, 'dssstsci open'    ;Not entirely sure what this does, but doesn't seem like a bad idea....
      if keyword_set(verbose) then print, 'Done'
      
      
      ;Make a bit more presentable
      xpasetds9, 'single'   ;Set ds9 to single frame view mode.
      xpasetds9, 'cmap invert yes'    ;Invert black and white
      xpasetds9, 'zoom to fit'
      
      
      ;Mark the target location
      targetmarkcommand = 'regions command {panda ' $
        + strtrim(targetra,2)+'d '+strtrim(targetdec,2)+'d ' $
        + " 0 360 4 0 1' 2 # color=black}"    ;1' sets a 1arcmin radius.
      xpasetds9, targetmarkcommand
      
      
      ;Mark a compass
      xcompass = strtrim(targetra - fieldsize/60./2. * 0.7, 2)  ;**** Inc. dec. dependency.... yuck.
      ycompass = strtrim(targetdec + fieldsize/60./2. * 0.7, 2)
      compasslen = strtrim(0.01, 2)
      xpasetds9, 'regions command {compass '$
        + xcompass + 'd ' + ycompass + 'd ' + compasslen+'d # compass=fk5 "N" "E" 1 1 color=black width=2 font="helvetica 12 normal roman"}'
        
        
      ;Mark a coordinate grid
      xpasetds9, 'grid grid color cyan'
      xpasetds9, 'grid grid style 2'
      xpasetds9, 'grid axes color cyan'
      xpasetds9, 'grid axes width 3'
      xpasetds9, 'grid axes type exterior'
      xpasetds9, 'grid numerics type exterior'
      xpasetds9, 'grid numerics color blue'
      xpasetds9, 'grid numerics vertical no'
      xpasetds9, 'grid labels no'
      xpasetds9, 'grid type publication'
      xpasetds9, 'grid title text {'+targetname+'}'
      xpasetds9, 'grid title fontweight bold'
      xpasetds9, 'grid title def no'
      xpasetds9, 'grid title gap 0'
      xpasetds9, 'grid title yes'
      xpasetds9, 'grid axesorigin lll'
      xpasetds9, 'grid yes'
      
      
      
      ;Mark all the guidestars...
      ds9mark, 'dummy', gstrs.raj2000, gstrs.dej2000, /noimageload, color='green', marksize=3./60./60.
      ;And the nearest guidestar more distinctly
      
      ;Mark the nearest n guidestars...
      ds9mark, 'dummy', nrstgstrs.raj2000, nrstgstrs.dej2000, /noimageload, color='red', $
        /bold, label=string(indgen(nearestn)+1,format='(I0)') + ', '+band+'=' $
        +string(nrstgstrs.(vmagtag_ind), format='(F0.2)')   ;Labeled with index and magnitude
        
        
        
      ;Output the separations, as text on the plot
      yleg = targetdec - ylegoffset
      legendtext = ['TARGET COORDINATES: '+sixtystring(targetra/360.D*24.D)+',   '+sixtystring(targetdec)]   ;+strtrim(targetra)+'  '+strtrim(targetdec)]
      legendtext = [legendtext, 'GD.STAR #1 (NRST.) COORDS.: '+sixtystring(nrstgstrra/360.D*24.D)+',   '+sixtystring(nrstgstrdec)]  ; +sixtystring(nearestgstr.raj2000)+'  '+sixtystring(nearestgstr.dej2000)]
      legendtext = [legendtext, 'ANGULAR SEPARATION: '+string(minsep,format='(F0.2)')+' arcsec']
      legendtext = [legendtext, 'SEPARATION IN RA AND DEC (arcsec of deg): '+string(minsepra,minsepdec,format='(F0.2,",   ",F0.2)')]
      legendtext = [legendtext, 'Gd.star mag. range ('+strtrim(band,2)+'): '+string(gstarmagrange, '(F0.2," -- ",F0.2)')];+';  Nearest mag: '];+string(nearestgstr.(vmagtag_ind), format='(F0.2)')]
      xleg=targetra   ;X-position for legend.
      for i = 0, n_elements(legendtext)-1 do begin
        ;print, legendtext[i]
        xpasetds9, 'regions command {text '+strtrim(xleg,2) +'d '+strtrim(yleg-i*linespacing,2)+'d # text="' + legendtext[i] + '" color=black}'
      endfor
      
    endif     ;DS9 output block end.
    
    
    ;Print output to the console:
    ;
    ;First some info plus a list of coordinates of the target and nearest n guidestars
    print
    title='TARGET: '+strtrim(targetname,2) & print, title
    print, strjoin(replicate('-', strlen(title)))
    print
    print
    
    print, '', 'RA', 'Dec', band+' mag', 'Dist. to targ.', format='(A14,2A14,A8,A18)'
    print, '', '(J2000)', '(J2000)', '', '(arcsec)', format='(A14,2A14,A8,A18)'
    for i=0, nearestn do begin    ;Not nearestn-1 because we're including the target itself
      print, format='(A14,2A14,F8.2,F11.2)', nrstnnames[i], sixtystring(ras[i]/15.D), $
        sixtystring(decs[i]), nrstnmags[i], ([0.0,nrstgstrssep])[i]
    endfor
    
    cellwidth = '18'    ;Number of characters per cell for the matrix printout (must be a string)
    cellseparator = ' | '  ;E.g. can specify '|' to mark edges of each cell
    
    
    ;Now the offset matrix
    print
    print
    print, 'OFFSETS (Delta RA, Delta dec, in arcsec): '
    print
    print, strjoin(string(['', nrstnnames], format='(A'+cellwidth+')'), cellseparator)    ;Header line
    print, strjoin(string(replicate('--------------------------------',nearestn+2), format='(A'+cellwidth+')'),cellseparator)
    for i=0L, nearestn do begin
      entries = string(nrstnnames[i], format='(A'+cellwidth+')')
      ;for j=0L, nearestn do begin
      entries = [entries, string(minsepras[*,i],format='(F7.2)')+', '+string(minsepdecs[*,i],format='(F0.2)')]
      line = strjoin(string(entries, format='(A'+cellwidth+')'), cellseparator)
      ;line+=entry ;string(entry,format='(A15)') ;Make sure the entries fit in the allowed space
      ;endfor
      print, line
    endfor
    
    print
    print, 'Offsets are *from* row label *to* column label.'
    print, 'Note delta RA, delta dec are in seconds of *degrees* for both RA and dec, '
    print, 'but following the RA/dec coordinate system.'
    print
    print
    print
    
    ;Save if requested
    if keyword_set(savetojpeg) then begin
      outputfile = strreplace(' ', '-', strtrim(targetname,2)) +'.tif'
      print, 'Saving as: '+outputfile
      ;wait, 5.0
      xpasetds9, 'saveimage '+outputfile    ;90% jpeg quality
    endif
    
  END
  
  
  
  
  
  
