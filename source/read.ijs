NB.   readpng      read PNG file, returning RGB data
NB.   readpnghdr   read header from PNG file

NB. =========================================================
NB.*readpng v read PNG file, returning RGB data
readpng=: 3 : 0

if. USEQTPNG do.
  if. 0=# dat=. readimg_jqtide_ y do.
    'Qt cannot read PNG file' return.
  end.
  dat return.
elseif. USEJAPNG do.
  if. 0=# dat=. readimg_ja_ y do.
    'jandroid cannot read PNG file' return.
  end.
  dat return.
elseif. USEJNPNG do.
  if. 0=# dat=. readimg_ja_ y do.
    'jnet cannot read PNG file' return.
  end.
  dat return.
elseif. USEPPPNG do.
  if. 0=# dat=. readimg_pplatimg_ y do.
    'pplatimg cannot read PNG file' return.
  end.
  dat return.
end.
r=. readpnghdrall y
if. 2 = 3!:0 r do. return. end.
'nos dat'=. r
'width height bit color compression filter interlace'=. nos

if. 0~:filter do.
  'invalid filter' return.
end.
if. 0~:interlace do.
  'interlace PNGs not supported' return.
end.
if. (-.bit e. 1 2 4 8) do.
  'only 1 2 4 8 bit depth supported' return.
end.

NB. only process IHDR IDAT IEND chunks
dat=. fread y
ie=. I. 'IEND' E. dat
if. 0=#ie do. 'missing IEND' return. end.
dat=. ({.ie){. dat
if. 3=color do.
  ip=. I. 'PLTE' E. dat
  if. 0=#ip do. 'mssing PLTE' return. end.
  p=. {.ip-4   NB. pointer to len
  len=. {.be32inv (p+i.4){dat
  crc=. ((len+8+p)+i.4){dat
  d=. (4+len){.(4+p)}.dat
  if. -. crc-:(be32 crc32 d) do. 'crc32 error' return. end.
  ipal=. fliprgb le32inv , ({:a.),~("1) _3]\ len{.(8+p)}.dat
end.

id=. I. 'IDAT' E. dat
if. 0=#id do. 'missing IDAT' return. end.

trns=. 0$0
if. color -.@e. 4 6 do.
  d=. ({.id){. dat
  if. #ir=. I. 'tRNS' E. d do.
    p=. {.ir-4
    len=. {.be32inv (p+i.4){dat
    s=. a.i. len{.(8+p)}.dat
    if. 0=color do.
      trns=. 8&gray2rgb 256 #. _2]\ s
    elseif. 2=color do.
      trns=. 256 #. _3]\ 256 #. _2]\ s
    elseif. 3=color do.
      trns=. (#ipal){.!.255 s
      ipal=. trns setalpha ipal
    end.
  end.
end.

id=. id-4 NB. pointer to len
idat=. ''
p=. {.id
for_i. i.#id do.
  if. p>i{id do. continue. end.
  len=. {.be32inv ((i{id)+i.4){dat
  crc=. ((len+8+i{id)+i.4){dat
  d=. (4+len){.(4+i{id)}.dat
  if. -. crc-:(be32 crc32 d) do. 'crc32 error' return. end.
  idat=. idat, len{.(8+i{id)}.dat
  p=. p+len
end.

NB. original size
NB. datalen=. (1+((3=color){1,~3+6=color)*width)*height
datalen=. 0
try.
  data=. datalen zlib_uncompress_jzlib_ idat
catch.
  'zlib uncompression error' return.
end.
if. color e. 0 4 do.
  if. (4=color) > bit e. 8 16 do.
    'only 8 and 16 bit grayscale can have alpha channel' return.
  end.
  if. 1=bit do.  NB. color 0
    r=. (height,width)$ (setalpha)`(trns&transparent)@.(*#trns) 1&gray2rgb , #: a.i. , 1&rfilter (height,1+>.width%8) $ data
  elseif. 2=bit do.  NB. color 0
    r=. (height,width)$ (setalpha)`(trns&transparent)@.(*#trns) 2&gray2rgb , 4 4 4 4 #: a.i. , 1&rfilter (height,1+>.width%4) $ data
  elseif. 4=bit do.  NB. color 0
    r=. (height,width)$ (setalpha)`(trns&transparent)@.(*#trns) 4&gray2rgb , 16 16 #: a.i. , 1&rfilter (height,1+>.width%2) $ data
  elseif. 8=bit do.
    if. 0=color do.
      r=. (height,width)$ (setalpha)`(trns&transparent)@.(*#trns) 8&gray2rgb , a.i. , 1&rfilter (height,1+width) $ data
    else.
      r=. (height,width)$ (a.i.{.("1) a) setalpha 8&gray2rgb a.i. {:("1) a=. _2]\ , 2&rfilter (height,1+2*width) $ data
    end.
  elseif. do.
    'only 1 2 4 8 bit grayscale PNGs support' return.
  end.
elseif. 3=color do.
  if. 1=bit do.
    r=. (height,width)$ ipal{~ , #: a.i. , 1&rfilter (height,1+>.width%8) $ data
  elseif. 2=bit do.
    r=. (height,width)$ ipal{~ , 4 4 4 4 #: a.i. , 1&rfilter (height,1+>.width%4) $ data
  elseif. 4=bit do.
    r=. (height,width)$ ipal{~ , 16 16 #: a.i. , 1&rfilter (height,1+>.width%2) $ data
  elseif. 8=bit do.
    r=. (height,width)$ ipal{~ a.i. , 1&rfilter (height,1+width) $ data
  elseif. do.
    'only 1 2 4 8 bit palette PNGs support' return.
  end.
elseif. 6=color do.
  r=. (height,width)$ fliprgb le32inv , 4&rfilter (height,1+4*width) $ data
elseif. 2=color do.
  r=. (height,width)$ fliprgb (trns&transparent)^:(*#trns) le32inv , ({:a.),~("1) _3[\ , 3&rfilter (height,1+3*width) $ data
elseif. do.
  'invalid color type' return.
end.
r
)

NB. =========================================================
transparent=: 4 : 0
((255 0){~({.x)=y) setalpha y
)

NB. =========================================================
NB.*readpnghdr v read header from PNG file
NB. returns:  width height bit color compression filter interlace
readpnghdr=: 3 : 0
r=. readpnghdrall y
if. 2 ~: 3!:0 r do.
  0 pick r
end.
)

NB. =========================================================
NB.*readpngall v read PNG data
NB.
NB. y is PNG file, or PNG data
NB. returns:  bitsize, rows, columns, offset, sheader, data
readpnghdrall=: 3 : 0

try.
  dat=. 1!:11 (boxopen y),<0 29
  if. -. magic-:8{.dat do. 'not a PNG file' return. end.
  if. -. 0 0 0 13 -: a.i.4{.8}.dat do. 'not a PNG file' return. end.
  if. -. 'IHDR' -: 4{.12}.dat do. 'not a PNG file' return. end.
catch.
  dat=. 29{.y
  if. -. magic-:8{.dat do. 'file read error' return. end.
  if. -. 0 0 0 13 -: a.i.4{.8}.dat do. 'file read error' return. end.
  if. -. 'IHDR' -: 4{.12}.dat do. 'file read error' return. end.
end.

ihdr=. (16+i.13){dat
'bit color compression filter interlace'=. a.i.8}.ihdr

'width height'=. be32inv 8{.ihdr

(width,height,bit,color,compression,filter,interlace);dat
)
