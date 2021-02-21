import sys
import os
from PIL import Image, ImageSequence, ImageDraw
from itertools import groupby

def StoreByte(file,value):
	value&=0xff
	file.write(value.to_bytes(1,byteorder='little'))

chunk = [] 


def main():
	global chunk 

	buffer = []
	infile = open(sys.argv[1],"rb")
	a = infile.read()
	infile.close()

	for b in a:
		buffer.append(b)

	res = [list(g) for k, g in groupby(buffer)]

	outfile = open(sys.argv[2],"wb")
	for x in res:
		if len(x)==1:
			chunk.append(x[0])
		else:
			if len(chunk)!=0:
				index = 0
				# generate 128 byte chunks ( should be rare )
				oul = len(chunk)
				# generate > 128 byte chunks ( common case )
				if (oul>127):
					print("raw " + str(oul))
					while oul>127:
						StoreByte(outfile,127)
#						StoreByte(outfile,oul>>8)
						for b in range(0,oul):
							StoreByte(outfile,chunk[index])
							index+=1
						oul-=127

				StoreByte(outfile,oul)
				for b in range(0,oul):
					StoreByte(outfile,chunk[index])
					index+=1
				chunk = []

			#	repeat chunk 
			oul = len(x)
			if oul>127:
				while oul>127:
					StoreByte(outfile,127 | 0x80)
					StoreByte(outfile,x[0])
					oul-=127

			#	generate normal chunk . len , byte 
			StoreByte(outfile,oul | 0x80)
			StoreByte(outfile,x[0])


	#	last chunk 
	if len(chunk)!=0:
		oul = len(chunk)
		# generate > 128 byte chunks ( common case )
		StoreByte(outfile,oul)
		StoreByte(outfile,oul>>8)
		for b in range(0,oul):
			StoreByte(outfile,chunk[index])
			index+=1

	StoreByte(outfile,0x00)
	StoreByte(outfile,0x00)
	outfile.close()

if __name__ == '__main__':
   main()


