;-------------------------------
;-------------------------------
; THE DEFINITIVE PLOTTING PROGRAM
;-------------------------------
;-------------------------------
;Controle observation flow
;1) Normal raster
;IF (size(data))[0] EQ 4 AND (size(data))[3] LT 4*(size(data))[4] THEN
;2) Sit and stare
;IF strpos(hdr[0].obs_desc,'stare') NE -1 THEN
;3) Many step (First bit so sit and stare doesnt break and try and read (size(data))[4])
;IF (size(data))[0] EQ 4 AND (size(data))[3] GT 4*(size(data))[4] THEN
;4) Single sweep
;IF strpos(mghdr[0].obs_desc,'raster') NE -1 AND (size(data))[0] EQ 3 THEN
;------------------------------- colors ---------------------------------------
cnameflare=['yellow','gold','goldenrod','dark goldenrod','coral','grey',$
'grey','grey','grey','purple','blue','orange','black','grey','white','white',$
'hot pink','violet','pink','saddle brown','dodger blue','grey','cyan']
cnameflux=['grey','grey','grey','grey','grey','grey','grey','grey','grey',$
'grey','grey','grey','grey','grey','grey']
cnameqs=['grey','grey','grey','grey','grey','grey','grey','grey']
cnamespot=['grey','grey','grey','grey','grey','grey','grey']
cname = [cnameflare,cnameflux,cnameqs,cnamespot]
nclusters = 53
;--------------------------- set parameters ------------------------------------
list = rd_tfile('/Users/brandon/papers/Akiko/paths.txt',3)
FOR flare = 0,(size(list))[2]-1 DO BEGIN
;----------------------restore saved data for movies ---------------------------
    movie_data_path = string(list[0,flare]+strmid(list[1,flare],40,11))
    restore, '/Users/brandon/paper1/MovieData/'+movie_data_path+'.sav',/ve
    labels = labelss
    field_of_view = (mghdr[0].fovy)/60
;--------------------------- read in sjidata -----------------------------------
    sjifiles = file_search(list[1,flare]+'/*SJI_1400*fits',count=nsji)
    IF nsji eq 0 THEN sjifiles = file_search(list[1,flare]+'/*SJI_2796*fits',count=nsji)
    rasterfiles = file_search(list[1,0]+'/*raster*fits',count=nraster)
;-----------------------------read in data--------------------------------------
    print,'reading in files'
    read_iris_l2,sjifiles,sjihdr,sjidata,/silent
;------------------------------ clean the sji ----------------------------------
    sjidata = IRIS_DUSTBUSTER(sjihdr,sjidata,bpaddress,clean_values,/run)
;----------------------------- set up dimensions -------------------------------
    data = mgdata
    hdr = mghdr
    sz = size(data)
    step_range = sz[3]
    slice_range = srg[1]-srg[0]+1 ; not sure about the pluss one here
    frame_range = slice_range
;------------------------------ run the movie ----------------------------------
    set_plot,'X'
    device,RETAIN=2,SET_FONT='Helvetica Bold Italic', /TT_FONT
    window,xsize=500,ysize=500

    IF strpos(hdr[0].obs_desc,'raster') NE -1 AND (size(data))[0] EQ 3 THEN frame_range = step_range
    IF (size(data))[0] EQ 4 AND (size(data))[3] GT 4*(size(data))[4] THEN frame_range = step_range*slice_range ;for many steps few sweeps (breaks sit and stare)
    IF (size(data))[0] EQ 3 AND strpos(mghdr[0].obs_desc,'raster') NE -1 THEN frame_range = step_range

    mymovie = bytarr(3,500,500,frame_range)
    siz = size(mymovie)

     FOR s=0,frame_range-1 DO BEGIN
       !p.color=0
       !p.background=255
       !p.charsize = 1
       loadct,0

       IF (size(data))[0] EQ 4 AND (size(data))[3] LT 4*(size(data))[4] THEN $
       findsji = min(abs(anytim(hdr[(srg[0]+s)*step_range].date_obs)$
       - anytim(sjihdr.date_obs)),sjiind)

       IF (size(data))[0] EQ 4 AND (size(data))[3] GT 4*(size(data))[4] THEN $
       findsji = min(abs(anytim(hdr[srg[0]*step_range+s].date_obs)$
       - anytim(sjihdr.date_obs)),sjiind)


       IF strpos(mghdr[0].obs_desc,'raster') NE -1 AND (size(data))[0] EQ 3 THEN $
       findsji = min(abs(anytim(hdr[(srg[0]+s)].date_obs)$
       - anytim(sjihdr.date_obs)),sjiind)

       IF strpos(hdr[0].obs_desc,'stare') NE -1 THEN $
       findsji = min(abs(anytim(mghdr[(srg[0]+s)].date_obs)$
       - anytim(sjihdr.date_obs)),sjiind)


       tmpp = where(sjidata[*,*,sjiind] eq -200)
       img = (sjidata[*,*,sjiind]>0)^.3
       img[tmpp] = min(img)

       index2map,sjihdr[sjiind],-img,irismap
       get_map_coord,irismap,xcoord,ycoord
       slpos = xcoord[sjihdr[sjiind].sltpx1ix-1,0] - sjihdr[sjiind].pztx + hdr.pztx

       plot_map,irismap,fov=field_of_view,center=[irismap.xc,irismap.yc],max=8,$
       ticklen=.02,title = sjihdr[0].tdesc1+' Flare: '+ list[0,flare] +' Date: '+sjihdr[sjiind].date_obs,charthick=.6,charsize=1
;----------------------plot colored bars on slit--------------------------------
    ;1) Raster with few steps compared to slices
    IF (size(data))[0] EQ 4 AND (size(data))[3] LT 4*(size(data))[4] THEN BEGIN
        y_range = sz[2]
        labels_mat = reform(labels,y_range*step_range,slice_range)
        labels_for_single_file = labels_mat[*,s]
        resvec2 = reform(labels_for_single_file,sz[2],sz[3])
        usedprof=fltarr(nclusters)
        FOR sl=0,sz[3]-1 DO BEGIN
           FOR jj=0,sz[2]-1 DO BEGIN
             plots,slpos[sl],!y.crange,lines=1,color=cgcolor('black'),thick=0.2
             IF (cname[resvec2[jj,sl]] EQ 'red') OR (cname[resvec2[jj,sl]] EQ 'cyan') THEN BEGIN
             IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
             plots,[slpos[sl]-.5,slpos[sl]+.5],ycoord[0,jj],$
             color=cgcolor(cname[resvec2[jj,sl]])
              IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
                 usedprof[resvec2[jj,sl]]=1.
             ENDIF
           ENDFOR
        ENDFOR
    ENDIF
    ;2) Sit and Stare
    IF strpos(mghdr[0].obs_desc,'stare') NE -1 THEN BEGIN
        y_range = sz[2]
        labels_mat = reform(labels,y_range,slice_range)
        resvec2 = labels_mat[*,s]
        usedprof=fltarr(nclusters)
        FOR jj=0,sz[2]-1 DO BEGIN
          plots,slpos[s],!y.crange,lines=1,color=cgcolor('black'),thick=0.2
          IF (cname[resvec2[jj]] eq 'red') OR (cname[resvec2[jj]] eq 'cyan') THEN BEGIN
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
           plots,[slpos[s]-.5,slpos[s]+.5],ycoord[0,jj],$
           color=cgcolor(cname[resvec2[jj]])
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
              usedprof[resvec2[jj]]=1.
          ENDIF
        ENDFOR
    ENDIF

    ;3) Many step
    IF (size(data))[0] EQ 4 AND (size(data))[3] GT 4*(size(data))[4] THEN BEGIN
        y_range = sz[2]
        labels_mat = reform(labels,y_range,slice_range*step_range)
        resvec2 = labels_mat[*,s]
        usedprof=fltarr(nclusters)
        FOR jj=0,sz[2]-1 DO BEGIN
          plots,slpos[s],!y.crange,lines=1,color=cgcolor('black'),thick=0.2
          IF (cname[resvec2[jj]] EQ 'red') OR (cname[resvec2[jj]] EQ 'cyan') THEN BEGIN
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
           plots,[slpos[s]-.5,slpos[s]+.5],ycoord[0,jj],$
           color=cgcolor(cname[resvec2[jj]])
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
              usedprof[resvec2[jj]]=1.
            endif
        ENDFOR
    ENDIF
    ;4) Singlw sweep
    IF strpos(mghdr[0].obs_desc,'raster') NE -1 AND (size(data))[0] EQ 3 THEN BEGIN
        y_range = sz[2]
        labels_mat = reform(labels,y_range,slice_range)
        resvec2 = labels_mat[*,s]
        usedprof=fltarr(nclusters)
        FOR jj=0,sz[2]-1 DO BEGIN
          IF (cname[resvec2[jj]] EQ 'red') or (cname[resvec2[jj]] EQ 'cyan') THEN BEGIN
          plots,slpos[s],!y.crange,lines=1,color=cgcolor('black'),thick=0.2
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
           plots,[slpos[s]-.5,slpos[s]+.5],ycoord[0,jj],color=cgcolor(cname[resvec2[jj]])
           IF ycoord[0,jj] GT !y.crange[0] AND ycoord[0,jj] LT !y.crange[1] THEN $
              usedprof[resvec2[jj]]=1.
            endif
        ENDFOR
    ENDIF
;-------------------------------------------------------------------------------
       a=tvrd(/true)
       mymovie[*,*,*,s] = a
     ENDFOR

     video = idlffvideowrite('/Users/brandon/papers/Akiko/Movies/' + list[0,flare] +'.mp4')
     framedims = [siz[2],siz[3]]
     framerate = 10.
     stream = video.addvideostream(framedims[0],framedims[1],framerate,BIT_RATE=9d8,codec='mpeg4')
     frame = bytarr(3,framedims[0],framedims[1])
     FOR i=0,siz[4]-1 do begin
        frame[0,*,*] = mymovie[0,*,*,i]
        frame[1,*,*] = mymovie[1,*,*,i]
        frame[2,*,*] = mymovie[2,*,*,i]
        timestamp = video.put(stream,frame)
     ENDFOR
     video.cleanup
ENDFOR
END
