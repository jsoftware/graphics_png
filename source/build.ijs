NB. build.ijs

writesourcex_jp_ '~Addons/graphics/png/source';'~Addons/graphics/png/png.ijs'

f=. 3 : 0
(jpath '~addons/graphics/png/',y) (fcopynew ::0:) jpath '~Addons/graphics/png/',y
)

f 'png.ijs'

f=. 3 : 0
(jpath '~Addons/graphics/png/',y) fcopynew jpath '~Addons/graphics/png/source/',y
(jpath '~addons/graphics/png/',y) (fcopynew ::0:) jpath '~Addons/graphics/png/source/',y
)

f 'manifest.ijs'
f 'history.txt'
