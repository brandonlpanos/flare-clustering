;Reconstructs locations wrt the original IRIS files for a select number of groups

list = rd_tfile('/Users/brandon/papers/Akiko/paths.txt',3)

FOR flare_name=0,(size(list))[2]-1 DO BEGIN
  print, list[0,flare_name]

  movie_data_path = string(list[0,flare_name]+strmid(list[1,flare_name],40,11))
  restore, '/Users/brandon/papers/paper1/MovieData/'+movie_data_path+'.sav',/ve
  labels = labelss
  rasterfiles = file_search(list[1,flare_name]+'/*raster*fits',count=nraster)
  read_iris_l2,rasterfiles[*],hdr,data,wave='Mg',/silent

;---------------------------- sit and stare ------------------------------------

  IF strpos(hdr[0].obs_desc,'stare') NE -1 THEN BEGIN

    dim = size(data)
    ndim = dim[0]
    x = dim[1]
    y = dim[2]
    t = dim[3]
    arr = fltarr(y, t)

    w11 = where(labels eq 11)
    IF w11[0] eq -1 then loc_11 = 'No profiles assigned to this group'
    IF w11[0] ne -1 then begin
      sz = (size(w11))[1]
      loc_11 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w11[i])
        loc_11[0,i] = pos[0]
        loc_11[1,i] = pos[1] + srg[0]
      endfor
    endif
    w12 = where(labels eq 12)
    IF w12[0] eq -1 then loc_12 = 'No profiles assigned to this group'
    IF w12[0] ne -1 then begin
      sz = (size(w12))[1]
      loc_12 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w12[i])
        loc_12[0,i] = pos[0]
        loc_12[1,i] = pos[1] + srg[0]
      endfor
    endif
    w52 = where(labels eq 52)
    IF w52[0] eq -1 then loc_52 = 'No profiles assigned to this group'
    IF w52[0] ne -1 then begin
      sz = (size(w52))[1]
      loc_52 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w52[i])
        loc_52[0,i] = pos[0]
        loc_52[1,i] = pos[1] + srg[0]
      endfor
    endif
    save,loc_11,loc_12,loc_52,filename='/Users/brandon/papers/John/locations/flare_'+list[0,flare_name]+'.sav'

  ENDIF
;---------------------------- raster -------------------------------------------

  IF (size(data))[0] EQ 4 AND (size(data))[3] LT 4*(size(data))[4] THEN BEGIN ; Care here, flare 11 and 12 will be missed if you dont change it to LT

    dim = size(data)

    ndim = dim[0]
    x = dim[1]
    y = dim[2]
    step = dim[3]
    t = dim[4]
    arr = fltarr(y, step, t)

    w11 = where(labels eq 11)
    IF w11[0] eq -1 then loc_11 = 'No profiles assigned to this group'
    IF w11[0] ne -1 then begin
      sz = (size(w11))[1]
      loc_11 = intarr(3,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w11[i])
        loc_11[0,i] = pos[0]
        loc_11[1,i] = pos[1]
        loc_11[2,i] = pos[2] + srg[0]
      endfor
    endif
    w12 = where(labels eq 12)
    IF w12[0] eq -1 then loc_12 = 'No profiles assigned to this group'
    IF w12[0] ne -1 then begin
      sz = (size(w12))[1]
      loc_12 = intarr(3,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w12[i])
        loc_12[0,i] = pos[0]
        loc_12[1,i] = pos[1]
        loc_12[2,i] = pos[2] + srg[0]
      endfor
    endif
    w52 = where(labels eq 52)
    IF w52[0] eq -1 then loc_52 = 'No profiles assigned to this group'
    IF w52[0] ne -1 then begin
      sz = (size(w52))[1]
      loc_52 = intarr(3,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w52[i])
        loc_52[0,i] = pos[0]
        loc_52[1,i] = pos[1]
        loc_52[2,i] = pos[2] + srg[0]
      endfor
    endif
    save,loc_11,loc_12,loc_52,filename='/Users/brandon/papers/John/locations/flare_'+list[0,flare_name]+'.sav'

  ENDIF
;---------------------------- single sweep --------------------------------------

  IF strpos(mghdr[0].obs_desc,'raster') NE -1 AND (size(data))[0] EQ 3 THEN BEGIN

    dim = size(data)

    ndim = dim[0]
    x = dim[1]
    y = dim[2]
    step = dim[3]
    arr = fltarr(y, step)

    w11 = where(labels eq 11)
    IF w11[0] eq -1 then loc_11 = 'No profiles assigned to this group'
    IF w11[0] ne -1 then begin
      sz = (size(w11))[1]
      loc_11 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w11[i])
        loc_11[0,i] = pos[0]
        loc_11[1,i] = pos[1] + srg[0]
      endfor
    endif
    w12 = where(labels eq 12)
    IF w12[0] eq -1 then loc_12 = 'No profiles assigned to this group'
    IF w12[0] ne -1 then begin
      sz = (size(w12))[1]
      loc_12 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w12[i])
        loc_12[0,i] = pos[0]
        loc_12[1,i] = pos[1] + srg[0]
      endfor
    endif
    w52 = where(labels eq 52)
    IF w52[0] eq -1 then loc_52 = 'No profiles assigned to this group'
    IF w52[0] ne -1 then begin
      sz = (size(w52))[1]
      loc_52 = intarr(2,sz)
      for i = 0, sz - 1 do begin
        pos = array_indices(arr, w52[i])
        loc_52[0,i] = pos[0]
        loc_52[1,i] = pos[1] + srg[0]
      endfor
    endif
    save,loc_11,loc_12,loc_52,filename='/Users/brandon/papers/John/locations/flare_'+list[0,flare_name]+'.sav'

  ENDIF

ENDFOR

END
