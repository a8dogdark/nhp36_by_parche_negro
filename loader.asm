load_init = $CC00
;
l_load = [.len loader]

.proc loader,load_init

BAFER = $0700
BUFAUX = $0800
?RUTINA = BUFAUX+JUMP-RUTINA
GENDAT = $47
;
	//ORG $CC00
	.BYTE $55,$55
    .BYTE $A0,$00
    STY $CC03
    INY
    STY $09
    JSR RECUPERO
    JMP START
NBYTES
    .BYTE 252   ;$FC
FLAGY
    .BYTE 0
FINISH
    .BYTE 0,0
MMMSIOV
    .BYTE $60,$00,$52,$40
    .WORD BAFER
    .BYTE $23,$00
    .WORD $0100
    .BYTE $00,$80
DLIST
    .BYTE $70,$70,$70,$47
    .WORD MENSAJE
    .BYTE $70,$02,$70,$02,$70,$70
    .BYTE $F0,$F0,$F0,$F0,$F0,$F0
    .BYTE $70,$70,$70,$70,$70,$46
DLERR
    .WORD NAME
    .BYTE $70,$02,$41
    .WORD DLIST
MENSAJE
    .SB "       "
    .SB +128,"prisma"
    .SB "       "
    .SB "      PROGRAMAS PARA COMPUTADORES       "
    .SB "              LINEA ATARI               "
NAME
    .SB "                    "
    .SB "     Cargara dentro de "
CONTADOR
    .SB "    Bloques.     "
MERR
    .SB "  -  E R R O R  -   "
    .SB " Retroceda 3 vueltas y presione  START  "
TIEMPO
    LDA #$40
    STA $D40E
    LDX #$E4
    LDY #$5F
    LDA #$06
    JSR $E45C
    RTS
LNEW
    LDX #$04
XNEW
    LDA $02C4,X
    STA PFIN+1,X
    DEX
    BPL XNEW
    LDA $0230
    STA PFIN+6
    LDA $0231
    STA PFIN+7
    LDA 559     ;$022F
    STA PFIN+8
    LDA 756     ;$02F4
    STA PFIN+9
    LDA 755     ;$02F3
    STA PFIN+10
    RTS
NEWL
    LDX #$04
YNEW
    LDA PFIN+1,X
    STA $02C4,X
    DEX
    BPL YNEW
    LDA PFIN+6
    STA $0230
    LDA PFIN+7
    STA $0231
    LDA PFIN+8
    STA 559
    LDA PFIN+9
    STA 756
    LDA PFIN+10
    STA 755
    RTS
NEWDL
    LDX # <DLIST
    LDA # >DLIST
    STX $0230
    STX $D402
    STA $0231
    STA $D403
    LDA #$22
    STA 559
    STA $D400
    LDA #224
    STA 756
    STA $D409
    LDA #$02
    STA 755
    STA $D401
    LDX #$04
COLORLOOP
    LDA TABLA,X
    STA $02C4,X
    STA $D016,X
    DEX
    BPL COLORLOOP
    LDA # <NAME
    LDX # >NAME
    STA DLERR
    STX DLERR+1
    LDX #$CD
    LDY #$D7
    LDA #$06
    JSR $E45C
    LDX #$E5
    LDY #$CD
    LDA #$C0
    STX $0200
    STY $0201
    STA $D40E
    RTS
    LDA #$00
    STA NOSEPO
    LDA $02C6
    STA NOSEPOR02
    JMP $E45F
    PHA
    TXA
    PHA
    LDX NOSEPO
    LDA NOSEPO01,X
    STA $D40A
    STA $D01A
    INC NOSEPO
    PLA
    TAX
    PLA
    RTI
NOSEPO
    .BYTE 0
NOSEPO01
    .BYTE $52,$72,$B4,$EA,$32
NOSEPOR02
    .BYTE $FF,$FF
TABLA
    .BYTE $28,$CA,$00,$44,$00
CONCHAT
    LDA # <MERR
    LDX # >MERR
	STA DLERR
    STX DLERR+1
    RTS
ERROR
    JSR CONCHAT
    LDA #$3C
    STA $D302
    LDA #$FD
    JSR $F2B0
VUELTA
    LDA 53279
    CMP #$06
    BNE VUELTA
    JSR SEARCH
    JMP GRAB
SEARCH
    LDA #$34
    STA $D302
    LDX #$10
    STX $021C
SPEED
    LDX $021C
    BNE SPEED
SIGUE
    LDX #$FD
    STX $14
BUSCA
    LDA $D20F
    AND #$10
    BEQ SIGUE
    LDX $14
    BNE BUSCA
    JMP NEWDL
GBYTE
    CPY NBYTES
    BEQ GRAB
    TYA
    EOR BAFER+3,Y
    EOR GENDAT
    INC GENDAT
    INY
    RTS
GRAB
    LDA $D40B
    BNE GRAB
    LDA PFIN
    BEQ BYE
    JSR LNEW
    JSR NEWDL
?GRAB
    LDX #$0B
MSIO
    LDA MMMSIOV,X
    STA $0300,X
    DEX
    BPL MSIO
    JSR $E459
    BMI ERROR
    LDA BAFER+2
    CMP PFIN
    BCC ERROR
    BEQ RETURN
    JMP ?GRAB
RETURN
    LDA BAFER+255
    STA NBYTES
    LDX #$02
C01
    LDA CONTADOR,X
    CMP #$10
    BNE C02
    LDA #$19
    STA CONTADOR,X
    DEX
    BPL C01
C02
    DEC CONTADOR,X
    JSR NEWL
    DEC PFIN
    LDY #$00
    STY 77
    JMP GBYTE
BYE
    JSR TIEMPO
    LDA #$3C
    LDX #$00
    LDY #$60
    STA $D302
    TXS
    STY BAFER
    JMP ($02E0)
START
    LDY NBYTES
LOOP
    JSR GBYTE
    STA MEMORY+1
    JSR GBYTE
    STA MEMORY+2
    AND MEMORY+1
    CMP #$FF
    BEQ LOOP
    JSR GBYTE
    STA FINISH
    JSR GBYTE
    STA FINISH+1
MBTM
    JSR GBYTE
MEMORY
    STA $FFFF
    LDA MEMORY+1
    CMP FINISH
    BNE OK
    LDA MEMORY+2
    CMP FINISH+1
    BEQ VERFIN
OK
    INC MEMORY+1
    BNE NIM
    INC MEMORY+2
NIM
    JMP MBTM
VERFIN
    LDA $02E2
    ORA $02E3
    BEQ LOOP
    LDX #$F0
    TXS
    STY FLAGY
    JSR TIEMPO
    JSR NEWL
    JSR RINIT
    JSR LNEW
    JSR SEARCH
    LDY FLAGY
    LDX #$00
    TXS
    STX $02E2
    STX $02E3
    JMP LOOP
RINIT
    LDX #PFIN-RUTINA-1
MVRUT
    LDA RUTINA,X
    STA BUFAUX,X
    DEX
    BPL MVRUT
    JMP BUFAUX
RUTINA
    LDA #$3C
    STA $D302
    JSR ?RUTINA
    LDA #$FE
    STA $D301
    RTS
JUMP
    JMP ($02E2)
PFIN
    .BYTE $00,$00,$00,$00,$00,$00
    .BYTE $00,$00,$00,$00,$00
RECUPERO
    JSR LNEW
    LDX #$0B
RECUPER02
    LDA FINRECUPERO,X
    STA $0300,X
    DEX
    BPL RECUPER02
    JSR $E459
    BPL RECUPERO03
    LDA #$3C
    STA $D302
    LDA $D301
    AND #$FD
    STA $D301
    JMP $0400
RECUPERO03
    LDX #$13
RECUPERO04
    LDA FINRECUPERO+2,X
RECUPERO05
    STA NAME,X
    DEX
    BPL RECUPERO04
    LDX #$02
RECUPERO06
    LDA FINRECUPERO+22,X
    STA CONTADOR,X
    DEX
    BPL RECUPERO06
    LDX #$03
    LDA FINRECUPERO+25
    STX $41
    STA PFIN
    LDY #$7F
    LDA #$00
RECUPERO07
    STA $0400,Y
    DEY
    BPL RECUPERO07
    JSR NEWDL
    JMP NEWL
FINRECUPERO
    .BYTE $60,$00,$52,$40
    .WORD FINRECUPERO
    .BYTE $23,$00
    .WORD 26
    .BYTE $00,$80
.endp