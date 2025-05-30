TIMER0_COUNTER		equ		65535-46080+8
TIMES_INTERRUPT         equ		40d             ;20d
;====================================================================
; VARIABLES
;====================================================================
milisegundos            equ             0Ah
fHighByte               equ             0Bh
fLowByte                equ             0Ch
binToBcdHigh            equ             0Dh
binToBcdLow             equ             0Eh
flag_passou_1seg        bit             20h.0
pulso                   bit             P1.0h
;====================================================================
; CODE SEGMENT
;====================================================================
        	     	org             0000h
        sjmp            setup
                        org             000Bh
        ljmp            tratar_interrupcao
setup:
        mov             sp,#(128-25)    
        call            config_timers
restart:

;=========
        mov             TMOD,#21h       ;Configura Timer 1 no modo 2 (8 bits com recarga automática)
        mov             SCON,#50h       ;Configura serial no modo 1 (Habilitando recepcao)
        mov             TH1,#0FAh       ;Carga de TH1 para um clock de 22.1184Mhz
        mov             TL1,TH1
        setb            TR1
;============
        ;clr            TR1
        ;call           delay
loop_displays:
        call            atualizar_displays      
        jnb             RI,loop_displays
        clr             RI
        mov             A,SBUF
        clr             TR1
        call            config_timers
        ;call           reset_contexto_serial
        
        ;jb             pulso,loop_displays
        ;jnb            pulso,$
        mov             TL1,#00h
        mov             TH1,#00h
        setb            TR1
        setb            TR0
        jnb             flag_passou_1seg,$
        clr             TR1
        clr             flag_passou_1seg
        mov             fLowByte,TL1
        mov             fHighByte,TH1
        ;;;TRANSMITIR SERIAL
        call            config_serial_transmissao
        setb            TR1
        mov             A,fHighByte
        mov             SBUF,A
        jnb             TI,$
        clr             TI
        mov             A,fLowByte
        mov             SBUF,A
        jnb             TI,$
        clr             TI
        call            reset_contexto_serial
        ajmp            restart


delay:
        mov             R7,#0FFh
        djnz            R7,$
        mov             R7,#0FFh
        djnz            R7,$
        ret

;
;Configura Timer para a lógica do frequencímetro
;
config_timers:
        mov             IE,#10000010b   ;habilita interrupcao timer 0
        mov             TL0, #low TIMER0_COUNTER        ;inicializa timer 0 low byte
        mov             TH0, #high TIMER0_COUNTER       ;inicializa timer0 high byte (Vai estourar a cada 10 ms)
        mov             TMOD,#01010001b ;Configura Timer 0 e 1
        mov             TL1,#00h        ;Zera Timer1 Low
        mov             TH1,#00h        ;Zera Timer1 High (o Valor da frequência será medido desse timer como contador)
        ;mov            milisegundos,#100d              ;Carrega a variavel milisegundos com o valor 20.Representa o número de estouros para contar 1 segundo
        mov             milisegundos,#TIMES_INTERRUPT
        clr             flag_passou_1seg                ;Limpa a flag que indica o passar de 1 segundo
        ret
;
;Configura Serial para recepcao da frequência
;
config_serial_recepcao:
        ;push           TMOD
        ;push           SCON
        mov             TMOD,#21h       ;Configura Timer 1 no modo 2 (8 bits com recarga automática)
        mov             SCON,#50h       ;Configura serial no modo 1 (Habilitando recepcao)
        mov             TH1,#0FAh       ;Carga de TH1 para um clock de 22.1184Mhz
        mov             TL1,TH1
        ret
;
;Configura Serial para transmissão da frequência
;
config_serial_transmissao:
        ;push           TMOD
        ;push           SCON
        
        ;orl            IE,#90h         ;habilita interrupcao Serial
        mov             TMOD,#21h       ;Configura Timer 1 no modo 2 (8 bits com recarga automática)
        mov             SCON,#40h       ;Configura serial no modo 1 
        ;mov            TH1,#0F3h
        mov             TH1,#0FAh       ;Carga de TH1 para um clock de 22.1184Mhz
        mov             TL1,TH1
        ret

;
;Configura Serial para transmissão da frequência
;
reset_contexto_serial:
        pop             SCON
        pop             TMOD
        ret
atualizar_displays:
        mov             binToBcdHigh,fHighByte
        mov             binToBcdLow,fLowByte
        call            bin24_to_bcd
        call            atualizar_display_frequencia
        call            atualizar_display_unidade
        call            atualizar_display_dezena
        call            atualizar_display_centena
        call            atualizar_display_unidade_milhar
        call            atualizar_display_dezena_milhar
        ret

atualizar_display_frequencia:
        mov             A,#00001110b    ;Move os bits necessário para formar a letra 'F'
        mov             P0,A
        clr             P2.0
        call            delay
        setb            P2.0
        ret
        
;PARAMETROS: R1 com o valor das unidades
atualizar_display_unidade:
        mov             A,R1
        call            convert
        mov             P0,A
        clr             P2.5
        call            delay
        setb            P2.5
        ret
;PARAMETROS: R2 com o valor das dezenas
atualizar_display_dezena:
        mov             A,R2
        call            convert
        mov             P0,A
        clr             P2.4
        call            delay
        setb            P2.4
        ret
;PARAMETROS: R3 com o valor das centenas
atualizar_display_centena:
        mov             A,R3
        call            convert
        mov             P0,A
        clr             P2.3
        call            delay
        setb            P2.3
        ret
;PARAMETROS: R4 com o valor das unidades de milhar
atualizar_display_unidade_milhar:
        mov             A,R4
        call            convert
        mov             P0,A
        clr             P2.2
        call            delay
        setb            P2.2
        ret
;PARAMETROS: R5 com o valor das dezenas de milhar
atualizar_display_dezena_milhar:
        mov             A,R5
        call            convert
        mov             P0,A
        clr             P2.1
        call            delay
        setb            P2.1
        ret

setup_transmissao:

tratar_interrupcao:
        mov             TL0, #low TIMER0_COUNTER
        mov             TH0, #high TIMER0_COUNTER
        djnz            milisegundos,saida
        ;mov            fHighByte,TH1
        ;mov            fLowByte,TL1
        ;clr            TR1
        ;clr            TR0
        mov             milisegundos,#TIMES_INTERRUPT   ;Carrega com o valor 100
        setb            flag_passou_1seg
        clr             TR0
        
saida:
        reti
convert:
        anl             A,#0Fh
        mov             DPTR ,#table
        movc            A,@A+DPTR
        cpl             A
        ret
table:
        DB              00111111B       ;0
        DB              00000110B       ;1
        DB              01011011B       ;2
        DB              01001111B       ;3
        DB              01100110B       ;4
        DB              01101101B       ;5
        DB              01111101B       ;6
        DB              00000111B       ;7
        DB              01111111B       ;8
        DB              01100111B       ;9
        DB              01110111B       ;A
        DB              01111100B       ;B
        DB              00111001B       ;C
        DB              01011110B       ;D
        DB              01111001B       ;E
        DB              01110001B       ;F

bin24_to_bcd:
        mov             R1,#00h
        mov             R2,#00h
        mov             R3,#00h
        mov             R4,#00h
        mov             R5,#00h
        ;
        mov             B,#10D
        mov             A,binToBcdLow
        div             AB
        mov             R1,B
        ;
        mov             B,#10D
        div             AB
        mov             R2,B
        mov             R3,A
        ;
        mov             A,binToBcdHigh
        cjne            A,#0h,next
        ljmp            exit
next:
        mov             A,#6D
        add             A,R1
        mov             B,#10D
        div             AB
        mov             R1,B
        ;
        add             A,#5D
        add             A,R2
        mov             B,#10D
        div             AB
        mov             R2,B
        ;
        add             A,#2D
        add             A,R3
        mov             B,#10D
        div             AB
        mov             R3,B
        ;
        add             A,R4
        mov             R4,A
        ;
        djnz            binToBcdHigh,next
        mov             B,#10D
        mov             A,R4
        div             AB
        mov             R4,B
        mov             R5,A
exit:
        ret
;;;

        
;====================================================================
        END