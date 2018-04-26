NB. init.ijs

NB. supports PNG files
NB.
NB. These are .png files in 24-bit true color format.
NB.
NB. readpng and writepng use RGB values (single numbers).
NB.
NB. writepng also accepts RGB triples
NB.
NB. main functions:
NB.
NB.   readpng      read PNG file, returning RGB data
NB.   writepng     write PNG file from RGB data
NB.   readpnghdr   read header from PNG file

require 'arc/zlib'

coclass 'jpng'

NB. RGBSEQ_j_ does not apply here,
NB. png is always RGBA: 255 = red
NB. in J: 255 = blue

IFJNET=: (IFJNET"_)^:(0=4!:0<'IFJNET')0
3 : 0''
if. (IFJNET +. IFIOS +. UNAME-:'Android') do. USEQTPNG=: USEPPPNG=: 0 end.
if. 0~: 4!:0<'USEQTPNG' do.
  if. IFQT do.
    USEQTPNG=: 1
  elseif. -. ((UNAME-:'Darwin') *. ((0;'') e.~ <2!:5 'QT_PLUGIN_PATH')) +. ((UNAME-:'Linux') *. (0;'') e.~ <2!:5 'DISPLAY') do.
    if. (0 < #1!:0 jpath '~addons/ide/qt/qtlib.ijs') *. ('"',libjqt,'" dummyfunction + n')&cd :: (2={.@cder) '' do.
      require 'ide/qt/qtlib'
      USEQTPNG=: 1
    else.
      USEQTPNG=: 0
    end.
  elseif. do.
    USEQTPNG=: 0
  end.
end.
if. 0~: 4!:0<'USEJAPNG' do.
  USEJAPNG=: IFJA
end.
if. 0~: 4!:0<'USEJNPNG' do.
  USEJNPNG=: IFJNET
end.
if. 0~: 4!:0<'USEPPPNG' do.
  USEPPPNG=: (0 < #1!:0 jpath '~addons/graphics/pplatimg/pplatimg.ijs')
  require^:USEPPPNG 'graphics/pplatimg'
  if. USEPPPNG *. UNAME-:'Linux' do.
    USEPPPNG=: (LIBGDKPIX_pplatimg_,' dummyfunction + n')&cd :: (2={.@cder) ''
  end.
end.
EMPTY
)

magic=: 137 80 78 71 13 10 26 10{a.
