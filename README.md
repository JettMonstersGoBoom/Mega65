# Mega65
Utils and samples for Mega65


# Tilemizer

python script to convert images to tile,color,and map data.

will detect x&y flipped tiles and remove duplicated tiles. 

python tools\tilemizers.py 
options 
	-b4		set output to 4bpp 16 color mode 
	-b8		set output to 8bpp 256 color mode
	-o=<outputprefix>	output files will be
										outputprefix.chrs ( tile data )
										outputprefix.clut ( color data )
										outputprefix.map ( screen data )
										outputprefix.atr ( color/attribute data )
										outputprefix.info ( width and height of map data )
	-t=<inputfile>		will convert specified image into Mega65 tiles and output the data




example
python tools\tilemizer.py -b4 -o=data\mega -t=data\mega.bmp
