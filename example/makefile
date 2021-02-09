
KICK = java -cp ..\tools\kickassembler-5.16-65ce02.i.jar kickass.KickAssembler65CE02  -vicesymbols -showmem  -bytedump

all: 16colortilemode.prg 

data\grid.map: data\grid.bmp
	python ..\tools\tilemizer.py -m=8000 -b4 -o=data\grid -t=data\grid.bmp

16colortilemode.prg:	data\grid.map 16colortilemode.s
	$(KICK) 16colortilemode.s

run: 16colortilemode.prg
	..\tools\m65.exe -l COM6 -F -r 16colortilemode.prg

clean:
	rm 16colortilemode.prg 
	rm data\grid.map 
	rm data\grid.chrs 
	rm data\grid.atr
