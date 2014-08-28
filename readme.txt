zlib
====

This png addon needs zlib to write compressed png files.  When zlib
is un-available and not running under JQt, it will use uncompressed
png format.

For Linux, zlib should already installed by default in
most distros. If not, install using (debian and its dervitives)

sudo aptitude install zlib1g

For Windows, type the following in a j session to install zlib dll.

load 'png'
install_jpng_''
load 'png'
