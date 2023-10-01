//test VBXE			
			icl 'atari.hea'
				
			opt h-
			
			org $70
			
zegar		org *+1
fx_ptr		org *+2
pom			org *+2
pom1		org *+2
pom2		org *+2
pom0		org *+1			

			opt h+

			icl 'init_vbxe.asm'
			icl 'init_vbxe1.asm'
			
			org $2000

nmi			bit nmist
			bpl *+5
			jmp (dliv)
			jmp (vbiv)	

vbi
			pha
			inc zegar
			mwa #dli0 dliv

			pla
			rti
			
dli0
irq			rti


run
			lda 20
			cmp 20
			beq *-2
			
			sei
			mva #0 nmien
			sta audctl			;inicjalizacja dźwięku
			mva #3 skctl
			
			mva #$fe portb
			mwa #vbi vbiv
			mwa #dli0 dliv
			
			mwa #nmi $fffa
			mwa #irq $fffe
			mwa #irq $fffc
			
			mva #64 nmien
			
l0			
			ldy	#$53	; BLITTER_BUSY
@			lda (fx_ptr),y
			bne @-	
			
			mwa #$e000+179*40 pom
			mva #7 vscrol0
			mva #$c0	level_m
			mva #6+1 	level_s
l2			
@			lda vcount
			cmp #41
			bne @-
			
			mwa pom pom1
			jsr draw_ekran									
			dec vscrol0
			bpl l1
			mva #7 vscrol0
			
			sec
			lda pom
			sbc #40
			sta pom
			bcs l1
			dec pom+1
			lda pom+1
			and #$1f
			cmp #$1f
			beq l0
					
l1		
			ldy	#$53	; BLITTER_BUSY
@			lda (fx_ptr),y
			bne @-	

			jmp l2
			



//rysuj pasek mapa=pom , x=nr paska
draw_ekran

			
			ldy #$5d
			mva #$80+[cp_znaki_vbxe >> 14] (fx_ptr),y
			mwa pom1 $4000+[cp_znaki_vbxe& $3fff]					;adres linii mapy , skad bedzie pobierac znaki
			
			lda vscrol0
			asl
			tax
			lda tab_vscrol0,x
			pha
			sta $4000+[cp_znaki_vbxe& $3fff]+21	
			lda tab_vscrol0+1,x
			tax
			sta $4001+[cp_znaki_vbxe& $3fff]+21	
			pla
			clc
			adc #1
			bcc *+4
			inx
			clc
			sta $4000+[cp_znaki_vbxe& $3fff]+42
			stx $4001+[cp_znaki_vbxe& $3fff]+42
			clc
			adc #1
			bcc *+3
			inx
			sta $4000+[cp_znaki_vbxe& $3fff]+63
			stx $4001+[cp_znaki_vbxe& $3fff]+63
			
			mva level_m $4010+[cp_znaki_vbxe& $3fff]+84			;która mapa 00=0,40=1,80=2,c0=3
			mva level_s $4010+[cp_znaki_vbxe& $3fff]+105			;ktora czworka map 6=0,1,2,3 7=4,5,6,7	
			

			mva #0 (fx_ptr),y
			
//wlacz blit'a			
			ldy	#$50	; BL_ADR0
			mva	#cp_znaki_vbxe&$ff	(fx_ptr),y+	; BL_ADR0			;najmlodszy bajt adresu
			mva	#[cp_znaki_vbxe>>8]&$ff	(fx_ptr),y+	; BL_ADR1		;nastepne bajty adresu
			mva	#cp_znaki_vbxe>>16	(fx_ptr),y+	; BL_ADR2
			mva	#1	(fx_ptr),y	; BLITTER_START				;wykonaj		
			
			rts
			
tab_vscrol0
.rept	4,#*2520
			dta a(adz0&$3fff+:1)
.endr
.rept	4,#*2520
			dta a(adz4&$3fff+$4000+:1)
.endr

vscrol0		dta b(0)
level_m		dta b(0)
level_s		dta b(0)


tab0		
			:21 dta a(#*320*8)
			
			
wait_vbl
			lda zegar
			cmp zegar
			beq *-2
			rts
			
			run run
			
			