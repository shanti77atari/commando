
/*			org $600
dl_load		.he 70,70,70,70,70
			dta $46,a(txt_load)
			dta $41,a(dl_load)
			
txt_load	dta d'** COMMANDO **  VBXE'

ini_title
			lda 20
			cmp 20
			beq *-2
			mwa #dl_load 560
			rts

			ini ini_title

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
					


_init				
			jsr fx_detect
			beq @+
			jmp (10)
@			equ *	  */

chd0=$3c
chd1=$1c		;żółty?		
			
			org $2000
_init			
//COPY SHAPE		
			ldy #$5d
			mva #$80+[shape_vbxe>>14] (fx_ptr),y
			
	
			mwa #$4000 pom1			;miejsce docelowe
			mwa #$8000+[192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 0 x2
			
			
			mwa #$8000+[24+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 1
			mwa #$8000+[48+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 2
			mwa #$8000+[72+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 3
			
			
			mwa #$8000+[96+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 4
			mwa #$8000+[120+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 5
			mwa #$8000+[144+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 6
			mwa #$8000+[168+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 7

			
			mwa #$8000+[192*62] pom	
			jsr copy_shape				;shape 8
			mwa #$8000+[24+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 9
			mwa #$8000+[48+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 10
			mwa #$8000+[72+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 11
			mwa #$8000+[96+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 12
			mwa #$8000+[120+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 13
			mwa #$8000+[144+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 14
			mwa #$8000+[168+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 15
						
			mwa #$8000+[192*41] pom	
			jsr copy_shape				;shape 16
			mwa #$8000+[24+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 17
			mwa #$8000+[48+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 18
			mwa #$8000+[72+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 19
			mwa #$8000+[96+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 20
			mwa #$8000+[120+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 21
			mwa #$8000+[144+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 22
			mwa #$8000+[168+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 23
						
			mwa #$8000+[192*20] pom	
			jsr copy_shape				;shape 24
			mwa #$8000+[24+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 25
			mwa #$8000+[48+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 26
			mwa #$8000+[72+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 27
			mwa #$8000+[96+192*20] pom	;gdzie zaczynamy
			mva #chd1 ch_d+1
			jsr copy_shape				;shape 28		O-napis (ostatnia litera)
			mva #chd0 ch_d+1
			mwa #$8000+[120+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 29
			mwa #$8000+[144+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 30
			mwa #$8000+[168+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 31
			
			rts

_init1			
			ldy #$5d
			mva #$81 (fx_ptr),y
	
			mwa #$4000 pom1			;miejsce docelowe
			mwa #$8000+[192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 32 x2
			mwa #$8000+[24+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 33
			mwa #$8000+[48+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 34
			mwa #$8000+[72+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 35
			mwa #$8000+[96+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 36
			mwa #$8000+[120+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 37
			mwa #$8000+[144+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 38
			mwa #$8000+[168+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 39
						
			mwa #$8000+[192*62] pom	
			jsr copy_shape				;shape 40
			mwa #$8000+[24+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 41
			mwa #$8000+[48+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 42
			mwa #$8000+[72+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 43
			mwa #$8000+[96+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 44
			mwa #$8000+[120+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 45
			mwa #$8000+[144+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 46
			mwa #$8000+[168+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 47
						
			mwa #$8000+[192*41] pom	
			jsr copy_shape				;shape 48
			mwa #$8000+[24+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 49
			mwa #$8000+[48+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 50
			mwa #$8000+[72+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 51
			mwa #$8000+[96+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 52
			mwa #$8000+[120+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 53
			mwa #$8000+[144+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 54
			mwa #$8000+[168+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 55
						
			mwa #$8000+[192*20] pom	
			jsr copy_shape				;shape 56
			mwa #$8000+[24+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 57
			mwa #$8000+[48+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 58
			mwa #$8000+[72+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 59
			mwa #$8000+[96+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 60
			mwa #$8000+[120+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 61
			mwa #$8000+[144+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 62
			mwa #$8000+[168+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 63
			
			rts			
			

_init2			
			ldy #$5d
			mva #$82 (fx_ptr),y
	
			mwa #$4000 pom1			;miejsce docelowe
			mwa #$8000+[192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 64 x2
			mwa #$8000+[24+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 65
			mwa #$8000+[48+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 66
			mwa #$8000+[72+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 67
			mwa #$8000+[96+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 68
			mwa #$8000+[120+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 69
			mwa #$8000+[144+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 70
			mwa #$8000+[168+192*83] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 71
						
			mwa #$8000+[192*62] pom	
			jsr copy_shape				;shape 72
			mwa #$8000+[24+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 73
			mwa #$8000+[48+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 74
			mwa #$8000+[72+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 75
			mwa #$8000+[96+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 76
			mwa #$8000+[120+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 77
			mwa #$8000+[144+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 78
			mwa #$8000+[168+192*62] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 79
						
			mwa #$8000+[192*41] pom	
			jsr copy_shape				;shape 80
			mwa #$8000+[24+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 81
			mwa #$8000+[48+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 82
			mwa #$8000+[72+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 83
			mwa #$8000+[96+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 84
			mwa #$8000+[120+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 85
			mwa #$8000+[144+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 86
			mwa #$8000+[168+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 87
						
			mwa #$8000+[192*20] pom	
			jsr copy_shape				;shape 88
			mwa #$8000+[24+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 89
			mwa #$8000+[48+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 90
			mwa #$8000+[72+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 91
			mwa #$8000+[96+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 92
			mwa #$8000+[120+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 93
			mwa #$8000+[144+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 94
			mwa #$8000+[168+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 95

			rts				


_init3			
			ldy #$5d
			mva #$83 (fx_ptr),y
	
			mwa #$4000 pom1			;miejsce docelowe
			mwa #$8000+[192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 96 x2
			mwa #$8000+[24+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 97
			mwa #$8000+[48+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 98
			mwa #$8000+[72+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 99
			mwa #$8000+[96+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 100
			mwa #$8000+[120+192*41] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 101
			mwa #$8000+[144+192*41] pom	;gdzie zaczynamy
			mva #chd1 ch_d+1
			jsr copy_shape				;shape 102		C-napis (pierwsza litera)
			mwa #$8000+[168+192*41] pom	;gdzie zaczynamy			
			jsr copy_shape				;shape 103		OM			
			mwa #$8000+[192*20] pom	
			jsr copy_shape				;shape 104		MM
			mwa #$8000+[24+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 105		A
			mwa #$8000+[48+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 106		N
			mwa #$8000+[72+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 107   	DO
			mwa #$8000+[96+192*20] pom	;gdzie zaczynamy
			mva #chd0 ch_d+1			
			jsr copy_shape				;shape 108
			mwa #$8000+[120+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 109
			;mwa #$8000+[144+192*20] pom	;gdzie zaczynamy
			mwa #celownik+24*20 pom
			jsr copy_shape1				;shape 110
			mwa #$8000+[168+192*20] pom	;gdzie zaczynamy
			jsr copy_shape				;shape 111		;pusty

			jsr set_colors0
			jsr set_colors0b
			
			ldy	#$44
			mva	#0	(fx_ptr),y+	; CSEL ,nr koloru
			mva	#1	(fx_ptr),y+	; PSEL	,nr palety		
			mva #78 (fx_ptr),y+
			mva #60 (fx_ptr),y+
			mva #00 (fx_ptr),y				;kolor4 = background (brązowy)

			jmp end_init


set_colors0b	
			ldy	#$44
			mva	#1+28	(fx_ptr),y+	; CSEL ,nr koloru   (żółty)
			mva	#1	(fx_ptr),y	; PSEL	,nr palety
			
			ldx #0
@			ldy	#$46	; CR
			lda tab_color0b,x
			sta	(fx_ptr),y		;RED
			iny
			inx
			lda tab_color0b,x
			sta	(fx_ptr),y		;GREEN
			iny
			inx
			lda tab_color0b,x
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			inx
			cpx #3*3
			bcc @-
			rts

tab_color0b
			.he 00,00,00		;  (5)
			dta 140,81,41		;
			dta 239,243,115		;
			dta 78,60,0		;background(brazowy)  (1)

set_colors0	
			ldy	#$45
			mva	#1	(fx_ptr),y	; PSEL	,nr palety
			
			ldx #0
			mva #1 pom0
			
@			lda pom0
			
			ldy #$44
			sta	(fx_ptr),y	; CSEL ,nr koloru
			clc
			adc #4
			sta pom0
			
			ldy	#$46	; CR
			lda #171
			sta	(fx_ptr),y		;RED
			iny
			sta	(fx_ptr),y		;GREEN
			iny
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			
			ldy	#$46	; CR
			lda tab_color0,x
			sta	(fx_ptr),y		;RED
			iny
			inx
			lda tab_color0,x
			sta	(fx_ptr),y		;GREEN
			iny
			inx
			lda tab_color0,x
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			inx
			
			ldy	#$46	; CR
			lda #0
			sta	(fx_ptr),y		;RED
			iny
			sta	(fx_ptr),y		;GREEN
			iny
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			
			cpx #16*3
			bcc @-
			rts


tab_color0
			dta 0,0,0	;black

			dta 255,255,255	;1=white			;pomijamy dwa pierwsze kolory

			dta 116,54,45
			;dta 137,64,54		;2=red

			dta 103,162,169
			;dta 122,191,199	;3=cyan

			dta 117,59,147
			;dta 138,70,174		;4=purple

			dta 85,143,55		;green		x0,85
			;dta 104,169,65		;5=green

			dta 52,41,137		;blue
			;dta 62,49,162		;6=blue

			dta 176,187,96
			;dta 208,220,113	;7=yellow

			dta 122,80,31
			;dta 144,95,37		;8=orange

			dta 78,60,0
			;dta 92,71,0			;9=brown

			dta 158,101,92
			;dta 187,119,109	;10=pink

			dta 72,72,72		;11=dark gray
			;dta 85,85,85		;11=dark gray
			
			dta 108,108,108
			;dta 128,128,128	;12=medium gray

			dta 146,198,115
			;dta 172,234,136	;13=lite green

			dta 105,95,185
			;dta 124,112,218	;14=lite blue

			dta 171,171,171	;15=lite gray

		


end_init			
			ldy #$5d
			mva #0 (fx_ptr),y			;wylacz pamiec vbxe

			rts

copy_shape
			ldx #21			;21 linii
@			ldy #24-1			;24-1 kolumn
@			lda (pom),y
			beq *+4
ch_d		ora #$3c	;#$78
			sta (pom1),y
			dey
			bpl @-
			sec			;+1
			lda pom1
			adc copy_shape+3
			sta pom1
			bcc *+4
			inc pom1+1
			sec
			lda pom
			sbc #192
			sta pom
			lda pom+1
			sbc #0
			sta pom+1
			dex
			bne @-1
			
			mva #0 pom1		;wyrownaj do strony
			inc pom1+1
			
			rts

copy_shape1
			ldx #21			;21 linii
@			ldy #24-1			;24-1 kolumn
@			lda (pom),y
			beq *+4
			ora #$78
			sta (pom1),y
			dey
			bpl @-
			sec			;+1
			lda pom1
			adc copy_shape1+3
			sta pom1
			bcc *+4
			inc pom1+1
			sec
			lda pom
			sbc #24
			sta pom
			lda pom+1
			sbc #0
			sta pom+1
			dex
			bne @-1
			
			mva #0 pom1		;wyrownaj do strony
			inc pom1+1
			
			rts

			
			
			org $8000
			ins './sprites/sprites0.spr'
			
			ini _init
			
			org $8000
			ins './sprites/sprites1.spr'
			
			ini _init1		

			org $8000
			ins './sprites/sprites2.spr'
			
			ini _init2			
			
			org $8000
			ins './sprites/sprites3.spr'
celownik			
			ins './sprites/celownik.dat'
			
			ini _init3	


			