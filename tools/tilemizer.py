import sys
import os
from PIL import Image, ImageSequence, ImageDraw

def StoreByte(value):
	global binaryData
	value&=0xff
	binaryData.write(value.to_bytes(1,byteorder='little'))

def StoreByteSwapped(value):
	global binaryData
	value&=0xff
	a = (value>>4) | ((value&0xf)<<4)
	binaryData.write(a.to_bytes(1,byteorder='little'))


def StoreWord(value):
	global binaryData
	value&=0xffff
	binaryData.write(value.to_bytes(2,byteorder='little'))


class Settings:
	def __init__(self):
		self.tile_width = 16
		self.tile_height = 8
		self.offset = 0x200
		self.output = "4bpp"
		self.mask = 0xf 
		self.outname = "output"

# split into tiles

def Tilemize(name):
	global binaryData,attrib,index,settings

	image = Image.open(name)
	(w, h) = image.size
	tiles = []
	map = []
	attribs = []	

	(mw,mh) = (w/settings.tile_width,h/settings.tile_height)

	if mw.is_integer()==False:
		print("map width isn't evenly divisible by " + str(settings.tile_width))
	if mh.is_integer()==False:
		print("map height isn't evenly divisible by " + str(settings.tile_height))

	# store the width and height of the map
	binaryData = open(settings.outname + ".info", 'wb')
	StoreWord(int(mw))
	StoreWord(int(mh))
	binaryData.close()

	# chop into tiles
	for ty in range(0,h,settings.tile_height):
		for tx in range(0,w,settings.tile_width):
			# for each type of char 
			blank = []
			blank_x = []
			blank_y = []
			blank_xy = []

			index = -1
			# default attribs for 4bpp
			if settings.output == "4bpp":
				attrib = 0x0f08
			else:
				attrib = 0x0f00

			palette_index = 0
			# check non flipped
			for py in range(0,settings.tile_height):
				for px in range(0,settings.tile_width):
					p = image.getpixel((tx+px,ty+py))
					blank.append(p & settings.mask)
					# pull palette index if not currently 0 
					if (p&0xf0)>0:
						palette_index = p>>4
			# set palette attribs
			attrib|=palette_index<<12

			#	check if we have this tile
			if blank in tiles:
				index = tiles.index(blank)
			# check x flipped
			if index == -1:
				for py in range(0,settings.tile_height):
					for px in range(0,settings.tile_width):
						p = image.getpixel((tx+(settings.tile_width-1-px),ty+py)) & settings.mask
						blank_x.append(p)
				#	lets see if we have this tile flipped in X
				if blank_x in tiles:
					index = tiles.index(blank_x)
					#	set flipped attributes
					attrib|=1<<6

			# check y flipped
			if index == -1:
				for py in range(0,settings.tile_height):
					for px in range(0,settings.tile_width):
						p = image.getpixel((tx+px,(ty+(settings.tile_height-1-py)))) & settings.mask
						blank_y.append(p)
				#	lets see if we have this tile flipped in Y
				if blank_y in tiles:
					index = tiles.index(blank_y)
					#	set flipped attributes
					attrib|=1<<7

			# check xy flipped
			if index == -1:
				for py in range(0,settings.tile_height):
					for px in range(0,settings.tile_width):
						p = image.getpixel((tx+(settings.tile_width-1-px),(ty+(settings.tile_height-1-py)))) & settings.mask
						blank_xy.append(p)
				#	lets see if we have this tile flipped in X&Y
				if blank_xy in tiles:
					index = tiles.index(blank_xy)
					#	set flipped attributes
					attrib|=1<<6
					attrib|=1<<7

			#	if we've never seen this one , add it 
			if (index==-1):
				index = len(tiles)
				tiles.append(blank)

			#	fill the map data with data we got above
			map.append(index)
			attribs.append(attrib)

	print(str(len(tiles)) + " tiles found")

	#	save 4bpp char data ( or 8 bpp )
	binaryData = open(settings.outname + ".chrs", 'wb')
	for t in tiles:
		for py in range(0,settings.tile_height):
			if settings.output == "8bpp":
				for px in range(0,settings.tile_width):
					b = t[px+(py*settings.tile_width)]
					StoreByte(b)	
			if settings.output == "4bpp":
				for px in range(0,settings.tile_width,2):
					a = t[px+(py*settings.tile_width)]
					b = t[(1+px)+(py*settings.tile_width)]
					StoreByte((b<<4) | a)	

	binaryData.close()

	#	save map / screen data
	binaryData = open(settings.outname + ".map", 'wb')
	for q in map:
		StoreWord(q+settings.offset)
	binaryData.close()

	#	save colors / attributes
	binaryData = open(settings.outname + ".atr", 'wb')
	for q in attribs:
		StoreWord(q)
	binaryData.close()

	# save palette data
	# nybble swapped and in seperate channels 
	binaryData = open(settings.outname + ".clut", 'wb')
	rgb = image.getpalette()
	for r in range(0,256):
		StoreByteSwapped(rgb[(r*3)+0])
	for r in range(0,256):
		StoreByteSwapped(rgb[(r*3)+1])
	for r in range(0,256):
		StoreByteSwapped(rgb[(r*3)+2])

	binaryData.close()	

def main():
	global binaryData,attrib,index,settings
	settings = Settings()

	for a in range(1,len(sys.argv)):
		arg = sys.argv[a]
		print(arg)

		if "-b4" in arg:
			settings.tile_width = 16
			settings.output = "4bpp"
			settings.mask = 0xf
		elif "-b8" in arg:
			settings.tile_width = 8
			settings.output = "8bpp"
			settings.mask = 0xff
		elif arg.startswith("-o="):
			settings.outname = arg[3:]
		elif arg.startswith("-t="):
			name = arg[3:]
			Tilemize(name)



if __name__ == '__main__':
   main()


