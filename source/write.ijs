NB.   writepng     write PNG file from RGB data

NB. =========================================================
NB.*writepng v write png file from RGB data
NB.
NB. Form:  data writepng filename [;compression]
NB. compression: 0 to 9

writepng=: 4 : 0

dat=. x
'file cmp'=. 2 {. (boxopen y), <_1

if3=. (3=#$dat) *. 3={:$dat
if. if3 do.
  dat=. setalpha 256&#. dat
end.

if. USEQTPNG do.
  dat writeimg_jqtide_ (>file);'png';'quality';_1
elseif. USEJAPNG do.
  if. 805> ".}.(i.&'/' {. ])9!:14'' do.
    dat writeimg_ja_ (>file);'png';'quality';_1
  else.
    writeimg_ja_ dat;(>file);'png'
  end.
elseif. USEJNPNG do.
  writeimg_jnet_ dat;(>file);'png'
elseif. USEPPPNG do.
  dat writeimg_pplatimg_ (>file)
elseif. do.
  (boxopen file) 1!:2~ cmp encodepng_unx dat
end.
)

NB. =========================================================
encodepng_unx=: 4 : 0
cmp=. (_1=x){x,NOZLIB_jzlib_{6 2 NB. 2 for NOZLIB assume lz can help
wh=. |. sy=. $y

opaque=. *./ 255= , getalpha y
if. opaque do. y=. 0&setalpha y end.

pal=. ~. ,y
bit=. 1 2 4 8 16 {~ +/ 2 4 16 256 < # pal

NB. palette for small image is larger than truecolor because PLTE is not compressed
if. (16>bit)*.((bit%~*/8,wh)>4*#pal) do.
  if. -.opaque do.
    alfa=. a.{~ getalpha pal
    pal=. 0&setalpha pal
    y=. 0&setalpha y
  end.
  y=. sy $ ,a.{~ pal i. y
  ipal=. , }:@Endian@(2&ic)"0 fliprgb pal
  if. 1=bit do.
    y=. a.{~ #.@(_8&(]\))"1 a.i.y
  elseif. 2=bit do.
    y=. a.{~ 4&#.@(_4&(]\))"1 a.i.y
  elseif. 4=bit do.
    y=. a.{~ 16&#.@(_2&(]\))"1 a.i.y
  end.
NB. do not use filter for palette png, factor 4 is arbitary
  if. 4 > (*/wh) % #pal do.
    lines=. , 1&ffilter0 y
  else.
    lines=. , 1&ffilter y
  end.
  if. opaque do.
    magic, (png_header wh,bit, 3), ('PLTE' png_chunk ipal), ('IDAT' png_chunk cmp&zlib_compress_jzlib_ lines), ('IEND' png_chunk '')
  else.
    magic, (png_header wh,bit, 3), ('PLTE' png_chunk ipal), ('tRNS' png_chunk alfa), ('IDAT' png_chunk cmp&zlib_compress_jzlib_ lines), ('IEND' png_chunk '')
  end.
else.
  if. opaque do.
    lines=. , 3&ffilter ,"2 }:@Endian@(2&ic)"0 fliprgb y
    magic, (png_header wh,8, 2), ('IDAT' png_chunk cmp&zlib_compress_jzlib_ lines), ('IEND' png_chunk '')
  else.
    lines=. , 4&ffilter ,"2 Endian@(2&ic)"0 fliprgb y
    magic, (png_header wh,8, 6), ('IDAT' png_chunk cmp&zlib_compress_jzlib_ lines), ('IEND' png_chunk '')
  end.
end.
)

NB. =========================================================
NB. chunk is length type data crc32
NB. length     4      4    n     4
png_chunk=: 4 : 0
(be32 #y), x, y, be32 crc32 x, y
)

NB. =========================================================
NB. header for 8 bit depth palette or truecolor
png_header=: 3 : 0
'IHDR' png_chunk (,be32"0 [ 2{.y), ((2}.y), 0 0 0){a.
)
