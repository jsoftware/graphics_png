NB. filter for encoding
NB. type None, for palette png
ffilter0=: 4 : 0
({.a.),"1 y return.
)

NB. filter for encoding
NB. type are None Sub Up Average Paeth
ffilter=: 4 : 0
NB. ({.a.),"1 y return.
y=. a.i. y
sy=. $y
r=. 0$0
prev=. ({:sy)#0
for_i. i.{.sy do.
  type=. 0
  iy=. i{y
  sum=. +/@signbyte iy
  sum=. sum, +/@signbyte sub=. 256&| iy - (-x)}.(x#0),iy
  sum=. sum, +/@signbyte up=. 256&| iy - prev
  sum=. sum, +/@signbyte ave=. 256&| iy - <.@-: prev+(-x)}.(x#0),iy
  sum=. | sum, +/@signbyte pae=. 256&| iy - paeth"1 ((-x)}.(x#0),iy),.prev,.((-x)}.(x#0),prev)
  type=. sum i.(<./sum)
  prev=. iy
  if. 1=type do.
    r=. r, type, sub
  elseif. 2=type do.
    r=. r, type, up
  elseif. 3=type do.
    r=. r, type, ave
  elseif. 4=type do.
    r=. r, type, pae
  elseif. do.
    r=. r, type, iy
  end.
end.
(0 1+sy)$a.{~r
)

NB. filter for decoding
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
    r=. r, prev=. prev (x rave) iy
  elseif. 4=i{f do.
    raw=. x#0
    prevbpp=. (-x)}.(x#0),prev
    for_j. i.#iy do.
      raw=. raw, 256&| (j{iy) + paeth (j{prev), (j{raw), j{prevbpp
    end.
    r=. r, prev=. x}.raw
  elseif. do.
    r=. r, prev=. iy
  end.
end.
sy$a.{~r
)

NB. Paeth Predictor
paeth=: 3 : 0
p=. +/ 1 1 _1 * y
y{~ (i.<./) |p-y
)

NB. reverse average filter
rave=: 1 : 0
:
raw=. m#0
for_i. i.#y do.
  raw=. raw, 256&| (i{y) + <. 2%~ (i{raw) + i{x
end.
m}.raw
)
