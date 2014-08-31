zlib
====

This png addon requires zlib to read and write png files.  When zlib
is un-available, it will write uncompressed png format, and reading
png files will not be supported.

For Linux, zlib should already installed by default in most distros.
If not, install using (debian and its dervitives) in terminal.

$ sudo aptitude install zlib1g

For Windows, type the following in a J session to install zlib dll.

load 'png'
install_jpng_''
load 'png'
