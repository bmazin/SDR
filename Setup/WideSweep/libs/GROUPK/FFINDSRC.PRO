;+
; NAME:
;        FFINDSRC
;
; PURPOSE:
;        Interactively finds all x-ray sources around a primary source
;        within the field of view of any HEAO A-1 scan in an IDL data
;        FILE. (FF abbreviation for FILE FIND)
;
; CATEGORY:
;        Database.
;
; CALLING SEQUENCE:
;
;        FFINDSRC [, Srclist]
;
; OUTPUTS:
;        This function first finds all the sources around a primary source
;        and within the field of view of any scan in the IDL data file
;        by searching the XXX database. Only those sources the USER interactively
;        specifies will be written out to a file containing information
;        about the Name, RA in DEGREES and DEC in DEGREES for each source
;        selected.
;
; OPTIONAL OUTPUT:
;
;        Srclist:  The same information written out to the file but
;                  packaged into an ARRAY of structures with tags
;                  defined as:
;
;                  Name:     The name of the source, string.
;                  RA:       The RA of the source in DEGREES.
;                  DEC:      The DEC of the source in DEGREES.
;
;                  If no sources are accepted by the USER then -1 is returned.
;
;
; PROCEDURE:
;        (See description in FINDSRC).
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November, 1994.
;        30-DEC-1994    Widgitized this routine, FFINDSRC -> FFINDSRC;
;                       also added the Additional Source(s) file output option
;                       used the XFIDUCIAL.
;        22-JAN-1995    Moved FFINDSRC->OBSOLETE directory. Renamed
;                       XFFINDSRC->FFINDSRC
;        06-AUG-1996    Check if !DATA_PATH system variable is defined.
;-

function FFINDSRC_INIT, DEGREES=Degrees, FLUX_CUTOFF=Flux_cutoff, $
                         OFILES=Ofiles

         common FIND_COM, othersrc, nother, file, search_ID
         common lc_colors, ncolors, linecolors, black, cyan, white

         nother    = 0
         othersrc  = 0
         search_ID = 0

         if n_elements( linecolors ) eq 0 then lcloadct

         dbopen,'xxx'

         return,1
end


function FFINDSRC_IO, Move, Pickmjf, DEGREES=Degrees, $
                        FLUX_CUTOFF=Flux_cutoff, OFILES=Ofiles

         common FIND_COM, othersrc, nother, file, search_ID

         Move = 1
         Pickmjf   = 0L
         buttons   = [ $
                        'Retrieve next scan', $
                        'Search for a particular scan',$
                        'Return to FFindsrc Main Menu' $
                     ]
         values    = [ 'N', 'S', 'Q' ]

QUERY:   rp = XBUTTON( buttons, values, /COLUMN, TITLE='FFindsrc Menu' )
         CASE rp OF
              'N'  : Pickmjf = 0L
              'S'  : begin
                        search_ID = 0
                        q         = 'Enter first major frame number of scan'
                        strmjf    = XQUERY( q, TITLE='Scan Search' )
                        Pickmjf   = long( strmjf(0) )
                        if Pickmjf eq 0 then Move = 0 $
                        else begin
                             xmsg,'Searching...   Please Wait...',$
                                  /NOBUTTON, MSG_ID=search_ID, $
                                  TITLE='FFindsrc Message'
                             WIDGET_CONTROL, /HOURGLASS
                        endelse
                     end
              'Q'  : return,0
         ENDCASE

         return,1
end

function FFINDSRC_DATA, Data, _EXTRA=Src_keywords, OFILES=Ofiles

         common FIND_COM, othersrc, nother, file, search_ID
         common lc_colors, ncolors, linecolors, black, cyan, white

         if search_ID ne 0 then begin
              WIDGET_CONTROL, search_ID, /DESTROY
              search_ID = 0
         endif

;   Extract relevant Data structures

         mode      = data(0).mode
         module    = data(0).module
         mjfs      = data.mjf
         nsrc      = data(0).nsrc
         nmjfs     = n_elements( data )
         nbin_mjf  = data(0).nbin
         nbin      = nmjfs*nbin_mjf
         cts       = reform( data.cts, nbin )
         trns      = reform( data.trns, nsrc, nbin )
         trn_src   = trns(0,*)
         srcRA     = data(0).srcRA(0)
         srcDEC    = data(0).srcDEC(0)

         if file.format eq 'ASPECTS' then begin
              RAY  = REFORM( data.sat.aspects.y(0,*), nbin )
              DEY  = REFORM( data.sat.aspects.y(1,*), nbin )
              RAZ  = REFORM( data.sat.aspects.z(0,*), nbin )
              DEZ  = REFORM( data.sat.aspects.z(1,*), nbin )

         endif else begin
              RAY  = data.RAY*!dtor
              DEY  = data.DEY*!dtor
              RAZ  = data.RAZ*!dtor
              DEZ  = data.DEZ*!dtor
         endelse

         src       = { $
                        trn: trn_src, $
                         RA: srcRA,   $
                        DEC: srcDEC   $
                     }
         sat       = { $
                        RAY: RAY, $
                        DEY: DEY, $
                        RAZ: RAZ, $
                        DEZ: DEZ  $
                     }

         othersrc  = FINDSRC( module, cts, src, sat, MJFS=Mjfs, $
                              USERSRC=othersrc, _EXTRA=Src_keywords )
         sother    = size( othersrc)
         nother    = N_ELEMENTS( othersrc)
         if (nother eq 1) and (sother(0) eq 0) then begin
              nother    = 0
              othersrc  = 0
         endif

         return, 1
end


function FFINDSRC_END, DEGREES=Degrees, FLUX_CUTOFF=Flux_cutoff, OFILES=Ofiles, $
                        OUTPUT=Output

         common FIND_COM, othersrc, nother, file, search_ID

         landscape,/close
         lcloadct,/unload

         dbclose,'xxx'
         xffmsg    = 'FFindsrc Message'

         if nother gt 0 then begin
              name = othersrc.name
              RA   = othersrc.RA
              DEC  = othersrc.DEC

              if N_ELEMENTS( FLUX_CUTOFF ) eq 0 then Flux_cutoff = 0
              output    = othersrc(0:nother-1)
              if keyword_set( OFILES.tmp ) then begin
                   qs        = 'Enter header information for the TMP file: '
                   header    = XQUERY( qs, XSIZE=30 )

                   tmpf = tmpfile( 'find', 'txt', 4 )
                   xmsg,'Writing sources to TMP file:'+tmpf, TITLE=xffmsg
                   openw, out, tmpf, /get_lun

                   nstr = arr2str( nother )
                   luns = [-1,out]
                   newline,luns,CHAR='-'
                   printfs,luns,'; ',strtrim(header,2)
                   printfs,luns,'; Flux cutoff:',arr2str(Flux_cutoff,5),$
                                ' microJy'
                   printfs,luns,'; File:',tmpf
                   printfs,luns,'; Created:',SYSTIME()
                   newline,luns
                   newline,luns,CHAR='-'
                   printfs,luns,'nsrc=',nstr
                   printfs,luns,'othersrc = { name:'''', RA:0.0, DEC:0.0 }'
                   printfs,luns,'othersrc = REPLICATE( othersrc,nsrc )'
                   for i=0,nother-1 do begin
                        istr = arr2str(i)
                        printfs,luns,'othersrc(',istr,').name = ''',$
                                  name(i),''''
                        printfs,luns,'othersrc(',istr,').RA   = ',$
                                  arr2str(RA(i))
                        printfs,luns,'othersrc(',istr,').DEC  = ',$
                                  arr2str(DEC(i))
                   endfor
                   newline,luns,CHAR='-'
                   for i=0,nother-1 do $
                        printf, out, format='(A15,2F15.7)', $
                                  name(i), RA(i), DEC(i)
                   close,out
                   free_lun,out
              endif

              srclist    = strarr( nother+1 )
              srclist(0) = string( 'Source name', 'RA', 'DEC', $
                                    format='(5X,3A15)' )
              for i=0,nother-1 do begin
                   srclist(i+1) = string( name(i), RA(i), DEC(i), $
                        format='(5X,3A15)')
              endfor

              if keyword_set( OFILES.add ) then begin
                   len     = strlen( file.name ) - 4
                   guess   = strmid( file.name, 0, len )+'.add'
                   addfile = PICKFILE( PATH=!DATA_PATH, $
                           FILE=!DATA_PATH+guess, $
                           FILTER='*.add', $
                           TITLE='Enter name of Additional Source(s) file')
                   if addfile ne '' then begin
                        openw, out, addfile, /get_lun
                        for i=0,nother-1 do begin
                             printf, out, format='(A15,2F15.7)', $
                                       name(i), RA(i), DEC(i)
                        endfor
                        close, out
                        free_lun, out

                   endif
              endif

              xmsg,srclist, /ALIGN, $
                   TITLE='Summary of Addtional Source(s) List'


         endif

         return, 1
end


pro FFINDSRC, Srclist

         common FIND_COM, othersrc, nother, file, search_ID

         On_error,2              ;Return to caller if an error occurs

         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         Infile = ''
         buttons= [ $
                   'Open IDL data file',$
                   'Options',$
                   'Begin finding sources...',$
                   'Quit' $
                  ]
         values = [ 'F', 'O', 'B', 'Q' ]

         items  = [ $
                   '    Flux cutoff for Additional Sources [microJy]: ', $
                   '    Enter RA/DEC of USER-defined sources in DEGREES: (y/n) ', $
                   '    Write out TMP file for Fiducial log file: (y/n) ', $
                   '    Write out Additional Source(s) file for Fiducial: (y/n) '$
                  ]
         cutoff = 0
         degstr = 'N'
         tmpstr = 'N'
         addstr = 'Y'
         repeat begin
              rp     = xbutton( buttons, values, /COLUMN, $
                                  TITLE='FFindsrc Main Menu')
              CASE rp OF
                   'F' : BEGIN
                      Infile = pickfile( PATH=!DATA_PATH, FILTER='*.idl', $
                                          TITLE='Select IDL data file')
                      pos    = strpos( Infile , !DATA_PATH )
                      len    = strlen( Infile  ) - strlen(!DATA_PATH) -pos
                      Infile1= strmid( Infile, pos+strlen(!DATA_PATH), len )
                      Fmt    = GET_FMT( Infile )
                      file   = { name : Infile1, $
                                 format : fmt }
                      END
                   'O' : BEGIN
                      default_ans = [strtrim(cutoff,2),degstr, tmpstr, addstr ]
                      xsize       = [20, 3, 3, 3]
                      settings    = XQUERY( items, DEFAULT=default_ans, $
                                       XSIZE=xsize, $
                                       TITLE='FFindsrc Options' )
                      cutoff      = float( settings(0) )
                      degstr      = strcompress(settings(1),/REMOVE_ALL)
                      degstr      = strupcase( strmid(degstr,0,1) )
                      tmpstr      = strcompress(settings(2),/REMOVE_ALL)
                      tmpstr      = strupcase( strmid(tmpstr,0,1) )
                      addstr      = strcompress(settings(3),/REMOVE_ALL)
                      addstr      = strupcase( strmid(addstr,0,1) )
                      END
                   'B' : BEGIN
                      if Infile ne '' then begin
                        if degstr eq 'Y' then degrees = 1
                        degrees   = (degstr eq 'Y' )
                        tmpfile   = (tmpstr eq 'Y' )
                        addfile   = (addstr eq 'Y' )
                        OFiles    = { tmp:tmpfile, add:addfile }
                        MAIN_SCAN, file.name, $
                                  USER_INIT='FFINDSRC_INIT',   $
                                  USER_IO  ='FFINDSRC_IO',     $
                                  USER_DATA='FFINDSRC_DATA',   $
                                  USER_END ='FFINDSRC_END',    $
                                  DEGREES  = degrees,           $
                                  FLUX_CUTOFF= cutoff,          $
                                  OFILES     = Ofiles,          $
                                  OUTPUT=Data

                        if N_ELEMENTS( Data ) gt 0 then begin
                             if N_ELEMENTS( Srclist ) gt 0 then $
                                  Srclist   = [Srclist, Data] $
                             else Srclist   = Data
                             Data      = 0
                        endif
                      endif else begin
                        xmsg,'No IDL data file opened.',$
                              TITLE='FFindsrc ERROR'
                      endelse
                      END
                   'Q'  :
              ENDCASE

         endrep until (rp eq 'Q')
end

