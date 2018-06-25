
USEQTPNG_jpng_=: USEJAPNG_jpng_=: USEJNPNG_jpng_=: USEPPPNG_jpng_=: 0
load 'graphics/png'

test=: 3 : 0

NB. write
dat=. 200 300 3 $ 0 0 255
dat writepng jpath '~temp/blue.png'
dat=. 200 300 3 $ 255 0 0
dat writepng jpath '~temp/red.png'
dat=. 200 300 3 $ , |."1 [ 256 256 256 #: ?.60000#16b100000
dat writepng jpath '~temp/random.png'

NB. read
dat=. readpng jpath '~Addons/graphics/png/test/lena.png'
dat writepng jpath '~temp/lena.png'
dat=. readpng jpath '~temp/red.png'
assert. dat -: setalpha 256&#. 200 300 3 $ 255 0 0

NB. read basic formats
for_f. pngs do.
echo >f
dat=. readpng jpath '~Addons/graphics/png/test/',>f
assert. 4= 3!:0 dat
dat writepng jpath '~temp/',>f
end.
)

pngs=: <;._2 (0 : 0)
coin1.png
coin.png
pnggrad8rgb.png
basn0g01.png
basn0g02.png
basn0g04.png
basn0g08.png
basn3p01.png
basn3p02.png
basn3p04.png
basn3p08.png
basn4a08.png
basn6a08.png
f00n0g08.png
f00n2c08.png
f01n0g08.png
f01n2c08.png
f02n0g08.png
f02n2c08.png
f03n0g08.png
f03n2c08.png
f04n0g08.png
f04n2c08.png
f99n0g04.png
z00n2c08.png
z03n2c08.png
z06n2c08.png
z09n2c08.png
)

test''
