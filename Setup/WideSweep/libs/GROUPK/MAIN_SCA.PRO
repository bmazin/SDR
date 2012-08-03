;+
; NAME:
;        MAIN_SCAN
;
; PURPOSE:
;        This is the main driver routine to loop through the major frame buffers
;        from IDL data files.  It serves to take care of the overhead of reading
;        major frames into the buffer and then accessing that buffer; i.e.
;        redundant code which every routine that accesses the data must have.
;        Each major frame buffer consists of a block of sequential major frames.
;
; CATEGORY:
;        I/O
;
; CALLING SEQUENCE:
;        MAIN_SCAN [,File]
;
; OPTIONAL INPUTS:
;         File:    The path/filename of the IDL data file you wish to access, [string].
;             If this option is not provided or there is a problem finding this
;             file, then the USER will interactively select the file.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;    USER_INIT:    Name of the function used to initialize USER variables,
;             open USER files, etc., [string].
;
;      USER_IO:    Name of the function used to determine the I/O operation
;             to be performed on the next access of the buffer; i.e. get
;             the next/previous major frame buffer, etc., [string].
;
;    USER_DATA:    Name of the function to pass all the variables from the
;             major frame buffer you selected using USER_IO. The USER may
;             use these variables for their analysis, [string].
;
;     USER_END:    Name of the function to clean-up any USER variables,
;             open files, etc., [string].
;
;     NBUFFERS:    The maximum number of major frames to be held in the buffer, [integer].
;
;       FORMAT:    String describing the format of the data file. (See DEF_MJF).
;
;       _EXTRA:    Any number of additional keywords may be added.  They are
;             passed to the USER_INIT routine (see example below).
;
;
; OUTPUT KEYWORD PARAMETERS:
;
;       OUTPUT:    A scalar, array or structure containing outputted
;             results from USER_END
;
; RESTRICTIONS:
;        The functions defined by the above INPUTS must have the following
;        form:
;
;                  function USER_INIT [, USER keywords ]
;                  function USER_IO, Move, PickMJF, Nowarn, Log $
;                                 [, USER keywords ]
;                  function USER_DATA,Data, [, USER keywords ]
;                  function USER_END,  OUTPUT=Output[, USER keywords ]
;
;        while the names can be anything the USER choses.
;        Data is a structure variable holding all the data of the major
;        frame buffer retrieved.  Its tags or members are defined in DEF_MJF.
;
;        NOTE: If any of these function returns a 0 value then MAIN_SCAN aborts by
;        closing the IDL data file and clearing all buffers.
;
; EXAMPLE:
;        Let's say you want to look at the light curves from an IDL
;        data file.  You may want to create a routine, LIGHT_CURVE:
;
;                pro LIGHT_CURVE, file, TEXT=Text
;                     MAIN_SCAN, file, USER_DATA='LC_DATA',USER_END='LC_END',$
;                           USER_INIT='LC_INIT',TEXT=Text
;                end
;
;        AND the following USER routines:
;
;                function LC_INIT, FORMAT=Format, TEXT=Text
;                       print,Text
;                       return, 1
;                end
;
;                function LC_DATA, Data, FORMAT=Format, TEXT=Text
;
;                    plot, data.cts, psym=10  ;plot data in histogram format
;                    return, 1
;                end
;
;                function LC_END, FORMAT=Format, TEXT=Text
;                    wdelete ;close plotting window
;                    return, 1
;                end
;
;        NOTE: The TEXT keyword is an "extra" keyword to MAIN_SCAN and is
;              passed to the LC_INIT routine.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1994.
;        03-AUG-1994    Removed OUTPUT keyword from USER_DATA.
;        29-AUG-1994    Implemented the !DATA_PATH system variable defined
;                       in HEAO.RUN
;        30-AUG-1994    Changed Init_params to USER_keywords and passed this
;                       using the _EXTRA keyword to ALL USER routines. The
;                       FORMAT keyword is also now passed to ALL USER routines.
;        30-DEC-1994    Added the GET_FMT function to determine the format
;                       of the data file if the FORMAT keyword is not specified.
;        31-JAN-1995    Added the ANONYMOUS_ to avoid a subtle/rare bug with the
;                       _EXTRA keyword. (Has no functionality for the USER
;                       -> i.e. for internal use only).
;        06-AUG-1996    Check if !DATA_PATH system variable is defined.
;-
pro MAIN_SCAN, File ,USER_INIT=User_init, USER_IO=User_IO, USER_DATA=User_data,$
          USER_END=User_end, NBUFFERS=NBuffers, _EXTRA = USER_keywords, $
          OUTPUT=Output, ANONYMOUS_=Dummy_


         On_error,2              ;Return to caller if an error occurs

         NP = N_PARAMS()
         if (NP gt 1) then $
            message, 'Must be called with 0-1 parameter: File'

         KEY_SET   = keyword_set( USER_KEYWORDS )
         INIT_SET  = keyword_set( USER_INIT )
         IO_SET    = keyword_set( USER_IO )
         DATA_SET  = keyword_set( USER_DATA )
         END_SET   = keyword_set( USER_END )

         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''

         if (N_ELEMENTS( File ) eq 0) then $
              print,'Looking for data files...' $
         else begin
              if (!DATA_PATH eq '') then begin
                   delim = RSTRPOS(File,'\')
                   if (delim eq -1) then delim = RSTRPOS(File,'/')
                   if (delim ne -1) $
                   then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
              endif
              File1  = !DATA_PATH+strtrim( File,2 )
              flist  = findfile( File1, COUNT=nfile )
              CASE 1 OF
                   (nfile eq 1)   :goto, OPENF
                   (nfile eq 0)   :print,'Cannot find file.'
                   (nfile gt 1)   :print,'Multiple files found.'
              ENDCASE
         endelse

         File1 = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.idl' )

OPENF:   Format = ''
         if Key_SET then begin
              tags = TAG_NAMES( USER_keywords )
              here = where( tags eq 'FORMAT', n )
              if n eq 1 then Format = USER_keywords.FORMAT
         endif
         if Format eq '' then Format = GET_FMT( File1 )
         lunit = INIT_SCAN( File1, NBUFFERS=NBuffers, $ ;open file, initialize buffer.
                                   FORMAT=Format )

         if not KEY_SET then goto, NOEXTRA

; Any USER initialization performed here

         if INIT_SET then begin
              iss = CALL_FUNCTION( USER_INIT, _EXTRA=USER_keywords )
              if not iss then goto, QUIT
         endif


;   USER determines what I/O to perform on file

NEXT:    if IO_SET then begin
              iss = CALL_FUNCTION( USER_IO, Move, Pickmjf, $
                                   Nowarn, Log, _EXTRA=USER_keywords )
              if not iss then goto, QUIT
         endif else Move = 1

;  Now read in a major frame buffer

         eofb = GET_SCAN( Move, PICKMJF=Pickmjf, NOWARN=nowarn, $
                         LOG=log, DATA=Data )
         if eofb then goto, QUIT

         if DATA_SET then begin
              iss = CALL_FUNCTION( USER_DATA, Data, _EXTRA=USER_keywords )
              if not iss then goto, QUIT
         endif
         goto, NEXT

QUIT:    END_SCAN
         CLEAR_SCAN  ; Clear the commons

; Any USER clean-up perfomed here

         if END_SET then $
               eofu = CALL_FUNCTION( USER_END, $
                                     _EXTRA=USER_keywords, OUTPUT=Output )

         return

;===========================================================================
;
;   Identical to the previous section except with the _EXTRA parameter
;   removed in CALL_FUNCTION
;
;===========================================================================

NOEXTRA:

; Any USER initialization performed here

         if INIT_SET then begin
              iss = CALL_FUNCTION( USER_INIT )
              if not iss then goto, QUITNE
         endif


;   USER determines what I/O to perform on file

NEXTNE:  if IO_SET then begin
              iss = CALL_FUNCTION( USER_IO, Move, Pickmjf, Nowarn, Log )
              if not iss then goto, QUITNE
         endif else Move = 1

;  Now read in a major frame buffer

         eofb = GET_SCAN( Move, PICKMJF=Pickmjf, NOWARN=nowarn, $
                         LOG=log, DATA=Data )
         if eofb then goto, QUITNE

         if DATA_SET then begin
              iss = CALL_FUNCTION( USER_DATA, Data )
              if not iss then goto, QUITNE
         endif
         goto, NEXTNE

QUITNE:  END_SCAN
         CLEAR_SCAN  ; Clear the commons

; Any USER clean-up perfomed here

         if END_SET then $
              eofu = CALL_FUNCTION( USER_END, OUTPUT=Output )
end
