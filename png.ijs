coclass 'jpng'
zlib=: IFUNIX{::'zlib1.dll';unxlib 'z'
NOZLIB=: 0=(zlib,' zlibVersion >',(IFWIN#'+'),' x')&cd ::0:''
zcompress2=: (zlib, ' compress2 >',(IFWIN#'+'),' i *c *x *c x i')&cd
zuncompress=: (zlib, ' uncompress >',(IFWIN#'+'),' i *c *x *c x')&cd

magic=: 137 80 78 71 13 10 26 10{a.
ffilter0=: 4 : 0
({.a.),"1 y return.
)
ffilter=: 4 : 0
y=. a.i. y
sy=. $y
r=. 0$0
prev=. ({:sy)#0
for_i. i.{.sy do.
  type=. 0
  iy=. i{y
  if. (+/iy) > +/ sub=. 256&| iy - (-x)}.(x#0),iy do.
    type=. 1
    iy=. sub
  end.
  r=. r, type, iy
end.
(0 1+sy)$a.{~r
)
rfilter=: 4 : 0
f=. a.i. {."1 y
y=. a.i. }."1 y
sy=. $y
r=. 0$0
prev=. ({:sy)#0
for_i. i.{.sy do.
  iy=. i{y
  if. 1=i{f do.
    r=. r, prev=. , <. |: 256&| +/\"1 |: (-x)[\ iy
  elseif. 2=i{f do.
    r=. r, prev=. iy (256&|@:+) prev
  elseif. 3=i{f do.
    r=. r, prev=. <. 2%~ ((-x)}.(x#0), iy) + prev
  elseif. 4=i{f do.
    raw=. x#0
    prevbpp=. (-x)}.(x#0),prev
    for_j. i.#iy do.
      raw=. raw, 256&| (j{iy) + (j{prev) (j{raw) paeth j{prevbpp
    end.
    r=. r, prev=. x}.raw
  elseif. do.
    r=. r, prev=. iy
  end.
end.
sy$a.{~r
)
paeth=: 1 : 0
:
a=. m [ b=. x [ c=. y
p=. a+b-c
'pa pb pc'=. | p-a,b,c
if. (pa<:pb) *. pa<:pc do. a return.
elseif. pb<:pc do. b return.
elseif. do. c return.
end.
)

readpng=: 3 : 0

r=. readpnghdrall y
if. 2 = 3!:0 r do. return. end.
'nos dat'=. r
'width height bit color compression filter interlace'=. nos

if. NOZLIB do.
  'missing zlib' return.
end.
if. 0~:filter do.
  'invalid filter' return.
end.
if. 0~:interlace do.
  'interlace PNGs not supported' return.
end.
if. (-.bit e. 1 2 4 8) do.
  'only 1 2 4 8 bit depth supported' return.
end.
dat=. fread y
ie=. I. 'IEND' E. dat
if. 0=#ie do. 'missing IEND' return. end.
dat=. ({.ie){. dat
if. 3=color do.
  ip=. I. 'PLTE' E. dat
  if. 0=#ip do. 'mssing PLTE' return. end.
  p=. {.ip-4
  len=. {.be32inv (p+i.4){dat
  crc=. ((len+8+p)+i.4){dat
  d=. (4+len){.(4+p)}.dat
  if. -. crc-:(be32 crc32 d) do. 'crc32 error' return. end.
  ipal=. fliprgb le32inv , ({.a.),~("1) _3]\ len{.(8+p)}.dat
end.

id=. I. 'IDAT' E. dat
if. 0=#id do. 'missing IDAT' return. end.
id=. id-4
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
datalen=. , (1+((3=color){1,~3+6=color)*width)*height
data=. ({.datalen)#{.a.
if. 0~: rc=. zuncompress data;datalen;idat;#idat do.
  'zlib uncompression error' return.
end.
data=. ({.datalen){.data
if. color e. 0 4 do.
  if. (4=color) > bit e. 8 16 do.
    'only 8 and 16 bit grayscale can have alpha channel' return.
  end.
  if. 1=bit do.
    r=. (height,width)$ 1&gray2rgb , #: a.i. , 1&rfilter (height,1+>.width%8) $ data
  elseif. 2=bit do.
    r=. (height,width)$ 2&gray2rgb , 4 4 4 4 #: a.i. , 1&rfilter (height,1+>.width%4) $ data
  elseif. 4=bit do.
    r=. (height,width)$ 4&gray2rgb , 16 16 #: a.i. , 1&rfilter (height,1+>.width%2) $ data
  elseif. 8=bit do.
    if. 0=color do.
      r=. (height,width)$ 8&gray2rgb , a.i. , 1&rfilter (height,1+width) $ data
    else.
      r=. (height,width)$ 8&gray2rgb , a.i. , }:("1) _2]\ , 2&rfilter (height,1+2*width) $ data
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
  r=. (height,width)$ alpha17 fliprgb le32inv , 4&rfilter (height,1+4*width) $ data
elseif. 2=color do.
  r=. (height,width)$ fliprgb le32inv , ({.a.),~("1) _3[\ , 3&rfilter (height,1+3*width) $ data
elseif. do.
  'invalid color type' return.
end.
r
)
readpnghdr=: 3 : 0
r=. readpnghdrall y
if. 2 ~: 3!:0 r do.
  0 pick r
end.
)
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
writepng=: 4 : 0

dat=. x
'file cmp'=. 2 {. (boxopen y), <_1

if3=. (3=#$dat) *. 3={:$dat
if. if3 do.
  dat=. 256 256 256&#. dat
end.

(boxopen file) 1!:2~ cmp encodepng_unx dat
)
encodepng_unx=: 4 : 0
cmp=. (_1=x){x,6
wh=. |. sy=. $y

pal=. ~. ,y
bit=. 1 2 4 8 16 {~ +/ 2 4 16 256 < # pal
if. (16>bit)*.((bit%~*/8,wh)>4*#pal) do.
  y=. sy $ a.{~ pal i. ,y
  ipal=. , }:@Endian@(2&ic)"0 fliprgb pal
  if. 1=bit do.
    y=. a.{~ #.@(_8&(]\))"1 a.i.y
  elseif. 2=bit do.
    y=. a.{~ 4&#.@(_4&(]\))"1 a.i.y
  elseif. 4=bit do.
    y=. a.{~ 16&#.@(_2&(]\))"1 a.i.y
  end.
  lines=. , 1&ffilter0 y
  magic, (png_header wh,bit, 3), ('PLTE' png_chunk ipal), ('IDAT' png_chunk cmp zlib_stream`uczlib_stream@.NOZLIB lines), ('IEND' png_chunk '')
else.
  lines=. , 3&ffilter ,"2 }:@Endian@(2&ic)"0 fliprgb y
  magic, (png_header wh,8, 2), ('IDAT' png_chunk cmp zlib_stream`uczlib_stream@.NOZLIB lines), ('IEND' png_chunk '')
end.
)
png_chunk=: 4 : 0
(be32 #y), x, y, be32 crc32 x, y
)
png_header=: 3 : 0
'IHDR' png_chunk (,be32"0 [ 2{.y), ((2}.y), 0 0 0){a.
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
install=: 3 : 0
if. -. IFWIN do. return. end.
require 'pacman'
'rc p'=. httpget_jpacman_ 'http://www.jsoftware.com/download/', z=. 'winlib/',(IF64{::'x86';'x64'),'/zlib1.dll'
if. rc do.
  smoutput 'unable to download: ',z return.
end.
(<jpath'~bin/zlib1.dll') 1!:2~ 1!:1 <p
1!:55 ::0: <p
smoutput 'done'
EMPTY
)
gray2rgb=: 4 : 0
if. 1=x do.
  <.y*16bffffff
else.
  ($y)$ 256#.("1) _3]\ 255<. (64 16 1{~2 4 8 i.x) * 3#,y
end.
)
ENDIAN=: ('a'={.2 ic a.i.'a')
be32=: ,@:(|."1)@(_4&(]\))^:ENDIAN@:(2&ic)
be32inv=: (_2&ic)@:(,@:(|."1)@(_4&(]\))^:ENDIAN)
le32=: ,@:(|."1)@(_4&(]\))^:(-.ENDIAN)@:(2&ic)
le32inv=: (_2&ic)@:(,@:(|."1)@(_4&(]\))^:(-.ENDIAN))
adler32=: [: ({: (23 b.) 16&(33 b.)@{.) _1 0 + [: ((65521 | +)/ , {.) [: (65521 | +)/\. 1 ,~ a. i. |.
NB, png checksum
crc32=: <.@:((2^32)&|)^:IF64 @: (((i.32) e. 32 26 23 22 16 12 11 10 8 7 5 4 2 1 0)&(128!:3))
readpng_z_=: readpng_jpng_
writepng_z_=: writepng_jpng_
readpnghdr_z_=: readpnghdr_jpng_
