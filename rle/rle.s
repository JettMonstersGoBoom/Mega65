

.label MEGA_DMA_lsb=$D700
.label MEGA_DMA_msb=$D701
.label MEGA_DMA_bank=$D702
.label MEGA_DMA_state=$D703

.label RLE_SOURCE=$f8

.macro RLE_GET() {
	lda ((RLE_SOURCE)),z
	inz 
	bne skip
	inc RLE_SOURCE+1
skip:
}


DMA_BUFFER:
DMA_COMMAND:	.byte 0 
DMA_SIZE:			.word 0 
DMA_SOURCE:		.byte	0,0,0
RLE_DEST:			.byte 0,0,0
DMA_MODULOS:	.dword 0 			//	ignored 


RLEDecompressRoutine:
{
	lda #$00
	sta DMA_SIZE+1
	sta	MEGA_DMA_state
	sta MEGA_DMA_bank
	lda RLE_SOURCE 
	sta DMA_SOURCE 
	lda RLE_SOURCE+1 
	sta DMA_SOURCE+1
	lda RLE_SOURCE+2 
	sta DMA_SOURCE+2

	ldz #$00

next:

	RLE_GET()
	//	if top byte is zero 
	cmp #$00
	bne noexit 
	//	quit
	rts

noexit:
	sta DMA_SIZE

	//	check top bit set for RLE run 
	and #$80 
	bne run 

	clc
	tza 
	adc RLE_SOURCE
	sta DMA_SOURCE
	lda RLE_SOURCE+1
	adc #0 
	sta DMA_SOURCE+1

	//	set command to COPY
	lda #$0
	sta DMA_COMMAND

	//	DMA 
	lda #>DMA_BUFFER
	sta MEGA_DMA_msb 
	lda #<DMA_BUFFER
	sta MEGA_DMA_lsb
	//	done

	//	offset the source to the next control byte
	clc 
	tza
	adc DMA_SIZE 
	taz
	lda RLE_SOURCE+1
	adc DMA_SIZE+1
	sta RLE_SOURCE+1
	//	next 
	jmp nextchunk

run:
	//	mask top bit off
	lda DMA_SIZE
	and #$7f 
	sta DMA_SIZE

	//	set command to fill
	lda #$3
	sta DMA_COMMAND

	//	FILL with byte 
	RLE_GET()
	sta DMA_SOURCE

	//	DMA
	lda #>DMA_BUFFER
	sta MEGA_DMA_msb 
	lda #<DMA_BUFFER
	sta MEGA_DMA_lsb
	//	done
	
nextchunk:
	clc 
	lda RLE_DEST
	adc DMA_SIZE 
	sta RLE_DEST
	lda RLE_DEST+1
	adc DMA_SIZE+1
	sta RLE_DEST+1
	jmp next
}

