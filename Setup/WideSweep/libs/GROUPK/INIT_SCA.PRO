;+
; NAME:
;        GET_SCAN
;
; PURPOSE:
;
;        This function reads in major frame(s) of the HEAO A-1 data from a
;        data file into buffers.  Each buffer contains a set of sequential
;        major frames and may be referred to as a "scan".  The number of
;        sequential major frames may vary according to the number of
;        sequential major frames found in the data file.
;
; CATEGORY:
;       I/O
;
; CALLING SEQUENCE:
;
;    Result = GET_SCAN( Move [, PICKMJF=Pickmjf, DATA=Data, NOWARN=Nowarn, LOG=Log] )
;
; INPUTS:
;         Move:    Buffer command to tell which buffer to retreive:
;                        1   ->   Get the next buffer.
;                        0   ->   Get the current buffer.
;                       -1   ->   Get the previous buffer.
;             If the buffer pointer is at the top of the buffer stack and
;             Move = 1, then the next major frame buffer is read from the data file.
;
; INPUT KEYWORD PARAMETERS:
;
;      PICKMJF:    Get the major frame buffer with the major frame number
;             specified by PICKMJF by searching forward.  NOTE: Move must
;             be set to 1 if the PICKMJF keyword is set, [long].
;
;       NOWARN:    Suppress printing of warning messages to screen.
;
;          LOG:    Output warning messages to log file.
;
; OUTPUTS:
;       This function serves to both read major frames from file into buffers
;       and return buffer elements to the USER through output keywords.  When
;       BOTH the end of file has been reached and the buffer for that file
;       is empty, then this function returns 1, otherwise it returns 0.
;       In other words, it returns the EOFB (end of file and buffer) status.
;
; OUTPUT KEYWORD PARAMETERS:
;
;         DATA:    Array of MJF data structures with dimension equal to the
;             number of sequential major frames in the scan.  (See DEF_MJF
;             for the definition of the MJF data structure.)
;
; RESTRICTIONS:
;       Data file must be in the proper IDL format as defined by the
;       FMT_SRCDATA program.
;
; EXAMPLE:
;       Assume we have a data file named crab.idl:
;
;       unit = INIT_SCAN( 'crab.idl' )
;
;       eofb = GET_SCAN( 1, DATA=Data )
;
;       nmjf = n_elements( data )
;       nbin = nmjf*data.nbin(0)
;       cts  = reform( data.cts, nbin )
;       trns = reform( data.trns, data.nsrc(0), nbin )
;
;       for i=0,nbin-1 do $
;          print, cts(i), trns(*,i)
;
; MODIFICATION HISTORY:
;        Written by:  H.C. Wen, May, 1994.
;        15-MAY-1994  Added an end-of-file flag for each file buffer, eofb.
;                     Changed logical unit to file pointer.
;                     Properly empty the contents of the buffers to the
;                     USER after the end of file has been reached.
;        18-MAY-1994  Before, data in buffers were physically moved using
;                     SHIFT, (e.g. buf.mjf  = SHIFT( buf.mjf,1  ) ), extremely
;                     inefficient! Now, only the POINTERS to the buffer elements
;                     get shifted, buf.ptr = SHIFT( buf.ptr,1 ).
;        09-JUN-1994  Added the NOWARN and LOG keywords.
;        26-JUN-1994  Formerly, READ_BUF; changed the variable keywords
;                     to structure keywords and the multiple commons with
;                     variables to one common with one structure variable.
;                     Eliminated multiple file option change file pointer
;                     back to logical unit.
;        01-AUG-1994  Formerly called GET_BUF; moved the specific definition
;                     of data structure to DEF_MJF. Had to add another element
;                     to SCAN_COM, bufdata, because IDL doesn't allow structures
;                     to have anonymous structure members.
;        09-AUG-1994  Bugfixes: set pickmjf_=0 after 1st time call to READ_MJF.
;                     Check if PICKMJF buffer is already in look ahead buffer.
;-
function GET_SCAN, Move, PICKMJF=Pickmjf, DATA=Data, NOWARN=Nowarn, LOG=Log


         common SCAN_COM, buf, bufdata

         ON_ERROR,2              ; Return to caller if an error occurs

         NP = N_PARAMS()
         if NP ne 1 then $
              message,'Must be called with 1 parameter, Move.'

         if N_ELEMENTS( buf ) eq 0 then $
              message,'Buffer not initialized. Call INIT_SCAN first.'

         in = buf.lunit
         Pickmjf_ = 0
         if keyword_set( PICKMJF ) then Pickmjf_ = pickmjf

;___________________________________________________________________________________
;
;
;  This will be our definitions for our pointers:
;
;   bufdata                 :Buffer array of structures which hold the data.
;   ptr                     :Array of pointers whose elements point to array buffer
;                            elements.
;   seq_ptr                 :Array of pointers whose elements point to the beginning
;                            of sequential ptr elements.
;   ptr_ptr                 :A pointer to a seq_ptr element. (pointer to a pointer)
;
;-----------------------------------------------------------------------------------
;
;  And this will be our conventions how data is held in these buffers:
;
;   Each element of seq_ptr points to the beginning of a group of sequential
;   major frames, where the number of major frames in a group can range from
;   1 to the maximum number of buffers, nbuffers.  As for the buffers, the
;   first buf.ptr element, (e.g. buf.mjf(buf.ptr(0))) is always reserved as
;   a look ahead buffer to check for sequential major frames.   Namely, only
;   buf.ptr elements (1) - (nbuffers-1) may be returned to the USER.
;   The first element can be accessed in the "next" call when it is
;   shifted up to higher indices.
;
;   ptr_ptr                  Points to the seq_ptr element pointing to the
;                            "current" group of sequential major frame(s). This
;                            group of major frame(s) is returned to the USER.
;
;   ptr_ptr - 1              Points to the seq_ptr element pointing to the
;                            "next" group of sequential major frame(s).
;
;   ptr_ptr + 1              Points to the seq_ptr element pointing to the
;                            "previous" group of sequential major frame(s).
;___________________________________________________________________________________
;


         if move eq 1 then begin

              if buf.ptr_ptr eq 0 then begin

;  Check if PICKMJF buffer is already in the "look ahead" buffer

                   if (bufdata(buf.ptr(0)).mjf eq pickmjf_) $
                   then pickmjf_ = 0

GET_NEW:           iss = READ_MJF( in, PICKMJF=pickmjf_, FORMAT=buf.format, $
                                   DATA=data_mjf )

                   if (iss) eq 0 then buf.eofb = 1
;
;  Shift previous major frames into higher indices

                   buf.ptr   = SHIFT( buf.ptr,1  )

;  Put current data into "look ahead" buffer

                   bufdata(buf.ptr(0))     = data_mjf(0)
                   buf.nbuffill = (buf.nbuffill+1) < buf.nbuffers

;  Take care of pointers

                   if buf.nbuffill eq 1 then begin
                        pickmjf_       = 0
                        buf.nptr       = 0
                        buf.ptr_ptr    = 0
                        buf.seq_ptr(0) = 0
                        goto, GET_NEW      ;need to push "look ahead" into current buffer
                   endif

;  Check if the "current" and "previous" major frames are sequential
;
;  If they are then the major frame just moved out of the "look ahead" buffer
;  is part of the "previous" major frame group.  Link this major frame to the
;  "previous" major frame by making the appropriate pointer assignments.
;
;  If they are not, then shift older pointer assignments up and position
;  "current" pointer on this new major frame.

                   adj_prev = bufdata( buf.ptr(1) ).mjf $
                              - bufdata( buf.ptr(2) ).mjf

                   if adj_prev eq 1 then begin
                        buf.seq_ptr = buf.seq_ptr + 1
                        if buf.seq_ptr( buf.nptr-1 ) gt (buf.nbuffers-1) then $
                             buf.nptr = buf.nptr-1
                   endif else begin
                        buf.seq_ptr(buf.nbuffers-1) = 0
                        buf.seq_ptr = SHIFT( buf.seq_ptr + 1,1 )
                        buf.nptr    = (buf.nptr+1) < (buf.nbuffers-1)
                   endelse

;  Check if the "next" and "current" major frames are sequential
;
;  If they are, then we need to move the sequential major frame out of the
;  "look ahead" buffer.

                   adj_now  = bufdata( buf.ptr(0) ).mjf $
                              - bufdata( buf.ptr(1) ).mjf
                   if adj_now eq 1 then goto, GET_NEW

;  Return if end of file and buffer is empty

                   if buf.eofb and (bufdata( buf.ptr(1) ).mjf eq 0) then begin
                       return, 1
                   endif
              endif else buf.ptr_ptr   = buf.ptr_ptr - 1
         endif

         if move eq -1 then begin
              if buf.seq_ptr(buf.ptr_ptr) ge buf.seq_ptr(buf.nptr-1) then begin
                   printdev,'Reached end of buffer.',NODISPLAY=nowarn,LOG=log
                   printdev,'Returning last major frame(s) stored in buffer.',$
                            NODISPLAY=nowarn, LOG=log
              endif else buf.ptr_ptr = buf.ptr_ptr + 1
         endif

         if pickmjf_ ne 0 then begin
            pickmjf_ = 0
            goto, GET_NEW   ;push "look ahead" buffer into current buffer
         endif

;  Return header information and data

         i_1st     = buf.seq_ptr( buf.ptr_ptr )

         if buf.seq_ptr( buf.ptr_ptr ) gt 1 then begin

              if buf.ptr_ptr eq 0 then i_last = 1  $
                   else i_last = buf.seq_ptr( buf.ptr_ptr - 1 ) + 1

              nmjf      = i_1st - i_last + 1         ; # MJFs in buffer
              imjf      = indgen(nmjf) + i_last
              imjf      = buf.ptr(reverse( imjf ))

         endif else begin                            ; beginning of buffer
              nmjf      = 1
              imjf      = buf.ptr(i_1st)

         endelse

         Data      = bufdata( imjf )

         return,0
end


;+
; NAME:
;        CLEAR_SCAN
;
; PURPOSE:
;
;        Resets all the common block structure to 0.
;
; CATEGORY:
;       I/O
;
; CALLING SEQUENCE:
;
;        CLEAR_SCAN
;
; RESTRICTIONS:
;        Remember, when you exit an IDL routine or program, any common
;        block variables are still defined!
;
; MODIFICATION HISTORY:
;        Written by:  H.C. Wen, May, 1994.
;        15-MAY-1994  Added an end-of-file flag for each file buffer, eofb.
;        26-JUN-1994  Reduced the multi-common, multi-variables to ONE common
;                     and ONE structure, buf.
;        01-AUG-1994  Formerly called CLEAR_BUF
;-
pro CLEAR_SCAN

         common SCAN_COM, buf, bufdata

         if N_ELEMENTS( buf ) ne 0 then buf = 0  ;deallocate structure
end



;+
; NAME:
;        END_SCAN
;
; PURPOSE:
;
;        Closes the data file used by GET_SCAN to extract
;        HEAO A-1 data.
;
; CATEGORY:
;       I/O
;
; CALLING SEQUENCE:
;
;        END_SCAN
;
; INPUT KEYWORD PARAMETERS:
;
;       NOWARN:    Suppress printing of warning messages to screen.
;
;          LOG:    Output warning messages to log file.
;
; OUTPUTS:
;        Closes the current data file associated with the buffer.
;
; MODIFICATION HISTORY:
;        Written by:  H.C. Wen, May, 1994.
;        15-MAY-1994  Changed logical unit to file pointer.
;        26-JUN-1994  Eliminated multiple file option. Change file pointer
;                     back to logical unit.
;        01-AUG-1994  Formerly named CLOSE_BUF
;        09-AUG-1994  Added the close statement
;-
pro END_SCAN, NOWARN=Nowarn, LOG=Log

         common SCAN_COM, buf, bufdata

         ON_ERROR,2              ; Return to caller if an error occurs
         ON_IOERROR, NOFILE

         printdev,'Closing data file.',NODISPLAY=nowarn,LOG=log
         close, buf.lunit
         free_lun, buf.lunit
         return

NOFILE:  message, !ERR_STRING

end


;+
; NAME:
;        INIT_SCAN
;
; PURPOSE:
;
;        Initializes all the common block variables to their
;        appropriate values before you run the GET_SCAN routine.
;
; CATEGORY:
;       I/O
;
; CALLING SEQUENCE:
;
;        Result = INIT_SCAN( Newfile, [, NBUFFERS=NBuffers, FORMAT=Format] )
;
; INPUT KEYWORD PARAMETERS:
;
;     NBUFFERS:    The number of major frames you want retained in the
;             buffer arrays, [integer].(See RESTRICTIONS below)
;
;       FORMAT:    String describing format of the data file. (See READ_MJF)
;
; OUTPUT:
;        This function returns the value of the file pointer associated
;        with Newfile.
;
; RESTRICTIONS:
;        You MUST call this routine BEFORE calling GET_SCAN!
;        One of the buffer elements is reserved for "looking ahead"
;        for sequential major frames. (i.e. the USER actually has
;        nbuffers - 1 buffers available.
;
; MODIFICATION HISTORY:
;        Written by:  H.C. Wen, May, 1994.
;        15-MAY-1994  Added an end-of-file flag for each file buffer, eofb.
;        26-JUN-1994  Replace multiple commons with multi-variables/arrays
;                     with one common and one structure.
;                     Merged OPEN_BUF, eliminated multiple files.
;        01-AUG-1994  Formerly called INIT_BUF; Added FORMAT keyword, shifted
;                     definition of data structure to a separate routine,
;                     DEF_MJF so that all xxx_SCAN routines will be independent
;                     of any modifications to the data structure.
;-
function INIT_SCAN, Newfile, NBUFFERS=Nbuffers, FORMAT=Format

         common SCAN_COM, buf, bufdata

         ON_ERROR,2              ; Return to caller if an error occurs
         ON_IOERROR, NOFILE

         NP = N_PARAMS()
         if NP ne 1 then message,'Must be called with 1 parameter, Newfile.'

         CLEAR_SCAN      ; Make sure buffer hasn't initialized by previous calls.

;   Define number of buffers
         if not keyword_set( NBUFFERS ) then Nbuffers = 10

;   Open data file
         openr,in,newfile,/GET_LUN

;   Define the MJF data structure associated with this file
         if NOT keyword_set( FORMAT ) then Format = !HEAO_FMT
         MJFstruc  = DEF_MJF( in, FORMAT=Format )

;   Initialize buffer structure scalars and define buffer structure arrays
         bufdata   = replicate( MJFstruc, nbuffers )   ;Array of structures

                                                ;pointers
         ptr       = indgen( nbuffers )              ;pointer to buffers
         ptr_ptr   = 0                             ;pointer to ptr
         nptr      = 0                             ;number of ptr's
         seq_ptr   = intarr( nbuffers )              ;pointer to sequential mjf buffers
                                                ;I/O
         lunit     = in                            ;logical unit
         eofb      = 0                             ;end of buffer status
         nbuffill  = 0                               ;number of filled buffers

;   Define buf structure
         buf       = {      nbuffers :   nbuffers, $  ;general dimensions
                            ptr      :   ptr     , $  ;pointers
                            ptr_ptr  :   ptr_ptr , $
                            nptr     :   nptr    , $
                            seq_ptr  :   seq_ptr , $
                            lunit    :   lunit   , $  ;I/O
                            format   :   format  , $
                            eofb     :   eofb    , $
                            nbuffill :   nbuffill  }
         return, buf.lunit

NOFILE:  message, !ERR_STRING

end



