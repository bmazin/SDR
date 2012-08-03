;-------  map_test_scale.pro = Test map_put_scale and map_set_scale  -------
;	R. Sterner, 1999 Sep 22
 
	pro map_test_scale_ovrplot
 
        map_put_scale
        a=tvrd()        
        plot,[0,10]
        tv,a
        map_set_scale,/list
        map_continents,col=1
	txt = ''
	print,' '
	read,' Press enter to continue (s to stop)',txt
	if txt eq 's' then stop
 
	end
 
	;===============================================
	;===============================================
	;===============================================
 
	pro map_test_scale
 
	;-----  Set up  -------------
	device,decomp=1
	wshow
	color,'yellow'
	color,'blue',1
	lim = [20,-120,55,-60]
 
	;-----  1: Stereographic  ----------------
	map_set,/cont,/hor,/iso,/Stereographic
	map_test_scale_ovrplot
 
	map_set,/cont,/hor,/iso,40,-90,30,/Stereographic
	map_test_scale_ovrplot
 
	map_set,/cont,40,-90,30,/noborder,/Stereographic
	map_test_scale_ovrplot
 
	map_set,/cont,40,-90,30,/noborder,/Stereographic,lim=lim
	map_test_scale_ovrplot
 
        ;-----  2: Orthographic  ----------------
        map_set,/cont,/hor,/iso,/Orthographic
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/Orthographic
        map_test_scale_ovrplot
 
        map_set,/cont,40,-90,30,/noborder,/Orthographic
        map_test_scale_ovrplot
 
        map_set,/cont,40,-90,30,/noborder,/Orthographic,lim=lim
        map_test_scale_ovrplot
 
        ;-----  3: Conic  ----------------
        map_set,/cont,/hor,/iso,/conic
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/conic,stand=[20,40]
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/conic,stand=[20,40]
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/conic,stand=[20,40],lim=lim
        map_test_scale_ovrplot
 
        ;-----  4: Lambert Azimuthal  ----------------
        map_set,/cont,/hor,/iso,/lamb
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/lamb,stand=[20,40]
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/lamb,stand=[20,40]
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/lamb,stand=[20,40],lim=lim
        map_test_scale_ovrplot
 
        ;-----  5: Gnomic  ----------------
        map_set,/cont,/hor,/iso,/gnom
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/gnom,stand=[20,40]
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/gnom
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/gnom,lim=lim
        map_test_scale_ovrplot
 
        ;-----  6: Azi  ----------------
        map_set,/cont,/hor,/iso,/Azi
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/Azi
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/Azi
        map_test_scale_ovrplot
 
        map_set,/cont,/hor,/iso,40,-90,30,/noborder,/Azi,lim=lim
        map_test_scale_ovrplot
 
	end
