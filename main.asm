;Descrição do projeto:
;Faça um firmware para incrementar um contador, e atribuí-lo ao PORTB, exceto no
;bit7. Este bit deve apresentar o estado do botão presente em no bit 2 de PORTA. O
;botão em RA2 deve, por fim, alterar o tempo de incremento. Quando pressionado, o
;contador deve incrementar mais lentamente. Use máscaras de bits para alterar o
;PORTB. Utilize o Timer1 como temporizador.

;OBS:. Colocar no trabalho frequencia utilizada 
#INCLUDE <P16F628A.INC>
__CONFIG _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _HS_OSC
#DEFINE BANK0 BCF STATUS,RP0 ;Seleciona Banco 0 de memória RAM
#DEFINE BANK1 BSF STATUS,RP0 ;Seleciona Banco 1 de memória RAM
;* VARIÁVEIS *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS PELO SISTEMA
CBLOCK 0x20 ;Endereço inicial de armazenamento das variáveis. Deve ser 0x20 para o PIC16F628A.
counter1;contador a ser incremetado(0x20)
counter2 ;alterar velocidade(0x21)
counterT1
AUX_W
AUX_STATUS

ENDC ;FIM DO BLOCO DE MEMÓRIA
ORG 0x00 ;Define localização da instrução seguinte na memória de programa
GOTO INICIO

ORG 0x04 ;Define localização da interrupção
;Rotina para salvar contexto
MOVWF AUX_W
SWAPF STATUS,W
MOVWF AUX_STATUS

;Rotina para tratar interrupção
BTFSS PIR1,0
GOTO OUT_INT
BCF PIR1,0

MOVLW H'0B'
MOVWF TMR1H
MOVLW H'DC'
MOVWF TMR1L

;-- 250ms-- precisamos multiplicar por 4 pra dar 1seg

INCF counterT1,f
MOVLW H'04' ;nº de repetições até bater 1 segundo
XORWF counterT1,w
BTFSS STATUS,Z
GOTO OUT_INT
CLRF counterT1
;Rotina para recuperar contexto (saída da interrupção)
OUT_INT
	MOVLW H'0B'
	MOVWF TMR1H
	MOVLW H'DC'
	MOVWF TMR1L
	MOVLW .0
	MOVWF counter2
	MOVLW .2
	MOVWF counter1
	SWAPF AUX_STATUS,W
	MOVWF STATUS ;recupera valor de registrador STATUS
	SWAPF AUX_W,W ;recupera valor de registrador W
RETFIE

INICIO
BANK1
MOVLW B'00000110'
MOVWF TRISA
MOVLW B'00000000'
MOVWF TRISB
MOVLW B'00110101'
MOVWF T1CON ;configura TMR1
MOVLW B'00000001'
MOVWF PIE1
MOVWF PIR1
BANK0
MOVLW B'00000111' ;desabilita comparadores analógicos e configura pinos do PORTA como E/S digitais
MOVWF CMCON
MOVLW B'11000000'
MOVWF INTCON ;configura interrupção
MOVLW H'5EE'
MOVWF TMR1H
MOVWF TMR1L
MOVLW B'00000000'
MOVWF PORTB

GOTO $

END