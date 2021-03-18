                                                                            

;    ___  _____  _____  _____  _____  _____  _   _          ______   ___  ______  _    _  _____  _   _
;   |_  ||  ___||_   _|/  ___|/  ___||  _  || \ | |         |  _  \ / _ \ | ___ \| |  | ||_   _|| \ | |
;     | || |__    | |  \ `--. \ `--. | | | ||  \| | ______  | | | |/ /_\ \| |_/ /| |  | |  | |  |  \| |
;     | ||  __|   | |   `--. \ `--. \| | | || . ` ||______| | | | ||  _  ||    / | |/\| |  | |  | . ` |
; /\_ / /| |___  _| |_ /\__/ //\__/ /\ \_/ /| |\  |         | |/ / | | | || |\ \ \  /\  / _| |_ | |\  |
; \____/ \____/  \___/ \____/ \____/  \___/ \_| \_/         |___/  \_| |_/\_| \_| \/  \/  \___/ \_| \_/

PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet
CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

PSECT code

INISYS:
    ;Cambio a Banco N1
    BCF STATUS, 6
    BSF STATUS, 5 ; Banco1
    ; Modificar TRIS
    BSF TRISC, 0    ; IN  portC0
    BSF TRISC, 1    ; IN  portC1
    BSF TRISC, 2    ; IN  portC2
    BSF TRISC, 3    ; IN  portC3
    BSF TRISC, 4    ; IN  portC4
    CLRF TRISD ; SALIDAS
    ; Regresar a banco 0
    BCF STATUS, 5 ; Banco0


main:
    MOVF PORTC,0
    MOVWF 0x20
    ; S5
    MOVF 0x20,0
    ANDLW 0b00010000
    MOVWF 0x21
    RRF 0x21,1
    RRF 0x21,1
    RRF 0x21,1
    RRF 0x21,1
    MOVF 0x21,0
    ANDLW 0b00000001
    MOVWF 0x21

    ; S4
    MOVF 0x20,0
    ANDLW 0b00001000
    MOVWF 0x22
    RRF 0x22,1
    RRF 0x22,1
    RRF 0x22,1
    MOVF 0x22,0
    ANDLW 0b00000001
    MOVWF 0x22

    ; S3
    MOVF 0x20,0
    ANDLW 0b00000100
    MOVWF 0x23
    RRF 0x23,1
    RRF 0x23,1
    MOVF 0x23,0
    ANDLW 0b00000001
    MOVWF 0x23

    ; S2
    MOVF 0x20,0
    ANDLW 0b00000010
    MOVWF 0x24
    RRF 0x24,1
    MOVF 0x24,0
    ANDLW 0b00000001
    MOVWF 0x24

    ; S1
    MOVF 0x20,0
    ANDLW 0b00000001
    MOVWF 0x25
    MOVF 0x25,0
    ANDLW 0b00000001
    MOVWF 0x25

    ; S5'
    MOVF 0x20,0
    ANDLW 0b00010000
    MOVWF 0x26
    RRF   0x26,1
    RRF   0x26,1
    RRF   0x26,1
    RRF   0x26,1
    COMF  0x26,1
    MOVF  0x26,0
    ANDLW 0b00000001
    MOVWF 0x26

    ; S4'
    MOVF 0x20,0
    ANDLW 0b00001000
    MOVWF 0x27
    RRF   0x27,1
    RRF   0x27,1
    RRF   0x27,1
    COMF  0x27,1
    MOVF  0x27,0
    ANDLW 0b00000001
    MOVWF 0x27

    ; S3'
    MOVF 0x20,0
    ANDLW 0b00000100
    MOVWF 0x28
    RRF 0x28,1
    RRF 0x28,1
    COMF 0x28,1
    MOVF 0x28,0
    ANDLW 0b00000001
    MOVWF 0x28

    ; S2'
    MOVF 0x20,0
    ANDLW 0b00000010
    MOVWF 0x29
    RRF 0x29,1
    COMF 0x29,1
    MOVF 0x29,0
    ANDLW 0b00000001
    MOVWF 0x29

    ; S1'
    MOVF 0x20,0
    ANDLW 0b00000001
    MOVWF 0x2A
    COMF  0x2A,1
    MOVF  0x2A,0
    ANDLW 0b00000001
    MOVWF 0x2A

   ;OPERACIONES
   ;!S2S3 + !S1S5 + !S1S4 M1(A)
    M1A:
    MOVF    0x23,0
    ANDWF   0x29,0
    MOVWF   0x3A
    MOVF    0x2A
    ANDWF   0x21,0
    MOVWF   0x4A
    MOVF    0x2A
    ANDWF   0x22,0
    IORWF   0x3A,0
    IORWF   0x4A,0
    MOVWF   0x2B

    BTFSC 0x2B,0
    GOTO ONM1A
    GOTO OFFM1A

    ONM1A:
    BSF PORTD,0
    GOTO M1R

    OFFM1A:
    BCF PORTD,0
    GOTO M1R

    ;!S2!S3!S4!S5 + S1!S4  M1(R)
   M1R:
    MOVF    0x29,0
    ANDWF   0x28,0
    ANDWF   0x27,0
    ANDWF   0x26,0
    MOVWF   0x2C
    MOVF    0x25,0
    ANDWF   0x27,0
    IORWF   0x2C,0
    MOVWF   0x3C

    BTFSC 0x3C,0
    GOTO ONM1R
    GOTO OFFM1R

    ONM1R:
    BSF PORTD,1
    GOTO M2A

    OFFM1R:
    BCF PORTD,1
    GOTO M2A

    ;S3!S4 + S2!S4 + S1!S3 M2(A)
   M2A:
    MOVF    0x23,0
    ANDWF   0x27,0
    MOVWF   0x2D
    MOVF    0X24,0
    ANDWF   0x27,0
    MOVWF   0x3D
    MOVF    0x25,0
    ANDWF   0x28,0
    IORWF   0x2D,0
    IORWF   0x3D,0
    MOVWF   0x4D

    BTFSC 0x4D,0
    GOTO ONM2A
    GOTO OFFM2A

    ONM2A:
    BSF PORTD,2
    GOTO M2R

    OFFM2A:
    BCF PORTD,2
    GOTO M2R

  ;!S1S5 + !S1!S2!S3!S4    M2 (R)
   M2R:
    MOVF    0x2A,0
    ANDWF   0x29,0
    ANDWF   0x28,0
    ANDWF   0x27,0
    MOVWF   0x2E
    MOVF    0x2A,0
    ANDWF   0x21,0
    IORWF   0x2E,0
    MOVWF   0x3E

    BTFSC 0x3E,0
     GOTO ONM2R
    GOTO OFFM2R

    ONM2R:
    BSF PORTD,3
    GOTO LAI

    OFFM2R:
    BCF PORTD,3
    GOTO LAI


    ;LED-IZ=   S2!S4+S1!S3
   LAI:
    MOVF    0x24,0
    ANDWF   0x27,0
    MOVWF   0x2F
    MOVF    0x25,0
    ANDWF   0X28,0
    IORWF   0x2F,0
    MOVWF   0x3F

    BTFSC 0x3F,0
    GOTO ONLAI
    GOTO OFFLAI

    ONLAI:
    BSF PORTD,4
    GOTO LAD

    OFFLAI:
    BCF PORTD,4
    GOTO LAD

    ;LED-DER= !S1S5+!S1S4
   LAD:
    MOVF    0x2A,0
    ANDWF   0x21,0
    MOVWF   0X30
    MOVF    0x2A,0
    ANDWF   0x22,0
    IORWF   0x30,0
    MOVWF   0x4E

    BTFSC 0x4E,0
    GOTO ONLAD
    GOTO OFFLAD

    ONLAD:
    BSF PORTD,5
    GOTO LR

    OFFLAD:
    BCF PORTD,5
    GOTO LR

    ;LED ROJO= !S1!S2!S3!S4!S5 + S2S5
    LR:
    MOVF    0x2A,0
    ANDWF   0x29,0
    ANDWF   0x28,0
    ANDWF   0x27,0
    ANDWF   0x26,0
    MOVWF   0x31
    MOVF    0x24,0
    ANDWF   0x21,0
    IORWF   0x31
    MOVWF   0x32

    BTFSC 0x32,0
    GOTO ONLR
    GOTO OFFLR

    ONLR:
    BSF PORTD,6
    GOTO main

    OFFLR:
    BCF PORTD,6
    GOTO main
END
