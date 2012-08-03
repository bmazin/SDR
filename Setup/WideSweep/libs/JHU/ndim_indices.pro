;-------------------------------------------------------------
;+
; NAME:
;       NDIM_INDICES
; PURPOSE:
;       Indexing info for an n-dimensional table.
; CATEGORY:
; CALLING SEQUENCE:
;       ndim_indices, dims, inds, s
; INPUTS:
;       dims = array of dimension sizes for table.   in
;       inds = array of indices into each dimension. in
;         The number of elements in dims and inds must be the
;         same.  The first index is 0 for each dimension.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       s = returned information structure:          out
;         {nd:nd,	; number of dimensions in table.
;          tot:tot, ; total cells in table.
;          nc:nc,   ; number of table cells completed.
;          nl:nl}   ; number of table cells left.
; COMMON BLOCKS:
; NOTES:
;       Note: For a set of indices (i1,i2,...,in) pointing to
;       a cell in the n-dimensional table, the returned
;       structure will indicate how many table cells there are
;       before that cell in the table (nc), and how many cells
;       are left including the indicated cell (nl).
;       The following chart shows how the values are computed:
;       Dimension  Size  Index  #_completed
;           1       n1     i1      i1 +
;           2       n2     i2      i2*n1 +
;           3       n3     i3      i3*n1*n2 +
;           4       n4     i4      i4*n1*n2*n3 +
;          ...      ...    ...     ...
;       Sum the last column over all the dimensions in the table
;       to get the number of cells completed.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jun 18
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ndim_indices, dims, inds, s, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Indexing info for an n-dimensional table.'
	  print,' ndim_indices, dims, inds, s'
	  print,'   dims = array of dimension sizes for table.   in'
	  print,'   inds = array of indices into each dimension. in'
	  print,'     The number of elements in dims and inds must be the'
	  print,'     same.  The first index is 0 for each dimension.'
	  print,'   s = returned information structure:          out'
	  print,'     {nd:nd,	; number of dimensions in table.'
	  print,'      tot:tot, ; total cells in table.'
	  print,'      nc:nc,   ; number of table cells completed.'
	  print,'      nl:nl}   ; number of table cells left.'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: For a set of indices (i1,i2,...,in) pointing to'
	  print,' a cell in the n-dimensional table, the returned'
	  print,' structure will indicate how many table cells there are'
	  print,' before that cell in the table (nc), and how many cells'
	  print,' are left including the indicated cell (nl).'
	  print,' The following chart shows how the values are computed:'
	  print,' Dimension  Size  Index  #_completed'
	  print,'     1       n1     i1      i1 +'
	  print,'     2       n2     i2      i2*n1 +'
	  print,'     3       n3     i3      i3*n1*n2 +'
	  print,'     4       n4     i4      i4*n1*n2*n3 +'
	  print,'    ...      ...    ...     ...'
	  print,' Sum the last column over all the dimensions in the table'
	  print,' to get the number of cells completed.'
	  return
	endif
 
	;------  Check that array sizes match  ----------
	nd1 = n_elements(dims)
	nd2 = n_elements(inds)
	if nd1 ne nd2 then begin
	  print,' Error in ndim_indices: Must give same number of indices'
	  print,' as dimension sizes.'
	  err = 1
	  return
	endif
 
	err = 0
 
	;------  Compute total and number completed  -------
	t = 0L				; Number of cells completed.
	tt = 1L				; Total number of cells.
	for i=nd1-1, 0, -1 do begin	; Loop through dimensions in reverse.
	  tt = tt*dims(i)		; Work on total cells.
	  t = t*dims(i) + inds(i)	; Work on number completed.
	endfor
 
	;------  Return values  ---------
	s = {nd:nd1, $		; Number of dimensions in table.
	     tot:tt, $		; Total number of table cells.
	       nc:t, $		; Number of cells completed to given indices.
	     nl:tt-t}		; Number of cells yet to complete.
 
	end
