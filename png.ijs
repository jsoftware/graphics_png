coclass 'jpng'

zlib=: IFUNIX{::'zlib1.dll';unxlib 'z'
NOZLIB=: 0=(zlib,' zlibVersion >+ x')&cd ::0:''
zcompress2=: (zlib, ' compress2 >+ i *c *x *c x i')&cd

flipreadrgb=: Endian^:RGBSEQ_j_
flipwritergb=: Endian^:RGBSEQ_j_

magic=: 137 80 78 71 13 10 26 10{a.
readpng=: 3 : 0

r=. readpnghdrall y
if. 2 = 3!:0 r do. return. end.
'nos dat'=. r
'width height bit color compression filter interlace'=. nos
'not implemented' 13!:8[3

pal=. off {. dat
dat=. off }. dat

if. bits e. 1 4 8 do.
  pal=. 256 #. flipreadrgb"1 a. i. _4 }: \ (shdr+14) }. pal
  dat=. , ((#~ ^.&256) 2^bits) #: a. i. dat
  pal {~ |. (rws,cls){.(rws,cls+(32%bits)|-cls) $ dat
elseif. bits=24 do.
  cl4=. 4 * >. (3*cls) % 4
  |. (rws,cls) {. 256 #. flipreadrgb"1 a.i. _3 [\"1 (rws,cl4) $ dat
elseif. 1 do.
  'only 1,4,8 and 24-bit PNGs supported, this is ',(":bits),'-bit'
end.
)
readpnghdr=: 3 : 0
r=. readpnghdrall y
if. 2 ~: 3!:0 r do.
  0 pick r
end.
)
readpnghdrall=: 3 : 0

try.
  dat=. 1!:1 boxopen y
  if. -. magic-:8{.dat do. 'not a PNG file' return. end.
  if. -. 4 0 0 0 -: a.i.4{.8}.dat do. 'not a PNG file' return. end.
  if. -. 'IHDR' -: 4{.12}.dat do. 'not a PNG file' return. end.
catch.
  dat=. y
  if. -. magic-:8{.dat do. 'file read error' return. end.
  if. -. 4 0 0 0 -: a.i.4{.8}.dat do. 'file read error' return. end.
  if. -. 'IHDR' -: 4{.12}.dat do. 'file read error' return. end.
end.

ihdr=. (16+i.13){dat
'bit color compression filter interlace'=. a.i.8}.ihdr

toi=. 256&#.@(a.&i.)@(|."1)
'width height'=. toi _4]\ 8{.ihdr

if. +./filter,interlace,(bit~:8),(color~:2) do.
  'only 24-bit truecolor supported' return.
end.

(width,height,bit,color,compression,filter,interlace);dat
)
writepng=: 4 : 0

dat=. x
'file cmp'=. 2 {. (boxopen y), <_1

if3=. (3=#$dat) *. 3={:$dat
if. if3 do.
  dat=. 256 256 256&#. dat
end.

if. -.NOZLIB do.
  (boxopen file) 1!:2~ cmp encodepng_unx dat
elseif. IFQT do.
  (boxopen file) 1!:2~ cmp encodepng_qt dat
elseif. IFWIN do.
  (boxopen file) 1!:2~ cmp encodepng_unx dat
elseif. do.
  (boxopen file) 1!:2~ cmp encodepng_unx dat
end.
)

encodepng_qt=: 4 : 0
cmp=. (_1=x){x,6
(fliprgb^:(-.RGBSEQ_j_) alpha27 y) putimg_jqtide_ 'png';'quality';cmp
)
big endian 4-byte
be32=: endian@:(2&ic)

crc32=: <.@:((2^32)&|)^:IF64 @: (((i.32) e. 32 26 23 22 16 12 11 10 8 7 5 4 2 1 0)&(128!:3))
png_chunk=: 4 : 0
(be32 #y), x, y, be32 crc32 x, y
)
png_header=: 3 : 0
'IHDR' png_chunk (,be32"0 y), 8 2 0 0 0{a.
)

encodepng_unx=: 4 : 0
cmp=. (_1=x){x,6
wh=. |.$y
y=. fliprgb^:(RGBSEQ_j_) y
lines=. , ({.a.),"1 ,"2 }:@Endian@(2&ic)"0 y
magic, (png_header wh), ('IDAT' png_chunk cmp zlib_stream`uczlib_stream@.NOZLIB lines), ('IEND' png_chunk '')
)

zlib_stream=: 4 : 0
len=. ,12+>.1.001*#y
buf=. ({.len)$' '
assert. 0= zcompress2 buf ; len ; y ; (#y) ; x
({.len){.buf
)
uczlib_stream=: 4 : 0
MAX_DEFLATE=. 16bffff
segments=. (-MAX_DEFLATE) <\ y
blocks=. ; 0&deflate_block&.> }:segments
blocks=. blocks, 1&deflate_block >@{:segments
(16b78 1 {a.) , blocks , be32 adler32 y
)

deflate_block=: 4 : 0
n=. #y
(x{a.),(Endian 1&ic n),(Endian 1&ic 0 (26 b.) n), y
)

adler32=: [: ({: (23 b.) 16&(33 b.)@{.) _1 0 + [: ((65521 | +)/ , {.) [: (65521 | +)/\. 1 ,~ a. i. |.
writepng_z_=: writepng_jpng_
