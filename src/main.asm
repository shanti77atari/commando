;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Commando for the C64 disassembled.
; https://gitlab.com/ricardoquesada/c64-commando-2084/tree/orig
;
; Game logic
;
; Comments by riq
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Note about levels:
; LVL0 -> Is "level 1" in the game
; LVL1 -> Is "level 2" in the game
; LVL2 -> Not present
; LVL3 -> Is "level 3" in the game
;
; LVL2:
; Apparently, four levels were designed for Commando.
; There is a lot of data/code that proves this, like:
; - Action table. See: LVL2_ACTION_TBL
; - Row trigger table. See: LVL2_TRIGGER_ROW_TBL
; - Sprites X pos. See: LVL2_SPRITE_X_LO_TBL / LVL2_SPRITE_HI_TBL
; - Charset mask. See: LVL2_CHARSET_MASK_TBL
; - The "main charset (included in co2.asm) was probably the one designed for
;   LVL2. Although part of it was overwritten with letters.
; What in theory is missing to have a working LVL2 is the map, and if fix the
; charset.

;
; **** CONSTANTS ****
;
TOTAL_MAX_SPRITES = 16

;
; **** ZP FIELDS ****
;
f4C = $4C
;
; **** ZP ABSOLUTE ADDRESSES ****
;
a01 = $01
a14 = $14
a41 = $41
aA5 = $A5
aAE = $AE
aD7 = $D7
aDA = $DA
;
; **** ZP POINTERS ****
;
p19 = $19                       ;Stores current hero animation, but seems unused
p1A = $1A
p22 = $22                       ;sprite to create: X lo
p23 = $23
p24 = $24                       ;rows that trigger sprite type init
p25 = $25
p26 = $26                       ;sprite to create: X hi
p27 = $27
p28 = $28                       ;what sprite type to create at row
p29 = $29
p2A = $2A                       ;charset attributes: background priority, collision, etc.
p2B = $2B
p5D = $5D                       ;Used by music
p5E = $5E                       ;Used by music
p5F = $5F                       ;Used by music
p60 = $60                       ;Used by music
pF7 = $F7
pF8 = $F8
pFB = $FB                       ;$FB/$FC: different meanings depending to the game state
pFC = $FC                       ; On Hiscore, it points to Screen RAM
                                ; During the game, it points to the Actions table
pFD = $FD                       ;But $FC/$FD is also used during the game to point
                                ; to the level data and is uses with $2A to determine
                                ; the sprite-background priority/collision
pFE = $FE
;
; **** FIELDS ****
;
f0000 = $0000
fD040 = $D040
fDB48 = $DB48
fDB98 = $DB98
fE087 = $E087
fE348 = $E348
fE398 = $E398
fE3F8 = $E3F8
;
; **** ABSOLUTE ADDRESSES ****
;
a003D = $003D                   ;Tmp var used by SORT_SPRITES_BY_Y
a003F = $003F                   ;Tmp var used by SORT_SPRITES_BY_Y
SPRITE_IDX_TBL = $004B          ;$4B-$5A sprite index, used in raster multiplexer
a00A7 = $00A7
VIC_SPRITE_IDX = $00A8          ;Index used for sprite pos (e.g: $D000,idx) in raster intr.
a00C9 = $00C9                   ;Tmp var used by SORT_SPRITES_BY_Y
a0400 = $0400                   ;Used by GET_RANDOM
a0401 = $0401                   ;Used by GET_RANDOM
V_SCROLL_BIT_IDX = $0402        ;pixels scrolled vertically: 0-7
V_SCROLL_ROW_IDX = $0403        ;index to the row in the level: 0 means end of scroll (top of map)
V_SCROLL_DELTA = $0404          ;How many pixels needs to get scrolled. $0: no scroll needed, $ff: -1 one pixel
LVL_MAP_MSB = $0405             ;MSB address for the level map: lvl0=$60, lvl1=$80, lvl3=$a0
IRQ_ADDR_LO = $0406
IRQ_ADDR_HI = $0407
GAME_TICK = $040A               ;Incremented from main loop
RASTER_TICK = $040B             ;Incremented from raster routine
SPRITES_X_HI00 = $040D          ;MSB for X pos
SPRITES_X_HI01 = $040E
SPRITES_X_HI04 = $0411
SPRITES_X_HI05 = $0412
SPRITES_X_LO00 = $041D          ;LSB for X pos
SPRITES_X_LO01 = $041E
SPRITES_X_LO04 = $0421
SPRITES_X_LO05 = $0422
SPRITES_Y00 = $042D
SPRITES_Y01 = $042E
SPRITES_Y04 = $0431
SPRITES_Y05 = $0432
SPRITES_BKG_PRI00 = $043D
SPRITES_BKG_PRI01 = $043E
SPRITES_BKG_PRI04 = $0441
SPRITES_BKG_PRI05 = $0442
SPRITES_COLOR00 = $044D         ;primary color of sprite
SPRITES_COLOR01 = $044E
SPRITES_COLOR04 = $0451
SPRITES_COLOR05 = $0452
SPRITES_PTR00 = $045D           ;frame to be used by sprite
SPRITES_PTR01 = $045E
SPRITES_PTR04 = $0461
SPRITES_PTR05 = $0462
SPRITES_DELTA_X00 = $046D       ;pixels to move horizontally for hero (neg or pos)
SPRITES_DELTA_X01 = $046E
SPRITES_DELTA_X04 = $0471
SPRITES_DELTA_X05 = $0472
SPRITES_DELTA_Y00 = $047D       ;pixels to move vertically for hero (neg or pos)
SPRITES_DELTA_Y01 = $047E
SPRITES_DELTA_Y04 = $0481
SPRITES_DELTA_Y05 = $0482
SPRITES_TYPE00 = $048D
SPRITES_TYPE01 = $048E
SPRITES_TYPE04 = $0491
SPRITES_TYPE05 = $0492
SPRITES_TMP_A01 = $049D         ;Used by different thigns. Only 15 slots (all but 0)
SPRITES_TMP_A04 = $04A0         ;referenced in throw grenade
SPRITES_TMP_A05 = $04A1         ;Used to link sprites together (?)
SPRITES_TMP_B05 = $04AC         ;Used as index to delta_tbl and more. Only 11 slots (enemies only)
SPRITES_TMP_C05 = $04B7         ;Used for timer: Only 11 slots (enemies only)
SPRITES_PREV_Y00 = $04C2        ;Used by raster interrupt. Is the Y value before applying delta.
                                ; Valid for all sprites expect for the Hero (SPRITE00)
FIRE_COOLDOWN = $04DF           ;reset with $ff
HERO_ANIM_MOV_IDX = $04E0       ;Movement anim for hero: left,right,up,down,diagonally,etc.
                                ; See: SOLDIER_ANIM_FRAMES
a04E1 = $04E1                   ;Bullet speed idx (???)
BKG_COLOR0 = $04E2
BKG_COLOR1 = $04E3
BKG_COLOR2 = $04E4
COUNTER1 = $04E6
a04E7 = $04E7                   ;unused
TRIGGER_ROW_IDX = $04E8         ;If equal to row index, create object
a04E9 = $04E9                   ;unused
a04EA = $04EA                   ;Used in mortar guy animation
POW_GUARDS_KILLED = $04EC       ;Number of POW guard killed. When == 2, "Free POW" anim is executed
POW_SPRITE_IDX = $04ED          ;Holds the sprite idx used by POW sprite
a04EE = $04EE                   ;Hero is moving up (unused)
ENEMIES_IN_FORT = $04EF         ;How many enemies are inside the fort/warehouse
TMP_SPRITE_X_LO = $04F0         ;Temp sprite-X LSB for current sprite
TMP_SPRITE_Y = $04F1            ;ditto for Y
TMP_SPRITE_X_HI = $04F2         ;ditto for X MSB
LEVEL_NR = $04F3
ANY_ENEMY_IN_MAP = $04F4        ;How many enemies are in the map. If 0, grenades are not thrown
IS_LEVEL_COMPLETE = $04F5       ;0: game in progress, 1:lvl complete. Exit animation finished (unused apparently)
IS_ANIM_EXIT_DOOR = $04F7       ;1: hero goes to exit door animation in progress
SCORE_LSB = $04F8
SCORE_MSB = $04F9
a04FD = $04FD                   ;unused
GRENADES = $04FF
LIVES = $0500
a0501 = $0501                   ;unused
a0502 = $0502                   ;unused
IS_HERO_DEAD = $0503            ;0: hero alive, 1:was shot, 2:fell down in trench
SHOOT_FREQ_MASK = $0504         ;How frequent soliders can shoot
HISCORE_IS_BULLET_ANIM = $0505  ;1: if the bullet in hiscore is being animated
HISCORE_NAME = $0506            ;8 chars reserved for the hiscore name ($0506-$050E)
HISCORE_NAME_IDX = $050F        ;Index to the hiscore name
HISCORE_SELECTED_CHAR = $0510   ;Selected char in hiscore
HISCORE_IS_CHAR_ANIM = $0511    ;1: if the selected char in hiscore is being animated
HISCORE_ANIM_CHAR_COUNTER = $0512       ;Counter to the selected char animation in hiscore
aE34E = $E34E
aE34F = $E34F
aE350 = $E350
aE351 = $E351
aE359 = $E359
aE35A = $E35A
aE361 = $E361
aE362 = $E362
aE36A = $E36A
aE36B = $E36B
aE36C = $E36C
aE36D = $E36D
aE3FA = $E3FA
aE3FB = $E3FB
aE3FF = $E3FF
aFFC0 = $FFC0
;
; **** POINTERS ****
;
pD800 = $D800
pD829 = $D829
pD882 = $D882
pE000 = $E000
pE029 = $E029
pE082 = $E082
;
; **** EXTERNAL JUMPS ****
;
e03F0 = $03F0
eF00A = $F00A
;
; **** PREDEFINED LABELS ****
;

        * = $0800

        .BYTE $00,$0B,$08,$0A,$00,$9E,$32,$30
        .BYTE $36,$31,$00,$00,$00

        LDA #$00
        TAY
        STA aA5
        STA aAE
        LDA #$09
        JSR s0828
        JSR s083D
        JSR eF00A       ;set charset: copy from e000-efff to d000-dfff
        JSR s083D       ; defined in "co2.asm"
        JSR s0828
        JMP BOOT

s0828   LDA #$01
        TAX
        TAY
        NOP
        NOP
        NOP
        LDA #$00
        NOP
        NOP
        NOP
        LDA #$00
        LDX #$FF
        LDY #$FF
        JMP e03F0       ;Load file. Defined in "commando.asm"

s083D   SEI
b083E   LDA a01
        EOR #$02        ;#%00000010
        STA a01
        RTS

        ; FIXME: unused, remove
        .BYTE $E0,$09,$D0,$F5,$20,$AD,$35,$20
        .BYTE $57,$0A,$20

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
BOOT    ;$0850
        SEI
        LDA #<NMI_HANDLER
        STA $0318    ;NMI
        LDA #>NMI_HANDLER
        STA $0319    ;NMI
        CLI

        ; FIXME: Probably this is not really needed. In fact, it generates
        ; a small artifact at the end of LVL1, since it is overwriting the
        ; data
        LDX #$00     ;#%00000000
_L00    LDA RESET_ROUTINE,X
        STA $8000,X  ;Sets the reset routine (CBM80)
        INX
        CPX #$09     ;#%00001001
        BNE _L00

        JSR SETUP_VIC_BANK
        JSR SET_SIGHT_SPRITE
        JSR INIT_RANDOM

        ; Sprite Y pos used in raster multiplexer
        LDX #$10
_L01    TXA
        STA SPRITE_IDX_TBL,b,X
        DEX
        BPL _L01

        LDA #$00     ;#%00000000
        STA a0502
        STA a0501

START                   ;$0883
        LDA #$A5        ;Set initial starting row
        STA V_SCROLL_ROW_IDX
        JSR SETUP_LEVEL
        JSR SETUP_SCREEN
        JSR SETUP_IRQ

        ; Display main title screen
        LDA #$00        ;Song to play (main theme)
        JSR MUSIC_INIT
        JSR SCREEN_MAIN_TITLE

        JSR s5006       ;Music stop?
        LDA #$00        ;#%00000000
        STA SCORE_LSB
        STA SCORE_MSB
        STA V_SCROLL_BIT_IDX
        STA LEVEL_NR
        STA $D01D    ;Sprites Expand 2x Horizontal (X)
        STA $D017    ;Sprites Expand 2x Vertical (Y)
        LDA #$05     ;#%00000101
        STA GRENADES
        STA LIVES

START_LEVEL          ;$08B8
        LDA #$A5     ;#%10100101
        STA V_SCROLL_ROW_IDX
        LDA #$00     ;Song to play (main theme)
        JSR MUSIC_INIT

        ; Restart after life lost
RESTART
        JSR SETUP_LEVEL
        JSR SETUP_SCREEN
        JSR SETUP_IRQ

        ; Main loop
GAME_LOOP            ;$08CB
        JSR WAIT_RASTER_AT_BOTTOM
        LDA V_SCROLL_DELTA
        BEQ _L00
        CLC
        ADC V_SCROLL_BIT_IDX
        AND #$07     ;#%00000111
        STA V_SCROLL_BIT_IDX
        CMP #$07     ;#%00000111
        BNE _L00
        DEC V_SCROLL_ROW_IDX
        LDA #$00     ;#%00000000
        STA a04E9
        JSR APPLY_DELTA_MOV
        INC a04E9
        JSR LEVEL_DRAW_VIEWPORT
        INC a04E9
        JMP GAME_LOOP

_L00    INC GAME_TICK
        JSR APPLY_DELTA_MOV
        JSR SORT_SPRITES_BY_Y
        JSR TRY_THROW_GRENADE
        JSR ANIM_ENEMIES
        JSR RUN_ACTIONS
        JSR ANIM_HERO

        LDA IS_HERO_DEAD
        BNE HERO_DIED
        JSR HANDLE_JOY2
        LDA IS_ANIM_EXIT_DOOR
        BNE _L01
        JSR CHECK_COLLISION
_L01    LDA SPRITES_Y00
        CMP #$5A
        BNE GAME_LOOP

        LDA #$14     ;Points won after beating lvl
        JSR SCORE_ADD
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        CMP #$03     ;#%00000011
        BNE _L02

        ;Play animation at end of Level 3
        LDA #$09     ;#%00001001
        JSR SFX_PLAY
        JSR SET_FORT_ON_FIRE

_L02    LDA #$02     ;Song to play (Level complete)
        JSR MUSIC_INIT
        JSR PRINT_LVL_COMPLETE
        INC LEVEL_NR

        ; Since LVL2 was removed from the game, when LVL2 is reached,
        ; the level is changed to LVL3.
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        CMP #$02     ;#%00000010
        BNE _L03
        INC LEVEL_NR

_L03    JMP START_LEVEL

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Animate hero "is dead"
HERO_DIED               ;b0953
        LDA IS_HERO_DEAD
        CMP #$02     ;Died of fall in trench/water?
        BNE _L01

        ; Hero fell down in trench
        INC COUNTER1
        LDA COUNTER1
        CMP #$14     ;#%00010100
        BCC _L00
        CMP #$50     ;#%01010000
        BCS _L03
        LDA #$CC     ;Hero fall down in trench frame #1
        STA SPRITES_PTR00
        JMP GAME_LOOP

_L00    LDA #$CB     ;Hero fall down in trench frame #0
        STA SPRITES_PTR00
        JMP GAME_LOOP

        ; Hero was shot
_L01    INC COUNTER1
        LDA COUNTER1
        CMP #$14     ;#%00010100
        BCC _L02
        CMP #$50     ;#%01010000
        BCS _L03
        LDA #$B8     ;Hero was shot: frame #1
        STA SPRITES_PTR00
        JMP GAME_LOOP

_L02    LDA #$DD     ;Hero was shot: frame #0
        STA SPRITES_PTR00
        JMP GAME_LOOP

        ; End of "died" animation. Decrease life.
_L03    DEC LIVES
        JSR SCREEN_REFRESH_LIVES
        LDA LIVES
        BEQ GAME_OVER
        JMP RESTART

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
GAME_OVER
        LDX #$06     ;#%00000110
_L00    TXA
        ASL A
        TAY
        LDA SCORE_MSB
        CMP HISCORE_LSB00,Y
        BCC _L04
        BNE _L01
        LDA SCORE_LSB
        CMP HISCORE_MSB00,Y
        BCC _L04
_L01    TXA
        ASL A
        TAY
        LDA HISCORE_LSB00,Y
        STA HISCORE_LSB01,Y
        LDA HISCORE_MSB00,Y
        STA HISCORE_MSB01,Y
        TXA
        ASL A
        ASL A
        ASL A
        TAY
_L02    LDA HISCORE_NAME00,Y
        STA HISCORE_NAME01,Y
        INY
        TYA
        AND #$07     ;#%00000111
        BNE _L02
        DEX
        BPL _L00

        LDA SCORE_MSB
        STA HISCORE_LSB00
        LDA SCORE_LSB
        STA HISCORE_MSB00
        JSR SCREEN_ENTER_HI_SCORE

        LDY #$00
_L03    LDA HISCORE_NAME,Y
        STA HISCORE_NAME00,Y
        INY
        CPY #$08
        BNE _L03
        JMP _L07

_L04    TXA
        ASL A
        TAY
        LDA SCORE_MSB
        STA HISCORE_LSB01,Y
        LDA SCORE_LSB
        STA HISCORE_MSB01,Y
        CPX #$06     ;#%00000110
        BNE _L05
        JMP START

_L05    TXA
        PHA
        JSR SCREEN_ENTER_HI_SCORE
        PLA
        ASL A
        ASL A
        ASL A
        TAX
        LDY #$00     ;#%00000000
_L06    LDA HISCORE_NAME,Y
        STA HISCORE_NAME01,X
        INX
        INY
        CPY #$08     ;#%00001000
        BNE _L06

_L07    JSR CLEANUP_SPRITES
        JSR DISPLAY_HI_SCORES

        LDY #$64     ;#%01100100
        JSR DELAY

        ; Wait for 255 frames or joystick fire

        LDA #$FF     ;#%11111111
        STA COUNTER1
_L08    LDA $DC00    ;CIA1: Data Port Register A  (fire in Game Over scene)
        CMP #$6F     ;#%01101111
        BEQ _L09
        JSR WAIT_RASTER_AT_BOTTOM
        DEC COUNTER1
        BNE _L08
_L09    JMP START

NMI_HANDLER
        RTI

        ;TODO: This generates small garbage in the top row of the map.
        ;Can be safely removed once we don't care about the generating exactly
        ;the same binary.
RESET_ROUTINE       ;$0A4E
        .ADDR BOOT, BOOT
        .BYTE $C3,$C2,$CD,$38,$30

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Sets the sight "()" sprite for high scores as sprite $41 (@ $D040)
; Charset for LVL2 is located between D000-D7FF. Since LVL2 is not present
; it is safe to overwrite parts of $D000 as long you don't overwrite where
; the letters/numbers are located.
SET_SIGHT_SPRITE    ;$0A57
        ;TODO: probably it is safe to remove the stop/start timer since
        ;timer is not being used by code, and is already stop
        LDA $DC0E    ;CIA1: CIA Control Register A
        AND #$FE     ;#%11111110 Stop timer
        STA $DC0E    ;Stop timer
        LDA a01
        AND #$FB     ;#%11111011    Enabling RAM at $D000 I guess
        STA a01

        LDX #$3F     ;size of sprite
_L00    LDA SIGHT_SPR_DATA,X
        STA fD040,X  ;It will be sprite $41
        DEX
        BPL _L00

        LDA a01
        ORA #$04     ;#%00000100    Enabling I/O at $D000 I guess
        STA a01
        LDA $DC0E    ;CIA1: CIA Control Register A
        ORA #$01     ;#%00000001 Start timer (why ?)
        STA $DC0E    ;Start Timer
        RTS

SIGHT_SPR_DATA      ;$0A7F
        .BYTE $00,$00,$00,$02,$AA,$00,$0A,$AA
        .BYTE $80,$28,$20,$A0,$20,$20,$20,$20
        .BYTE $00,$20,$A0,$00,$28,$80,$00,$08
        .BYTE $80,$20,$08,$80,$20,$08,$A0,$A8
        .BYTE $28,$A0,$A8,$28,$80,$20,$08,$80
        .BYTE $20,$08,$80,$00,$08,$A0,$00,$28
        .BYTE $20,$00,$20,$20,$20,$20,$28,$20
        .BYTE $A0,$0A,$AA,$80,$02,$AA,$00

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Animates the selected char in hiscore
HISCORE_ANIM_CHAR       ;$0ABE
        LDA HISCORE_IS_CHAR_ANIM
        BEQ _SKIP

        LDY #$00     ;#%00000000
        INC HISCORE_ANIM_CHAR_COUNTER
        LDA HISCORE_ANIM_CHAR_COUNTER
        CMP #$32     ;#%00110010
        BEQ _L02
        AND #$0F     ;#%00001111
        LSR A
        LSR A
        AND #$03
        BEQ _L00
        AND #$01
        BNE _L01
        LDA HISCORE_SELECTED_CHAR
        CLC
        ADC #$20     ;Select the flipped char
        STA (pF7),Y
        RTS

_L00    LDA HISCORE_SELECTED_CHAR
        STA (pF7),Y
        RTS

_L01    LDA #$79     ;Select the regular char
        STA (pF7),Y
        RTS

_L02    LDA #$00     ;#%00000000
        STA HISCORE_IS_CHAR_ANIM
        LDA HISCORE_SELECTED_CHAR
        STA (pF7),Y
_SKIP   RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Get the selected char with the sight in the hiscore scene
HISCORE_GET_SELECTED_CHAR       ;$0AFA
        LDA SPRITES_X_LO05
        AND #$F0     ;#%11110000
        SEC
        SBC #$10     ;#%00010000
        PHP
        LSR A
        LSR A
        LSR A
        PLP
        BCC _L00
        LDY SPRITES_X_HI05
        BEQ _L00
        CLC
        ADC #$20     ;#%00100000
_L00    STA pFB,b
        LDA #$00     ;#%00000000
        STA pFC,b
        STA pFD,b
        STA pFE,b
        LDA SPRITES_Y05
        AND #$F0     ;#%11110000
        SEC
        SBC #$2E     ;#%00101110
        LSR A
        LSR A
        LSR A
        PHA
        LSR A
        ROR pFC,b
        LSR A
        ROR pFC,b
        LSR A
        ROR pFC,b
        STA pFD,b
        PLA
        ASL A
        ROL pFE,b
        ASL A
        ROL pFE,b
        ASL A
        ROL pFE,b
        CLC
        ADC pFC,b
        STA pFC,b
        LDA pFD,b
        ADC pFE,b
        STA pFD,b
        LDA pFC,b
        CLC
        ADC pFB,b
        STA pFC,b
        LDA pFD,b
        ADC #$00     ;#%00000000
        STA pFD,b
        LDA pFD,b
        CLC
        ADC #$E0     ;#%11100000
        STA pFD,b
        LDA pFC,b
        STA pF7,b
        LDA pFD,b
        STA pF8,b
        SEI
        LDA a01
        AND #$FD     ;Enable I/O to read from Screen RAM
        STA a01

        LDY #$00     ;#%00000000
        LDA (pFC),Y
        STA HISCORE_SELECTED_CHAR

        LDA a01
        ORA #$02
        STA a01

        CLI
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Sets up the hero and sight sprite, and cleans up name and other vars
HISCORE_SETUP_SPRITES   ;$0B94
        ; Sight sprite
        LDA #$64     ;#%01100100
        AND #$F0     ;#%11110000
        STA SPRITES_X_LO05
        LDA #$64     ;#%01100100
        AND #$F0     ;#%11110000
        STA SPRITES_Y05
        LDA #$00
        STA SPRITES_X_HI05
        LDA #$41     ;sight sprite
        STA SPRITES_PTR05
        LDA #$02     ;red
        STA SPRITES_COLOR05
        LDA #$FF
        STA SPRITES_BKG_PRI05
        LDA #$01            ;anim_type_01: bullet
        STA SPRITES_TYPE05
        LDA SPRITES_X_LO05

        ; Hero sprite
        STA SPRITES_X_LO00
        LDA #$B4
        STA SPRITES_Y00
        LDA #$00
        STA SPRITES_X_HI00
        LDA #$98     ;Hero going up
        STA SPRITES_PTR00
        LDA #$06     ;blue
        STA SPRITES_COLOR00
        LDA #$00
        STA SPRITES_BKG_PRI00
        LDA #$01
        STA SPRITES_TYPE00

        LDX #$07
        LDA #$00
_L00    STA HISCORE_NAME,X
        DEX
        BPL _L00

        LDA #$00
        STA HISCORE_IS_BULLET_ANIM
        STA HISCORE_NAME_IDX
        STA HISCORE_IS_CHAR_ANIM

        ; $F7/$F8 -> Screen RAM
        LDA #<pE000
        STA pF7,b
        LDA #>pE000
        STA pF8,b

        LDA #$20
        STA HISCORE_SELECTED_CHAR
        JSR APPLY_DELTA_MOV
        JSR SORT_SPRITES_BY_Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
HISCORE_READ_JOY_MOV
        LDA $DC00
        AND #$01     ;#%00000001        up?
        BNE _L00
        LDA SPRITES_Y05
        CMP #$64     ;reached top?
        BCC _L00
        LDA #$FE     ;2 pixels up
        STA SPRITES_DELTA_Y05

_L00    LDA $DC00
        AND #$02     ;#%00000010        down?
        BNE _L01
        LDA SPRITES_Y05
        CMP #$78     ;reached bottom?
        BCS _L01
        LDA #$02     ;2 pixels down
        STA SPRITES_DELTA_Y05

_L01    LDA $DC00    ;CIA1: Data Port Register A (enter high score)
        AND #$04     ;#%00000100        left?
        BNE _L02
        LDA SPRITES_X_LO05
        CMP #$64     ;reached margin left?
        BCC _L02
        LDA #$FE     ;2 pixels to left
        STA SPRITES_DELTA_X05

_L02    LDA $DC00
        AND #$08     ;#%00001000        right?
        BNE _L03
        LDA SPRITES_X_LO05
        CMP #$F0     ;reached margin right?
        BCS _L03
        LDA #$02     ;2 pixels to right
        STA SPRITES_DELTA_X05

_L03    LDA SPRITES_X_LO05
        STA SPRITES_X_LO00
        AND #$1F     ;#%00011111
        LSR A
        LSR A
        LSR A
        TAY
        LDA HERO_FRAMES_UP,Y
        STA SPRITES_PTR00
        LDA SPRITES_X_HI05
        STA SPRITES_X_HI00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
s0C6F   LDA SPRITES_X_LO05
        AND #$0F     ;#%00001111
        BNE _L00
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X05
_L00    LDA SPRITES_Y05
        AND #$0F     ;#%00001111
        BNE _L01
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y05
_L01    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_ENTER_HI_SCORE   ;$0C88
        LDA #$01     ;Song to play (high scores)
        JSR MUSIC_INIT
        JSR CLEAR_SCREEN
        JSR CLEANUP_SPRITES
        LDA #$00     ;#%00000000
        STA V_SCROLL_DELTA
        STA V_SCROLL_BIT_IDX
        STA BKG_COLOR0
        LDA #$02     ;#%00000010
        STA LEVEL_NR

        ; $FB/$FC -> Screen RAM
        ; $FD/$FE -> Color RAM
        ; Row 3, Column 10
        LDA #<pE082
        STA pFB,b
        LDA #>pE082
        STA pFC,b
        LDA #<pD882
        STA pFD,b
        LDA #>pD882
        STA pFE,b

        LDX #$00
_L00    LDY #$00
_L01    LDA f0D09,X
        CMP #$FF     ;End of line?
        BEQ _L02
        CMP #$FE     ;Finish printing?
        BEQ _L04
        STA (pFB),Y
        LDA #$01     ;white
        STA (pFD),Y
        INX
        INY
        JMP _L01

_L02    INX
        LDA pFB,b
        CLC
        ADC #$28     ;Put "cursor" in next line
        STA pFB,b
        STA pFD,b
        BCC _L03
        INC pFC,b
        INC pFE,b
_L03    JMP _L00

_L04    JSR HISCORE_SETUP_SPRITES

_L05    JSR WAIT_RASTER_AT_BOTTOM
        JSR HISCORE_READ_JOY_MOV
        JSR HISCORE_READ_JOY_FIRE
        JSR HISCORE_ANIM_CHAR
        JSR APPLY_DELTA_MOV
        JSR SORT_SPRITES_BY_Y
        JSR s0C6F
        LDA HISCORE_SELECTED_CHAR
        CMP #$78     ;#%01111000
        BNE _L05
        RTS

        ;Alphabet for hiscore
f0D09   .BYTE $20,$20,$20,$20,$20,$75,$75,$75
        .BYTE $75,$75,$75,$75,$75,$78,$FF,$FF
        .BYTE $FF,$5B,$20,$5C,$20,$5D,$20,$5E
        .BYTE $20,$5F,$20,$60,$20,$61,$20,$62
        .BYTE $20,$63,$20,$64,$FF,$FF,$65,$20
        .BYTE $66,$20,$67,$20,$68,$20,$69,$20
        .BYTE $6A,$20,$6B,$20,$6C,$20,$6D,$20
        .BYTE $6E,$FF,$FF,$6F,$20,$70,$20,$71
        .BYTE $20,$72,$20,$73,$20,$74,$20,$75
        .BYTE $20,$76,$20,$77,$20,$78,$FF,$FE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Reads joystick fire, only if bullet is not being animated
HISCORE_READ_JOY_FIRE       ;$0D59
        LDA HISCORE_IS_BULLET_ANIM
        BEQ _L02

        ; Bullet reached destination?
        LDA SPRITES_Y01
        CMP SPRITES_TMP_A01
        BCC _L00
        RTS

_L00
        ; Cleanup bullet sprite
        LDA #$00
        STA SPRITES_TYPE01
        STA HISCORE_IS_BULLET_ANIM
        LDA #$FF                ;Empty sprite
        STA SPRITES_PTR01
        LDA HISCORE_SELECTED_CHAR
        CMP #$77                ;"backspace" char
        BEQ _L01
        LDA #$01
        STA HISCORE_IS_CHAR_ANIM
_L01    RTS

_L02    LDA $DC00               ;Fire pressed?
        AND #$10                ;#%00010000
        BEQ _L03
        RTS

_L03
        ; Create bullet sprite type
        LDA #$00
        STA SPRITES_DELTA_X01
        LDA #$FA
        STA SPRITES_DELTA_Y01
        LDA SPRITES_X_LO00
        STA SPRITES_X_LO01
        LDA SPRITES_Y00
        STA SPRITES_Y01
        LDA SPRITES_X_HI00
        STA SPRITES_X_HI01
        LDA #$01
        STA SPRITES_TYPE01
        LDA #$90                ;Bullet frame
        STA SPRITES_PTR01
        STA SPRITES_BKG_PRI01
        LDA #$01                ;white
        STA SPRITES_COLOR01
        STA HISCORE_IS_BULLET_ANIM
        LDA SPRITES_Y05
        STA SPRITES_TMP_A01

        LDA HISCORE_SELECTED_CHAR
        LDY #$00
        STA (pF7),Y
        JSR HISCORE_GET_SELECTED_CHAR
        LDA #$0B                ;"Fire" SFX
        JSR SFX_PLAY

        LDA HISCORE_SELECTED_CHAR
        CMP #$78                ;"end" char
        BEQ _L05
        CMP #$77                ;"backspace" char
        BNE _L04

        ; Delete char
        LDA HISCORE_NAME_IDX
        BEQ _L05
        DEC HISCORE_NAME_IDX
        LDX HISCORE_NAME_IDX
        LDA #$75                ;"stop/dot" char
        STA HISCORE_NAME,X
        STA fE087,X             ;update it in Screen RAM as well
        LDA #$00
        STA HISCORE_IS_CHAR_ANIM
        STA HISCORE_ANIM_CHAR_COUNTER
        JMP _L05

_L04    LDA HISCORE_NAME_IDX
        CMP #$08                ;strlen(name) == 8 ?
        BEQ _L05

        LDA HISCORE_SELECTED_CHAR
        LDX HISCORE_NAME_IDX
        STA HISCORE_NAME,X
        STA fE087,X             ;update name in Screen RAM
        INC HISCORE_NAME_IDX
_L05    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
DISPLAY_HI_SCORES       ;$0E0F
        JSR CLEAR_SCREEN

        ;  $FB/$FC -> Screen RAM: 3rd row, column 10
        LDA #<pE082
        STA pFB,b
        LDA #>pE082
        STA pFC,b

        LDX #$00
_L00    JSR HISCORE_PRINT_PREFIX
        LDA pFB,b
        CLC
        ADC #$05
        STA pFB,b
        JSR HISCORE_PRINT_NAME
        LDA pFB,b
        CLC
        ADC #$0A
        STA pFB,b
        JSR HISCORE_PRINT_SCORE
        LDA pFB,b
        CLC
        ADC #$04     ;#%00000100
        STA pFB,b
        LDY #$00     ;#%00000000
        LDA #$21     ;#%00100001
        STA (pFB),Y
        INY
        LDA #$21     ;#%00100001
        STA (pFB),Y
        LDA pFB,b
        CLC
        ADC #$3D     ;#%00111101
        STA pFB,b
        BCC _L01
        INC pFC,b
_L01    INX
        CPX #$08     ;#%00001000
        BNE _L00

        ; Wait for fire button

_L02    LDA $DC00
        CMP #$6F     ;#%01101111
        BNE _L02
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Prints the hiscore prefix. E.g: "1st", "2nd",...
; X=prefix to print
HISCORE_PRINT_PREFIX    ;$0E68
        TXA
        PHA
        ASL A
        ASL A
        TAX
        LDY #$00     ;#%00000000
_L00    LDA HISCORE_PREFIX_TBL,X
        STA (pFB),Y
        INX
        INY
        CPY #$04     ;#%00000100
        BNE _L00
        PLA
        TAX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Print hiscore name. E.g: "john"
; X=name to print
HISCORE_PRINT_NAME      ;$0E7D
        TXA
        PHA
        ASL A
        ASL A
        ASL A
        TAX
        LDY #$00     ;#%00000000
_L00    LDA HISCORE_NAME00,X
        STA (pFB),Y
        INX
        INY
        CPY #$08     ;#%00001000
        BNE _L00
        PLA
        TAX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Prints the score
; X=score to print
HISCORE_PRINT_SCORE     ;$0E93
        TXA
        PHA
        ASL A
        TAX
        LDY #$00     ;#%00000000
        LDA HISCORE_LSB00,X
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        ADC #$21     ;#%00100001
        STA (pFB),Y
        INY
        LDA HISCORE_LSB00,X
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA (pFB),Y
        INY
        LDA HISCORE_MSB00,X
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        CLC
        ADC #$21     ;#%00100001
        STA (pFB),Y
        INY
        LDA HISCORE_MSB00,X
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA (pFB),Y
        PLA
        TAX
        RTS

HISCORE_PREFIX_TBL      ;$0ECE
        .BYTE $22,$6D,$6E,$20           ;"1st "
        .BYTE $23,$68,$5E,$20           ;"2nd "
        .BYTE $24,$6C,$5E,$20           ;"3rd "
        .BYTE $25,$6E,$62,$20           ;"4th "
        .BYTE $26,$6E,$62,$20           ;"5th "
        .BYTE $27,$6E,$62,$20           ;"6th "
        .BYTE $28,$6E,$62,$20           ;"7th "
        .BYTE $29,$6E,$62,$20           ;"8th "

HISCORE_NAME00
        .BYTE $5D,$62,$6C,$63,$6D,$20,$20,$20   ;name for 1st
HISCORE_NAME01
        .BYTE $6C,$69,$6C,$73,$20,$20,$20,$20   ;...2nd
        .BYTE $6E,$62,$5F,$20,$5E,$6F,$5E,$5F
        .BYTE $6D,$5B,$6C,$5B,$62,$20,$76,$20
        .BYTE $68,$63,$61,$5F,$66,$20,$20,$20
        .BYTE $65,$5F,$63,$6E,$62,$20,$20,$20
        .BYTE $5B,$5E,$69,$66,$60,$20,$20,$20
        .BYTE $5E,$63,$66,$65,$20,$20,$20,$20   ;...8th
        .BYTE $20,$20,$20,$20,$20,$20,$20,$20

        ; High Scores
HISCORE_MSB00 =*+1
HISCORE_LSB00
        .WORD $9000
HISCORE_MSB01 =*+1
HISCORE_LSB01
        .WORD $8000,$7000,$6000,$5000
        .WORD $4000,$3000,$2000,$0000

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_MAIN_TITLE
        JSR CLEANUP_SPRITES
        JSR CLEAR_SCREEN
        LDA #$00     ;#%00000000
        STA BKG_COLOR0

        ; HACK: Sets level number to LVL2 in order to use the charset from $D000
        LDA #$02     ;#%00000010
        STA LEVEL_NR

        LDA #$FF     ;#%11111111
        STA $D01D    ;Sprites Expand 2x Horizontal (X)
        STA $D017    ;Sprites Expand 2x Vertical (Y)
        LDX #$00     ;#%00000000
_L00    LDA #$48     ;Sprite Y position
        STA SPRITES_Y05,X
        LDA _MS_SPRITES_X_LO05,X
        STA SPRITES_X_LO05,X
        LDA _MS_SPRITES_PTR05,X
        STA SPRITES_PTR05,X
        LDA _MS_SPRITES_X_HI05,X
        STA SPRITES_X_HI05,X
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA #$10            ;anim_type_10: void
        STA SPRITES_TYPE05,X
        LDA #$08     ;orange
        STA SPRITES_COLOR05,X
        LDA #$00     ;#%00000000
        STA SPRITES_BKG_PRI05,X
        INX
        CPX #$07     ;total number of sprites
        BNE _L00

        JSR APPLY_DELTA_MOV
        JSR SORT_SPRITES_BY_Y
        LDA #$00     ;#%00000000
        STA $D025    ;Sprite Multi-Color Register 0
        LDA #$07     ;#%00000111
        STA $D026    ;Sprite Multi-Color Register 1
        JSR PRINT_CREDITS
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_A01

_L01    LDA #$FF     ;#%11111111
        STA COUNTER1
_WAIT_FIRE
        LDA $DC00    ;CIA1: Data Port Register A (main screen - fire)
        CMP #$6F     ;#%01101111
        BEQ _END
        JSR WAIT_RASTER_AT_BOTTOM
        DEC COUNTER1
        BNE _WAIT_FIRE

        ; Change background image
        LDA #$09     ;#%00001001
        STA BKG_COLOR0
        LDX SPRITES_TMP_A01
        LDA _SCROLL_IDX,X
        STA V_SCROLL_ROW_IDX
        LDA _LEVEL_IDX,X
        STA LEVEL_NR
        JSR INIT_LEVEL_DATA
        JSR SET_LEVEL_COLOR_RAM
        JSR LEVEL_DRAW_VIEWPORT
        INC SPRITES_TMP_A01
        LDA SPRITES_TMP_A01

        CMP #$08        ;Total number of screens to display
        BNE _L01        ;FIXME: actually the loop does it one extra time
                        ; a fixes it in SCREEN_MAIN_TITLE

        JMP SCREEN_MAIN_TITLE

_END    RTS

; Main Screen (MS) "Commando" 7-sprites data
_MS_SPRITES_X_LO05
        .BYTE $1C,$4C,$7C,$AC,$DC,$0C,$3C
_MS_SPRITES_X_HI05
        .BYTE $00,$00,$00,$00,$00,$FF,$FF
_MS_SPRITES_PTR05
        .BYTE $F6,$F7,$F8,$F9,$FA,$FB,$AC
_LEVEL_IDX      ;$1001
        .BYTE $00,$00,$01,$01,$03,$03,$03
_SCROLL_IDX     ;$1008
        .BYTE $53,$7C,$3A,$01,$A9,$6E,$36

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
CHECK_COLLISION       ;$100F
        LDY #$00     ;#%00000000
_L00    LDA SPRITES_TYPE05,Y
        STY pFB,b
        TAY
        LDA f1074,Y
        LDY pFB,b
        AND #$01     ;#%00000001
        BEQ _L01

        LDA SPRITES_X_HI00
        CMP SPRITES_X_HI05,Y
        BNE _L01
        LDA SPRITES_X_LO00
        CLC
        ADC #$04     ;#%00000100
        CMP SPRITES_X_LO05,Y
        BCC _L01
        LDA SPRITES_X_LO00
        SEC
        SBC #$04     ;#%00000100
        CMP SPRITES_X_LO05,Y
        BCS _L01
        LDA SPRITES_Y00
        CLC
        ADC #$08     ;#%00001000
        CMP SPRITES_Y05,Y
        BCC _L01
        LDA SPRITES_Y00
        SEC
        SBC #$08     ;#%00001000
        CMP SPRITES_Y05,Y
        BCS _L01
        LDA #$01     ;Hero was shot
        STA IS_HERO_DEAD
        STA COUNTER1
        LDA #$04     ;#%00000100
        JSR SFX_PLAY
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X00
        STA SPRITES_DELTA_Y00
        STA V_SCROLL_DELTA
_L01    INY
        CPY #$0B     ;#%00001011
        BNE _L00
        RTS

        ; Sprite types that can collide with hero.
        ; Flagged types:
        ; anim_type_05, anim_type_08, anim_type_0A, anim_type_0C,
        ; anim_type_15, anim_type_17, anim_type_18, anim_type_19,
        ; anim_type_1A, anim_type_1B, anim_type_1F, anim_type_20,
        ; anim_type_21, anim_type_22, anim_type_23, anim_type_24,
        ; anim_type_25

        ; FIXME: Missing information of anim_type_27 and anim_type_28
f1074   .BYTE $00,$00,$00,$00,$00,$01,$00,$00   ;$00-$07
        .BYTE $01,$00,$01,$00,$01,$00,$00,$00   ;$08-$0F
        .BYTE $00,$00,$00,$00,$00,$01,$00,$01   ;$10-$17
        .BYTE $01,$01,$01,$01,$00,$00,$00,$01   ;$18-$1F
        .BYTE $01,$01,$01,$01,$01,$01,$00       ;$28-$26

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Re-execute actions based on the row index. Called when the level is restarted.
; E.g: after losing a life.
RERUN_ACTIONS             ;$109B
        LDY #$00
_L00    LDA (p24),Y         ;End of trigger-rows?
        CMP #$FF
        BEQ _L04
        CMP V_SCROLL_ROW_IDX
        BCC _L04
        SEC
        SBC #$16     ;#%00010110
        CMP V_SCROLL_ROW_IDX
        BCS _L03
        STY pFD,b
        LDA (p28),Y         ;Object to init
        ASL A
        TAY

        ; $FB/$FC -> action table
        LDA ACTION_TBL,Y    ;Prepare jump table for actions
        STA pFB,b
        LDA ACTION_TBL+1,Y
        STA pFC,b

        ; Find empty seat
        LDX #$00
_L01    LDA SPRITES_TYPE05,X
        BEQ _L02
        INX
        CPX #(TOTAL_MAX_SPRITES-5)
        BNE _L01
        JMP _L03

_L02    TXA
        PHA
        JSR JMP_FB
        PLA
        TAX

        LDY pFD,b
        LDA (p24),Y         ;Trigger row
        SEC
        SBC V_SCROLL_ROW_IDX
        ASL A
        ASL A
        ASL A
        CLC
        ADC #$2B     ;#%00101011
        STA SPRITES_Y05,X
        LDY SPRITES_TMP_A05,X
        STA SPRITES_Y05,Y
        LDY pFD,b
_L03    INY
        JMP _L00

_L04    STY TRIGGER_ROW_IDX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
PRINT_CREDITS       ;$10FC
        ; $FB/$FC -> Screen RAM
        LDA #<pE029  ;Screen RAM lo
        STA pFB,b
        LDA #>pE029  ;Screen RAM hi
        STA pFC,b

        ; $FD/$FE -> Color RAM
        LDA #<pD829  ;Color RAM lo
        STA pFD,b
        LDA #>pD829  ;Color RAM hi
        STA pFE,b

        LDX #$00
_L00    LDY #$00
_L01    LDA CREDITS_TXT,X
        CMP #$FF     ;End of line?
        BEQ _L02
        CMP #$FE     ;End of message
        BEQ _L04
        STA (pFB),Y
        LDA #$01     ;Color
        STA (pFD),Y
        INX
        INY
        JMP _L01

_L02    INX
        LDA pFB,b
        CLC
        ADC #$50     ;#%01010000
        STA pFB,b
        STA pFD,b
        BCC _L03
        INC pFC,b
        INC pFE,b
_L03    JMP _L00
_L04    RTS

CREDITS_TXT         ;$1143
        .BYTE $20,$20,$20,$20,$20,$20,$20,$20
        .BYTE $20,$20,$20,$5F,$66,$63,$6E,$5F
        .BYTE $20,$6A,$6C,$5F,$6D,$5F,$68,$6E
        .BYTE $6D,$FF,$FF,$FF,$FF,$20,$20,$20
        .BYTE $20,$20,$6A,$6C,$69,$61,$6C,$5B
        .BYTE $67,$67,$63,$68,$61,$20,$20,$20
        .BYTE $5D,$62,$6C,$63,$6D,$20,$5C,$6F
        .BYTE $6E,$66,$5F,$6C,$FF,$20,$20,$20
        .BYTE $20,$20,$20,$20,$20,$61,$6C,$5B
        .BYTE $6A,$62,$63,$5D,$6D,$20,$20,$20
        .BYTE $6C,$69,$6C,$73,$20,$61,$6C,$5F
        .BYTE $5F,$68,$FF,$20,$20,$20,$20,$20
        .BYTE $20,$20,$20,$20,$20,$20,$20,$20
        .BYTE $20,$20,$20,$20,$20,$20,$5D,$62
        .BYTE $6C,$63,$6D,$20,$62,$5B,$6C,$70
        .BYTE $5F,$73,$FF,$20,$20,$20,$20,$20
        .BYTE $20,$20,$20,$20,$20,$20,$6D,$69
        .BYTE $6F,$68,$5E,$20,$20,$20,$6C,$69
        .BYTE $5C,$20,$62,$6F,$5C,$5C,$5B,$6C
        .BYTE $5E,$FF,$20,$20,$20,$20,$20,$64
        .BYTE $5B,$6A,$5B,$68,$20,$5D,$5B,$6A
        .BYTE $6D,$6F,$66,$5F,$20,$5D,$69,$67
        .BYTE $6A,$6F,$6E,$5F,$6C,$6D,$20,$6F
        .BYTE $65,$20,$66,$6E,$5E,$FF,$FF,$20
        .BYTE $20,$20,$20,$20,$20,$20,$20,$20
        .BYTE $5D,$69,$6A,$73,$6C,$63,$61,$62
        .BYTE $6E,$20,$5D,$5B,$6A,$5D,$69,$67
        .BYTE $20,$22,$2A,$29,$26,$FF,$20,$20
        .BYTE $20,$20,$20,$20,$20,$20,$20,$20
        .BYTE $6A,$6C,$5F,$6D,$6D,$20,$60,$63
        .BYTE $6C,$5F,$20,$6E,$69,$20,$6D,$6E
        .BYTE $5B,$6C,$6E,$FF,$FE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Prints the "broke area... now rush... " msg
PRINT_LVL_COMPLETE      ;$1240
        LDA LEVEL_NR
        PHA
        AND #$03
        ASL A
        ASL A
        TAY

        LDX #$00
_L00    LDA _TXT_1ST,Y
        STA f12E0,X
        LDA _TXT_2ND,Y
        STA f12F5,X
        INY
        INX
        CPX #$03
        BNE _L00

        LDA #<p12D6
        STA _L02
        LDA #>p12D6
        STA _L03
        LDA #<p12E8
        STA _L05
        LDA #>p12E8
        STA _L06

        LDA LEVEL_NR
        AND #$03     ;#%00000011
        CMP #$03     ;#%00000011
        BNE _L01

        LDA #<p12FD
        STA _L02
        LDA #>p12FD
        STA _L03
        LDA #<p130F
        STA _L05
        LDA #>p130F
        STA _L06

_L01    LDA #$02     ;#%00000010
        STA LEVEL_NR
        JSR CLEANUP_SPRITES
        JSR CLEAR_SCREEN
        LDA #$00     ;#%00000000
        STA BKG_COLOR0

        ; Print "Broke the NNN area" msg
        LDX #$00
_L02    =*+$01
_L03    =*+$02
_L04    LDA f2596,X                 ;Self-modifying
        STA $E000 + 40*10 + 10,X    ;Screen RAM
        LDA #$01                    ;white
        STA $D800 + 40*10 + 10,X    ;Color RAM
        LDY #$05
        JSR DELAY
        INX
        CPX #$12        ;msg len
        BNE _L04

        ; Print "Now rush the NNN area" msg
        LDX #$00
_L05    =*+$01
_L06    =*+$02
_L07    LDA f2596,X                 ;Self-modifying
        STA $E000 + 40*12 + 9,X     ;Screen RAM
        LDA #$01                    ;white
        STA $D800 + 40*12 + 9,X     ;Color RAM
        LDY #$05
        JSR DELAY
        INX
        CPX #$15        ;msg len
        BNE _L07

        LDY #$78
        JSR DELAY
        PLA
        STA LEVEL_NR
        RTS

p12D6   .BYTE $5C,$6C,$69,$65,$5F,$20,$6E,$62
        .BYTE $5F,$20
f12E0   .BYTE $72,$72,$72,$20,$5B,$6C,$5F,$5B
p12E8   .BYTE $68,$69,$71,$20,$6C,$6F,$6D,$62
        .BYTE $20,$6E,$62,$5F,$20
f12F5   .BYTE $72,$72,$72,$20,$5B,$6C,$5F,$5B
p12FD   .BYTE $20,$20,$5D,$69,$68,$61,$6C,$5B
        .BYTE $6E,$6F,$66,$5B,$6E,$63,$69,$68
        .BYTE $6D,$20
p130F   .BYTE $20,$20,$20,$67,$63,$6D,$6D,$63
        .BYTE $69,$68,$20,$5D,$69,$67,$6A,$66
        .BYTE $5F,$6E,$5F,$20,$20

_TXT_1ST
        .BYTE $22,$6D,$6E,$20       ;1st
_TXT_2ND
        .BYTE $23,$68,$5E,$20       ;2nd
        .BYTE $24,$6C,$5E,$20       ;3rd
        .BYTE $24,$6C,$5E,$20       ;3rd

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
CLEAR_SCREEN    ;$1334
        ; $FB/$FC -> Screen RAM
        ; $FD/$FE -> Color RAM
        LDA #$00
        STA pFB,b
        STA pFD,b
        LDA #$E0
        STA pFC,b
        LDA #$D8
        STA pFE,b

        LDY #$00
_L00    LDA #$20     ;space
        STA (pFB),Y
        LDA #$01     ;white
        STA (pFD),Y
        INC pFB,b
        INC pFD,b
        BNE _L00
        INC pFC,b
        INC pFE,b
        LDA pFC,b
        CMP #$E4
        BNE _L00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Y = number of frames to wait
DELAY   ;$1366
        JSR WAIT_RASTER_AT_BOTTOM
        DEY
        BPL DELAY
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; A=Score to add
SCORE_ADD
        SED
        CLC
        ADC SCORE_LSB
        STA SCORE_LSB
        BCC _L00

        ; Lives +=1 every 10000 points
        LDA SCORE_MSB
        CLC
        ADC #$01     ;#%00000001
        STA SCORE_MSB
        CLD
        INC LIVES
        JSR SCREEN_REFRESH_LIVES
        LDA #$0C     ;#%00001100
        JSR SFX_PLAY
_L00    CLD
        ; fall-through

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_REFRESH_SCORE
        LDA SCORE_MSB
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        ADC #$21     ;#%00100001
        STA aE34E
        LDA SCORE_MSB
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE34F
        LDA SCORE_LSB
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        CLC
        ADC #$21     ;#%00100001
        STA aE350
        LDA SCORE_LSB
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE351
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_REFRESH_HISCORE
        LDA HISCORE_LSB00
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        ADC #$21     ;#%00100001
        STA aE36A
        LDA HISCORE_LSB00
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE36B
        LDA HISCORE_MSB00
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        CLC
        ADC #$21     ;#%00100001
        STA aE36C
        LDA HISCORE_MSB00
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE36D
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_REFRESH_GRENADES
        LDA GRENADES
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        ADC #$21     ;#%00100001
        STA aE359
        LDA GRENADES
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE35A
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SCREEN_REFRESH_LIVES
        LDA LIVES
        AND #$F0     ;#%11110000
        LSR A
        LSR A
        LSR A
        LSR A
        ADC #$21     ;#%00100001
        STA aE361
        LDA LIVES
        AND #$0F     ;#%00001111
        CLC
        ADC #$21     ;#%00100001
        STA aE362
        RTS

        LDX #$0F     ;#%00001111
_L00    LDA SPRITES_Y00,X
        STA SPRITES_PREV_Y00,X
        DEX
        BPL _L00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
        ; Original Y positions for al 16 sprites
ORIG_SPRITE_Y00
        .BYTE $C2
ORIG_SPRITE_Y01
        .BYTE $C2,$C2,$C2,$28
ORIG_SPRITE_Y05
        .BYTE $28,$28,$28,$1E,$1E,$1E,$1E,$1E
        .BYTE $1E,$1E,$1E

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; $D018 points to right charset for level
; And sets a bunch of variables needed for the level
INIT_LEVEL_DATA                 ;$1445
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        TAY
        LDA f3ECE,Y
        STA LVL_MAP_MSB
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        ASL A
        TAY
        LDA f14AB,Y
        STA p24,b     ;Rows that trigger the creation of sprites
        LDA f14AC,Y
        STA p25,b

        LDA f14A3,Y
        STA p22,b     ;X LSB of newly created sprite
        LDA f14A4,Y
        STA p23,b

        LDA f14B3,Y
        STA p26,b     ; X MSB of newly created sprite
        LDA f14B4,Y
        STA p27,b

        LDA f14BB,Y
        STA p28,b     ;Sprite type to create
        LDA f14BC,Y
        STA p29,b

        LDA f14C3,Y
        STA p2A,b
        LDA f14C4,Y
        STA p2B,b

        ; Charsets:
        ; lvl0 = $c000
        ; lvl1 = $c800
        ; main screen / lvl2: $d000
        ; lvl3 = $d800
        STY pFB,b
        LDA $D018    ;VIC Memory Control Register
        AND #$F0     ;#%11110000
        ORA pFB,b  ;Set charset address
        STA $D018    ;VIC Memory Control Register
        RTS

        ; Data for lvl0-3, although lvl2 was not included in the game
f14A4   =*+1
f14A3   .ADDR LVL0_SPRITE_X_LO_TBL
        .ADDR LVL1_SPRITE_X_LO_TBL
        .ADDR LVL3_SPRITE_X_LO_TBL
        .ADDR LVL3_SPRITE_X_LO_TBL
f14AC   =*+1
f14AB   .ADDR LVL0_TRIGGER_ROW_TBL
        .ADDR LVL1_TRIGGER_ROW_TBL
        .ADDR LVL3_TRIGGER_ROW_TBL
        .ADDR LVL3_TRIGGER_ROW_TBL
f14B4   =*+1
f14B3   .ADDR LVL0_SPRITE_X_HI_TBL
        .ADDR LVL1_SPRITE_X_HI_TBL
        .ADDR LVL3_SPRITE_X_HI_TBL
        .ADDR LVL3_SPRITE_X_HI_TBL
f14BC   =*+1
f14BB   .ADDR LVL0_ACTION_TBL
        .ADDR LVL1_ACTION_TBL
        .ADDR LVL3_ACTION_TBL
        .ADDR LVL3_ACTION_TBL
f14C4   =*+1
f14C3   .ADDR LVL0_CHARSET_MASK_TBL
        .ADDR LVL1_CHARSET_MASK_TBL
        .ADDR LVL3_CHARSET_MASK_TBL
        .ADDR LVL3_CHARSET_MASK_TBL

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Patches the level data with the turret destroyed/restored
; A = 0 left turret Ok
;   = 2 right turret Ok
;   = 4 left turret destroyed
;   = 6 right turret destroyed
; FB = ptr to destination
f14CC   =*+1
f14CB   .ADDR f1502,f1538,f156E,f15A4

LEVEL_PATCH_TURRET         ;$14D3
        TAX
        LDA f14CB,X
        STA _L01
        LDA f14CC,X
        STA _L02
        LDX #$00
_L00    LDY #$00
_L01    =*+$01
_L02    =*+$02
_L03    LDA f2596,X                 ;Self-modifying
        STA (pFB),Y
        INX
        INY
        CPY #$06     ;#%00000110
        BNE _L03

        LDA pFB,b
        CLC
        ADC #$28     ;#%00101000        Next row
        STA pFB,b
        BCC _L04
        INC pFC,b
_L04    CPX #$36     ;#%00110110
        BCC _L00
        RTS

; Turrets to draw: left turret / right turret, destroyed, restored
f1502   .BYTE $30,$30,$30,$7A,$71,$30
        .BYTE $30,$30,$7A,$D7,$DD,$71
        .BYTE $30,$7A,$B7,$7B,$7B,$73
        .BYTE $7A,$B7,$7B,$7B,$72,$6B
        .BYTE $6E,$7B,$7B,$72,$7D,$6B
        .BYTE $74,$6E,$72,$7D,$DA,$6A
        .BYTE $74,$74,$7B,$DA,$6A,$30
        .BYTE $69,$74,$7B,$6A,$30,$30
        .BYTE $30,$69,$6A,$30,$30,$30

f1538   .BYTE $30,$7A,$71,$30,$30,$30
        .BYTE $7A,$70,$D7,$71,$30,$30
        .BYTE $82,$7B,$7B,$DD,$71,$30
        .BYTE $76,$79,$7B,$7B,$DD,$71
        .BYTE $76,$6E,$79,$7B,$7B,$7D
        .BYTE $77,$EF,$6E,$79,$7D,$74
        .BYTE $30,$77,$EF,$7B,$74,$74
        .BYTE $30,$30,$77,$7B,$74,$78
        .BYTE $30,$30,$30,$77,$78,$30

f156e   .BYTE $30,$30,$30,$30,$30,$30
        .BYTE $30,$30,$30,$30,$30,$30
        .BYTE $30,$30,$DF,$DE,$EB,$30
        .BYTE $30,$DE,$E0,$6A,$77,$EB
        .BYTE $E2,$8F,$6A,$35,$18,$EE
        .BYTE $F1,$6A,$FF,$EC,$DE,$6A
        .BYTE $74,$F1,$DE,$E0,$6A,$30
        .BYTE $69,$74,$7B,$6A,$FF,$1F
        .BYTE $30,$69,$6A,$30,$30,$30

f15A4   .BYTE $30,$30,$30,$30,$30,$30
        .BYTE $30,$30,$30,$30,$30,$30
        .BYTE $30,$E2,$92,$1B,$30,$30
        .BYTE $1C,$6A,$69,$92,$ED,$30
        .BYTE $E1,$1B,$1E,$69,$F1,$30
        .BYTE $77,$14,$30,$33,$EE,$32
        .BYTE $30,$77,$EB,$E2,$F1,$EC
        .BYTE $30,$30,$77,$8E,$74,$78
        .BYTE $30,$30,$30,$77,$78,$30

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Patches the level data with the door in open/closed state.
; A = 0: Closed door
;   = 2: Open door
; $0405: Destination MSB
;        Destination LSB is always $0D
LEVEL_PATCH_DOOR         ;$15DA
        TAX
        LDA f161D,X
        STA _L01
        LDA f161E,X
        STA _L02

        ; Only lvl 0 and 1 has doors. Skip in lvl 3
        LDA LEVEL_NR
        AND #$03
        CMP #$03
        BEQ _SKIP

        LDA #$0D     ;#%00001101
        STA pFB,b
        LDA LVL_MAP_MSB
        STA pFC,b
        LDX #$00     ;#%00000000
_L00    LDY #$00     ;#%00000000
_L01    =*+$01
_L02    =*+$02
_L03    LDA f2596,X         ;Self-modfying
        STA (pFB),Y
        INX
        INY
        CPY #$0F     ;#%00001111
        BNE _L03

        LDA pFB,b
        CLC
        ADC #$28     ;#%00101000
        STA pFB,b
        BCC _L04
        INC pFC,b
_L04    CPX #$86     ;#%10000110
        BCC _L00
_SKIP   RTS

f161E   =*+1
f161D   .ADDR f1621,f16A8
        ; Patch for closed door
f1621   .BYTE $CC,$CC,$D8,$D8,$D8,$D8,$D8,$D9
        .BYTE $D8,$D8,$D8,$D8,$D8,$CC,$CC,$CF
        .BYTE $CE,$4F,$4F,$4F,$4F,$4F,$CD,$4F
        .BYTE $4F,$4F,$4F,$4F,$CE,$CF,$D2,$D1
        .BYTE $4F,$4F,$4F,$4F,$4F,$CD,$4F,$4F
        .BYTE $4F,$4F,$4F,$D1,$D2,$CF,$CE,$4F
        .BYTE $4F,$4F,$4F,$4F,$CD,$4F,$4F,$4F
        .BYTE $4F,$4F,$CE,$CF,$D2,$D1,$4F,$4F
        .BYTE $4F,$4F,$4F,$CD,$4F,$4F,$4F,$4F
        .BYTE $4F,$D1,$D2,$D6,$D5,$4F,$4F,$4F
        .BYTE $4F,$4F,$CD,$4F,$4F,$4F,$4F,$4F
        .BYTE $D5,$D6,$DC,$DB,$D8,$D8,$D8,$D8
        .BYTE $D8,$D9,$D8,$D8,$D8,$D8,$D8,$DB
        .BYTE $DC,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00
        ; Patch for open door
f16A8   .BYTE $CC,$45,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$8C,$CC,$47
        .BYTE $46,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$8D,$8E,$45,$4F
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$4F,$8C,$48,$4F,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$4F,$8F,$48,$4F,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$4F,$8F,$48,$4F,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $4F,$8F,$48,$D3,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$E6
        .BYTE $8F,$48,$D4,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$E7,$8F
        .BYTE $49,$30,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$30,$90

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
j172F   LDA TMP_SPRITE_X_LO
        SEC
        SBC #$10     ;#%00010000
        PHP
        LSR A
        LSR A
        LSR A
        PLP
        BCC _L00

        LDY TMP_SPRITE_X_HI
        BEQ _L00

        CLC
        ADC #$20     ;#%00100000

_L00    STA pFB,b
        LDA #$00     ;#%00000000
        STA pFC,b
        STA pFD,b
        STA pFE,b
        LDA TMP_SPRITE_Y
        SEC
        SBC #$1E     ;#%00011110
        LSR A
        LSR A
        LSR A
        CLC
        ADC V_SCROLL_ROW_IDX
        PHA
        LSR A
        ROR pFC,b
        LSR A
        ROR pFC,b
        LSR A
        ROR pFC,b
        STA pFD,b
        PLA
        ASL A
        ROL pFE,b
        ASL A
        ROL pFE,b
        ASL A
        ROL pFE,b
        CLC
        ADC pFC,b
        STA pFC,b
        LDA pFD,b
        ADC pFE,b
        STA pFD,b
        LDA pFC,b
        CLC
        ADC pFB,b
        STA pFC,b
        LDA pFD,b
        ADC #$00
        STA pFD,b
        LDA pFD,b
        CLC                 ;FIXME: CLC/ADC could be replaced with ORA
        ADC LVL_MAP_MSB
        STA pFD,b
        RTS

        ; CHARSET_MASK_TBL
        ; Bit 0 = ??
        ; Bit 1 = Used for sprite-char background priority.
        ; Bit 2 = ??
        ; LVL0 data. Used by ($2A)
LVL0_CHARSET_MASK_TBL    ;$17A9
        .BYTE $00,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$00,$00,$00,$02,$02,$00
        .BYTE $00,$00,$01,$01,$00,$00,$00,$00
        .BYTE $01,$00,$01,$01,$02,$00,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $00,$01,$00,$00,$00,$00,$00,$01
        .BYTE $01,$02,$03,$01,$00,$03,$01,$01
        .BYTE $03,$01,$03,$02,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$02
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $02,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$00,$00,$02,$01,$01,$01
        .BYTE $00,$02,$02,$03,$00,$01,$01,$00
        .BYTE $00,$00,$00,$00,$02,$01,$00,$02
        .BYTE $02,$02,$02,$02,$02,$02,$01,$01
        .BYTE $00,$01,$01,$01,$01,$01,$01,$00
        .BYTE $02,$02,$01,$01,$01,$00,$01,$01
        .BYTE $01,$01,$02,$02,$02,$03,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $02,$01,$01,$01,$01,$03,$02,$01
        .BYTE $03,$02,$01,$03,$00,$01,$01,$00

        ; LVL1 data. Used by ($2A)
LVL1_CHARSET_MASK_TBL   ;$18A9
        .BYTE $00,$04,$04,$04,$04,$04,$04,$04
        .BYTE $04,$04,$04,$04,$04,$04,$04,$04
        .BYTE $02,$02,$02,$02,$02,$02,$00,$00
        .BYTE $00,$04,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$04,$04,$04,$00,$04
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$02,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$01,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$00,$01,$01,$01,$01
        .BYTE $01,$01,$01,$00,$00,$00,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$00,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$00,$00,$00,$00,$01,$01
        .BYTE $01,$01,$01,$00,$01,$01,$01,$01
        .BYTE $00,$01,$01,$01,$01,$01,$01,$00
        .BYTE $02,$02,$01,$01,$01,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$01,$01
        .BYTE $00,$00,$00,$00,$00,$00,$00,$01
        .BYTE $02,$00,$01,$01,$01,$03,$02,$01
        .BYTE $03,$02,$01,$03,$00,$01,$01,$00

        ; LVL2 data (not used). FIXME: remove
LVL2_CHARSET_MASK_TBL
        .BYTE $00,$04,$04,$04,$04,$04,$04,$04
        .BYTE $04,$04,$04,$04,$04,$04,$04,$04
        .BYTE $02,$02,$01,$01,$01,$01,$00,$00
        .BYTE $00,$00,$01,$01,$01,$01,$00,$00
        .BYTE $01,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$01,$01,$01,$00,$01
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$02,$01,$01,$00,$01,$01,$00
        .BYTE $01,$01,$01,$01,$01,$00,$00,$00
        .BYTE $00,$00,$01,$01,$01,$01,$01,$02
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$00,$00,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$02,$01,$01,$01
        .BYTE $00,$01,$01,$01,$01,$01,$01,$00
        .BYTE $01,$01,$00,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $02,$01,$01,$01,$01,$03,$02,$01
        .BYTE $03,$02,$01,$03,$00,$01,$01,$00

        ; LVL3 data. Used by $2A
LVL3_CHARSET_MASK_TBL   ;$1AA9
        .BYTE $00,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$00,$02,$02,$02,$02,$00
        .BYTE $00,$02,$00,$00,$00,$02,$02,$02
        .BYTE $00,$00,$01,$01,$02,$04,$00,$00
        .BYTE $01,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$04,$04,$04,$04,$04,$04,$04
        .BYTE $04,$04,$04,$04,$04,$01,$01,$01
        .BYTE $01,$01,$04,$04,$04,$04,$04,$00
        .BYTE $04,$04,$04,$04,$04,$04,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $00,$00,$04,$04,$04,$04,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$00,$01,$01,$01,$01,$00,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$04,$04,$04,$02,$01,$01,$01
        .BYTE $01,$02,$02,$00,$01,$01,$02,$02
        .BYTE $01,$02,$00,$00,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $00,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$00,$01,$02,$00

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Execute actions according to the scroll Y position
; An action can to create a new enemy (obj), or things like open the door
; that don't require any kind of object creation.
;
; For the case of new objects, one seat must be available for the sprite
; creation but it might be possible that the new object uses an extra
; sprite (like the bike that requires two) in case an extra seat is
; available.
;
; It is possible that two different actions creates the same sprite
; type. This happens when it wants to create the same sprite type, but
; the sprite type must be init in a different way. E.g: one for placing
; the sprite type at the left, and the other at the right of the screen.
;
; TODO: How many actions per row are possible? 8?
RUN_ACTIONS   ;$1BA9
        LDY TRIGGER_ROW_IDX
        LDA (p24),Y
        CMP V_SCROLL_ROW_IDX
        BEQ _L00
        RTS

_L00    INC TRIGGER_ROW_IDX

        ; Find empty seat
        LDX #(TOTAL_MAX_SPRITES-5-1)
_L01    LDA SPRITES_TYPE05,X
        BEQ _L04
        DEX
        BPL _L01

        ; FIXME: Loop tried twice, probably a bug. Remove

        LDX #(TOTAL_MAX_SPRITES-5-1)
_L02    LDA SPRITES_TYPE05,X
        BEQ _L04
        DEX
        BPL _L02

        ; If an empty seat (type == 0) cannot be found, try reusing one with
        ; lower priority

        ; Lower priority ones:
        ; $08, $09, $13, $0C, $06, $0B, $05
        LDX #(TOTAL_MAX_SPRITES-1-5)
_L03    LDA SPRITES_TYPE05,X
        CMP #$08        ;anim_type_08: soldier bullet
        BEQ _L04
        CMP #$09        ;anim_type_09: soldier bullet end
        BEQ _L04
        CMP #$13        ;anim_type_13: delayed cleanup
        BEQ _L04
        CMP #$0C        ;anim_type_0C: explosion
        BEQ _L04
        CMP #$06        ;anim_type_06: soldier die
        BEQ _L04
        CMP #$0B        ;anim_type_0B: grenade
        BEQ _L04
        CMP #$05        ;anim_type_05: regular solider
        BEQ _L04
        DEX
        BPL _L03

        ; It might be possible that a new sprite cannot be alloced
        RTS

        ; Create the action

_L04    STY pFD,b
        LDA (p28),Y
        ASL A
        TAY
        LDA ACTION_TBL,Y
        STA pFB,b
        LDA ACTION_TBL+1,Y
        STA pFC,b
        JMP (pFB)

ACTION_TBL                              ;$1C06
        .ADDR ACTION_NEW_SOLDIER_BEHIND_TRENCH  ;$00
        .ADDR ACTION_NEW_JUMPING_SOLDIER_R      ;$01
        .ADDR ACTION_NEW_JUMPING_SOLDIER_L      ;$02
        .ADDR ACTION_NEW_MORTAR_ENEMY           ;$03
        .ADDR ACTION_NEW_BIKE_LVL0              ;$04
        .ADDR ACTION_NEW_POW_GUARD              ;$05
        .ADDR ACTION_NEW_POW                    ;$06
        .ADDR ACTION_NEW_GRENADE_BOX            ;$07
        .ADDR ACTION_NEW_SOLDIER_FROM_SIDE_L    ;$08
        .ADDR ACTION_NEW_SOLDIER_FROM_SIDE_R    ;$09
        .ADDR ACTION_NEW_SOLDIER_FROM_SIDE_R_B  ;$0A
        .ADDR ACTION_OPEN_DOOR                  ;$0B
        .ADDR ACTION_0C                         ;$0C
        .ADDR ACTION_NEW_BOSS_LVL0              ;$0D
        .ADDR ACTION_NEW_SOLDIER_IN_TRENCH      ;$0E
        .ADDR ACTION_NEW_TURRET_CANNON_L        ;$0F
        .ADDR ACTION_NEW_TURRET_CANNON_R        ;$10
        .ADDR ACTION_NEW_BAZOOKA_ENEMY_R        ;$11
        .ADDR ACTION_NEW_BAZOOKA_ENEMY_L        ;$12
        .ADDR ACTION_NEW_BIKE_LVL1              ;$13
        .ADDR ACTION_NEW_TRUCK                  ;$14
        .ADDR ACTION_NEW_CART_UP_LVL1           ;$15
        .ADDR ACTION_NEW_PINK_CAR               ;$16
        .ADDR ACTION_17                         ;$17
        .ADDR ACTION_18                         ;$18
        .ADDR ACTION_NEW_SOLDIER_IN_TOWER       ;$19
        .ADDR ACTION_1A                         ;$1A
        .ADDR ACTION_VOID                       ;$1B

        ; LVL0 data
LVL0_TRIGGER_ROW_TBL    ;$1C3E
        .BYTE $9E,$9B,$98,$90,$8E,$84,$81,$7E
        .BYTE $7B,$7B,$7B,$66,$64,$5B,$5B,$57
        .BYTE $56,$54,$53,$50,$4D,$4A,$46,$3E
        .BYTE $3E,$3E,$37,$34,$2E,$2E,$29,$26
        .BYTE $1E,$19,$19,$14,$11,$01,$00,$00
        .BYTE $FF
LVL0_SPRITE_X_LO_TBL
        .BYTE $00,$00,$00,$14,$F0,$00,$00,$00
        .BYTE $E6,$D2,$BE,$32,$1E,$00,$00,$50
        .BYTE $00,$50,$AE,$1E,$50,$76,$BE,$2B
        .BYTE $A5,$1D,$46,$28,$14,$2E,$2E,$28
        .BYTE $A4,$1E,$3C,$1E,$14,$00,$00,$00
LVL0_SPRITE_X_HI_TBL    ;$1C8F
        .BYTE $00,$00,$00,$FF,$00,$00,$00,$00
        .BYTE $00,$00,$00,$FF,$FF,$00,$00,$58
        .BYTE $00,$58,$00,$00,$58,$00,$00,$00
        .BYTE $00,$FF,$00,$00,$FF,$FF,$00,$00
        .BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
LVL0_ACTION_TBL         ;$1CB7
        .BYTE $01,$01,$01,$00,$07,$02,$02,$02
        .BYTE $05,$06,$05,$03,$07,$04,$0C,$08
        .BYTE $0C,$09,$00,$00,$08,$00,$00,$00
        .BYTE $00,$00,$00,$07,$00,$00,$00,$07
        .BYTE $00,$00,$00,$00,$07,$0B,$0D,$1B

        ; LVL1 data
LVL1_TRIGGER_ROW_TBL    ;$1CDF
        .BYTE $A5,$A2,$9D,$9B,$9B,$96,$95,$95
        .BYTE $93,$8C,$8C,$8A,$88,$83,$7B,$7B
        .BYTE $7B,$74,$70,$68,$61,$5E,$52,$51
        .BYTE $46,$3D,$3D,$3A,$29,$1B,$01,$00
        .BYTE $FF
LVL1_SPRITE_X_LO_TBL    ;$1D00
        .BYTE $00,$32,$00,$DC,$0A,$00,$3C,$5A
        .BYTE $F0,$96,$B4,$28,$32,$32,$D2,$F0
        .BYTE $14,$32,$C8,$00,$50,$50,$00,$00
        .BYTE $C8,$6E,$00,$00,$00,$00,$00,$00
LVL1_SPRITE_X_HI_TBL    ;$1D20
        .BYTE $00,$00,$00,$00,$FF,$00,$00,$00
        .BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
        .BYTE $FF,$00,$00,$00,$63,$63,$00,$00
        .BYTE $00,$3F,$00,$00,$00,$00,$00,$00
LVL1_ACTION_TBL         ;$1D40
        .BYTE $15,$07,$0E,$16,$0E,$13,$0E,$0E
        .BYTE $0E,$0E,$0E,$07,$0E,$0E,$0E,$0E
        .BYTE $0E,$0E,$07,$0C,$08,$09,$12,$11
        .BYTE $0E,$09,$0F,$0C,$10,$0F,$0B,$1B

        ; LVL2 data
        ; FIXME: all LVL2 data can be removed since it is not used.
LVL2_TRIGGER_ROW_TBL
        .BYTE $C6,$C4,$B5,$B4,$A7,$9D,$97,$95
        .BYTE $87,$81,$68,$68,$5E,$5E,$50,$4B
        .BYTE $3C,$36,$32,$28,$09,$09,$01,$00
        .BYTE $00,$FF

LVL2_SPRITE_X_LO_TBL
        .BYTE $F5,$3F,$21,$E9,$90,$38,$1E,$AA
        .BYTE $E2,$5F,$00,$00,$50,$50,$00,$00
        .BYTE $00,$00,$00,$00,$0E,$4A,$00,$00
        .BYTE $00
LVL2_SPRITE_X_HI_TBL
        .BYTE $00,$00,$00,$00,$00,$00,$FF,$00
        .BYTE $00,$00,$00,$00,$63,$63,$00,$00
        .BYTE $00,$00,$00,$00,$FF,$00,$00,$00
        .BYTE $00
LVL2_ACTION_TBL
        .BYTE $18,$18,$17,$17,$18,$18,$07,$17
        .BYTE $18,$18,$04,$0C,$08,$09,$14,$14
        .BYTE $16,$13,$16,$16,$03,$1A,$0B,$0D
        .BYTE $1B

        ; LVL3 data
LVL3_TRIGGER_ROW_TBL    ;$1DC5
        .BYTE $B4,$B3,$A4,$A3,$92,$8B,$8B,$83
        .BYTE $77,$74,$73,$61,$60,$5D,$58,$53
        .BYTE $50,$4E,$4C,$43,$3E,$3B,$3A,$26
        .BYTE $24,$1E,$1C,$18,$16,$0A,$0A,$02
        .BYTE $02,$00,$FF
LVL3_SPRITE_X_LO_TBL    ;$1DE8
        .BYTE $00,$00,$00,$00,$00,$28,$41,$50
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$1E,$32,$00,$00,$00,$00
        .BYTE $00,$00,$1E,$00,$00,$47,$1E,$78
        .BYTE $E6,$00
LVL3_SPRITE_X_HI_TBL    ;$1E0A
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$FF,$FF,$00,$00,$00,$00
        .BYTE $00,$00,$FF,$00,$00,$00,$FF,$00
        .BYTE $00,$00
LVL3_ACTION_TBL         ;$1E2C
        .BYTE $12,$11,$12,$12,$11,$00,$00,$07
        .BYTE $13,$11,$12,$13,$12,$14,$14,$11
        .BYTE $12,$12,$07,$19,$11,$12,$11,$12
        .BYTE $12,$12,$07,$11,$11,$00,$00,$00
        .BYTE $00,$1B

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_1B
ACTION_VOID        ;$1E4E
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_1A
; Create sprite type: $28
; Unused. Only referenced from LVL2.
; FIXME: remove me
ACTION_1A       ;$1E4F
        JSR ACTION_NEW_MORTAR_ENEMY
        LDA #$28        ;anim_type_28:
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_19
ACTION_NEW_SOLDIER_IN_TOWER       ;$1E58
        JSR ACTION_NEW_SOLDIER_BEHIND_TRENCH
        LDA #$27        ;anim_type_27: tower in lvl3 shoot
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0B
; Open door
ACTION_OPEN_DOOR    ;$1E61
        LDA #$02     ;Draw open door
        JMP LEVEL_PATCH_DOOR

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_18
; Unused action. Only used in LVL2, which is not present in the game.
; Uses anim_type_26
; FIXME: remove me
ACTION_18       ;$1E66
        LDA #$06     ;#%00000110
        STA SPRITES_TMP_B05,X
        LDA #$F5     ;Frame: Door right open?
        STA SPRITES_PTR05,X
        JMP j1E7D

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_17
; Unused action. Only used in LVL2, which is not present in the game.
; FIXME: remove me
ACTION_17       ;$1E73
        LDA #$0A     ;#%00001010
        STA SPRITES_TMP_B05,X
        LDA #$F4     ;Frame: Door left open?
        STA SPRITES_PTR05,X

        ; fall-through

j1E7D   LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$28
        STA SPRITES_Y05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA (p26),Y
        STA SPRITES_X_HI05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        JSR GET_RANDOM
        STA SPRITES_TMP_C05,X
        LDA #$FF
        STA SPRITES_BKG_PRI05,X
        LDA #$26            ;anim_type_26:
        STA SPRITES_TYPE05,X
        RTS

f1EAD   .BYTE $78,$D2

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_15
ACTION_NEW_CART_UP_LVL1     ;$1EAF
        JSR GET_RANDOM
        AND #$01
        TAY
        LDA f1EAD,Y
        STA SPRITES_X_LO05,X
        LDA #$B8
        STA SPRITES_Y05,X
        LDA #$FE            ;go up
        STA SPRITES_DELTA_Y05,X
        LDA #$F3            ;cart going up frame
        STA SPRITES_PTR05,X
        LDA #$06     ;blue
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        STA SPRITES_BKG_PRI05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_TMP_C05,X
        LDA #$08
        STA SPRITES_TMP_B05,X
        LDA #$25            ;anim_type_25: cart in lvl2 going up
        STA SPRITES_TYPE05,X
        LDA #$05
        JSR SFX_PLAY
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_14
; Create truck that carries soldiers in LVL3.
; Moves horizontally from R to L.
ACTION_NEW_TRUCK       ;$1EED
        LDA #$3E
        STA SPRITES_X_LO05,X
        LDA #$64
        STA SPRITES_Y05,X
        LDA #$F1
        STA SPRITES_PTR05,X
        LDA #$08     ;orange
        STA SPRITES_COLOR05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$23            ;anim_type_23: void
        STA SPRITES_TYPE05,X

        ; Find empty seat
        LDY #$00
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L01
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L00
        RTS

_L01    TYA
        STA SPRITES_TMP_A05,X                     ;links Y with X
        LDA #$56
        STA SPRITES_X_LO05,Y
        LDA #$64
        STA SPRITES_Y05,Y
        LDA #$F2
        STA SPRITES_PTR05,Y
        LDA #$08     ;orange
        STA SPRITES_COLOR05,Y
        LDA #$FF
        STA SPRITES_X_HI05,Y
        LDA #$FF
        STA SPRITES_DELTA_X05,Y
        LDA #$00
        STA SPRITES_DELTA_Y05,Y
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$24            ;anim_type_24:solider jump (from truck)
        STA SPRITES_TYPE05,Y
        TXA
        STA SPRITES_TMP_A05,Y                     ;links X with Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_16
; Create the pink car that moves horizontally, from left to right at the
; beginning of LVL1.
; Uses anim_type_22.
; Requires an extra empty seat
ACTION_NEW_PINK_CAR     ;$1F5F
        ; FIXME: Might override existing seat. ACTION_NEW_BIKE_LVL1 might fail
        ; if no extra seat is found. The fix should be:
        ; If Y == #$0B, ret
        JSR ACTION_NEW_BIKE_LVL1

        LDA #$1E
        STA SPRITES_X_LO05,X
        LDA #$36
        STA SPRITES_X_LO05,Y
        LDA #$00
        STA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$B6            ;car back frame
        STA SPRITES_PTR05,X
        LDA #$B7            ;car front frame
        STA SPRITES_PTR05,Y
        LDA #$04            ;purple
        STA SPRITES_COLOR05,X
        STA SPRITES_COLOR05,Y
        LDA #$02            ;Move right
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_13
; Create bike that moves horizontally from R to L at LVL1.
; Requires an extra empty seat
ACTION_NEW_BIKE_LVL1       ;$1F8F
        LDY #$00
        ; Find empty seat
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L01
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L00
        RTS

_L01    TYA
        STA SPRITES_TMP_A05,X             ;links Y with X
        LDA #$3E
        STA SPRITES_X_LO05,X
        LDA #$82
        STA SPRITES_Y05,X
        LDA #$B0                ;bike front frame
        STA SPRITES_PTR05,X
        LDA #$0B                ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FE
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$22                ;anim_type_22
        STA SPRITES_TYPE05,X

        TXA
        STA SPRITES_TMP_A05,Y             ;links X with Y
        LDA #$56
        STA SPRITES_X_LO05,Y
        LDA #$82
        STA SPRITES_Y05,Y
        LDA #$B1                ;bike back frame
        STA SPRITES_PTR05,Y
        LDA #$0B                ;dark grey
        STA SPRITES_COLOR05,Y
        LDA #$FF
        STA SPRITES_X_HI05,Y
        LDA #$FE                ;move left
        STA SPRITES_DELTA_X05,Y
        LDA #$00
        STA SPRITES_DELTA_Y05,Y
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$10                ;anim_type_10: void. No amin for back part
        STA SPRITES_TYPE05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_11
ACTION_NEW_BAZOOKA_ENEMY_R  ;$2001
        LDA #$46
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$1E
        STA SPRITES_Y05,X
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        LDA #$0C     ;#%00001100
        STA SPRITES_TMP_B05,X
        JMP INIT_NEW_BAZOOKA_ENEMY

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_12
ACTION_NEW_BAZOOKA_ENEMY_L  ;$201D
        LDA #$32
        STA SPRITES_X_LO05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        LDA #$1E
        STA SPRITES_Y05,X
        LDA #$04
        STA SPRITES_TMP_B05,X
        LDA #$01
        STA SPRITES_DELTA_X05,X

        ; Fall-through

INIT_NEW_BAZOOKA_ENEMY
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y05,X
        LDA #$E6     ;#%11100110
        STA SPRITES_PTR05,X
        LDA #$06     ;blue
        STA SPRITES_COLOR05,X
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$20     ;anim_type_20: bazooka enemy
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0F
; creates the left cannon (inside the turret). Appears in lvl1
ACTION_NEW_TURRET_CANNON_L      ;$2053
        LDA #$2C
        STA SPRITES_X_LO05,X
        LDA #$24
        STA SPRITES_Y05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA #$FC
        STA SPRITES_PTR05,X
        LDA #$08     ;orange
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$06
        STA SPRITES_TMP_B05,X
        LDA #$1E        ;anim_type_1E: turret fire
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_10
; creates the right cannon (inside the turret). Appears in lvl1
ACTION_NEW_TURRET_CANNON_R     ;$2082
        LDA #$30
        STA SPRITES_X_LO05,X
        LDA #$1E
        STA SPRITES_Y05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$FD     ;Cannon in turret
        STA SPRITES_PTR05,X
        LDA #$08     ;orange
        STA SPRITES_COLOR05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$0A
        STA SPRITES_TMP_B05,X
        LDA #$1E    ;anim_type_1E: turret fire
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0D
; Creates the boss from lvl0
ACTION_NEW_BOSS_LVL0  ;$20B1
        LDA #$A0
        STA SPRITES_X_LO05,X
        LDA #$50
        STA SPRITES_Y05,X
        LDA #$01
        STA SPRITES_DELTA_Y05,X
        LDA #$08
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA #$B9    ;boss l1 frame
        STA SPRITES_PTR05,X
        LDA #$05     ;green
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        JSR GET_RANDOM
        AND #$1F     ;#%00011111
        STA SPRITES_TMP_C05,X
        LDA #$00
        STA SPRITES_BKG_PRI05,X
        LDA #$1A    ;anim_type_1A: boss l1
        STA SPRITES_TYPE05,X
        JSR GET_RANDOM
        AND #$01
        ASL A
        SEC
        SBC #$01
        STA SPRITES_DELTA_X05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0A
; Create sprite "soldier from side b" which seems to be more or less similar
; to the regular "sprite from side".
; TODO: investigate the differences
ACTION_NEW_SOLDIER_FROM_SIDE_R_B ;$20F6
        LDA #$1E
        STA SPRITES_Y05,X
        LDA #$5A
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA #$D5    ;soldier from side r frame
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$18        ;anim_type_18: soldier from side B
        STA SPRITES_TYPE05,X
        LDA #$0C     ;#%00001100
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_07
; Create sprite type $16
ACTION_NEW_GRENADE_BOX  ;$212F
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$26
        STA SPRITES_Y05,X
        LDA #$BB        ;grenade box frame
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA (p26),Y
        STA SPRITES_X_HI05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$16        ;anim_type_16: grenade box
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_06
; Create sprite type $12
ACTION_NEW_POW      ;$215F
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$21
        STA SPRITES_Y05,X
        LDA #$C2    ;POW frame
        STA SPRITES_PTR05,X
        LDA #$06     ;blue
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$12        ;anim_type_12: POW
        STA SPRITES_TYPE05,X
        STX POW_SPRITE_IDX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_05
; Create sprite type $11
ACTION_NEW_POW_GUARD    ;$2190
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$21
        STA SPRITES_Y05,X
        LDA #$C0     ;POW guard frame
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        STA POW_GUARDS_KILLED
        LDA #$11     ;anim_type_11: POW guard
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_04
; Create bike (sprite types $0f and $10) that crosses bridge in LVL0.
; This object requires two different sprite types: front and back bike.
; Creates the back one only if there is space for it.
ACTION_NEW_BIKE_LVL0         ;$21C1
        LDA #$20     ;#%00100000
        STA SPRITES_X_LO05,X
        LDA #$21     ;#%00100001
        STA SPRITES_Y05,X
        LDA #$B0     ;Bike Front. Anim #0
        STA SPRITES_PTR05,X
        LDA #$09     ;brown
        STA SPRITES_COLOR05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI05,X
        LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_X05,X
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$0F            ;anim_type_0F: bike in bridge (lvl 1)
        STA SPRITES_TYPE05,X

        ; If there is additional room, create the back bike sprite type
        ; as well.
        LDY #$00     ;#%00000000
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L01
        INY
        CPY #$0B     ;#%00001011
        BNE _L00
        RTS

_L01    TYA
        STA SPRITES_TMP_A05,X     ;links front with back
        LDA #$38     ;#%00111000
        STA SPRITES_X_LO05,Y
        LDA #$21     ;#%00100001
        STA SPRITES_Y05,Y
        LDA #$B1     ;Bike Back. Anim #0
        STA SPRITES_PTR05,Y
        LDA #$09     ;brown
        STA SPRITES_COLOR05,Y
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI05,Y
        LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_X05,Y
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y05,Y
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$10            ;anim_type_10: void
        STA SPRITES_TYPE05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Tries to create a new mortar enemy in case a seat is available.
; Seems to be unused (?)
        LDY #$00
b2231   LDA SPRITES_TYPE05,Y
        BEQ ACTION_NEW_MORTAR_ENEMY
        INY
        CPY #$0B     ;#%00001011
        BNE b2231
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_03
; Create the red mortar guy (sprite type: $0D)
ACTION_NEW_MORTAR_ENEMY    ;$223C
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$21     ;#%00100001
        STA SPRITES_Y05,X
        LDA #$CD     ;#%11001101
        STA SPRITES_PTR05,X
        LDA #$02     ;red
        STA SPRITES_COLOR05,X
        LDA (p26),Y
        STA SPRITES_X_HI05,X
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA a04EA
        LDA #$FF     ;#%11111111
        STA SPRITES_BKG_PRI05,X
        LDA #$0D            ;anim_type_0D: mortar enemy
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_00
; Create soldier behind trench (sprite type: $07)
ACTION_NEW_SOLDIER_BEHIND_TRENCH       ;$2271
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$26
        STA SPRITES_Y05,X
        LDA #$C8     ;Soldier in trench
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA (p26),Y
        STA SPRITES_X_HI05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$08
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA #$07            ;anim_type_07: soldier behind trench
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0E
ACTION_NEW_SOLDIER_IN_TRENCH    ;$22A9
        LDY pFD,b
        LDA (p22),Y
        STA SPRITES_X_LO05,X
        LDA #$2A
        STA SPRITES_Y05,X
        LDA #$ED
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA (p26),Y
        STA SPRITES_X_HI05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_BKG_PRI05,X
        JSR GET_RANDOM
        STA SPRITES_TMP_C05,X
        LDA #$08
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA #$1C            ;anim_type_1C: soldier in trench
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_01
; Create jumping sprite from right margin (sprite type: $0A)
ACTION_NEW_JUMPING_SOLDIER_R       ;$22E4
        LDY pFD,b
        LDA #$9F     ;#%10011111
        SEC
        SBC (p24),Y
        ASL A
        ASL A
        ASL A
        CLC
        ADC #$1E
        STA SPRITES_Y05,X
        LDA #$5A
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FE
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA #$D5
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$0A            ;anim_type_0A: jumping soldier
        STA SPRITES_TYPE05,X
        LDA #$0C
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_02
; Create jumping sprite from left margin (sprite type: $0A)
ACTION_NEW_JUMPING_SOLDIER_L       ;$2329
        LDY pFD,b
        LDA #$86     ;#%10000110
        SEC
        SBC (p24),Y
        ASL A
        ASL A
        ASL A
        CLC
        ADC #$1E
        STA SPRITES_Y05,X
        LDA #$01
        STA SPRITES_X_LO05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        LDA #$02
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA #$D9
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$0A            ;anim_type_0A: jumping soldier
        STA SPRITES_TYPE05,X
        LDA #$04
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_08
; Sprite is placed at the left of screen
ACTION_NEW_SOLDIER_FROM_SIDE_L  ;$236E
        LDA #$01
        STA SPRITES_X_LO05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        LDA #$02
        STA SPRITES_DELTA_X05,X
        LDA #$04
        STA SPRITES_TMP_B05,X
        JMP NEW_SOLDIER_FROM_SIDE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_09
; Sprite is placed at right of screen
ACTION_NEW_SOLDIER_FROM_SIDE_R  ;$2385
        LDA #$5A
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FE
        STA SPRITES_DELTA_X05,X
        LDA #$0C
        STA SPRITES_TMP_B05,X

        ; fall-through

NEW_SOLDIER_FROM_SIDE
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA #$D5    ;soldier from side heading west
        STA SPRITES_PTR05,X
        LDA #$0B    ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$17            ;anim_type_17: soldier from side type
        STA SPRITES_TYPE05,X
        LDY pFD,b
        LDA (p26),Y
        SEC
        SBC (p24),Y
        ASL A
        ASL A
        ASL A
        CLC
        ADC #$1E
        STA SPRITES_Y05,X
        LDA (p22),Y
        STA SPRITES_TMP_A05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: action_0C
; Creates a soldier from side that throws grenades
ACTION_0C       ;$23CC
        LDA #$1E
        STA SPRITES_Y05,X
        LDA #$5A
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA #$D5     ;soldier from side B
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$19            ;anim_type_19
        STA SPRITES_TYPE05,X
        LDA #$0C     ;#%00001100
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Add score based on killed enemy, and convert enemy sprite type into
; "enemy dying" type.
DIE_ANIM_AND_SCORE  ;$2405
        TYA
        PHA
        LDA SPRITES_TYPE05,Y
        TAY
        LDA POINTS_TBL,Y
        JSR SCORE_ADD
        PLA
        TAY
        LDA SPRITES_TYPE05,Y
        CMP #$07            ;anim_type_07: soldier behind trench
        BEQ _L00
        CMP #$1C            ;anim_type_1C: soldier in trench
        BNE _L01
_L00    LDA #$1D            ;anim_type_1D: soldier in trench die
        STA SPRITES_TYPE05,Y
        LDA #$CB            ;#%11001011
        STA SPRITES_PTR05,Y
        JMP _L06

_L01    LDA SPRITES_TYPE05,Y
        CMP #$1A            ;anim_type_1A: boss lvl0
        BNE _L02
        LDA #$BC            ;"2000" points sprite frame
        STA SPRITES_PTR05,Y
        LDA #$01            ;white
        STA SPRITES_COLOR05,Y
        LDA #$13            ;anim_type_13: delayed cleanup
        STA SPRITES_TYPE05,Y
        JMP _L06

_L02    LDA SPRITES_TYPE05,Y
        CMP #$11            ;anim_type_11: POW guard
        BNE _L03
        LDA SPRITES_TYPE01,X
        CMP #$04            ;anim_type_04: hero grenade
        BEQ _L03

        LDA #$BD            ;"1000" points sprite frame
        STA SPRITES_PTR05,Y
        LDA #$0E            ;light blue
        STA SPRITES_COLOR05,Y
        LDA #$13            ;anim_type_13: delayed cleanup
        STA SPRITES_TYPE05,Y
        INC POW_GUARDS_KILLED
        LDA POW_GUARDS_KILLED
        CMP #$02            ;how many guard killed? 2?
        BNE _L06

        TXA
        PHA
        LDX POW_SPRITE_IDX
        LDA #$14            ;anim_type_14: POW is freed
        STA SPRITES_TYPE05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_TMP_C05,X
        PLA
        TAX
        JMP _L06

_L03    LDA SPRITES_TYPE05,Y
        CMP #$23            ;anim_type_23: void
        BEQ _L04
        CMP #$24            ;anim_type_24: solider jumping (from truck)
        BNE _L05
_L04    TXA
        PHA
        LDX SPRITES_TMP_A05,Y
        JSR CONVERT_TO_TYPE_ANIM_EXPLOSION
        TYA
        TAX
        JSR CONVERT_TO_TYPE_ANIM_EXPLOSION
        PLA
        TAX
        JMP _L06

_L05    LDA #$06            ;anim_type_06: soldier die
        STA SPRITES_TYPE05,Y

_L06    LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_DELTA_X05,Y
        STA SPRITES_DELTA_Y05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Anim routine for enemies
ANIM_ENEMIES    ;$24B3
        LDX #$00     ;#%00000000
        STX ANY_ENEMY_IN_MAP

        ; If sprite is out of bounds, clean it up
_L00    LDA SPRITES_Y05,X
        CMP #$1E     ;#%00011110
        BCC _L01
        CMP #$C2     ;#%11000010
        BCS _L01
        LDA SPRITES_X_LO05,X
        CMP #$5B     ;#%01011011
        BCC _L02
        LDA SPRITES_X_HI05,X
        BEQ _L02
_L01    JSR CLEANUP_SPRITE

_L02    LDA SPRITES_TYPE05,X
        ASL A
        TAY
        LDA TYPE_ANIM_TBL,Y
        STA pFB,b
        LDA TYPE_ANIM_TBL+1,Y
        STA pFC,b
        INC a04E7
        JSR JMP_FB
        INX
        CPX #$0B
        BNE _L00

        RTS

JMP_FB              ;$24EF
        JMP (pFB)

        ; Animation table
TYPE_ANIM_TBL
        .ADDR TYPE_ANIM_SPAWN_SOLDIER           ;$00
        .ADDR TYPE_ANIM_BULLET                  ;$01
        .ADDR TYPE_ANIM_GRENADE                 ;$02
        .ADDR TYPE_ANIM_BULLET_END              ;$03
        .ADDR TYPE_ANIM_GRENADE_END             ;$04
        .ADDR TYPE_ANIM_SOLDIER                 ;$05
        .ADDR TYPE_ANIM_SOLDIER_DIE             ;$06
        .ADDR TYPE_ANIM_SOLDIER_BEHIND_SMTH     ;$07
        .ADDR TYPE_ANIM_SOLDIER_BULLET          ;$08
        .ADDR TYPE_ANIM_SOLDIER_BULLET_END      ;$09
        .ADDR TYPE_ANIM_SOLDIER_JUMPING         ;$0A
        .ADDR TYPE_ANIM_SOLDIER_GRENADE         ;$0B
        .ADDR TYPE_ANIM_EXPLOSION               ;$0C
        .ADDR TYPE_ANIM_MORTAR_ENEMY            ;$0D
        .ADDR TYPE_ANIM_MORTAR_BOMB             ;$0E
        .ADDR TYPE_ANIM_BIKE_IN_BRIDGE          ;$0F
        .ADDR TYPE_ANIM_VOID0                   ;$10
        .ADDR TYPE_ANIM_POW_GUARD               ;$11
        .ADDR TYPE_ANIM_POW                     ;$12
        .ADDR TYPE_ANIM_DELAYED_CLEANUP         ;$13
        .ADDR TYPE_ANIM_POW_FREE                ;$14
        .ADDR TYPE_ANIM_SOLIDER_GO_UP           ;$15
        .ADDR TYPE_ANIM_GRENADE_BOX             ;$16
        .ADDR TYPE_ANIM_SOLDIER_FROM_SIDE_A     ;$17
        .ADDR TYPE_ANIM_SOLDIER_FROM_SIDE_B     ;$18
        .ADDR TYPE_ANIM_19                      ;$19
        .ADDR TYPE_ANIM_BOSS_LVL0               ;$1A
        .ADDR TYPE_ANIM_SOLDIER_IN_FORT         ;$1B
        .ADDR TYPE_ANIM_SOLDIER_IN_TRENCH       ;$1C
        .ADDR TYPE_ANIM_SOLDIER_IN_TRENCH_DIE   ;$1D
        .ADDR TYPE_ANIM_TURRET_FIRE             ;$1E
        .ADDR TYPE_ANIM_TURRET_FIRE_END         ;$1F
        .ADDR TYPE_ANIM_BAZOOKA_ENEMY           ;$20
        .ADDR TYPE_ANIM_TURRET_FIRE_END         ;$21
        .ADDR TYPE_ANIM_22                      ;$22
        .ADDR TYPE_ANIM_VOID1                   ;$23
        .ADDR TYPE_ANIM_SOLDIER_JUMPING_FROM_TRUCK  ;$24
        .ADDR TYPE_ANIM_CART_UP_LVL1            ;$25
        .ADDR TYPE_ANIM_26                      ;$26
        .ADDR TYPE_ANIM_TOWER_FIRE_LVL3         ;$27
        .ADDR TYPE_ANIM_28                      ;$28

        ; Flags: bit0: bullet can kill it
        ;        bit1: grenade can kill it
f2544   .BYTE $00,$00,$00,$00,$00,$03,$00,$02
        .BYTE $00,$00,$03,$00,$00,$02,$00,$00
        .BYTE $00,$01,$00,$00,$00,$03,$00,$03
        .BYTE $03,$03,$03,$03,$02,$00,$02,$00
        .BYTE $03,$00,$00,$02,$02,$00,$00,$02
        .BYTE $02

        ; Points to score for each sprite type killed
POINTS_TBL      ;$256D
        .BYTE $00,$00,$00,$00,$00,$03,$00,$03
        .BYTE $00,$00,$03,$00,$00,$05,$00,$00
        .BYTE $00,$0A,$00,$00,$00,$03,$00,$03
        .BYTE $03,$03,$14,$03,$02,$00,$0A,$00
        .BYTE $05,$00,$00,$0A,$0A,$00,$00,$05
        .BYTE $05

f2596   ;Label used in self-modifying code
        ; By default points to incorrect place.

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_10
TYPE_ANIM_VOID0      ;$2596
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_28
; Only referenced from ACTION_1A, which is only used in LVL2.
; FIXME: remove me
TYPE_ANIM_28        ;$2597
        INC SPRITES_TMP_C05,X
        LDA a04EA
        BEQ _L02
        LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        CMP #$03     ;#%00000011
        BNE _L00
        LDA #$CF     ;Mortar guy
        STA SPRITES_PTR05,X
_L00    CMP #$0F     ;#%00001111
        BNE _L01

        LDA #$CE
        STA SPRITES_PTR05,X
_L01    CMP #$14     ;#%00010100
        BNE _L02

        LDA #$CD
        STA SPRITES_PTR05,X
        LDA #$00     ;#%00000000
        STA a04EA

_L02    LDA SPRITES_TMP_C05,X
        AND #$3F     ;#%00111111
        BEQ _L03
        RTS

_L03    JSR THROW_GRENADE
        LDA #$01
        STA a04EA
        CPY #$FF
        BEQ _L04

        LDA #$D0        ;bomb frame
        STA SPRITES_PTR05,Y
        LDA #$00        ;black
        STA SPRITES_COLOR05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$0E        ;anim_type_0E: bomb from mortar animation
        STA SPRITES_TYPE05,Y
_L04    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_27
; The animation of the tower in lvl3 with a guy firing at the hero.
TYPE_ANIM_TOWER_FIRE_LVL3   ;$25F0
        INC SPRITES_TMP_C05,X
        JSR SOLIDER_IN_TRENCH_AIM_TO_HERO
        JMP j33D0

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_26
; Unused, since it is only referenced from ACTION_17 and ACTION_18, only used
; in LVL2.
; FIXME: remove me
TYPE_ANIM_26            ;$25F9
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$7F     ;#%01111111
        BNE _L00

        LDA #$FF
        STA SPRITES_DELTA_Y05,X

_L00    LDA SPRITES_DELTA_Y05,X
        BEQ _L01
        LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        CMP #$0F     ;#%00001111
        BEQ _L03
        CMP #$1E     ;#%00011110
        BEQ _L02
_L01    RTS

_L02    LDA #$00
        STA SPRITES_DELTA_Y05,X
        RTS

_L03    LDA #$01
        STA SPRITES_DELTA_Y05,X

        ; Find empty seat
        LDY #$00
_L04    LDA SPRITES_TYPE05,Y
        BEQ _L05
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L04
        RTS

_L05    LDA SPRITES_X_LO05,X
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        CLC
        ADC #$10
        STA SPRITES_Y05,Y
        LDA #$05            ;anim_type_05: regular soldier
        STA SPRITES_TYPE05,Y
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        TXA
        PHA
        LDA SPRITES_TMP_B05,X
        STA SPRITES_TMP_B05,Y
        STA SPRITES_TMP_A05,Y
        TAX
        LDA DELTA_X_TBL,X
        STA SPRITES_DELTA_X05,Y
        LDA DELTA_Y_TBL,X
        STA SPRITES_DELTA_Y05,Y
        PLA
        TAX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_25
; The animation for the "cart" that appears going up at the very beginning of
; lvl1
TYPE_ANIM_CART_UP_LVL1  ;$2675
        INC SPRITES_TMP_C05,X
        JSR s3128
        JSR j33D0
        LDA SPRITES_TMP_C05,X
        CMP #$46
        BEQ _L00
        CMP #$8C
        BEQ _L01
        RTS

_L00    LDA #$FF
        STA SPRITES_DELTA_Y05,X
        RTS

_L01    LDA #$FE
        STA SPRITES_DELTA_Y05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_23
TYPE_ANIM_VOID1     ;$2696
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_24
; Truck from right that appears on lvl3 contains soldiers.
; This is the animation for those soldiers.
TYPE_ANIM_SOLDIER_JUMPING_FROM_TRUCK    ;$2697
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$3F     ;#%00111111
        BNE TYPE_ANIM_VOID1

        ; Find empty seat
        LDY #$00
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L01
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L00
        RTS

        ; Create a anim type $0A: jumping soldier

_L01    LDA SPRITES_X_LO05,X
        CLC
        ADC #$0A
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$0A            ;anim_type_0A: jumping soldier
        STA SPRITES_TYPE05,Y
        LDA #$08            ;dark grey
        STA SPRITES_COLOR05,Y
        LDA #$1D
        STA SPRITES_TMP_C05,Y
        LDA #$00
        STA SPRITES_BKG_PRI05,Y
        LDA #$01
        STA SPRITES_DELTA_X05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_22
TYPE_ANIM_22        ;$26DD
        INC SPRITES_TMP_C05,X
        LDY SPRITES_TMP_A05,X
        LDA SPRITES_TMP_C05,X
        AND #$0F            ;#%00001111
        BNE _L00            ;FIXME: probably it should say _L01 instead

        INC SPRITES_Y05,X
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
_L00    CMP #$10
        BNE _L01

        DEC SPRITES_Y05,X
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
_L01    RTS


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_unk
; Seems like an unused animation
TYPE_ANIM_UNUSED0
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$3C     ;#%00111100
        BEQ _L00
        RTS

_L00    LDA #$0C            ;anim_type_0C: explosion
        STA SPRITES_TYPE05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        TAY
        LDA FRAME_BULLET_END,Y
        STA SPRITES_PTR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_20
; Animation for the guys that fire the bazooka
TYPE_ANIM_BAZOOKA_ENEMY     ;$2724
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$07     ;#%00000111
        BNE _L00
        LDA SPRITES_TMP_C05,X
        AND #$18     ;#%00011000
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_BAZOOKA_GUY,Y
        STA SPRITES_PTR05,X
        LDY SPRITES_TMP_B05,X
        LDA DELTA_X_TBL,Y
        STA SPRITES_DELTA_X05,X
        LDA DELTA_Y_TBL,Y
        STA SPRITES_DELTA_Y05,X
_L00    LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        BEQ _L02
_L01    RTS

_L02    LDA SPRITES_Y00
        CMP SPRITES_Y05,X
        BCC _L01

        ; Find empty seat
        LDY #$00
_L03    LDA SPRITES_TYPE05,Y
        BEQ _L04
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L03
        RTS

_L04    LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,X
        LDA #$E8            ;Frame Bazooka guy #3
        STA SPRITES_PTR05,X
        LDA SPRITES_X_LO05,X
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
        LDA #$21            ;anim_type_21: turret fire end
        STA SPRITES_TYPE05,Y
        LDA #$01            ;white
        STA SPRITES_COLOR05,Y
        LDA #$EA            ;Frame bazooka left-down
        STA SPRITES_PTR05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$02
        STA SPRITES_DELTA_Y05,Y
        LDA SPRITES_X_HI05,X
        BNE _L05
        LDA SPRITES_X_LO05,X
        SEC
        SBC #$1E
        CMP SPRITES_X_LO00
        BCS _L05
        LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E
        CMP SPRITES_X_LO00
        BCC _L06
        LDA #$00
        STA SPRITES_DELTA_X05,Y
        LDA #$E9            ;Frame bazooka down
        STA SPRITES_PTR05,Y
        RTS

_L05    LDA #$FE
        STA SPRITES_DELTA_X05,Y
        LDA #$EA            ;Frame bazooka left-down
        STA SPRITES_PTR05,Y
        RTS

_L06    LDA #$02
        STA SPRITES_DELTA_X05,Y
        LDA #$EB            ;Frame bazooka right-down
        STA SPRITES_PTR05,Y
        RTS

FRAME_BAZOOKA_GUY       ;$27E0
        .BYTE $E5,$E6,$E7,$E6

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1E
; Turrets are the small houses that can be destroyed and appear on lvl1
TYPE_ANIM_TURRET_FIRE   ;$27E4
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$1F
        BEQ _L01
        RTS

_L01    LDA SPRITES_Y00
        CMP SPRITES_Y05,X
        BCC _L03

        ; Find empty seat
        LDY #$00
_L02    LDA SPRITES_TYPE05,Y
        BEQ _L04
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L02

_L03    RTS

_L04    LDA SPRITES_X_LO05,X
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
        LDA #$1F            ;anim_type_1F: turret fire end
        STA SPRITES_TYPE05,Y
        LDA #$00            ;black
        STA SPRITES_COLOR05,Y
        LDA #$D2            ;bullet frame
        STA SPRITES_PTR05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$01
        STA SPRITES_DELTA_Y05,Y
        LDA SPRITES_Y05,Y
        CLC
        ADC #$06
        STA SPRITES_Y05,Y
        LDA SPRITES_TMP_B05,X
        CMP #$06
        BEQ _L05
        LDA #$FE
        STA SPRITES_DELTA_X05,Y
        LDA SPRITES_X_LO05,Y
        SEC
        SBC #$08
        STA SPRITES_X_LO05,Y
        RTS

_L05    LDA #$02
        STA SPRITES_DELTA_X05,Y
        LDA SPRITES_X_LO05,Y
        CLC
        ADC #$08
        STA SPRITES_X_LO05,Y
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1D
; Found in lvl1 (might work other levels as well).
; Performs the "sprite in trench" die animation and then cleanup.
TYPE_ANIM_SOLDIER_IN_TRENCH_DIE     ;$2860
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$0A     ;#%00001010
        BEQ _L00
        CMP #$14     ;#%00010100
        BEQ _L01
        RTS

_L00    INC SPRITES_PTR05,X
        RTS

_L01    JMP CLEANUP_SPRITE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1C
TYPE_ANIM_SOLDIER_IN_TRENCH     ;$2876
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$70     ;#%01110000
        LSR A
        LSR A
        LSR A
        LSR A
        TAY
        LDA _TRENCH_FRAMES,Y
        STA SPRITES_PTR05,X
        CMP #$C8            ;soldier in trench heading south
        BEQ _L00
        RTS

_L00    LDA SPRITES_Y05,X
        CMP #$50
        BCC _L01
        JSR SOLIDER_IN_TRENCH_AIM_TO_HERO
_L01    JMP j33D0

_TRENCH_FRAMES
        .BYTE $EC,$ED,$C8,$C8,$C8,$ED,$EC,$EC

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Valid only for enemies: sprites 5-15
UPDATE_ENEMY_PATH     ;$28A3
        ; X
        LDA SPRITES_X_LO05,X
        CLC
        ADC SPRITES_DELTA_X05,X
        CLC
        ADC SPRITES_DELTA_X05,X
        CLC
        ADC SPRITES_DELTA_X05,X
        CLC
        ADC SPRITES_DELTA_X05,X
        STA TMP_SPRITE_X_LO

        ; Y
        LDA SPRITES_Y05,X
        CLC
        ADC SPRITES_DELTA_Y05,X
        CLC
        ADC SPRITES_DELTA_Y05,X
        CLC
        ADC SPRITES_DELTA_Y05,X
        CLC
        ADC SPRITES_DELTA_Y05,X
        STA TMP_SPRITE_Y

        LDA SPRITES_X_HI05,X
        STA TMP_SPRITE_X_HI
        JMP j172F

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
s28D8
        ; Get charset mask info
        LDY #$00
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        AND #$01     ;#%00000001
        BNE _L00

        LDA (p2A),Y
        AND #$04     ;#%00000100
        BEQ _L01

_L00    JSR GET_RANDOM
        AND #$07     ;#%00000111
        SEC
        SBC #$04     ;#%00000100
        CLC
        ADC SPRITES_TMP_A05,X
        CLC
        ADC #$08     ;#%00001000
        AND #$0F     ;#%00001111
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        TAY
        LDA DELTA_X_TBL,Y
        STA SPRITES_DELTA_X05,X
        LDA DELTA_Y_TBL,Y
        STA SPRITES_DELTA_Y05,X
_L01    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
UPDATE_ENEMY_BKG_PRI    ;$290E

        ; Get charset mask info
        LDY #$00
        LDA (pFC),Y
        TAY
        LDA #$00
        STA SPRITES_BKG_PRI05,X

        LDA (p2A),Y
        AND #$02     ;#%00000010
        BEQ _L00

        LDA #$FF
        STA SPRITES_BKG_PRI05,X
_L00    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1A
; Animation for Level 1 Boss
TYPE_ANIM_BOSS_LVL0     ;$2924
        JSR UPDATE_ENEMY_PATH
        JSR s28D8
        JSR UPDATE_ENEMY_BKG_PRI
        LDA SPRITES_DELTA_X05,X
        BPL _L00
        LDA GAME_TICK
        AND #$08     ;#%00001000
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_BOSS1_LEFT,Y
        STA SPRITES_PTR05,X
        RTS

_L00    LDA GAME_TICK
        AND #$08     ;#%00001000
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_BOSS1_RIGHT,Y
        STA SPRITES_PTR05,X
        RTS

FRAME_BOSS1_RIGHT       ;$2952
        .BYTE $B9,$BA
FRAME_BOSS1_LEFT        ;$2954
        .BYTE $EF,$F0

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_19
TYPE_ANIM_19        ;$2956
        INC SPRITES_TMP_C05,X
        LDA SPRITES_DELTA_X05,X
        ORA SPRITES_DELTA_Y05,X
        BEQ _L00
        LDA SPRITES_TMP_C05,X
        CMP #$64
        BNE _L04

_L00    LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA SPRITES_TMP_C05,X
        CMP #$C8
        BCS _L03
        AND #$0F     ;#%00001111
        BEQ _L01
        CMP #$08     ;#%00001000
        BEQ _L02
        RTS

_L01    LDA #$E3    ; soldier throw grenade #1-frame
        STA SPRITES_PTR05,X
        RTS

_L02    LDA #$E4    ; soldier throw grenade #2-frame
        STA SPRITES_PTR05,X
        JMP THROW_GRENADE

_L03    LDA #$04
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA #$01
        STA SPRITES_DELTA_X05,X
_L04    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_18
; Appears from the sides, specially at the beginning of lvl0
; Very common solider.
TYPE_ANIM_SOLDIER_FROM_SIDE_B   ;$29BB
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        AND #$3F
        BNE _L00

        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA #$E3     ;Frame enemy throw grenade
        STA SPRITES_PTR05,X
        RTS

_L00    CMP #$06
        BNE _L01
        INC SPRITES_PTR05,X
        JMP THROW_GRENADE

_L01    CMP #$14
        BNE _L02
        JSR GET_RANDOM
        AND #$01
        ASL A
        SEC
        SBC #$01
        CLC
        ADC SPRITES_TMP_A05,X
        AND #$0F
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        TAY
        LDA DELTA_X_TBL,Y
        STA SPRITES_DELTA_X05,X
        LDA DELTA_Y_TBL,Y
        STA SPRITES_DELTA_Y05,X
        RTS

_L02    CMP #$14
        BCC _L03
        LDA SPRITES_TMP_B05,X
        AND #$FE
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
_L03    JSR UPDATE_ENEMY_PATH
        JSR s28D8
        JSR UPDATE_ENEMY_BKG_PRI
        JSR j33D0
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_17
; Animates the soldiers that appears from the sides and moves mostly
; horizontally.
; Appears in lvl0, more or less after crossing the bridge
TYPE_ANIM_SOLDIER_FROM_SIDE_A     ;$2A34
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
        JSR UPDATE_ENEMY_PATH
        JSR UPDATE_ENEMY_BKG_PRI
        LDA SPRITES_TMP_C05,X
        CMP SPRITES_TMP_A05,X
        BEQ _L00
        RTS

_L00    LDA #$08     ;#%00001000
        STA SPRITES_TMP_B05,X
        TAY
        LDA DELTA_X_TBL,Y
        STA SPRITES_DELTA_X05,X
        LDA DELTA_Y_TBL,Y
        STA SPRITES_DELTA_Y05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_16
TYPE_ANIM_GRENADE_BOX   ;$2A78
        LDA SPRITES_X_HI00
        CMP SPRITES_X_HI05,X
        BNE _L00
        LDA SPRITES_X_LO00
        CLC
        ADC #$0F     ;#%00001111
        CMP SPRITES_X_LO05,X
        BCC _L00
        LDA SPRITES_X_LO00
        SEC
        SBC #$0F     ;#%00001111
        CMP SPRITES_X_LO05,X
        BCS _L00
        LDA SPRITES_Y00
        CLC
        ADC #$12     ;#%00010010
        CMP SPRITES_Y05,X
        BCC _L00
        LDA SPRITES_Y00
        SEC
        SBC #$0A     ;#%00001010
        CMP SPRITES_Y05,X
        BCS _L00
        LDA #$03     ;#%00000011
        SED
        CLC
        ADC GRENADES
        STA GRENADES
        CLD
        JSR SCREEN_REFRESH_GRENADES
        LDA #$0A
        JSR SCORE_ADD
        JSR CLEANUP_SPRITE
        LDA #$00     ;play "pick up grenade" sfx
        JSR SFX_PLAY
_L00    LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA GAME_TICK
        AND #$08     ;#%00001000
        BEQ _L01
        RTS

_L01    LDA #$08     ;orange
        STA SPRITES_COLOR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_14
TYPE_ANIM_POW_FREE  ;$2ADA
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$64     ;#%01100100
        BEQ _L00
        LDA GAME_TICK
        AND #$08     ;#%00001000
        LSR A
        LSR A
        LSR A
        TAY
        LDA _FRAME_POW_FREE,Y
        STA SPRITES_PTR05,X
        RTS

_L00    JMP CLEANUP_SPRITE

_FRAME_POW_FREE         ;$2AF7 (Pow == Prisoner of War)
        .BYTE $C4,$C5

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_13
TYPE_ANIM_DELAYED_CLEANUP   ;s2AF9
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$41     ;#%01000001
        BEQ _L00
        RTS

_L00    JMP CLEANUP_SPRITE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_12
TYPE_ANIM_POW   ;$2B07
        LDA GAME_TICK
        AND #$08     ;#%00001000
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_POW_RUN,Y
        STA SPRITES_PTR05,X
        LDA V_SCROLL_ROW_IDX
        CMP #$71     ;#%01110001
        BCS _L00
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_X05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_Y05,X
_L00    RTS

FRAME_POW_RUN       ;$2B28 (POW == Prisoner of War)
        .BYTE $C2,$C3

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_11
TYPE_ANIM_POW_GUARD     ;$2B2A
        LDA GAME_TICK
        AND #$08     ;#%00001000
        LSR A
        LSR A
        LSR A
        TAY
        LDA _FRAME_POW_GUARD,Y
        STA SPRITES_PTR05,X
        LDA V_SCROLL_ROW_IDX
        CMP #$71
        BCS _L00
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        LDA #$FF
        STA SPRITES_DELTA_Y05,X
_L00    RTS

_FRAME_POW_GUARD     ;$2B4B
        .BYTE $C0,$C1

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_0F
TYPE_ANIM_BIKE_IN_BRIDGE ;$2B4D
        INC SPRITES_TMP_C05,X
        LDY SPRITES_TMP_A05,X
        LDA SPRITES_X_LO05,X
        CMP #$A5
        BNE _L03

        ; Throw grenades when bike reaches X=$A5
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,Y
        LDA #$B2     ;Bike Front (throw grenade #0)
        STA SPRITES_PTR05,X
        LDA #$B3     ;Bike Back (throw grenade #0)
        STA SPRITES_PTR05,Y
        LDA SPRITES_TMP_C05,X
        AND #$10     ;#%00010000
        BEQ _L00
        LDA #$B4     ;Bike Front (throw grenade #1)
        STA SPRITES_PTR05,X
        LDA #$B5     ;Bike Back (throw grenade #1)
        STA SPRITES_PTR05,Y
_L00    LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        BNE _L01
        JSR THROW_GRENADE
        RTS

        ; Bike moving forward (left-direction)
_L01    LDA SPRITES_Y05,X
        CMP #$73
        BCC _L02
        LDA #$FF
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,Y
        LDA #$B0     ;Bike Front (ride)
        STA SPRITES_PTR05,X
        LDA #$B1     ;Bike Back (ride)
        STA SPRITES_PTR05,Y
_L02    RTS

_L03    LDA SPRITES_X_LO05,X
        AND #$1F     ;#%00011111
        BNE _L04
        INC SPRITES_Y05,X
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
_L04    CMP #$10     ;#%00010000
        BNE _L05
        DEC SPRITES_Y05,X
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
_L05    LDA SPRITES_X_LO05,X
        CMP #$B4     ;#%10110100
        BNE _L06
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,Y
        RTS

_L06    LDA SPRITES_X_LO05,X
        CMP #$A0     ;#%10100000
        BNE _L07
        LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_X05,Y
_L07    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_0D
TYPE_ANIM_MORTAR_ENEMY  ;$2BDF
        INC SPRITES_TMP_C05,X
        LDA a04EA
        BEQ _L02
        LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        CMP #$03     ;#%00000011
        BNE _L00
        LDA #$CF     ;Mortar guy frame #2
        STA SPRITES_PTR05,X
_L00    CMP #$0F     ;#%00001111
        BNE _L01
        LDA #$CE     ;Mortar guy frame #1
        STA SPRITES_PTR05,X
_L01    CMP #$14     ;#%00010100
        BNE _L02
        LDA #$CD     ;Mortar guy frame #0
        STA SPRITES_PTR05,X
        LDA #$00     ;#%00000000
        STA a04EA
_L02    LDA SPRITES_Y05,X
        CMP #$82     ;#%10000010
        BCC _L03
        LDA #$98     ;Frame Hero/Enemy heading up
        STA SPRITES_PTR05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        STA SPRITES_TMP_C05,X
        LDA #$FF
        STA SPRITES_DELTA_Y05,X
        LDA #$05            ;anim_type_05: regular solider
        STA SPRITES_TYPE05,X
        RTS

_L03    LDA SPRITES_TMP_C05,X
        AND #$3F     ;#%00111111
        BEQ _L04
        RTS

        ; Find empty seat
_L04    LDY #$00     ;#%00000000
_L05    LDA SPRITES_TYPE05,Y
        BEQ _L06
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L05
        RTS

_L06    LDA SPRITES_X_HI00
        BNE b2CC0
        LDA #$FF     ;#%11111111
        SEC
        SBC SPRITES_X_LO00
        CLC
        ADC #$2F     ;#%00101111
        BCS b2CC0
        STA pFB,b
        LDA SPRITES_Y00
        SEC
        SBC SPRITES_Y05,X
        STA pFC,b
        LDA #$CE     ;Motar guy frame #1
        STA SPRITES_PTR05,X
        LDA #$01
        STA a04EA
        LDA SPRITES_X_LO05,X
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        SEC
        SBC #$02     ;#%00000010
        STA SPRITES_Y05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        JSR s3555
        LDA pFB,b
        EOR #$FF     ;#%11111111
        STA pFB,b
        INC pFB,b
        LDA pFB,b
        BNE _L07
        LDA #$FF     ;#%11111111
_L07    STA SPRITES_DELTA_X05,Y
        LDA pFC,b
        STA SPRITES_DELTA_Y05,Y
        LDA SPRITES_DELTA_Y05,Y
        SEC
        SBC #$02
        STA SPRITES_DELTA_Y05,Y
        LDA #$D0            ;Big grenade #0
        STA SPRITES_PTR05,Y
        LDA #$00            ;black
        STA SPRITES_COLOR05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$0E            ;anim_type_0E: mortar bomb
        STA SPRITES_TYPE05,Y
b2CC0   RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Used to spawn the "regular solider".
f2CC1   .BYTE $29,$29,$32,$32       ;Sprite X lo
f2CC5   .BYTE $78,$A5,$78,$A5       ;Sprite Y
f2CC9   .BYTE $01,$01,$FF,$FF       ;Sprite delta X
f2CCD   .BYTE $04,$04,$0C,$0C       ;Sprite tmp
f2CD1   .BYTE $9B,$9B,$9B,$9B       ;Sprite frames
f2CD5   .BYTE $00,$00,$FF,$FF       ;Sprite X hi

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_00
; The animation that spawns regular soldiers, even at the end of the level
; This is called when there is at least an empty seat, since this is the
; animation handler for "empty seat". If there are no empty seats, then no
; extra "regular soldiers" are spawned, which makes sense.
TYPE_ANIM_SPAWN_SOLDIER      ;$2CD9
        LDA V_SCROLL_ROW_IDX
        BEQ _L00
        JMP _L05

        ; End of level logic
_L00    LDA ENEMIES_IN_FORT
        BEQ b2CC0
        JSR GET_RANDOM
        AND #$7F     ;#%01111111
        BNE b2CC0
        LDA #$3F                ;Restore frequency to normal at the end of level
        STA SHOOT_FREQ_MASK
        DEC ENEMIES_IN_FORT
        BNE _L01                ;FIXME: probably an "RTS" is missing here?

_L01    LDA LEVEL_NR
        AND #$03
        CMP #$03
        BEQ _L04

        CMP #$01
        BNE _L02

        JSR GET_RANDOM
        AND #$01
        BEQ _L03

        ; End of lvl0 - door
_L02    JSR GET_RANDOM
        AND #$3F     ;#%00111111
        CLC
        ADC #$8C
        STA SPRITES_X_LO05,X
        LDA #$3C
        STA SPRITES_Y05,X
        LDA #$1B            ;anim_type_1B: soldier in fort lvl0,1,3
        STA SPRITES_TYPE05,X
        INC ANY_ENEMY_IN_MAP
        JMP _L06

        ; End of lvl1 - soldiers from sides
_L03    JSR GET_RANDOM
        AND #$03     ;#%00000011
        TAY
        LDA f2CC1,Y
        STA SPRITES_X_LO05,X
        JSR GET_RANDOM
        AND #$07     ;#%00000111
        CLC
        ADC f2CC5,Y
        STA SPRITES_Y05,X
        LDA f2CD5,Y
        STA SPRITES_X_HI05,X
        LDA f2CC9,Y
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        LDA f2CCD,Y
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA f2CD1,Y
        STA SPRITES_PTR05,X
        LDA #$1B            ;anim_type_1B: soldier in fort lvl0,1,3
        STA SPRITES_TYPE05,X
        JMP _L07

        ; End of lvl3
_L04    JSR GET_RANDOM
        AND #$3F     ;#%00111111
        CLC
        ADC #$8C
        STA SPRITES_X_LO05,X
        LDA #$64
        STA SPRITES_Y05,X
        LDA #$1B            ;anim_type_1B: soldier in fort lvl0,1,3
        STA SPRITES_TYPE05,X
        INC ANY_ENEMY_IN_MAP
        JMP _L06

_L05    JSR GET_RANDOM
        AND #$03     ;#%00000011
        BNE _L08
        JSR GET_RANDOM
        AND #$FF     ;#%11111111
        BNE _L09
        JSR GET_RANDOM
        STA TMP_SPRITE_X_LO
        LDA #$28
        STA TMP_SPRITE_Y
        LDA #$00
        STA TMP_SPRITE_X_HI
        JSR j172F

        ; Get charset mask info
        LDY #$00
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        BNE _L09

        LDA TMP_SPRITE_X_LO
        STA SPRITES_X_LO05,X
        LDA TMP_SPRITE_Y
        STA SPRITES_Y05,X
        LDA #$05            ;anim_type_05: regular soldier
        STA SPRITES_TYPE05,X
_L06    LDA #$01
        STA SPRITES_DELTA_Y05,X
        LDA #$00
        STA SPRITES_DELTA_X05,X
        LDA #$08
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        LDA #$9B            ;soldier head south
        STA SPRITES_PTR05,X
        LDA #$00
        STA SPRITES_X_HI05,X
_L07    LDA #$0B            ;dark grey
        STA SPRITES_COLOR05,X
        JSR GET_RANDOM
        AND #$1F
        STA SPRITES_TMP_C05,X
        LDA #$00
        STA SPRITES_BKG_PRI05,X
_L08    RTS

_L09    JSR GET_RANDOM
        AND #$FF            ;#%11111111
        BEQ _L10
        RTS

_L10    JSR GET_RANDOM
        AND #$01     ;#%00000001
        BNE _L12
        JSR GET_RANDOM
        AND #$7F     ;#%01111111
        CLC
        ADC #$3C     ;#%00111100
        STA TMP_SPRITE_Y
        LDA #$18     ;#%00011000
        STA TMP_SPRITE_X_LO
        LDA #$00     ;#%00000000
        STA TMP_SPRITE_X_HI
        JSR j172F

        ; Get charset mask info
        LDY #$00
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        BEQ _L11
        RTS

_L11    LDA TMP_SPRITE_X_LO
        STA SPRITES_X_LO05,X
        LDA TMP_SPRITE_Y
        STA SPRITES_Y05,X
        LDA #$00
        STA SPRITES_X_HI05,X
        LDA #$01
        STA SPRITES_DELTA_X05,X
        LDA #$00
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$D9            ;soldier head east
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$14
        STA SPRITES_TMP_C05,X
        LDA #$18            ;anim_type_18: soldier from side B
        STA SPRITES_TYPE05,X
        JSR GET_RANDOM
        AND #$03     ;#%00000011
        CLC
        ADC #$02     ;#%00000010
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

_L12    JSR GET_RANDOM
        AND #$7F     ;#%01111111
        CLC
        ADC #$3C     ;#%00111100
        STA TMP_SPRITE_Y
        LDA #$3A     ;#%00111010
        STA TMP_SPRITE_X_LO
        LDA #$FF     ;#%11111111
        STA TMP_SPRITE_X_HI
        JSR j172F
        LDY #$00     ;#%00000000
        LDA (pFC),Y
        CMP #$30     ;#%00110000
        BNE _L13
        LDA TMP_SPRITE_X_LO
        STA SPRITES_X_LO05,X
        LDA TMP_SPRITE_Y
        STA SPRITES_Y05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_X05,X
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_BKG_PRI05,X
        LDA #$15     ;FIXME: sprite points at 0xc540.
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$14     ;#%00010100
        STA SPRITES_TMP_C05,X
        LDA #$18            ;anim_type_18: soldier from side B
        STA SPRITES_TYPE05,X
        JSR GET_RANDOM
        AND #$03     ;#%00000011
        CLC
        ADC #$0B     ;#%00001011
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        RTS

_L13    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_0B
TYPE_ANIM_SOLDIER_GRENADE   ;$2EBF
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$50     ;#%01010000
        BNE _L00
        JSR CONVERT_TO_TYPE_ANIM_EXPLOSION
        RTS

_L00    LDA SPRITES_TMP_C05,X
        LSR A
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_GRENADE0,Y
        STA SPRITES_PTR05,X
        LDA SPRITES_TMP_C05,X
        AND #$0F     ;#%00001111
        BNE _L01
        INC SPRITES_DELTA_Y05,X
_L01    RTS

FRAME_GRENADE0       ;$2EE6
        .BYTE $92,$91,$91,$92,$93

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Converts the current animation into an explosion animation.
; X=anim to be converted
CONVERT_TO_TYPE_ANIM_EXPLOSION       ;$2EEB
        LDA #$0C            ;anim_type_0C: explosion
        STA SPRITES_TYPE05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA #$AF
        STA SPRITES_PTR05,X
        LDA #$02     ;red
        STA SPRITES_COLOR05,X
        LDA IS_HERO_DEAD
        BNE _L00    ;FIXME: what should happen on the other condition?
_L00    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_0E
TYPE_ANIM_MORTAR_BOMB   ;$2F0B
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$50
        BNE _L00
        JSR CONVERT_TO_TYPE_ANIM_EXPLOSION
        RTS

_L00    LDA SPRITES_TMP_C05,X
        LSR A
        LSR A
        LSR A
        LSR A
        TAY
        LDA _BOMB_FRAMES,Y
        STA SPRITES_PTR05,X
        LDA SPRITES_TMP_C05,X
        AND #$0F     ;#%00001111
        BNE _L01
        INC SPRITES_DELTA_Y05,X
_L01    RTS

_BOMB_FRAMES
        .BYTE $D2,$D1,$D0,$D1,$D2

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_08
TYPE_ANIM_SOLDIER_BULLET       ;$2F37
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$46     ;#%01000110
        BEQ _L01
        LDA SPRITES_TMP_C05,X
        CMP #$16     ;#%00010110
        BCC _L00
        JSR UPDATE_ENEMY_PATH

        ; Get charset mask info
        LDY #$00     ;#%00000000
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        AND #$01     ;#%00000001
        BNE _L01

        LDA #$00
        STA SPRITES_BKG_PRI05,X
        LDA (p2A),Y
        AND #$02     ;#%00000010
        BEQ _L00

        LDA #$FF     ;#%11111111
        STA SPRITES_BKG_PRI05,X
_L00    RTS

_L01    LDA #$09            ;anim_type_09: soldier bullet end
        STA SPRITES_TYPE05,X
        LDA #$00
        STA SPRITES_TMP_C05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        TAY
        LDA FRAME_BULLET_END,Y
        STA SPRITES_PTR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1F / anim_type_21
TYPE_ANIM_TURRET_FIRE_END ;2F7F
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$5A     ;#%01011010
        BEQ _L00
        RTS

_L00    JMP CONVERT_TO_TYPE_ANIM_EXPLOSION

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_09
TYPE_ANIM_SOLDIER_BULLET_END   ;$2F8D
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$09     ;#%00001001
        BEQ _L00
        TAY
        LDA FRAME_BULLET_END,Y
        STA SPRITES_PTR05,X
        RTS

_L00    JSR _L01
        RTS

        ; Cleanup sprite
_L01    LDA #$00            ;anim_type_00: spawn soldiers
        STA SPRITES_TYPE05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA ORIG_SPRITE_Y05,X
        STA SPRITES_Y05,X
        LDA #$64     ;#%01100100
        STA SPRITES_X_LO05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI05,X
        STA SPRITES_PTR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_07
TYPE_ANIM_SOLDIER_BEHIND_SMTH   ;$2FC2
        INC SPRITES_TMP_C05,X
        LDA SPRITES_Y05,X
        CMP #$82
        BCC _L01
        LDA #$98
        STA SPRITES_PTR05,X
        LDA #$0B     ;dark grey
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        STA SPRITES_TMP_C05,X
        LDA #$FF
        STA SPRITES_DELTA_Y05,X
        JSR GET_RANDOM
        AND #$03     ;#%00000011
        SEC
        SBC #$02     ;#%00000010
        CMP #$FE     ;#%11111110
        BNE _L00
        LDA #$00
_L00    STA SPRITES_DELTA_X05,X

        ; Switch animation to "go up"
        LDA #$15            ;anim_type_15: soldier go up
        STA SPRITES_TYPE05,X
        LDA #$FF
        STA SPRITES_BKG_PRI05,X
        RTS

_L01    CMP #$50     ;#%01010000
        BCC _L02
        JSR SOLIDER_IN_TRENCH_AIM_TO_HERO
_L02    JMP j33D0

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Make the soldier in trench or behind something to aim to hero
SOLIDER_IN_TRENCH_AIM_TO_HERO
        LDA SPRITES_X_HI05,X
        CMP SPRITES_X_HI00
        BEQ _L00
        LDA SPRITES_X_HI00
        BNE _L03
        JMP _L01

_L00    LDA SPRITES_X_LO00
        CLC
        ADC #$32     ;#%00110010
        BCS _L02
        CMP SPRITES_X_LO05,X
        BCS _L02

_L01    LDA #$0A     ;#%00001010
        STA SPRITES_TMP_B05,X
        LDA #$CA     ;Soldier in trench: left
        STA SPRITES_PTR05,X
        JMP _L05

_L02    LDA SPRITES_X_LO00
        SEC
        SBC #$32     ;#%00110010
        BCC _L04
        CMP SPRITES_X_LO05,X
        BCC _L04

_L03    LDA #$06     ;#%00000110
        STA SPRITES_TMP_B05,X
        LDA #$C9     ;Soldier in trench: right
        STA SPRITES_PTR05,X
        JMP _L05

_L04    LDA #$08     ;#%00001000
        STA SPRITES_TMP_B05,X
        LDA #$C8     ;Soldier in trench: down
        STA SPRITES_PTR05,X
_L05    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_0A
TYPE_ANIM_SOLDIER_JUMPING        ;$305B
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$1E     ;#%00011110
        BNE _L01
        LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_Y05,X
        LDA SPRITES_DELTA_X05,X
        BPL _L00
        LDA #$C6     ;#%11000110
        STA SPRITES_PTR05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_X05,X
        RTS

_L00    LDA #$D3     ;#%11010011
        STA SPRITES_PTR05,X
        LDA #$01     ;#%00000001
        STA SPRITES_DELTA_X05,X
_L01    BCS _L02
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
        RTS

_L02    LDA SPRITES_TMP_C05,X
        CMP #$23     ;#%00100011
        BNE _L03
        INC SPRITES_PTR05,X
_L03    AND #$07     ;#%00000111
        BNE _L04
        INC SPRITES_DELTA_Y05,X
        LDA SPRITES_DELTA_Y05,X
        CMP #$03     ;#%00000011
        BEQ _L05
_L04    RTS

_L05    LDA #$98     ;#%10011000
        STA SPRITES_PTR05,X
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X05,X
        STA SPRITES_TMP_A05,X
        STA SPRITES_TMP_B05,X
        STA SPRITES_TMP_C05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_Y05,X
        LDA #$05            ;anim_type_05: regular soldier
        STA SPRITES_TYPE05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_15
; When the "soldier behind something" (see sprite_type_17) is below our Y
; position, it is converted into this sprite_type.
; This sprite_type moves the sprite up and kind of chase the hero.
TYPE_ANIM_SOLIDER_GO_UP     ;$30DD
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
        LDA SPRITES_TMP_C05,X
        BNE _L00
        LDA #$10     ;#%00010000
        STA SPRITES_TMP_C05,X
_L00    CMP #$0F     ;#%00001111
        BCC _L01
        JSR UPDATE_ENEMY_PATH
        JSR s28D8
        JSR UPDATE_ENEMY_BKG_PRI
_L01    JSR GET_RANDOM
        AND #$07     ;#%00000111
        BEQ s3128
        LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        BNE _L02
        JMP j3255

_L02    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Compares hero with sprite X, and based on positions updates 04AC var.
s3128   LDA SPRITES_X_HI05,X
        CMP SPRITES_X_HI00
        BCC _L01
        BNE _L04

        LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L01
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L04
        LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L00
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L07
        RTS

_L00    JMP _L10

_L01    LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L02
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L03
        LDA #$04     ;#%00000100
        STA SPRITES_TMP_B05,X
        RTS

_L02    LDA #$06     ;#%00000110
        STA SPRITES_TMP_B05,X
        RTS

_L03    LDA #$02     ;#%00000010
        STA SPRITES_TMP_B05,X
        RTS

_L04    LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L05
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L06
        LDA #$0C     ;#%00001100
        STA SPRITES_TMP_B05,X
        RTS

_L05    LDA #$0A     ;#%00001010
        STA SPRITES_TMP_B05,X
        RTS

_L06    LDA #$0E     ;#%00001110
        STA SPRITES_TMP_B05,X
        RTS

_L07    LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L08
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L09
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_B05,X
        RTS

_L08    LDA #$02     ;#%00000010
        STA SPRITES_TMP_B05,X
        RTS

_L09    LDA #$0E     ;#%00001110
        STA SPRITES_TMP_B05,X
        RTS

_L10    LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L11
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L12
        LDA #$08     ;#%00001000
        STA SPRITES_TMP_B05,X
        RTS

_L11    LDA #$06     ;#%00000110
        STA SPRITES_TMP_B05,X
        RTS

_L12    LDA #$0A     ;#%00001010
        STA SPRITES_TMP_B05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_1B
; Sprites that goes out of the fort in LVL0, LVL1 and LVL3
; Same logic as regular soldier but with some randomness at the beginning
TYPE_ANIM_SOLDIER_IN_FORT       ;$31F0
        INC ANY_ENEMY_IN_MAP
        JSR GET_RANDOM
        AND #$3F     ;#%00111111
        BNE TYPE_ANIM_SOLDIER
        JSR THROW_GRENADE
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X

        ; fall-through

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_05
TYPE_ANIM_SOLDIER        ;$3205
        INC SPRITES_TMP_C05,X
        LDA SPRITES_DELTA_X05,X
        ORA SPRITES_DELTA_Y05,X
        BEQ _L00
        LDA SPRITES_TMP_B05,X
        AND #$FE
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        LDA GAME_TICK
        AND #$0C
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR05,X
        JMP _L01

_L00    LDA #$E4
        STA SPRITES_PTR05,X
_L01    JSR UPDATE_ENEMY_PATH
        JSR s28D8
        JSR UPDATE_ENEMY_BKG_PRI
        JSR j33D0
        LDA SPRITES_TMP_C05,X
        AND #$1F     ;#%00011111
        BEQ j3255
        LDA GAME_TICK
        AND #$1F     ;#%00011111
        BNE _L02
        JSR s3128
_L02    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
j3255   JSR GET_RANDOM
        AND #$01     ;#%00000001
        BNE _L04
        LDA SPRITES_X_HI05,X
        CMP SPRITES_X_HI00
        BEQ _L01
        BCC _L00
        LDA #$0C     ;#%00001100
        STA pFB,b
        JMP _L02

_L00    LDA #$04     ;#%00000100
        STA pFB,b
        JMP _L02

_L01    LDA #$04     ;#%00000100
        STA pFB,b
        LDA SPRITES_X_LO00
        SEC
        SBC SPRITES_X_LO05,X
        BPL _L02
        LDA #$0C     ;#%00001100
        STA pFB,b
_L02    LDA SPRITES_Y00
        SEC
        SBC SPRITES_Y05,X
        BPL _L03
        LSR pFB,b
        LDA pFB,b
        JMP _L06

_L03    LDA pFB,b
        CLC
        ADC #$08     ;#%00001000
        LSR A
        STA pFB,b
        JMP _L06

_L04    JSR GET_RANDOM
        AND #$03     ;#%00000011
        SEC
        SBC #$02     ;#%00000010
        CMP #$FE     ;#%11111110
        BNE _L05
        LDA #$00     ;#%00000000
_L05    CLC
        ADC SPRITES_TMP_A05,X
_L06    AND #$0F     ;#%00001111
        STA SPRITES_TMP_A05,X
        TAY
        LDA DELTA_X_TBL,Y
        STA SPRITES_DELTA_X05,X
        LDA DELTA_Y_TBL,Y
        STA SPRITES_DELTA_Y05,X
        RTS

DELTA_X_TBL
    .BYTE $00,$01,$01,$01,$01,$01,$01,$01
    .BYTE $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DELTA_Y_TBL
    .BYTE $FF,$FF,$FF,$00,$00,$00,$01,$01
    .BYTE $01,$01,$01,$00,$00,$00,$FF,$FF

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Soldier tries to throw a grenade. If there are no empty seats, grenade
; is not thrown.
THROW_GRENADE   ;$32ED
        ; Same X part?
        LDA SPRITES_X_HI05,X
        CMP SPRITES_X_HI00
        BNE _L01

        ; Find empty seat
        LDY #$00
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L02
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L00

_L01    LDY #$FF
        RTS

_L02    TXA
        PHA
        LDA SPRITES_X_LO05,X
        CLC
        ADC #$06     ;#%00000110
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        STA SPRITES_Y05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$93    ;grenade frame #0
        STA SPRITES_PTR05,Y
        LDA #$0E     ;light blue
        STA SPRITES_COLOR05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$0B     ;anim_type_0B: grenade
        STA SPRITES_TYPE05,Y
        LDA SPRITES_X_LO00
        SEC
        SBC SPRITES_X_LO05,Y
        STA pFB,b
        BCS _L04
        LDA pFB,b
        EOR #$FF
        STA pFB,b
        INC pFB,b
        LDA SPRITES_Y00
        SEC
        SBC SPRITES_Y05,Y
        STA pFC,b
        BCS _L03
        LDA pFC,b
        EOR #$FF
        STA pFC,b
        INC pFC,b
        JSR s3555
        LDA pFC,b
        EOR #$FF
        STA pFC,b
        INC pFC,b
        LDA pFB,b
        EOR #$FF
        STA pFB,b
        INC pFB,b
        JMP _L06

_L03    JSR s3555
        LDA pFB,b
        EOR #$FF
        STA pFB,b
        INC pFB,b
        JMP _L06

_L04    LDA SPRITES_Y00
        SEC
        SBC SPRITES_Y05,Y
        STA pFC,b
        BCS _L05
        LDA pFC,b
        EOR #$FF
        STA pFC,b
        INC pFC,b
        JSR s3555
        LDA pFC,b
        EOR #$FF
        STA pFC,b
        INC pFC,b
        JMP _L06

_L05    JSR s3555

_L06    LDA pFB,b
        STA SPRITES_DELTA_X05,Y
        LDA pFC,b
        STA SPRITES_DELTA_Y05,Y
        LDA SPRITES_DELTA_Y05,Y
        SEC
        SBC #$02
        STA SPRITES_DELTA_Y05,Y
        PLA
        TAX
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; related to shoot
j33D0   LDA SPRITES_TMP_C05,X
        AND SHOOT_FREQ_MASK             ;cooldown for solider shooting
        BNE _L01

        ; Find empty seat
        LDY #$00
_L00    LDA SPRITES_TYPE05,Y
        BEQ _L02
        INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE _L00
_L01    RTS

_L02    LDA SPRITES_X_HI05,X
        CMP SPRITES_X_HI00
        BEQ _L03
        BCS _L09
        JMP _L05

_L03    LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L05
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L09
        LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L04
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L12
        RTS

_L04    JMP _L15

_L05    LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L06
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L07
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$04     ;#%00000100
        BEQ _L08
        RTS

_L06    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$06     ;#%00000110
        BEQ _L08
        RTS

_L07    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$02     ;#%00000010
        BEQ _L08
        RTS

_L08    JMP _L18

_L09    LDA SPRITES_Y05,X
        CLC
        ADC #$14     ;#%00010100
        CMP SPRITES_Y00
        BCC _L10
        SEC
        SBC #$28     ;#%00101000
        CMP SPRITES_Y00
        BCS _L11
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$0C     ;#%00001100
        BEQ _L08
        RTS

_L10    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$0A     ;#%00001010
        BEQ _L08
        RTS

_L11    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$0E     ;#%00001110
        BEQ _L08
        RTS

_L12    LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L13
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L14
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        BEQ _L18
        RTS

_L13    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$02     ;#%00000010
        BEQ _L18
        RTS

_L14    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$0E     ;#%00001110
        BEQ _L18
        RTS

_L15    LDA SPRITES_X_LO05,X
        CLC
        ADC #$1E     ;#%00011110
        CMP SPRITES_X_LO00
        BCC _L16
        SEC
        SBC #$3C     ;#%00111100
        CMP SPRITES_X_LO00
        BCS _L17
        LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$08     ;#%00001000
        BEQ _L18
        RTS

_L16    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$06     ;#%00000110
        BEQ _L18
        RTS

_L17    LDA SPRITES_TMP_B05,X
        AND #$FE     ;#%11111110
        CMP #$0A     ;#%00001010
        BEQ _L18
        RTS

_L18    STX pFB,b
        STA SPRITES_TMP_B05,X
        TAX
        LDA _DELTA_X_TBL,X
        STA SPRITES_DELTA_X05,Y
        LDA _DELTA_Y_TBL,X
        STA SPRITES_DELTA_Y05,Y
        LDA f3617,X
        STA SPRITES_X_LO05,Y
        LDA f3627,X
        STA SPRITES_Y05,Y
        LDX pFB,b
        LDA SPRITES_X_LO05,X
        CLC
        ADC SPRITES_X_LO05,Y
        STA SPRITES_X_LO05,Y
        LDA SPRITES_Y05,X
        CLC
        ADC SPRITES_Y05,Y
        STA SPRITES_Y05,Y
        LDA SPRITES_X_HI05,X
        STA SPRITES_X_HI05,Y
        LDA #$90     ;bullet frame
        STA SPRITES_PTR05,Y
        LDA #$01     ;white
        STA SPRITES_COLOR05,Y
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_C05,Y
        STA SPRITES_BKG_PRI05,Y
        LDA #$08            ;anim_type_08: soldier bullet
        STA SPRITES_TYPE05,Y
        RTS

        ; Sprite delta X tbl
_DELTA_X_TBL    ;$3535
        .BYTE $00,$01,$01,$02,$02,$02,$01,$01
        .BYTE $00,$FF,$FF,$FE,$FE,$FE,$FF,$FF

        ; Sprite delta Y tbl
_DELTA_Y_TBL    ;$3545
        .BYTE $FE,$FE,$FF,$FF,$00,$01,$01,$02
        .BYTE $02,$02,$01,$01,$00,$FF,$FF,$FE

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
s3555   LDX #$05
_L00    LSR pFB,b
        LSR pFC,b
        DEX
        BPL _L00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_06
; Animation when regular soldier dies
TYPE_ANIM_SOLDIER_DIE  ;$3561
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$18     ;#%00011000
        BEQ _L00
        TAY
        LDA _FRAME_TBL,Y
        STA SPRITES_PTR05,X
        RTS

_L00    JMP CLEANUP_SPRITE

        ; Sprite frames
_FRAME_TBL      ;f3576
        .BYTE $BE,$FF,$BE,$FF,$BE,$FF,$BF,$FF
        .BYTE $BF,$FF,$BF,$FF,$BE,$FF,$BE,$FF
        .BYTE $BE,$FF,$BF,$FF,$BF
        .BYTE $FF,$BF,$FF

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Cleanup current sprite: init sprites and leaves the seat available
; X=sprite to cleanup
CLEANUP_SPRITE      ;$358E
        LDA #$00
        STA SPRITES_TYPE05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        LDA ORIG_SPRITE_Y05,X
        STA SPRITES_Y05,X
        LDA #$64
        STA SPRITES_X_LO05,X
        LDA #$FF
        STA SPRITES_X_HI05,X
        STA SPRITES_PTR05,X             ;set empty sprite frame
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SETUP_VIC_BANK          ;$35AD
        LDA a01
        AND #$FE     ;#%11111110        Enable I/O
        STA a01

        LDA $DD02    ;CIA2: Data Direction Register A
        ORA #$03     ;#%00000011        Allow writing to $DD00 VIC bank
        STA $DD02    ;CIA2: Data Direction Register A

        LDA $DD00    ;CIA2: Data Port Register A
        AND #$FC     ;#%11111100        Set VIC bank: $C000-$FFFF
        STA $DD00    ;CIA2: Data Port Register A

        LDA $D018    ;VIC Memory Control Register
        AND #$0F     ;#%00001111
        ORA #$80     ;#%10000000        Set screen RAM to $E000
        STA $D018    ;VIC Memory Control Register

        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
s35CE   LDA GAME_TICK   ;unused
        LDA a04E1
        AND #$0F     ;#%00001111
        CMP HERO_ANIM_MOV_IDX
        BEQ _L02
        SEC
        SBC HERO_ANIM_MOV_IDX
        AND #$0F     ;#%00001111
        CMP #$08     ;#%00001000
        BCC _L01
        INC a04E1
        INC a04E1
_L01    DEC a04E1
_L02    LDA a04E1
        AND #$0F     ;#%00001111
        STA a04E1
        RTS

        ; Bullet delta-X values
f35F7   .BYTE $00,$03,$06,$07,$08,$07,$06,$03
        .BYTE $00,$FD,$FA,$F9,$F8,$F9,$FA,$FD
        ; Bullet delta-Y values
f3607   .BYTE $FA,$FB,$FC,$FE,$00,$02,$04,$05
        .BYTE $06,$05,$04,$02,$00,$FE,$FC,$FB
        ; Bullet (?) X-lo values
f3617   .BYTE $04,$04,$04,$04,$00,$00,$02,$02
        .BYTE $F9,$F9,$00,$00,$00,$00,$00,$00
        ; Bullet (?) Y values
f3627   .BYTE $00,$00,$02,$02,$00,$00,$02,$02
        .BYTE $00,$00,$02,$02,$00,$00,$07,$07

HERO_TYPE_ANIM_TBL
        .ADDR TYPE_ANIM_HERO_MAIN               ;hero_type_anim_00
        .ADDR TYPE_ANIM_BULLET                  ;hero_type_anim_01
        .ADDR TYPE_ANIM_GRENADE                 ;hero_type_anim_02
        .ADDR TYPE_ANIM_BULLET_END              ;hero_type_anim_03
        .ADDR TYPE_ANIM_GRENADE_END             ;hero_type_anim_04

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Calls the different hero-related animation, based on the sprite type assigned.
; E.g: throw grenade, bullet start, bullet end, main anim, etc.
ANIM_HERO       ;$3641
        ; Sprites 1-5 are bullets / grenades
        LDX #$00     ;#%00000000

        ; If bullet/grenade is outside bounds, remove it
_L00    LDA SPRITES_Y01,X
        CMP #$1E     ;#%00011110
        BCC _L01
        CMP #$DC     ;#%11011100
        BCS _L01
        LDA SPRITES_X_LO01,X
        CMP #$5B     ;#%01011011
        BCC _L02
        LDA SPRITES_X_HI01,X
        BEQ _L02
_L01    JSR CLEANUP_HERO_SPRITE

        ; FIXME: Fallthrough. Intended? will it be possible to call
        ; TYPE_ANIM_HERO_MAIN more than once per frame?

_L02    LDA SPRITES_TYPE01,X
        ASL A
        TAY
        LDA HERO_TYPE_ANIM_TBL,Y
        STA pFB,b
        LDA HERO_TYPE_ANIM_TBL+1,Y
        STA pFC,b
        JSR _L03
        INX
        CPX #$04     ;For sprites 1-5
        BNE _L00

        RTS

_L03    JMP (pFB)

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_02, hero_type_anim_02
; Hero anim grenade
TYPE_ANIM_GRENADE
        INC SPRITES_TMP_A01,X
        LDA SPRITES_TMP_A01,X
        CMP #$0F     ;#%00001111
        BCS _L00
        LSR A
        LSR A
        TAY
        LDA f36F9,Y
        STA SPRITES_PTR00
_L00    LDA SPRITES_TMP_A01,X
        AND #$07     ;#%00000111
        BNE _L01
        LDA SPRITES_TMP_A01,X
        LSR A
        LSR A
        LSR A
        TAY
        LDA FRAME_GRENADE1,Y
        STA SPRITES_PTR01,X
        LDA SPRITES_TMP_A01,X
_L01    CMP #$28     ;#%00101000
        BEQ _L03
        LDA SPRITES_X_LO01,X
        STA TMP_SPRITE_X_LO
        LDA SPRITES_Y01,X
        STA TMP_SPRITE_Y
        LDA SPRITES_X_HI01,X
        STA TMP_SPRITE_X_HI
        JSR j172F
        LDA #$00     ;#%00000000
        STA SPRITES_BKG_PRI01,X

        ; Get charset mask info
        LDY #$00     ;#%00000000
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        AND #$02     ;#%00000010
        BEQ _L02

        LDA #$FF     ;#%11111111
        STA SPRITES_BKG_PRI01,X
_L02    RTS

_L03    LDA #$04     ;#%00000100
        STA SPRITES_TYPE01,X
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_A01,X
        STA SPRITES_DELTA_X01,X
        STA SPRITES_DELTA_Y01,X
        STA SPRITES_BKG_PRI01,X
        TAY
        LDA FRAME_EXPLOSION,Y
        STA SPRITES_PTR01,X
        LDA #$08     ;orange
        STA SPRITES_COLOR01,X
        RTS

FRAME_GRENADE1      ;$36F3
        .BYTE $92,$91,$91,$92,$93,$93
f36F9   .BYTE $A4,$A5,$DE,$98,$98

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_03, hero_type_anim_03
; Hero Anim bullet end
TYPE_ANIM_BULLET_END      ;$36FE
        INC SPRITES_TMP_A01,X
        LDA SPRITES_TMP_A01,X
        CMP #$09     ;Frames for anim(?)
        BEQ _L00
        TAY
        LDA FRAME_BULLET_END,Y
        STA SPRITES_PTR01,X
        RTS

_L00    JSR CLEANUP_HERO_SPRITE
        RTS

FRAME_BULLET_END             ;$3714
        .BYTE $94,$95,$96,$97,$96,$96,$94,$FF
        .BYTE $FF

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Hero Reset state (bullet, grenade, main) and disable/hide
; Not necessarily the hero in itself, but sprites associated with it like bullet
; and grenade.
CLEANUP_HERO_SPRITE     ;$371D
        LDA #$00
        STA SPRITES_TYPE01,X
        STA SPRITES_DELTA_X01,X
        STA SPRITES_DELTA_Y01,X
        LDA ORIG_SPRITE_Y01,X
        STA SPRITES_Y01,X
        LDA #$64
        STA SPRITES_X_LO01,X
        LDA #$FF
        STA SPRITES_X_HI01,X
        STA SPRITES_PTR01,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_04, hero_type_anim_04
; Exploding grenade animation
TYPE_ANIM_GRENADE_END ;$373C
        INC SPRITES_TMP_A01,X
        LDY #$00     ;#%00000000

b3741   LDA SPRITES_TYPE05,Y
        STY pFB,b
        TAY
        LDA f2544,Y
        LDY pFB,b
        AND #$02            ;grenade mask
        BEQ b3793

        ; Collision between hero grenade and enemy?
        LDA SPRITES_X_HI01,X
        CMP SPRITES_X_HI05,Y
        BNE b3793
        LDA SPRITES_X_LO01,X
        CLC
        ADC #$12     ;#%00010010
        CMP SPRITES_X_LO05,Y
        BCC b3793
        LDA SPRITES_X_LO01,X
        SEC
        SBC #$12     ;#%00010010
        CMP SPRITES_X_LO05,Y
        BCS b3793
        LDA SPRITES_Y01,X
        CLC
        ADC #$16     ;#%00010110
        CMP SPRITES_Y05,Y
        BCC b3793
        LDA SPRITES_Y01,X
        SEC
        SBC #$16     ;#%00010110
        CMP SPRITES_Y05,Y
        BCS b3793
        LDA SPRITES_TYPE05,Y
        CMP #$1E            ;anim_type_1E: turret fire
        BNE b3790
        JMP DESTROY_TURRET

b3790   JSR DIE_ANIM_AND_SCORE
b3793   INY
        CPY #(TOTAL_MAX_SPRITES-5)
        BNE b3741

        LDA SPRITES_TMP_A01,X
        CMP #$14     ;#%00010100
        BEQ b37A9
        LSR A
        LSR A
        TAY
        LDA FRAME_EXPLOSION,Y
        STA SPRITES_PTR01,X
        RTS

b37A9   LDA #$00     ;#%00000000
        STA SPRITES_TYPE01,X
        STA SPRITES_DELTA_X01,X
        STA SPRITES_DELTA_Y01,X
        LDA ORIG_SPRITE_Y01,X
        STA SPRITES_Y01,X
        LDA #$64     ;#%01100100
        STA SPRITES_X_LO01,X
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI01,X
        LDA #$FF     ;#%11111111
        STA SPRITES_PTR01,X
        RTS

FRAME_EXPLOSION     ;$37CA
        .BYTE $AF,$AE,$AD,$AF,$FF

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Destroys the turret
DESTROY_TURRET
        TXA
        PHA
        TYA
        PHA
        LDA #$0A            ;Points scored
        JSR SCORE_ADD
        LDA #$02            ;"Turret destroyed" SFX
        JSR SFX_PLAY
        LDA SPRITES_TMP_B05,Y
        CMP #$0A
        BEQ _L01
        LDA SPRITES_X_LO05,Y
        SEC
        SBC #$0E
        STA SPRITES_X_LO01,X
        LDA SPRITES_Y05,Y
        STA SPRITES_Y01,X
        LDA #$0C            ;anim_type_0C: explosion
        STA SPRITES_TYPE05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        TAX
        LDA FRAME_EXPLOSION,X
        STA SPRITES_PTR05,Y
        LDA #$08            ;orange
        STA SPRITES_COLOR05,Y
        LDA SPRITES_X_LO05,Y
        SEC
        SBC #$18
        STA TMP_SPRITE_X_LO
        LDA SPRITES_Y05,Y
        SEC
        SBC #$2E
        STA TMP_SPRITE_Y
        LDA SPRITES_X_HI05,Y
        STA TMP_SPRITE_X_HI
        LDA SPRITES_Y05,Y
        SEC
        SBC #$0A
        STA SPRITES_Y05,Y
        JSR j172F
        LDA pFC,b
        STA pFB,b
        LDA pFD,b
        STA pFC,b
        LDA #$04            ;Draw left turret destroyed
        JSR LEVEL_PATCH_TURRET
        JSR LEVEL_DRAW_VIEWPORT
_L00    PLA
        TAY
        PLA
        TAX
        JMP b3793           ;A grenade could kill more than one enemy at the time.
                            ; Continue with the next enemy.

_L01    LDA SPRITES_X_LO05,Y
        CLC
        ADC #$0E
        STA SPRITES_X_LO01,X
        LDA SPRITES_Y05,Y
        STA SPRITES_Y01,X
        LDA #$0C            ;anim_type_0C: explosion
        STA SPRITES_TYPE05,Y
        LDA #$00
        STA SPRITES_TMP_C05,Y
        TAX
        LDA FRAME_EXPLOSION,X
        STA SPRITES_PTR05,Y
        LDA #$08     ;orange
        STA SPRITES_COLOR05,Y
        LDA SPRITES_Y05,Y
        SEC
        SBC #$0A
        STA SPRITES_Y05,Y
        LDA #<$859A         ;Turret location in lvl1 lo
        STA pFB,b
        LDA #>$859A         ;Turret location in lvl1 hi
        STA pFC,b
        LDA #$06            ;Draw right turret destroyed
        JSR LEVEL_PATCH_TURRET
        JSR LEVEL_DRAW_VIEWPORT
        JMP _L00

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Animate explosion
; ref: anim_type_0C
TYPE_ANIM_EXPLOSION    ;$388B
        INC SPRITES_TMP_C05,X
        LDA SPRITES_TMP_C05,X
        CMP #$14     ;#%00010100
        BEQ _L00
        LSR A
        LSR A
        TAY
        LDA FRAME_EXPLOSION,Y
        STA SPRITES_PTR05,X
        RTS

_L00    LDA #$00            ;anim_type_00: spawn soldiers
        STA SPRITES_TYPE05,X
        STA SPRITES_DELTA_X05,X
        STA SPRITES_DELTA_Y05,X
        STA SPRITES_BKG_PRI05,X
        LDA ORIG_SPRITE_Y05,X
        STA SPRITES_Y05,X
        LDA #$64     ;#%01100100
        STA SPRITES_X_LO05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_X_HI05,X
        LDA #$FF     ;#%11111111
        STA SPRITES_PTR05,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
TRY_THROW_GRENADE               ;$38c3
        LDA IS_HERO_DEAD
        BNE _SKIP
        LDA ENEMIES_IN_FORT
        BNE _L00
        LDA ANY_ENEMY_IN_MAP
        BEQ _SKIP
_L00    LDA SPRITES_TYPE04
        BNE _SKIP
        LDA GRENADES
        BEQ _SKIP
        LDA $DC01    ;CIA1: Data Port Register B (in-game grenades)
        CMP #$EF     ;#%11101111
        BNE _SKIP
        LDA SPRITES_X_LO00
        STA SPRITES_X_LO04
        LDA SPRITES_Y00
        STA SPRITES_Y04
        LDA SPRITES_X_HI00
        STA SPRITES_X_HI04
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X04
        LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_Y04
        LDA #$93     ;Grenade (small) frame
        STA SPRITES_PTR04
        LDA #$0E     ;light blue
        STA SPRITES_COLOR04
        LDA SPRITES_BKG_PRI00
        STA SPRITES_BKG_PRI04
        LDA #$02     ;#%00000010
        STA SPRITES_TYPE04
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_A04
        STA HERO_ANIM_MOV_IDX
        LDA #$A4     ;#%10100100
        STA SPRITES_PTR00
        SED
        LDA GRENADES
        SEC
        SBC #$01     ;#%00000001
        STA GRENADES
        CLD
        JSR SCREEN_REFRESH_GRENADES
        LDA #$01     ;Throw grenade SFX
        JSR SFX_PLAY
_SKIP   RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; ref: anim_type_01, hero_type_anim_01
; Hero Anim bullet
TYPE_ANIM_BULLET  ;$3935
        INC SPRITES_TMP_A01,X
        LDA SPRITES_TMP_A01,X
        CMP #$0F
        BNE _L00
        JMP _L04

_L00    LDY #$00
_L01    LDA SPRITES_TYPE05,Y
        STY pFB,b
        TAY
        LDA f2544,Y
        LDY pFB,b
        AND #$01                ;bullet mask
        BEQ _L02

        ; Is there collision between enemy and bullet?
        LDA SPRITES_X_HI01,X
        CMP SPRITES_X_HI05,Y
        BNE _L02
        LDA SPRITES_X_LO01,X
        CLC
        ADC #$0A
        CMP SPRITES_X_LO05,Y
        BCC _L02
        LDA SPRITES_X_LO01,X
        SEC
        SBC #$0A
        CMP SPRITES_X_LO05,Y
        BCS _L02
        LDA SPRITES_Y01,X
        CLC
        ADC #$0C
        CMP SPRITES_Y05,Y
        BCC _L02
        LDA SPRITES_Y01,X
        SEC
        SBC #$0C
        CMP SPRITES_Y05,Y
        BCS _L02
        JSR DIE_ANIM_AND_SCORE
        JSR CLEANUP_HERO_SPRITE

_L02    INY
        CPY #$0B     ;#%00001011
        BNE _L01

        LDA SPRITES_X_LO01,X
        STA TMP_SPRITE_X_LO
        LDA SPRITES_Y01,X
        SEC
        SBC #$06     ;#%00000110
        STA TMP_SPRITE_Y
        LDA SPRITES_X_HI01,X
        STA TMP_SPRITE_X_HI
        JSR j172F

        ; Get charset mask info
        LDY #$00     ;#%00000000
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        AND #$01     ;#%00000001
        BNE _L04

        LDA (p2A),Y
        AND #$02     ;#%00000010
        BEQ _L03

        LDA #$FF     ;#%11111111
        STA SPRITES_BKG_PRI01,X
        RTS

_L03    LDA #$00     ;#%00000000
        STA SPRITES_BKG_PRI01,X
        RTS

_L04    LDA #$03     ;#%00000011
        STA SPRITES_TYPE01,X
        LDA #$00     ;#%00000000
        STA SPRITES_TMP_A01,X
        STA SPRITES_DELTA_X01,X
        STA SPRITES_DELTA_Y01,X
        TAY
        LDA FRAME_BULLET_END,Y
        STA SPRITES_PTR01,X
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Animation for hero in "normal" state
; X=Sprite to update
; ref: hero_type_anim_00
TYPE_ANIM_HERO_MAIN
        LDA IS_HERO_DEAD
        BNE _L02
        LDA ENEMIES_IN_FORT
        BNE _L00
        LDA ANY_ENEMY_IN_MAP
        BEQ _L02

_L00    LDA $DC00    ;CIA1: Data Port Register A (in-game fire)
        AND #$10     ;#%00010000
        BNE _L02

        LDA FIRE_COOLDOWN
        CMP #$08     ;#%00001000
        BEQ _L01
        INC FIRE_COOLDOWN
        LDA FIRE_COOLDOWN
        AND #$07     ;#%00000111
        BNE _L01

        ; Fire routine executed when FIRE_COOLDOWN is 0

        LDY a04E1
        LDA f35F7,Y
        STA SPRITES_DELTA_X01,X
        LDA f3607,Y
        STA SPRITES_DELTA_Y01,X
        LDA SPRITES_X_LO00
        CLC
        ADC f3617,Y
        STA SPRITES_X_LO01,X

        LDA SPRITES_Y00
        CLC
        ADC f3627,Y
        STA SPRITES_Y01,X

        LDA SPRITES_X_HI00
        STA SPRITES_X_HI01,X

        LDA #$01
        STA SPRITES_TYPE01,X
        LDA #$90     ;Bullet frame
        STA SPRITES_PTR01,X
        LDA #$00
        STA SPRITES_TMP_A01,X
        LDA #$01     ;white
        STA SPRITES_COLOR01,X
_L01    RTS

_L02    LDA #$FF     ;#%11111111
        STA FIRE_COOLDOWN
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Level complete. Open door and animate hero to go through the exit door
HERO_START_ANIM_EXIT_DOOR          ;$3A4C
        LDA #$01
        STA IS_ANIM_EXIT_DOOR
        LDA #$02     ;Draw open door
        JSR LEVEL_PATCH_DOOR
        JSR LEVEL_DRAW_VIEWPORT

HERO_ANIM_EXIT_DOOR     ;b3A59
        LDA SPRITES_X_HI00
        BNE _L00
        LDA SPRITES_X_LO00
        CMP #$AF     ;#%10101111
        BEQ _L01
        BCS _L00

        ; Right
        LDA #$04     ;Hero right anim
        STA HERO_ANIM_MOV_IDX
        LDA #$02     ;2 pixels to the right
        STA SPRITES_DELTA_X00
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y00
        JMP SETUP_HERO_ANIMATION

        ; Left
_L00    LDA #$0C     ;Hero left anim
        STA HERO_ANIM_MOV_IDX
        LDA #$FE     ;to pixels to the left
        STA SPRITES_DELTA_X00
        LDA #$00     ;#%00000000
        STA SPRITES_DELTA_Y00
        JMP SETUP_HERO_ANIMATION

        ; Up
_L01    LDA #$00     ;Hero up anim
        STA SPRITES_DELTA_X00
        STA HERO_ANIM_MOV_IDX
        LDA #$FF     ;1 pixel up
        STA SPRITES_DELTA_Y00
        LDA SPRITES_Y00
        CMP #$5A     ;Hero Y pos?
        BEQ _L02
        JMP SETUP_HERO_ANIMATION

        ;Level complete. Hero animation going up done.
_L02    LDA #$01
        STA IS_LEVEL_COMPLETE
        JMP SETUP_HERO_ANIMATION

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
HANDLE_JOY2         ;$3AAA
        LDA IS_ANIM_EXIT_DOOR
        BNE HERO_ANIM_EXIT_DOOR
        LDA ENEMIES_IN_FORT
        BNE _L00
        LDA ANY_ENEMY_IN_MAP
        BNE _L00
        JMP HERO_START_ANIM_EXIT_DOOR

_L00    LDA #$00     ;#%00000000
        STA SPRITES_DELTA_X00
        STA SPRITES_DELTA_Y00
        STA V_SCROLL_DELTA

        LDA $DC00    ;CIA1: Data Port Register A (in-game up)
        AND #$01     ;#%00000001
        BNE _L03
        LDA #$00     ;Anim index for SOLDIER_ANIM_FRAMES (up)
        STA HERO_ANIM_MOV_IDX
        LDA V_SCROLL_ROW_IDX
        BNE _L01

        LDA #$01     ;#%00000001
        STA a04EE
        LDA SPRITES_Y00
        CMP #$6E     ;#%01101110        Hero reached top to move up?
        BCC _L03
        LDA #$FF     ;Sprite move up 1 pixel
        STA SPRITES_DELTA_Y00
        JMP _L03

_L01    LDA SPRITES_Y00
        CMP #$A4     ;#%10100100
        BCC _L02
        LDA #$FF     ;#%11111111
        STA SPRITES_DELTA_Y00
        JMP _L03

_L02    LDA #$FF     ;Scroll up 1 pixel
        STA V_SCROLL_DELTA

_L03    LDA $DC00    ;CIA1: Data Port Register A (in-game down)
        AND #$02     ;#%00000010
        BNE _L04
        LDA #$08     ;Anim index for SOLIDER_ANIM_FRAMES (down)
        STA HERO_ANIM_MOV_IDX
        LDA SPRITES_Y00
        CMP #$C1     ;#%11000001
        BCS _L04
        LDA #$01     ;#%00000001
        STA SPRITES_DELTA_Y00

_L04    LDA $DC00    ;CIA1: Data Port Register A (in-game left)
        AND #$04     ;#%00000100
        BNE _L06
        LDA #$0C     ;Anim index for SOLDIER_ANIM_FRAMES (left)
        STA HERO_ANIM_MOV_IDX
        LDA SPRITES_X_HI00
        BNE _L05
        LDA SPRITES_X_LO00
        CMP #$18     ;#%00011000
        BCC _L06
_L05    LDA #$FE     ;#%11111110
        STA SPRITES_DELTA_X00

_L06    LDA $DC00    ;CIA1: Data Port Register A (in-game right)
        AND #$08     ;#%00001000
        BNE _L08
        LDA #$04     ;Anim index for SOLDIER_ANIM_FRAMES (right)
        STA HERO_ANIM_MOV_IDX
        LDA SPRITES_X_HI00
        BEQ _L07
        LDA SPRITES_X_LO00
        CMP #$41     ;#%01000001
        BCS _L08
_L07    LDA #$02     ;#%00000010
        STA SPRITES_DELTA_X00

_L08    LDA $DC00    ;CIA1: Data Port Register A (multiple directions)
        ORA #$10     ;#%00010000
        CMP #$76     ;#%01110110        up-right
        BNE _L09

        LDX #$02     ;Anim index for SOLDIER_ANIM_FRAMES (up-right)
        STX HERO_ANIM_MOV_IDX
        LDA #<HERO_FRAMES_UP_RIGHT  ;#%10111000
        STA p19,b
        LDA #>HERO_FRAMES_UP_RIGHT  ;#%00111100
        STA p1A,b
        ;FIXME: unintended fallthrough.
        ;       a jump must be placed here

_L09    CMP #$75     ;#%01110101        down-right
        BNE _L10
        LDX #$06     ;Anim index for SOLDIER_ANIM_FRAMES (down-right)
        STX HERO_ANIM_MOV_IDX
        LDA #<HERO_FRAMES_DOWN_RIGHT  ;#%10110000
        STA p19,b
        LDA #>HERO_FRAMES_DOWN_RIGHT  ;#%00111100
        STA p1A,b
        ;FIXME: unintended fallthrough.
        ;       a jump must be placed here

_L10    CMP #$79     ;#%01111001        down-left
        BNE _L11
        LDX #$0A     ;Anim index for SOLDER_ANIM_FRAMES (down-left)
        STX HERO_ANIM_MOV_IDX
        LDA #<HERO_FRAMES_DOWN_LEFT  ;#%10110100
        STA p19,b
        LDA #>HERO_FRAMES_DOWN_LEFT  ;#%00111100
        STA p1A,b
        ;FIXME: unintended fallthrough.
        ;       a jump must be placed here

_L11    CMP #$7A     ;#%01111010        up-left
        BNE _L12
        LDX #$0E     ;Anim index for SOLDIER_ANIM_FRAMES (up-left)
        STX HERO_ANIM_MOV_IDX
        LDA #<HERO_FRAMES_UP_LEFT  ;#%10111100
        STA p19,b
        LDA #>HERO_FRAMES_UP_LEFT  ;#%00111100
        STA p1A,b

_L12    LDA $DC00    ;CIA1: Data Port Register A (in-game direction changed)
        AND #$0F     ;#%00001111
        CMP #$0F     ;#%00001111
        BEQ b3BCC

        ; Fall-through

SETUP_HERO_ANIMATION            ;$3BAC
        LDA HERO_ANIM_MOV_IDX
        TAY
        LDA SOLDIER_ANIM_FRAMES,Y
        STA pFB,b
        LDA SOLDIER_ANIM_FRAMES+1,Y
        STA pFC,b
        INC COUNTER1
        LDA COUNTER1
        AND #$0C     ;#%00001100
        LSR A
        LSR A
        TAY
        LDA (pFB),Y
        STA SPRITES_PTR00
b3BCC   JSR s35CE
        LDA SPRITES_X_HI00
        STA TMP_SPRITE_X_HI
        LDA SPRITES_DELTA_X00
        CLC
        ADC SPRITES_DELTA_X00
        STA pFB,b
        LDA SPRITES_X_LO00
        CLC
        ADC pFB,b
        PHA
        BVS b3BF8
        EOR SPRITES_X_LO00
        AND #$80     ;#%10000000
        BEQ b3BF8
        LDA TMP_SPRITE_X_HI
        EOR #$FF     ;#%11111111
        STA TMP_SPRITE_X_HI
b3BF8   PLA
        STA TMP_SPRITE_X_LO
        LDA SPRITES_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC V_SCROLL_DELTA
        CLC
        ADC V_SCROLL_DELTA
        CLC
        ADC V_SCROLL_DELTA
        STA TMP_SPRITE_Y
        JSR j172F

        ; Get charset mask info
        LDY #$00
        LDA (pFC),Y
        TAY
        LDA (p2A),Y
        AND #$01     ;#%00000001
        BNE b3C8F

        LDA (p2A),Y
        AND #$04     ;#%00000100
        BEQ b3C7D

        LDA #$02        ;Hero fell in trench/water
        STA IS_HERO_DEAD
        LDA #$04        ;"Hero dead" SFX
        JSR SFX_PLAY
        STA COUNTER1
        LDA TMP_SPRITE_X_LO
        CLC
        ADC SPRITES_DELTA_X00
        CLC
        ADC SPRITES_DELTA_X00
        CLC
        ADC SPRITES_DELTA_X00
        CLC
        ADC SPRITES_DELTA_X00
        STA SPRITES_X_LO00
        LDA TMP_SPRITE_Y
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        CLC
        ADC V_SCROLL_DELTA
        CLC
        ADC V_SCROLL_DELTA
        CLC
        ADC V_SCROLL_DELTA
        CLC
        ADC #$0C     ;#%00001100
        STA SPRITES_Y00
        LDA #$00
        STA SPRITES_DELTA_X00
        STA SPRITES_DELTA_Y00
        STA V_SCROLL_DELTA

        ; Get charset mask info
b3C7D   LDA (p2A),Y
        AND #$02     ;#%00000010
        BEQ b3C89

        LDA #$FF
        STA SPRITES_BKG_PRI00
        RTS

b3C89   LDA #$00
        STA SPRITES_BKG_PRI00
        RTS

b3C8F   LDA IS_ANIM_EXIT_DOOR
        BNE b3C9F
        LDA #$00
        STA SPRITES_DELTA_X00
        STA SPRITES_DELTA_Y00
        STA V_SCROLL_DELTA
b3C9F   RTS

HERO_FRAMES_UP
        .BYTE $98,$99,$9A,$99                   ;Anim up
HERO_FRAMES_DOWN
        .BYTE $9B,$9C,$9D,$9C                   ;Anim down
HERO_FRAMES_LEFT
        .BYTE $D5,$D6,$D7,$D8                   ;Anim left
HERO_FRAMES_RIGHT
        .BYTE $D9,$DA,$DB,$DC                   ;Anim right
HERO_FRAMES_DOWN_RIGHT
        .BYTE $9E,$9F,$DF,$A0                   ;Anim down-right
HERO_FRAMES_DOWN_LEFT
        .BYTE $A1,$A2,$E0,$A3                   ;Anim down-left
HERO_FRAMES_UP_RIGHT
        .BYTE $A6,$A7,$A8,$E1                   ;Anim up-right
HERO_FRAMES_UP_LEFT
        .BYTE $A9,$AA,$AB,$E2                   ;Anim up-left

; These frames are shared by the hero and the regular enemies
SOLDIER_ANIM_FRAMES                     ;$3CC0
        .ADDR HERO_FRAMES_UP            ;0
        .ADDR HERO_FRAMES_UP_RIGHT      ;1
        .ADDR HERO_FRAMES_RIGHT         ;2
        .ADDR HERO_FRAMES_DOWN_RIGHT    ;3
        .ADDR HERO_FRAMES_DOWN          ;4
        .ADDR HERO_FRAMES_DOWN_LEFT     ;5
        .ADDR HERO_FRAMES_LEFT          ;6
        .ADDR HERO_FRAMES_UP_LEFT       ;7

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Set fort on fire animation (lvl3, when you beat the game)
SET_FORT_ON_FIRE      ;$3CD0
        JSR CLEANUP_SPRITES
        LDX #$00
_L00    LDA f3D27,X
        STA SPRITES_X_LO05,X
        LDA f3D3D,X
        STA SPRITES_Y05,X
        LDA f3D32,X
        STA SPRITES_X_HI05,X
        LDA #$EE            ;Fire frame
        STA SPRITES_PTR05,X
        LDA #$02            ;red
        STA SPRITES_COLOR05,X
        LDA #$00
        STA SPRITES_BKG_PRI05,X
        INX
        CPX #$0B            ;Number of sprites to set
        BNE _L00

        JSR APPLY_DELTA_MOV
        JSR SORT_SPRITES_BY_Y
        LDA #$FF
        STA COUNTER1
_L01    LDX #$00
_L02    LDA #$EE            ;Fire frame
        STA SPRITES_PTR05,X
        JSR GET_RANDOM
        AND #$03            ;#%00000011
        BNE _L03
        LDA #$FF            ;Empty frame
        STA SPRITES_PTR05,X
_L03    INX
        CPX #$0B
        BNE _L02

        JSR WAIT_RASTER_AT_BOTTOM
        DEC COUNTER1
        BNE _L01
        RTS

        ; Fire position
        ; sprite X LSB
f3D27   .BYTE $6E,$82,$96,$AA,$BE,$DC,$E6,$48
        .BYTE $52,$19,$23
        ; sprite X MSB
f3D32   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$FF,$FF
        ; sprite Y
f3D3D   .BYTE $32,$32,$32,$32,$32,$32,$32,$6E
        .BYTE $6E,$6E,$6E

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
APPLY_DELTA_MOV         ;$3D48
        ; For the hero (sprite 0)
        ; Apply delta X
        LDA SPRITES_X_LO00
        CLC
        ADC SPRITES_DELTA_X00
        PHA
        BVS _L00
        EOR SPRITES_X_LO00
        AND #$80     ;#%10000000
        BEQ _L00
        LDA SPRITES_X_HI00
        EOR #$FF     ;#%11111111
        STA SPRITES_X_HI00
_L00    PLA
        STA SPRITES_X_LO00

        ; Apply delta Y
        LDA SPRITES_Y00
        CLC
        ADC SPRITES_DELTA_Y00
        STA SPRITES_Y00
        STA SPRITES_PREV_Y00

        ; For the remaining sprites: 1-15
        LDX #$01
_L01    LDA SPRITES_Y00,X
        STA SPRITES_PREV_Y00,X
        LDA SPRITES_TYPE00,X
        BEQ _L03

        ; Apply delta X
        LDA SPRITES_X_LO00,X
        CLC
        ADC SPRITES_DELTA_X00,X
        PHA
        BVS _L02
        EOR SPRITES_X_LO00,X
        AND #$80     ;#%10000000
        BEQ _L02
        LDA SPRITES_X_HI00,X
        EOR #$FF     ;#%11111111
        STA SPRITES_X_HI00,X
_L02    PLA
        STA SPRITES_X_LO00,X

        ; Apply delta Y
        LDA SPRITES_Y00,X
        CLC
        ADC SPRITES_DELTA_Y00,X
        SEC
        SBC V_SCROLL_DELTA
        STA SPRITES_Y00,X
_L03    INX
        CPX #TOTAL_MAX_SPRITES
        BNE _L01
        RTS

        ; FIXME: Unused, remove me

        LDA #$00
        STA SPRITES_TYPE00,X
        STA SPRITES_DELTA_X00,X
        STA SPRITES_DELTA_Y00,X
        LDA ORIG_SPRITE_Y00,X
        STA SPRITES_Y00,X
        LDA #$64
        STA SPRITES_X_LO00,X
        LDA #$FF
        STA SPRITES_X_HI00,X
        LDA #$FF
        STA SPRITES_PTR00,X
        JMP _L03

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; CLEANUP_SPRITES
; All 16 sprites are init and make them invisible
CLEANUP_SPRITES     ;$3DD3
        LDX #$00
_L00    LDA #$64
        STA SPRITES_X_LO00,X
        LDA ORIG_SPRITE_Y00,X
        STA SPRITES_Y00,X
        LDA #$00
        STA SPRITES_DELTA_X00,X
        STA SPRITES_DELTA_Y00,X
        LDA #$FF
        STA SPRITES_X_HI00,X
        STA SPRITES_PTR00,X
        LDA #$00
        STA SPRITES_BKG_PRI00,X
        STA SPRITES_TYPE00,X
        INX
        CPX #TOTAL_MAX_SPRITES
        BNE _L00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Setup up lvl: hero position, patches door to closed, patches turrets to restored,
; min grenades is 5, and more
SETUP_LEVEL             ;$3DFE
        JSR CLEANUP_SPRITES
        LDA #$97     ;#%10010111
        STA SPRITES_X_LO00
        LDA #$B4     ;#%10110100
        STA SPRITES_Y00
        LDA #$98     ;#%10011000
        STA SPRITES_PTR00
        LDA #$06     ;blue
        STA SPRITES_COLOR00
        LDA #$00     ;#%00000000
        STA SPRITES_X_HI00
        STA SPRITES_DELTA_X00
        STA SPRITES_DELTA_Y00
        STA a04E1
        STA HERO_ANIM_MOV_IDX
        STA SPRITES_BKG_PRI00
        STA IS_HERO_DEAD
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        ASL A
        TAX

        ; $FB/$FC -> points to tbl related to levels
        LDA f3EEE,X
        STA pFB,b
        LDA f3EEF,X
        STA pFC,b

        LDY #$00
_L00    LDA (pFB),Y
        CMP V_SCROLL_ROW_IDX
        BCS _L01
        INY
        JMP _L00

_L01    STA V_SCROLL_ROW_IDX
        LDA #$00
        STA V_SCROLL_BIT_IDX
        STA a04EE
        LDA #$14     ;Number of enemies that leaves the final fort/warehouse
        STA ENEMIES_IN_FORT
        JSR INIT_LEVEL_DATA
        LDA #$00     ;Closed door
        JSR LEVEL_PATCH_DOOR
        LDA #$00
        STA IS_ANIM_EXIT_DOOR
        STA a04FD

        ;Draw Left turret at row 56 ($88c0) in lvl1
        LDA #<$88C0
        STA pFB,b
        LDA #>$88C0
        STA pFC,b
        LDA #$00     ;Draw left turret Ok
        JSR LEVEL_PATCH_TURRET

        ;Draw right turret at row  35 ($859a) in lvl1
        LDA #<$859A
        STA pFB,b
        LDA #>$859A
        STA pFC,b
        LDA #$02     ;Draw right turret Ok
        JSR LEVEL_PATCH_TURRET

        ;Draw Left turret at row 22 ($859a) in lvl1
        LDA #<$8370
        STA pFB,b
        LDA #>$8370
        STA pFC,b
        LDA #$00     ;Draw left turret Ok
        JSR LEVEL_PATCH_TURRET

        LDA #$00
        STA IS_LEVEL_COMPLETE

        LDA LEVEL_NR
        AND #$07     ;#%00000111
        TAX
        LDA f3ED2,X
        STA SHOOT_FREQ_MASK
        LDA #$00
        STA FIRE_COOLDOWN

        LDX #$00     ;Set sprite $ff as empty
_L02    LDA #$00
        STA aFFC0,X
        INX
        CPX #$40     ;length of the sprite
        BNE _L02

        JSR SORT_SPRITES_BY_Y
        JSR RERUN_ACTIONS

        ; Make sure player has at least 5 grenades
        LDA GRENADES
        CMP #$05
        BCS _L03
        LDA #$05
        STA GRENADES
_L03    RTS

        ;LVL MAP MSB address. E.g: $6000,$8000,$8000,$A000
f3ECE   .BYTE $60,$80,$80,$A0

        ;Mask regarding how frequent sholdiers shoot.
f3ED2   .BYTE $3F,$1F,$0F,$0F       ;Mask for level 0-3
        .BYTE $0F,$0F,$0F,$0F       ;Mask for level 0-3, 2nd loop

        ; Restart row index for each level.
f3EDA   .BYTE $13,$3D,$61,$83,$AF   ;LVL0
f3EDF   .BYTE $13,$3D,$61,$83,$A6   ;LVL1
        .BYTE $13,$3D,$61,$83,$B2   ;LVL2
f3EE9   .BYTE $13,$3D,$61,$83,$A6   ;LVL3

f3EEF    =*+1
f3EEE   .ADDR f3EDA         ;LVL0
        .ADDR f3EDF         ;LVL1
        .ADDR f3EDF         ;LVL2
        .ADDR f3EE9         ;LVL3

        ; Unused (?)
b3EF6   LDX #$00     ;#%00000000
        STX aD7,b
b3EFB   LDY SPRITE_IDX_TBL + 1,b,X
        LDA SPRITES_Y00,Y
        LDY SPRITE_IDX_TBL,b,X
        CMP SPRITES_Y00,Y
        BCS b3F19
        LDY SPRITE_IDX_TBL,b,X
        LDA SPRITE_IDX_TBL + 1,b,X
        STA SPRITE_IDX_TBL,b,X
        STY f4C,X
        LDA #$01     ;#%00000001
        STA aD7,b
b3F19   INX
        CPX #$0F     ;#%00001111
        BNE b3EFB
        LDA aD7,b
        BNE b3EF6
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Sort sprites by Y.
; FIXME: kind of slow algorithm
SORT_SPRITES_BY_Y       ;$3F24
        LDA #$0F        ;#%00001111
        STA a14,b
        STA aD7,b
_L00    LSR a14,b
        BEQ _L04
        LDA aD7,b
        SEC
        SBC a14,b
        STA a00C9,b
        LDA #$00     ;#%00000000
        STA a003D,b
_L01    LDA a003D,b
        STA a003F,b
_L02    LDA a003F,b
        CLC
        ADC a14,b
        STA a41,b
        LDX a41,b
        LDY SPRITE_IDX_TBL,b,X
        LDA SPRITES_Y00,Y
        LDX a003F,b
        LDY SPRITE_IDX_TBL,b,X
        CMP SPRITES_Y00,Y
        BCS _L03
        LDX a003F,b
        LDY a41,b
        LDA SPRITE_IDX_TBL,Y
        PHA
        LDA SPRITE_IDX_TBL,b,X
        STA SPRITE_IDX_TBL,Y
        PLA
        STA SPRITE_IDX_TBL,b,X
        LDA a003F,b
        SEC
        SBC a14,b
        STA a003F,b
        BPL _L02
_L03    INC a003D,b
        LDA a00C9,b
        CMP a003D,b
        BCC _L00
        JMP _L01

_L04    RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Copies "current" map to screen RAM
; FIXME: Can be improved by having a precalcualted offset table
LEVEL_DRAW_VIEWPORT             ;$3F93
        LDA #<pE000  ;Screen RAM low
        STA _L04
        LDA #>pE000  ;Screen RAM hi
        STA _L05
        LDA #$00
        STA pFB,b
        STA pFD,b
        LDA V_SCROLL_ROW_IDX
        LSR A
        ROR pFB,b
        LSR A
        ROR pFB,b
        LSR A
        ROR pFB,b
        STA pFC,b
        LDA V_SCROLL_ROW_IDX
        ASL A
        ROL pFD,b
        ASL A
        ROL pFD,b
        ASL A
        ROL pFD,b
        CLC
        ADC pFB,b
        STA _L01
        LDA pFC,b
        ADC pFD,b
        CLC
        ADC LVL_MAP_MSB
        STA _L02

_L00    LDY #$27     ;Copy entire row (40 chars)
_L01    =*+$01
_L02    =*+$02
_L03    LDA f0000,Y     ;Self-modifying
_L04    =*+$01
_L05    =*+$02
        STA f0000,Y     ;Self-modifying
        DEY
        BPL _L03

        ;Next row: origin
        CLC
        LDA _L01
        ADC #$28     ;#%00101000
        STA _L01
        BCC _L06
        INC _L02

        ;Next row destination
_L06    CLC
        LDA _L04
        ADC #$28     ;#%00101000
        STA _L04
        BCC _L07
        INC _L05

_L07    CMP #$48     ;#%01001000
        BNE _L00

        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Not really a random number generator, but used as one.
; This function kind of duplicates the value in $0400/$0401
; This function is used mostly to place certain enemies in a pseudo-random
; position.
GET_RANDOM      ;$4006
        LDA a0400
        ASL A
        ROL a0401
        ROL a0400
        LDA a0401
        EOR a0400
        ADC a0401
        STA a0400
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Sets the random "seed". Any value different than 0 is valid, since
; a 0 will generate 0 all the time.
INIT_RANDOM     ;$401D
        LDA $D012    ;Raster Position
        STA a0400
        ASL A
        STA a0401
        BEQ INIT_RANDOM
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Waits until raster reaches $d5 vertical position
; triggered by IRQ_A
WAIT_RASTER_AT_BOTTOM   ;$402A
        LDA RASTER_TICK
_L00    CMP RASTER_TICK
        BEQ _L00
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Updates the Color RAM for current level
SET_LEVEL_COLOR_RAM             ;$4033
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        TAX

        ; $FB/$FC -> Color RAM
        LDA #<pD800
        STA pFB,b
        LDA #>pD800
        STA pFC,b

        LDY #$00     ;#%00000000
_L00    LDA LEVEL_COLOR_RAM,X
        STA (pFB),Y
        INC pFB,b
        BNE _L00
        INC pFC,b
        LDA pFC,b
        CMP #$DC     ;#%11011100
        BNE _L00

        LDY #$27     ;#%00100111
        LDA #$01     ;#%00000001
_L01    STA fDB48,Y
        STA fDB98,Y
        DEY
        BPL _L01
        RTS

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; Setup VIC, plus status bar, scores, sprites, etc.
SETUP_SCREEN            ;$4067
        LDA $D011    ;VIC Control Register 1
        AND #$F7     ;#%11110111        Rows to display = 24
        STA $D011    ;VIC Control Register 1
        LDA #$00     ;#%00000000
        STA $D020    ;Border Color
        LDA $D016    ;VIC Control Register 2
        ORA #$10     ;#%00010000        Enable multi color mode
        STA $D016    ;VIC Control Register 2
        LDA #$09     ;#%00001001
        STA BKG_COLOR0
        STA $D021    ;Background Color 0
        STA $D024    ;Background Color 3
        LDA #$00     ;#%00000000
        STA BKG_COLOR1
        STA $D022    ;Background Color 1, Multi-Color Register 0
        LDA #$0C     ;#%00001100
        STA BKG_COLOR2
        STA $D023    ;Background Color 2, Multi-Color Register 1
        JSR SET_LEVEL_COLOR_RAM
        JSR LEVEL_DRAW_VIEWPORT

        ; set rows 21 and 23 with text and color
        LDX #$00     ;#%00000000
_L00    LDA STATUS_BAR_TXT,X
        STA fE348,X  ;row 21
        LDA #$01     ;#%00000001
        STA fDB48,X  ;white for row 21
        LDA #$20     ;#%00100000
        STA fE398,X  ;row 23
        LDA #$00     ;#%00000000
        STA fDB98,X  ;black for row 23
        INX
        CPX #$28     ;#%00101000
        BNE _L00

        JSR SCREEN_REFRESH_SCORE
        JSR SCREEN_REFRESH_GRENADES
        JSR SCREEN_REFRESH_LIVES
        JSR SCREEN_REFRESH_HISCORE

        LDA #$FF     ;#%11111111
        STA $D015    ;Sprite display Enable
        LDA #$FF     ;#%11111111
        STA $D01C    ;Sprites Multi-Color Mode Select
        LDA #$0F     ;#%00001111
        STA $D025    ;Sprite Multi-Color Register 0
        LDA #$00     ;#%00000000
        STA $D026    ;Sprite Multi-Color Register 1
        RTS

LEVEL_COLOR_RAM         ;$40DA
        .BYTE $0D,$0E,$0D,$0D

STATUS_BAR_TXT          ;$40DE
        .BYTE $6D,$5D,$69,$6C,$5F,$20,$20,$20
        .BYTE $20,$20,$21,$21,$20,$20,$20,$3C
        .BYTE $3F,$21,$20,$20,$20,$67,$5F,$68
        .BYTE $20,$21,$21,$20,$20,$20,$20,$62
        .BYTE $63,$20,$20,$20,$20,$20,$21,$21

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
SETUP_IRQ               ;$4106
        LDA #$DF     ;FIXME: Not a big deal, but should be $D5 instead
        STA $D012    ;Raster Position
        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111
        STA $D011    ;VIC Control Register 1
        LDA #<IRQ_A
        STA IRQ_ADDR_LO
        LDA #>IRQ_A
        STA IRQ_ADDR_HI

        LDA #$00     ;Stop timer
        STA $DC0E    ;CIA1: CIA Control Register A

        SEI
        LDA #<IRQ_HANDLER
        STA $0314    ;IRQ
        LDA #>IRQ_HANDLER
        STA $0315    ;IRQ
        LDA #$F1     ;#%11110001
        STA $D01A    ;VIC Interrupt Mask Register (IMR)
        CLI
        RTS

IRQ_HANDLER
        JMP (IRQ_ADDR_LO)

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; raster = $d5
IRQ_A   NOP
        LDA $D011    ;VIC Control Register 1
        ORA #$60     ;#%01100000    Extended Color = 1, Bitmap = 1
        STA $D011    ;VIC Control Register 1

        ; FIXME: unroll this loop
        LDX #$03     ;#%00000011
_L0     LDA #$FF     ;#%11111111
        STA fE3F8,X  ;Sprites 0,1,2,3 points to spr $ff (empty sprite)
        DEX
        BPL _L0

        LDA $D011    ;VIC Control Register 1
        AND #$F8     ;#%11111000
        ORA #$07     ;#%00000111    Scroll Y position to 7
        STA $D011    ;VIC Control Register 1

        LDA #$00     ;#%00000000
        STA $D021    ;Background Color 0

        ; Charset at $D000 is the one used that contains the letters/numbers
        ; needed to print "SCORE", "MEN", etc.
        LDA $D018    ;VIC Memory Control Register
        AND #$F0     ;#%11110000
        ORA #$04     ;#%00000100    bitmap at $c000 / charset at 010 = $D000
        STA $D018    ;VIC Memory Control Register

        INC RASTER_TICK
        LDA #$DE
        STA $D012    ;Raster Position

        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111    Raster MSB=0
        STA $D011    ;VIC Control Register 1

        LDA #<IRQ_B
        STA IRQ_ADDR_LO
        LDA #>IRQ_B
        STA IRQ_ADDR_HI
        LDA #$01
        STA $D019    ;VIC Interrupt Request Register (IRR)

        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; raster = $de
IRQ_B   NOP
        NOP
        LDA $D011    ;VIC Control Register 1
        AND #$9F     ;#%10011111    Turn Off bitmap, turn off Extended color
        STA $D011    ;VIC Control Register 1

        LDA #$01     ;white
        STA $D022    ;Background Color 1, Multi-Color Register 0
        LDA #$02     ;red
        STA $D023    ;Background Color 2, Multi-Color Register 1

        JSR MUSIC_PLAY

        LDA #$1E
        STA $D012    ;Raster Position

        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111    Raster MSB off
        STA $D011    ;VIC Control Register 1

        LDA #<IRQ_C
        STA IRQ_ADDR_LO
        LDA #>IRQ_C
        STA IRQ_ADDR_HI
        LDA #$01
        STA $D019    ;VIC Interrupt Request Register (IRR)

        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

        ; FIXME: unused vars
        .BYTE $1E,$2A,$3B
        .BYTE $52

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; raster = $1e
; Renders 8 sprites
IRQ_C   LDA V_SCROLL_BIT_IDX
        EOR #$07     ;#%00000111    Reverse Y-bits
        STA a00A7,b

        LDA $D011    ;VIC Control Register 1
        AND #$F8     ;#%11111000
        ORA a00A7,b  ;Vertical scroll position
        STA $D011    ;VIC Control Register 1

        LDA BKG_COLOR0
        STA $D021    ;Background Color 0
        LDA BKG_COLOR1
        STA $D022    ;Background Color 1, Multi-Color Register 0
        LDA BKG_COLOR2
        STA $D023    ;Background Color 2, Multi-Color Register 1

        LDA #$00
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        STA $D01B    ;Sprite to Background Display Priority

        LDA #$0E     ;Points to $D00E (sprite 7 x pos)
        STA VIC_SPRITE_IDX,b
        LDY #$00    ;#%00000000
        STY a00A7,b

_L0     LDX SPRITE_IDX_TBL,b,Y
        LDY VIC_SPRITE_IDX,b
        LDA SPRITES_PREV_Y00,X
        STA $D001,Y  ;Sprite 0 Y Pos
        LDA SPRITES_X_LO00,X
        STA $D000,Y  ;Sprite 0 X Pos
        LDA VIC_SPRITE_IDX,b
        LSR A
        TAY
        LDA SPRITES_PTR00,X
        STA fE3F8,Y
        LDA SPRITES_COLOR00,X
        STA $D027,Y  ;Sprite 0 Color
        LDA SPRITES_X_HI00,X
        AND MASK_0000_0001,Y
        ORA $D010    ;Sprites 0-7 MSB of X coordinate
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA SPRITES_BKG_PRI00,X
        AND MASK_0000_0001,Y
        ORA $D01B    ;Sprite to Background Display Priority
        STA $D01B    ;Sprite to Background Display Priority
        DEC VIC_SPRITE_IDX,b
        DEC VIC_SPRITE_IDX,b
        INC a00A7,b
        LDY a00A7,b
        CPY #$08
        BNE _L0

        ; Set the correct charset for the level
        LDA LEVEL_NR
        AND #$03     ;#%00000011
        ASL A        ;Shift to left, since bit 0 is unused in $D018
        STA a00A7,b

        LDA $D018    ;VIC Memory Control Register
        AND #$F0     ;#%11110000
        ORA a00A7,b  ; Charset Idx. lvl0=$c000, lvl1=$c800, main=$d000, lvl3=$d800
        STA $D018    ;VIC Memory Control Register

        ; FIXME: Not sure whether this is a bug or a feature.
        ; Should it be SPRITE_IDX_TBL + 8 (??)
        ; And instead of adding $14, I guess it should substract $02.
        LDX SPRITE_IDX_TBL + 3,b
        LDA SPRITES_PREV_Y00,X
        CLC
        ADC #$14     ;20 pixels below. Each sprite has 21 pixels.
        STA $D012    ;Raster Position

        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111    Raster MSB off
        STA $D011    ;VIC Control Register 1

        LDA #<IRQ_D
        STA IRQ_ADDR_LO
        LDA #>IRQ_D
        STA IRQ_ADDR_HI
        LDA #$01     ;#%00000001
        STA $D019    ;VIC Interrupt Request Register (IRR)

        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; sprite multiplexor: sprites 4-7
; raster = $??
IRQ_D   ;$4284
        ; Turn off MSB and sprite-bkg pri for upper 4 sprites.
        ; Each sprite will set it individually in case it is needed
        LDA $D010    ;Sprites 0-7 MSB of X coordinate
        AND #$0F     ;#%00001111
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA $D01B    ;Sprite to Background Display Priority
        AND #$0F     ;#%00001111
        STA $D01B    ;Sprite to Background Display Priority

        .FOR I:=8, I<12, I+=1
        LDX SPRITE_IDX_TBL + I,b
        LDA SPRITES_PREV_Y00,X
        STA $D00F - (I-8) * 2   ;Sprite 7 Y Pos
        LDA SPRITES_X_LO00,X
        STA $D00E - (I-8) * 2   ;Sprite 7 X Pos
        LDA SPRITES_PTR00,X
        STA aE3FF - (I - 8)     ;Sprite 7 frame
        LDA SPRITES_COLOR00,X
        STA $D02E - (I - 8)    ;Sprite 7 Color
        LDA SPRITES_X_HI00,X
        AND MASK_1000_0000 - (I - 8)
        ORA $D010    ;Sprites 0-7 MSB of X coordinate
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA SPRITES_BKG_PRI00,X
        AND MASK_1000_0000 - (I - 8)
        ORA $D01B    ;Sprite to Background Display Priority
        STA $D01B    ;Sprite to Background Display Priority
        .NEXT

        ; Y pos for next sprites sets the raster pos
        LDX SPRITE_IDX_TBL + 12,b
        LDA SPRITES_PREV_Y00,X
        SEC
        SBC #$02
        STA $D012    ;Raster Position
        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111    Raster MSB off
        STA $D011    ;VIC Control Register 1

        LDA #<IRQ_E
        STA IRQ_ADDR_LO
        LDA #>IRQ_E
        STA IRQ_ADDR_HI
        LDA #$01
        STA $D019    ;VIC Interrupt Request Register (IRR)

        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; sprite multiplexor: sprites 0-3
; raster = $??
IRQ_E
        ; Turn off MSB and sprite-bkg pri for lower 4 sprites.
        ; Each sprite will set it individually in case it is needed
        LDA $D010    ;Sprites 0-7 MSB of X coordinate
        AND #$F0     ;#%11110000
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA $D01B    ;Sprite to Background Display Priority
        AND #$F0     ;#%11110000
        STA $D01B    ;Sprite to Background Display Priority

        .FOR I:=12, I<16, I+=1
        LDX SPRITE_IDX_TBL + I,b
        LDA SPRITES_PREV_Y00,X
        STA $D007 - (I-12) * 2      ;Sprite 3 Y Pos
        LDA SPRITES_X_LO00,X
        STA $D006 - (I-12) * 2      ;Sprite 3 X Pos
        LDA SPRITES_PTR00,X
        STA aE3FB - (I - 12)
        LDA SPRITES_COLOR00,X
        STA $D02A - (I - 12)        ;Sprite 3 Color
        LDA SPRITES_X_HI00,X
        AND MASK_0000_1000 - (I - 12)
        ORA $D010    ;Sprites 0-7 MSB of X coordinate
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA SPRITES_BKG_PRI00,X
        AND MASK_0000_1000 - (I - 12)
        ORA $D01B    ;Sprite to Background Display Priority
        STA $D01B    ;Sprite to Background Display Priority
        .NEXT

        LDA #$D5
        STA $D012    ;Raster Position
        LDA $D011    ;VIC Control Register 1
        AND #$7F     ;#%01111111    Raster MSB off
        STA $D011    ;VIC Control Register 1

        LDA #<IRQ_A
        STA IRQ_ADDR_LO
        LDA #>IRQ_A
        STA IRQ_ADDR_HI
        LDA #$01     ;#%00000001
        STA $D019    ;VIC Interrupt Request Register (IRR)

        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

        ; Masks
MASK_0000_0001   .BYTE $01           ;0000_0001
MASK_0000_0010   .BYTE $02           ;0000_0010
MASK_0000_0100   .BYTE $04           ;0000_0100
MASK_0000_1000   .BYTE $08           ;0000_1000
MASK_0001_0000   .BYTE $10           ;0001_0000
MASK_0010_0000   .BYTE $20           ;0010_0000
MASK_0100_0000   .BYTE $40           ;0100_0000
MASK_1000_0000   .BYTE $80           ;1000_0000
        ; Unused (?)
        .BYTE $FE
        .BYTE $FD,$FB,$F7
        .BYTE $EF,$DF,$BF
        .BYTE $7F,$8D,$28
        .BYTE $D0

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
; FIXME: From here until $4fff - Unused, remove me.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

        LDA SPRITES_X_HI00,X
        AND MASK_0000_0010
        ORA $D010    ;Sprites 0-7 MSB of X coordinate
        STA $D010    ;Sprites 0-7 MSB of X coordinate
        LDA SPRITES_BKG_PRI00,X
        AND MASK_0000_0010
        ORA $D01B    ;Sprite to Background Display Priority
        STA $D01B    ;Sprite to Background Display Priority
        LDX SPRITE_IDX_TBL + 15,b
        LDA SPRITES_PREV_Y00,X
        STA $D001    ;Sprite 0 Y Pos
        LDA SPRITES_X_LO00,X
        STA $D000    ;Sprite 0 X Pos
        LDA SPRITES_PTR00,X
        STA fE3F8
        LDA SPRITES_COLOR00,X
        STA $D027    ;Sprite 0 Color
        LDA SPRITES_X_HI00,X

        .BYTE $0F,$0E,$0D
        .BYTE $0C,$0B,$0A
        .BYTE $09,$08,$07,$06,$05,$04,$03,$02
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FD,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$02,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FD,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$08,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$02,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$02,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$02,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$20,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FD,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$02,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FD,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$8A,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$8A,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$0A,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82,$02,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$80,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$00,$00,$FF,$00,$FF,$00,$FF
        .BYTE $00,$FF,$FF,$00,$FF,$00,$FF,$00
        .BYTE $FF,$82

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
        *= $5000
.include "music.asm"

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
        *= $6000
.binary "l0-map.bin"
.binary "l0-padding.bin"        ;TODO: can be removed
                                ;only needed to make md5sum identical

        *= $8000
.binary "l1-map.bin"
.binary "l1-padding.bin"        ;TODO: can be removed
                                ;only needed to make md5sum identical

        *= $a000
.binary "l3-map.bin"
.binary "l3-padding.bin"        ;TODO: can be removed
                                ;only needed to make md5sum identical

        *= $c000
.binary "l0-charset.bin"
        *= $c800
.binary "l1-charset.bin"
