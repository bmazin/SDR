
pro printdev, Message, NODISPLAY=Nodisplay, LOG=Log, FLUSH=flush_file

         COMMON LOGCOM, LogUnit, LogFile

         if keyword_set( LOG ) then begin

              if N_ELEMENTS( LogUnit ) eq 0 then LogUnit   =  -2
              if N_ELEMENTS( LogFile ) eq 0 then LogFile   = '-1'

              io_stat = FSTAT( LogUnit )
              if (io_stat.OPEN eq 0) or $
                 (strupcase(io_stat.NAME) ne strupcase(LogFile)) then begin


                   time      = systime(0)
                   day       = strmid(time,0,3)
                   month     = strmid(time,4,3)
                   dayno     = strtrim(strmid(time,8,2),2)
                   filen     = day+month+dayno+'.log'

                   LogFile   = FILEPATH(filen, SUBDIRECTORY='log')
                   update    = findfile( LogFile, COUNT=nupdate )
                   if nupdate eq 1 then $
                        openu, LogUnit, LogFile, /GET_LUN, /APPEND $
                   else $
                        openw, LogUnit, LogFile, /GET_LUN


              endif

              printf, LogUnit, Message

              if keyword_set( flush_file ) then $
                   if io_stat.OPEN ne 0 then close, LogUnit

         endif

         if not keyword_set( NODISPLAY ) then print, Message


end


