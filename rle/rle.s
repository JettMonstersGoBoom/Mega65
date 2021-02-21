

.segment ZP
RLE_DMA:
RLE_SOURCE:	.dword	0
RLE_DEST:		.dword	0

.macro RLE_GET() {
	ldz #$00
	lda ((RLE_SOURCE)),z
	inc RLE_SOURCE
	bne skip
	inc RLE_SOURCE+1
skip:
}

.segment CODE 

DMA_BUFFER:
DMA_COMMAND:	.byte 0 
DMA_SIZE:			.word 0 
DMA_SOURCE:		.byte	0,0,0
DMA_DEST:			.byte 0,0,0
DMA_MODULOS:	.dword 0 			//	ignored 

RLEDecompressRoutine:
{
	lda #$00
	sta DMA_SIZE+1
	sta	dma_state
	//	copy dest 
	lda RLE_DEST
	sta DMA_DEST
	lda RLE_DEST+1
	sta DMA_DEST+1
	lda RLE_DEST+2
	sta DMA_DEST+2

	ldz #$00

next:

	RLE_GET()
	sta DMA_SIZE
	//	if top byte is zero 
	cmp #$00 
	bne noexit 
	rts

noexit:

	and #$80 
	bne run 
	//	copy source pointers
	lda RLE_SOURCE
	sta DMA_SOURCE
	lda RLE_SOURCE+1
	sta DMA_SOURCE+1
	lda RLE_SOURCE+2
	sta DMA_SOURCE+2

	//	COPY
	lda #$0
	sta DMA_COMMAND

	lda #$00 
	sta dma_bank
	lda #>DMA_BUFFER
	sta dma_hi 
	lda #<DMA_BUFFER
	sta dma_lo

	//	offset the source to the next control byte
	clc 
	lda RLE_SOURCE
	adc DMA_SIZE 
	sta RLE_SOURCE 
	lda RLE_SOURCE+1
	adc DMA_SIZE+1
	sta RLE_SOURCE+1
	lda RLE_SOURCE+2
	adc #$00
	sta RLE_SOURCE+2

	jmp nextchunk

run:
	//	mask top bit off
	lda DMA_SIZE
	and #$7f 
	sta DMA_SIZE

	//	fill
	lda #$3
	sta DMA_COMMAND
	//	get value to fill with 
	RLE_GET()
	sta DMA_SOURCE
	//	FILL 
	lda #$00 
	sta dma_bank
	lda #>DMA_BUFFER
	sta dma_hi 
	lda #<DMA_BUFFER
	sta dma_lo
	
nextchunk:
	clc 
	lda DMA_DEST
	adc DMA_SIZE 
	sta DMA_DEST
	lda DMA_DEST+1
	adc DMA_SIZE+1
	sta DMA_DEST+1
	lda DMA_DEST+2
	adc #$00
	sta DMA_DEST+2

	jmp next
exit:
}

