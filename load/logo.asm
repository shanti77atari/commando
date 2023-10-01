//logo 

			org $2000
; Detect VBXE
fx_detect
			mwa	#$d600	fx_ptr
			jsr	fx_detect_1
			beq	fx_detect_exit
			inc	fx_ptr+1
fx_detect_1
			ldy	#$40	; CORE_VERSION
			lda	(fx_ptr),y
			cmp	#$10	; FX 1.xx
			bne	fx_detect_exit
			iny	; MINOR_VERSION
			lda	(fx_ptr),y
			and	#$70
			cmp	#$20	; 1.2x
fx_detect_exit
			rts
					


_in0				
			jsr fx_detect
			beq @+
			jmp (10)
@			equ *	

			mva #0 559
			sta dmactl

			ldy #$5d
			mva #$80+[scr_vbxe>>14] (fx_ptr),y
			rts
			
_in1		
			ldy #$5d
			mva #$81+[scr_vbxe>>14] (fx_ptr),y
			rts
			
_in2		
			ldy #$5d
			mva #$82+[scr_vbxe>>14] (fx_ptr),y
			rts

_in3		
			ldy #$5d
			mva #$83+[scr_vbxe>>14] (fx_ptr),y
			rts		

_in4		
			ldy #$5d
			mva #$84+[scr_vbxe>>14] (fx_ptr),y
			rts			

_in5
			mwa #paleta pom
			ldy	#$44
			mva	#0	(fx_ptr),y+	; CSEL ,nr koloru
			mva	#2	(fx_ptr),y	; PSEL	,nr palety
			
			lda fx_ptr+1
			sta _lg0+2
			sta _lg1+2
			sta _lg2+2
			ldy #$46
			sty _lg0+1
			iny
			sty _lg1+1
			iny
			sty _lg2+1
			

			ldx #4
			ldy #0
@			iny
			iny
			lda (pom),y
_lg0		sta $ffff
			dey
			lda (pom),y
_lg1		sta $ffff
			dey
_lg2		sta $ffff
			:4 iny
			bne @-
			inc pom+1
			dex
			bne @-

			ldy #$5d
			mva #0 (fx_ptr),y

			ldy	#$40	; VIDEO_CONTROL
			mva	#1+4	(fx_ptr),y	; xdl_enabled
			iny
			mva	#0	(fx_ptr),y	; XDL_ADR0			podaj adres 24bitowy
			iny
			mva	#0	(fx_ptr),y	; XDL_ADR1
			iny
			mva	#2	(fx_ptr),y	; XDL_ADR2	

			rts			
			
paleta
			ins './load/paleta.dat'
			
			ini _in0
			org $4000
			ins './load/load_0.dat'
			
			ini _in1
			org $4000
			ins './load/load_1.dat'
			
			ini _in2
			org $4000
			ins './load/load_2.dat'
			
			ini _in3
			org $4000
			ins './load/load_3.dat'
			
			ini _in4
			org $4000

			dta	a($24),b(23+12)	; XDLC_OVOFF|XDLC_RTPL  ;24 puste linie
			dta	a($8862),b(160-1-1) ; XDLC_GMON|XDLC_RTPL|XDLC_OVADR|XDLC_END|XDLC_ATT  ; 192 linie w hires
			dta	a(0)		;adres pamieci obrazu dla tych linii	
			dta	b(1),a(320)		;3 bajt adresu obrazu=0,256=o ile bajtów skaczemy co linie
			dta a($ff21)			;paleta1+szerokosc 320 bajtów=$11, prio_default=$ff
			
			ini _in5