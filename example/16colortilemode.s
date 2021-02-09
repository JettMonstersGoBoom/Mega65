
	//	16 color mode notes
	//	this sample shows using 16 color mode, with multiple palettes
	//	the colour ram is divided into 16 sets of colors $00-$0f set 0 $10-$1f set 1 etc. 
	
.cpu _45gs02

	//	boot header
	* = $2001
		.var addrStr = toIntString(Entry)

		.byte $09,$20 //End of command marker (first byte after the 00 terminator)
		.byte $0a,$00 //10
		.byte $fe,$02,$30,$00 //BANK 0
		.byte <end, >end //End of command marker (first byte after the 00 terminator)
		.byte $14,$00 //20
		.byte $9e //SYS
		.text addrStr
		.byte $00
	end:
		.byte $00,$00	//End of basic terminators

*=$2020
Entry:
	sei
	lda #$35
	sta $01

	lda #$41
	sta $00 //40 Mhz mode

	//	something to do with memory mapping, unclear 
	lda #$00
	tax 
	tay 
	taz 
	map
	eom

	//Enable VIC IV
	//	use knock code 
	lda #$47	
	sta $D02F 
	lda #$53
	sta $D02F 

	//Disable CIA and IRQ interrupts
	lda #$7f
	sta $DC0D 
	sta $DD0D 

	lda #$00
	sta $D01A 
	//Interupt control register

	//	disable C65 rom 
	lda #$70
	sta $D640
	nop

	//Turn Off H640 mode
	lda $D031
	and #%0111111
	sta $D031
	
	//Number of chars per ROW
	lda #40
	sta $D058 
	lda #20
	sta $D05E

	//	or-ing for clarity 
	lda #$1					//	enable CHR16 mode 2 bytes per char 
	ora #%00000110	//	enable full colour for both <256 and >256 
	sta $D054

	ldx #$00 
xl1:
	lda CHRMAP,x 
	sta $0800,x
	lda CHRMAP+256,x 
	sta $0900,x
	lda CHRMAP+512,x 
	sta $0A00,x
	lda CHRMAP+768,x 
	sta $0B00,x
	lda COLORMAP,x 
	sta $D800,x
	lda COLORMAP+256,x 
	sta $D900,x
	lda COLORMAP+512,x 
	sta $DA00,x
	lda COLORMAP+768,x 
	sta $DB00,x
	inx 
	bne xl1


	//	enable C64 MCM
	//	this allows us to use multiple palettes 
	lda $D016 
	ora #$10 
	sta $D016

	ldx #$00 
!:
	//	set colour ramp
	//	red
	lda COLORS,x	
	sta $D100,x 
	//	green
	lda COLORS+256,x
	sta $D200,x
	//	blue 
	lda COLORS+512,x
	sta $D300,x 
	inx
		bne !-

	lda #$00
	sta $D020 //set back color to index 0 
	sta $D021 //set back color to index 0


	ldx #<irq1
	ldy #>irq1
	stx $FFFE
	sty $FFFF
	lda $D01A
	ora #$01
	sta $D01A
	lda #$1B
	sta $D011
	asl $D019
	cli

!:
	jmp !-



irq1: {
	pha
	txa
	pha
	tya
	pha
	asl $D019

	lda #$F0
	sta $D012

	pla
	tay
	pla
	tax
	pla
	rti
}

COLORS:
	.import binary "data/grid.clut"

CHRMAP:
	.import binary "data/grid.map"

COLORMAP:
	.import binary "data/grid.atr"

* = $8000 "Chars"
	.import binary "data/grid.chrs"
