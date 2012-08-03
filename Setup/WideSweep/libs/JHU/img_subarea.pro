;-------------------------------------------------------------
;+
; NAME:
;       IMG_SUBAREA
; PURPOSE:
;       Returns a subarea from an array or color image.
; CATEGORY:
; CALLING SEQUENCE:
;       sub = img_subarea(img, ix, iy, dx, dy).
; INPUTS:
;       img = Input image.                            in
;       ix,iy = Starting x and y pixel for subimage.  in
;       dx,dy = Size of subimage to extract.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=tr Returned interleave dimension (0 means 2-D image).
;         NX=nx, NY=ny Returned input image dimensions.
;         MISSING=miss Value to use for parts of the subarea
;           that fall outside the image (default = 0).
;           If MISSING=miss is used then it should have the same
;           data type as the input image to avoid a type change.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D.
; OUTPUTS:
;       sub = Returned subimage.                      out
; COMMON BLOCKS:
; NOTES:
;       Note: Can deal with 2-D or 3-D image arrays.
;         Returns a subimage of size dx by dy.  Deals
;         with areas that extend outside the input image.
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Mar 01.
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_subarea, img, ix, iy, dx, dy, $
	  true=tr, nx=nx, ny=ny, error=err, missing=miss, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Returns a subarea from an array or color image.'
	  print,' sub = img_subarea(img, ix, iy, dx, dy).'
	  print,'   img = Input image.                            in'
	  print,'   ix,iy = Starting x and y pixel for subimage.  in'
	  print,'   dx,dy = Size of subimage to extract.          in'
	  print,'   sub = Returned subimage.                      out'
	  print,' Keywords:'
	  print,'   TRUE=tr Returned interleave dimension (0 means 2-D image).'
	  print,'   NX=nx, NY=ny Returned input image dimensions.'
	  print,'   MISSING=miss Value to use for parts of the subarea'
	  print,'     that fall outside the image (default = 0).'
	  print,'     If MISSING=miss is used then it should have the same'
	  print,'     data type as the input image to avoid a type change.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D.'
	  print,' Note: Can deal with 2-D or 3-D image arrays.'
	  print,'   Returns a subimage of size dx by dy.  Deals'
	  print,'   with areas that extend outside the input image.'
	  return,''
	endif
 
	;-------------------------------------------------------
	;  Defaults
	;-------------------------------------------------------
	if n_elements(miss) eq 0 then miss=0B
 
	;-------------------------------------------------------
	;  Find input image dimensions
	;-------------------------------------------------------
	img_shape, img, true=tr, nx=nx, ny=ny, error=err
	if err ne 0 then begin
	  if err eq 1 then $
	    print,' Error in img_subarea: array must 2-D or 3-D.'
	  if err eq 2 then $
	    print,' Error in img_subarea: array must have 3 color channels.'
	  return,img
	endif
 
	;-------------------------------------------------------
	;  Find indices of subarea
	;-------------------------------------------------------
	ix1 = ix			; Indices of requested area (unclipped).
	iy1 = iy
	ix2 = ix + dx - 1
	iy2 = iy + dx - 1
 
	;-------------------------------------------------------
	;  Find dimensions and data type of requested subarea
	;-------------------------------------------------------
	case tr of			; Dimensions of requested subarea.
0:	  dim = [dx,dy]
1:	  dim = [3,dx,dy]
2:	  dim = [dx,3,dy]
3:	  dim = [dx,dy,3]
	endcase
	typ = size(img,/type)		; Input image data type.
 
	;-------------------------------------------------------
	;  Check if subarea is completely outside image
	;-------------------------------------------------------
	if (ix1 ge nx) or (ix2 lt 0) or $
	   (iy1 ge ny) or (iy2 lt 0) then begin
	  return, make_array(dim=dim, typ=typ,val=miss)
	endif
 
	;-------------------------------------------------------
	;  Indices of overlap region
	;-------------------------------------------------------
	ix1c = ix1>0<(nx-1)		; Find clipped indices.
	iy1c = iy1>0<(ny-1)		; This is the part of the
	ix2c = ix2>0<(nx-1)		; subarea that is within the
	iy2c = iy2>0<(ny-1)		; given image.
 
	;-------------------------------------------------------
	;  Extract overlap region
	;-------------------------------------------------------
	case tr of
0:	  overlap = img[ix1c:ix2c,iy1c:iy2c]
1:	  overlap = img[*,ix1c:ix2c,iy1c:iy2c]
2:	  overlap = img[ix1c:ix2c,*,iy1c:iy2c]
3:	  overlap = img[ix1c:ix2c,iy1c:iy2c,*]
	endcase
 
	;-------------------------------------------------------
	;  Check if subarea is completely inside image
	;-------------------------------------------------------
	if (ix1 ge 0) and (ix2 lt nx) and $
	   (iy1 ge 0) and (iy2 lt ny) then begin
	  return, overlap
	endif
 
	;-------------------------------------------------------
	;  Make subarea array and insert overlap region
	;-------------------------------------------------------
	sub = make_array(dim=dim, typ=typ,val=miss)
	ix0 = ix1c - ix1		; Insertion point.
	iy0 = iy1c - iy1
	case tr of
0:	  sub[ix0,iy0]   = overlap
1:	  sub[0,ix0,iy0] = overlap
2:	  sub[ix0,0,iy0] = overlap
3:	  sub[ix0,iy0,0] = overlap
	endcase
	return,sub
 
	end
