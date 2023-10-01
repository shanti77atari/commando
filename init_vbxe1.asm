//inicjalizacja vbxe
shape_vbxe=$00000
scr_vbxe=$10000			//(2 pages)
dane_vbxe=$40000
map_vbxe=$50000
znaki0_vbxe=$60000
znaki1_vbxe=$70000


xdl_vbxe=$38000
clear_vbxe=$38040
cp_znaki_vbxe=$38100	; konczy sie dokladnie przed pasek_vbxe
pasek_vbxe=$3817e		;zmieści się dokładnie $2fa=762 w pierwszej16,potrzeba jeszcze 840-762=78 na drugiej 16
duszki_vbxe=$3c666



			
			
			org $2000

				
ini0
			ldy #$5d
			mva #$80+[znaki0_vbxe>>14] (fx_ptr),y   //zestaw00
			rts
			
ini1
			ldy #$5d
			mva #$81+[znaki0_vbxe>>14] (fx_ptr),y   //zestaw01
			rts
			
ini2
			ldy #$5d
			mva #$82+[znaki0_vbxe>>14] (fx_ptr),y   //zestaw02
			rts
			
ini3
			ldy #$5d
			mva #$83+[znaki0_vbxe>>14] (fx_ptr),y   //zestaw03
			rts	
			
ini3a
			ldy #$5d
			mva #$80+[znaki1_vbxe>>14] (fx_ptr),y   //zestaw04
			rts	

ini3b
			ldy #$5d
			mva #$81+[znaki1_vbxe>>14] (fx_ptr),y   //zestaw05
			rts	

ini3c
			ldy #$5d
			mva #$82+[znaki1_vbxe>>14] (fx_ptr),y   //zestaw06
			rts	

ini3d
			ldy #$5d
			mva #$83+[znaki1_vbxe>>14] (fx_ptr),y   //zestaw07
			rts				

ini4
			ldy #$5d
			mva #$80+[map_vbxe>>14] (fx_ptr),y   //mapy
			rts	
			
ini4a
			ldy #$5d
			mva #$81+[map_vbxe>>14] (fx_ptr),y   //mapy
			rts				

ini4b
			ldy #$5d
			mva #$82+[map_vbxe>>14] (fx_ptr),y   //mapy
			rts	
			
ini4c
			ldy #$5d
			mva #$83+[map_vbxe>>14] (fx_ptr),y   //mapy
			rts	

ini4d
			ldy #$5d
			mva #$82+[dane_vbxe>>14] (fx_ptr),y   //mapy

			rts				

ini5		
			ldy #$5d
			mva #$80+[xdl_vbxe>>14] (fx_ptr),y   //xdl
			
			ldx #xdl_len-1
@			lda xdl_src,x
			sta $4000+[xdl_vbxe & $3fff],x
			dex
			bpl @-
			
	
//bcb cp_znaki			
			ldx #6*21-1
@			lda cp_znaki_src,x
			sta $4000+[cp_znaki_vbxe & $3fff],x
			dex
			bpl @-
			
			ldx #20
@			lda clear_src,x
			sta $4000+[clear_vbxe & $3fff],x
			dex
			bpl @-
		


//bcb paski			
			mwa #([pasek_vbxe & $3fff]+$4000) pom
@			ldy #20
@			lda pasek_src,y
			sta (pom),y
			dey
			bpl @-
			clc
			lda pom
			adc #21
			sta pom
			bcc *+4
			inc pom+1
			lda pom+1
			cmp #$80					;koniec 16KB
			bne @-1
			
			ldy #$5d
			mva #$81+[xdl_vbxe>>14] (fx_ptr),y   //xdl	next 16KB

			ldx #78
			mwa #$4000 pom
@			ldy #20
@			lda pasek_src,y
			sta (pom),y
			dey
			bpl @-
			clc
			lda pom
			adc #21
			sta pom
			bcc *+4
			inc pom+1
			dex					;koniec 16KB
			bne @-1

			
//bcb duszki			
			ldx #15
@			ldy #20
@			lda duszek_src,y
			sta (pom),y
			dey
			bpl @-
			clc
			lda pom
			adc #21
			sta pom
			bcc *+4
			inc pom+1
			dex
			bne @-1
			
			mva #1 duszek_src+20			;ostatni bcb
			ldy #20
@			lda duszek_src,y
			sta (pom),y
			dey
			bpl @-			
			
			ldy #$5d
			mva #0 (fx_ptr),y			;off window B
//ustawiamy kolory planszy				
			ldy	#$44
			mva	#$40	(fx_ptr),y+	; CSEL ,nr koloru
			mva	#1	(fx_ptr),y	; PSEL	,nr palety
			
			ldx #$40
@			ldy	#$46	; CR				;szary
			lda tab_color80
			sta	(fx_ptr),y		;RED
			iny
			lda tab_color80+1
			sta	(fx_ptr),y		;GREEN
			iny
			lda tab_color80+2
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			dex
			bne @-
			
			ldx #$40
@			ldy	#$46	; CR
			lda tab_color80+3					;czarny
			sta	(fx_ptr),y		;RED
			iny
			lda tab_color80+4
			sta	(fx_ptr),y		;GREEN
			iny
			lda tab_color80+5
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			dex
			bne @-		

			ldx #$40
@			ldy	#$46	; CR
			lda tab_color80+6					;zielony/niebieski
			sta	(fx_ptr),y		;RED
			iny
			lda tab_color80+7
			sta	(fx_ptr),y		;GREEN
			iny
			lda tab_color80+8
			sta	(fx_ptr),y		;BLUE, nr_koloru++
			dex
			bne @-					
			
					
			ldy #$5d
			mva #$80+[$40000>>14] (fx_ptr),y   //xdl+2, tu beda tablice, pierwsza czesc
			rts
			
ini6					
			ldy #$5d
			mva #$81+[$40000>>14] (fx_ptr),y   //xdl+2, tu beda tablice	 druga czesc	

			rts
			
ini7		
			ldy #$5d
			mva #0 (fx_ptr),y   //end			
			
			rts			

tab_color80
			dta 110,110,110	;szary
			.he 00,00,00		;czarny	
			dta 91,141,60		;zielony/niebieski

/*			.he 00,00,00		;czarny		
			;dta 82,65,32		;brazowy
			dta 78,60,0
			dta 110,110,110	;szary
			dta 91,141,60		;zielony  */
			

SCREEN_SZER=512			
							
//dlist dla VBXE
xdl_src
	dta	a($24),b(23)	; XDLC_OVOFF|XDLC_RTPL  ;24 puste linie
	dta	a($8862),b(160-1) ; XDLC_GMON|XDLC_RTPL|XDLC_OVADR|XDLC_END|XDLC_ATT  ; 192 linie w hires
	dta	a([37+16]*SCREEN_SZER+24)		;adres pamieci obrazu dla tych linii	
xdl_frame
	dta	b(scr_vbxe >> 16),a(SCREEN_SZER)		;3 bajt adresu obrazu=0,256=o ile bajtów skaczemy co linie
	dta a($ff11)			;paleta1+szerokosc 320 bajtów=$11, prio_default=$ff
	
xdl_len	equ	*-xdl_src

//rysuje pasek w buforze
pasek_src
			dta	a(0),b(znaki0_vbxe >> 16)			;adres zrodlowy=nr znaku, 1 bajt(=0zestaw0,=64 2 zestaw,=1283 zestaw,=192 4 zestaw)
												;2 bajt=nr znaku,3 bajt = ktora czworka zestawow 	
			dta	a(8),1		;odstęp w pamięci pomiędzy kolejnymi liniami <-4096..4095>, kolejność pobierania danych (1,-1)
			dta	a(0)						;adres docelowy dla operacji blittera 24bity, adres paska, kazdy z 21 paskow to 320*8=2560 bajtow
			dta	b(0)
			dta	a(512),1				;odleglość w pamięci pomiędzy kolejnymi liniami <-4096..4095>,skok pomiędzy danymi (-1,1)
			dta	a(8-1),8-1	;szerokosć obiektu-1(0,511),wysokosć obiektu-1(0,255)
			dta	$ff,0,0				;maska AND źródła,maska XOR źródła,maska AND wykrywania kolizji
			dta	0,0,8				;kopiowanie+next

			
//kopiuje numery znakow  i adresy ich rysowania do bcb pasek_vbxe			
cp_znaki_src
			dta a(0),b(map_vbxe >> 16)
			dta a(40),1
			dta a([pasek_vbxe & $ffff]+1),b([pasek_vbxe+1]>>16)
			dta a(840),21
			dta a(40-1),21-1
			dta $ff,0,0
			dta 0,0,8
			
			dta a($8000),b($40000>>16)			;adres tablic z adresami pamieci obrazu
			dta a(40*3),3							;po 3 bajty na adres
			dta a([pasek_vbxe & $ffff]+6),b([pasek_vbxe+6]>>16)			;najmlodszy bajt adresu
			dta a(840),21							;bcb co 21 bajtow 21*40=840
			dta a(40-1),21-1						;szerokosc i wysokosc
			dta $ff,0,0
			dta 0,0,8
			
			dta a($8001),b($40000>>16)			;adres tablic z adresami pamieci obrazu
			dta a(40*3),3							;po 3 bajty na adres
			dta a([pasek_vbxe & $ffff]+7),b([pasek_vbxe+7]>>16)			;sredni bajt adresu
			dta a(840),21							;bcb co 21 bajtow 21*40=840
			dta a(40-1),21-1						;szerokosc i wysokosc
			dta $ff,0,0
			dta 0,0,8
			
			dta a($8002),b($40000>>16)			;adres tablic z adresami pamieci obrazu
			dta a(40*3),3							;po 3 bajty na adres
			dta a([pasek_vbxe & $ffff]+8),b([pasek_vbxe+8]>>16)			;najstarszy bajt adresu
			dta a(840),21							;bcb co 21 bajtow 21*40=840
			dta a(40-1),21-1						;szerokosc i wysokosc
			dta $ff,0,0
			dta 0,0,8
//ktory z czworki poziomow			
			dta a([xdl_vbxe+xdl_len]&$ffff),b([xdl_vbxe+xdl_len]>>16)
			dta a(1),0
			dta a(pasek_vbxe & $ffff),b(pasek_vbxe>>16)
			dta a(840),21
			dta a(40-1),21-1
			dta 0,$40,0				;and=0, xor=00,40,80,c0 zaleznie od mapy
			dta 0,0,8
//ktora czworka poziomow 0,1,2,3 czy 4,5,6,7			
			dta a([xdl_vbxe+xdl_len]&$ffff),b([xdl_vbxe+xdl_len]>>16)
			dta a(1),0
			dta a([pasek_vbxe & $ffff]+2),b([pasek_vbxe+2]>>16)
			dta a(840),21
			dta a(40-1),21-1
			dta 0,$40,0				;and=0, xor=00,40,80,c0 zaleznie od mapy
			dta 0,0,8
			
//rysuje duszki	
duszek_src
			dta	a(0),0			;adres danych żródłowych w pamięci vbxe 24bity
			dta	a(24),1		;odstęp w pamięci pomiędzy kolejnymi liniami <-4096..4095>, kolejność pobierania danych (1,-1)
			dta	a(es&$ffff),b(1)						;adres docelowy dla operacji blittera 24bity	
			dta	a(512),1				;odleglość w pamięci pomiędzy kolejnymi liniami <-4096..4095>,skok pomiędzy danymi (-1,1)
			dta	a(24-1),21-1	;szerokosć obiektu-1(0,511),wysokosć obiektu-1(0,255)
			dta	$ff,0,0				;maska AND źródła,maska XOR źródła,maska AND wykrywania kolizji	
			dta	0,0,1+8	
//czysci ekran
clear_src
			dta a(0),0
			dta a(1),1
			dta a(es&$ffff),b(1)
			dta a(512),1
			dta a(320-1),160-1
			dta 0,0,0
			dta 0,0,0
			
					
			ini ini0		
			
			org $4000
			ins './orig/zestaw00.fnt'
			ini ini1
			
			org $4000
			ins './orig/zestaw01.fnt'
			ini ini2

			org $4000
			ins './orig/zestaw02.fnt'
			ini ini3	

			org $4000
			ins './orig/zestaw03.fnt'
			
			ini	ini3a
			org $4000
			ins './orig/zestaw04.fnt'
			ini ini3b
			org $4000
			ins './orig/zestaw05.fnt'
			ini ini3c
			org $4000
			ins './orig/zestaw06.fnt'
			ini ini3d
			org $4000
			ins './orig/zestaw07.fnt'
			
			ini ini4			
			org $4000
			ins './orig/l0n-map.bin'			
			org $6000
			ins './orig/l1n-map.bin'
			
			ini ini4a			
			org $4000
			ins './orig/l2n-map.bin'			
			org $6000
			ins './orig/l3n-map.bin'	

			ini ini4b			
			org $4000
			ins './orig/l4n-map.bin'			
			org $6000
			ins './orig/l5n-map.bin'
			
			ini ini4c			
			org $4000
			ins './orig/l6n-map.bin'			
			org $6000
			ins './orig/l7n-map.bin'	

			ini ini4d
			org $4000
			ins './orig/l0n-dane.bin'
			ins './orig/l1n-dane.bin'
			ins './orig/l2n-dane.bin'
			ins './orig/l3n-dane.bin'
			ins './orig/l4n-dane.bin'
			ins './orig/l5n-dane.bin'
			ins './orig/l6n-dane.bin'
			ins './orig/l7n-dane.bin'
			
			
			ini ini5		//xdl+blity


es=53*SCREEN_SZER+24+scr_vbxe			//poczatek pamieci ekranu
			org $4000
adz0						//przesuniecie=0,  40x3*21=2520b,   2520*4=10080
.rept	21,#
?linia=es+4096*:1
.rept 	40,#
			dta a([?linia+8*:1]&$ffff),b([?linia+8*:1]>>16)	
.endr			
.endr				
			
adz1						//przesuniecie=1,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*1			;rysuje 1 linie wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr				
			
adz2						//przesuniecie=2,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*2			;rysuje 2 linie wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr		

adz3						//przesuniecie=3,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*3			;rysuje 3 linie wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr		

			ini ini6
			
			org $4000
adz4						//przesuniecie=4,  40x3*21=2520b
.rept	21,#
?linia=es+4096*:1-512*4		;rysuje 4 linie wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr				
			
adz5						//przesuniecie=0,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*5			;rysuje 5 linii wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr				
			
adz6						//przesuniecie=0,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*6			;rysuje 6 linii wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr		

adz7						//przesuniecie=0,  40x3*21=2520b  
.rept	21,#
?linia=es+4096*:1-512*7			;rysuje 7 linii wyzej
			:40 dta a([?linia+8*#]&$ffff),b([?linia+8*#]>>16)	
.endr				
			
			ini ini7
			
			