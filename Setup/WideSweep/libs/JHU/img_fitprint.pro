;-------------------------------------------------------------
;+
; NAME:
;       IMG_FITPRINT
; PURPOSE:
;       Add margin to fit an image to a print size.
; CATEGORY:
; CALLING SEQUENCE:
;       img_fitprint, file, prnt
; INPUTS:
;       file = Name of image file (*.png or *.jpg).  in
;       prnt = print dimensions, like '11 x 14', or '16x20', ...
; KEYWORD PARAMETERS:
;       Keywords:
;         /TOP place image at the top of the enlarged area (default).
;         /BOTTOM place image at the bottom of the enlarged area.
;         /LEFT place image at the left of the enlarged area.
;         /RIGHT place image at the right of the enlarged area.
;         /CENTER place image in the center of the enlarged area.
;         COLOR=clr Color of the extra added area (def=white).
;         BTHICK=bthk Thickness in pixels of added border (def=none).
;         BCOLOR=bclr 24-bit color of added border (def=0=black).
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Area is added to the image to make the shape fit
;       a specified print size.  The image will be saved as a JPEG
;       file with something like _11x14 added at the end of the
;       image file name to indicate the target print size.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 06
;       R. Sterner, 2006 Dec 06 ---  Added border.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_fitprint, file, prnt0, bottom=bot, top=top, center=cen, $
	  right=rgt, left=lef, help=hlp, color=clr, error=err, $
	  bthick=bthk, bolor=bclr
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Add margin to fit an image to a print size.'
	  print,' img_fitprint, file, prnt'
	  print,'   file = Name of image file (*.png or *.jpg).  in'
	  print,"   prnt = print dimensions, like '11 x 14', or '16x20', ..."
	  print,' Keywords:'
	  print,'   /TOP place image at the top of the enlarged area (default).'
	  print,'   /BOTTOM place image at the bottom of the enlarged area.'
	  print,'   /LEFT place image at the left of the enlarged area.'
	  print,'   /RIGHT place image at the right of the enlarged area.'
	  print,'   /CENTER place image in the center of the enlarged area.'
	  print,'   COLOR=clr Color of the extra added area (def=white).'
	  print,'   BTHICK=bthk Thickness in pixels of added border (def=none).'
	  print,'   BCOLOR=bclr 24-bit color of added border (def=0=black).'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Notes: Area is added to the image to make the shape fit'
	  print,' a specified print size.  The image will be saved as a JPEG'
	  print,' file with something like _11x14 added at the end of the'
	  print,' image file name to indicate the target print size.'
	  return
	endif
 
	;---------------------------------------------------------------
	;  Read image
	;---------------------------------------------------------------
	f = file_search(file,count=cnt)
	if cnt eq 0 then begin
	  print,' Error in img_fitprint: File not found: '+file
	  err = 1
	  return
	endif
	filebreak, file, ext=ext, name=name
	if strupcase(ext) eq 'PNG' then begin
	  print,' Reading PNG image ...'
	  read_png, file, img
	endif else begin
	  print,' Reading JPEG image ...'
	  read_jpeg, file, img
	endelse
 
	;---------------------------------------------------------------
	;  Process requested shape
	;
	;  Shape GT 1: Portait
	;  Shape LT 1: Landscape
	;---------------------------------------------------------------
	prnt = strupcase(prnt0)		; Copy of size in upper case.
	prnt = repchr(prnt,'X')		; Remove X if there.
	xsz = getwrd(prnt,0)+0.		; Grab x size.
	ysz = getwrd(prnt,1)+0.		; Grab y size.
	pshp = ysz/xsz			; Print shape.
	if n_elements(bthk) eq 0 then bthk=0	; No added border by default.
	if n_elements(bclr) eq 0 then bclr=0	; Default border color = black.
 
	;---------------------------------------------------------------
	;  Image dimensions, shape, and color components
	;---------------------------------------------------------------
	print,' Splitting image ...'
	img_split,img,imgr,imgg,imgb,nx=nx,ny=ny  ; Image dims and components.
	ishp = float(ny)/nx		; Image shape.
	if (ishp lt 1.) and (pshp gt 1.) then pshp=1./pshp ; Match orientation.
	if (ishp gt 1.) and (pshp lt 1.) then pshp=1./pshp
 
	;---------------------------------------------------------------
	;  Expanded image dimensions
	;---------------------------------------------------------------
	if pshp eq ishp then begin	; No change needed.
	  img2 = img
	  goto, output
	endif
	if pshp lt ishp then begin	; Expand in X.
	  ny2 = ny
	  if pshp lt 1. then nx2=round(ny*pshp)
	  if pshp ge 1. then nx2=round(ny/pshp)
	endif
	if pshp gt ishp then begin	; Expand in Y.
	  nx2 = nx
	  if pshp lt 1. then ny2=round(nx/pshp)
	  if pshp ge 1. then ny2=round(nx*pshp)
	endif
 
	;---------------------------------------------------------------
	;  Deal with added border
	;
	;  This is not exact but ok for big images and thin borders.
	;  Should compute more exact added border above.  Add bthk to
	;  smallest increase and a bit more to other dimension.
	;---------------------------------------------------------------
	if bthk ne 0 then begin
	  nx2 = nx2 + 2*bthk
	  ny2 = ny2 + 2*bthk
	endif
 
	;---------------------------------------------------------------
	;  Create expanded image color components
	;---------------------------------------------------------------
	print,' Creating expanded image ...'
	if n_elements(clr) eq 0 then clr=16777215L
	c2rgb, clr, r, g, b			; Added area color.
	img2r = bytarr(nx2,ny2) + byte(r)	; New red.
	img2g = bytarr(nx2,ny2) + byte(g)	; New green.
	img2b = bytarr(nx2,ny2) + byte(b)	; New blue.
 
	;---------------------------------------------------------------
	;  Color added border
	;---------------------------------------------------------------
	if bthk gt 0 then begin
	  lst = bthk-1
	  c2rgb, bclr, r_b, g_b, b_b		; Added border color.
 
	  img2r[*,0:lst] = r_b			; Red bottom.
	  img2r[*,(ny2-1-lst):(ny2-1)] = r_b	; Red top.
	  img2r[0:lst,*] = r_b			; Red left.
	  img2r[(nx2-1-lst):(nx2-1),*] = r_b	; Red right.
 
	  img2g[*,0:lst] = g_b			; Green bottom.
	  img2g[*,(ny2-1-lst):(ny2-1)] = g_b	; Green top.
	  img2g[0:lst,*] = g_b			; Green left.
	  img2g[(nx2-1-lst):(nx2-1),*] = g_b	; Green right.
 
	  img2b[*,0:lst] = b_b			; Blue bottom.
	  img2b[*,(ny2-1-lst):(ny2-1)] = b_b	; Blue top.
	  img2b[0:lst,*] = b_b			; Blue left.
	  img2b[(nx2-1-lst):(nx2-1),*] = b_b	; Blue right.
	endif
 
	;---------------------------------------------------------------
	;  Insert image into expanded image
	;---------------------------------------------------------------
	print,' Inserting into exapnded image ...'
	flag = 0
	if keyword_set(bot) then flag=1		; Insertion type code.
	if keyword_set(top) then flag=2
	if keyword_set(cen) then flag=3
	if keyword_set(rgt) then flag=4
	if keyword_set(lef) then flag=5
	if flag eq 0 then flag=2
 
	case flag of		; Find insertion index.
1:	begin	; Bottom.
	  ix = 0
	  iy = 0
	  pos = '_bottom'
	end
2:	begin	; Top.
	  ix = 0
	  iy = ny2-ny
	  pos = '_top'
	end
3:	begin	; Center.
	  ix = nx2/2 - nx/2
	  iy = ny2/2 - ny/2
	  pos = '_center'
	end
4:	begin	; Right.
	  ix = nx2-nx
	  iy = 0
	  pos = '_right'
	end
5:	begin	; Left.
	  ix = 0
	  iy = 0
	  pos = '_left'
	end
	endcase
 
	img2r(ix,iy) = imgr	; Insert image.
	img2g(ix,iy) = imgg
	img2b(ix,iy) = imgb
 
	img2 = img_merge(img2r,img2g,img2b,true=3)
 
	;---------------------------------------------------------------
	;  Save result
	;---------------------------------------------------------------
output:
	print,' Saving expanded JPEG ...'
	jpg = name+'_'+strcompress(strlowcase(prnt0),/rem)+pos+'.jpg'
	write_jpeg, jpg, img2, true=3, quality=90
	print,' Modified image saved in '+jpg
	print,' Print shape = ',pshp
	print,' New image shape = ',float(ny2)/nx2
	print,' Old image shape = ',ishp
 
	end
