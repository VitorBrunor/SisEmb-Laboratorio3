#INCLUDE <P16F628A.INC>
	__CONFIG _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _HS_OSC
#DEFINE BANK0 BCF STATUS,RP0 ;Seleciona Banco 0 de mem�ria RAM
#DEFINE BANK1 BSF STATUS,RP0 ;Seleciona Banco 1 de mem�ria RAM
 
;* VARI�VEIS *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS PELO SISTEMA
	CBLOCK 0x20 ;Endere�o inicial de armazenamento das vari�veis. Deve ser 0x20 para o PIC16F628A.
	AUXW ;Endere�o 0x20
	AUXSTATUS;Endere�o 0x21
	counter1 ;Endere�o 0x22
	ENDC ;FIM DO BLOCO DE MEM�RIA

	ORG 0x00 ;Define localiza��o da instru��o seguinte na mem�ria de programa
	GOTO INICIO
	ORG 0x04
	MOVWF AUXW
	SWAPF STATUS,W
	MOVWF AUXSTATUS
	BTFSS INTCON,T0IF ;testar se o timer0 realmente estourou.
	GOTO OUT_INT
	;Rotina para tratar interrup��o
	DECFSZ counter1,F	;zerar contador simbolizando que 30 ciclos se passaram 1 segundo
	GOTO OUT_INT
	MOVLW B'00001111'; como na XOR s� passa bits diferentes 00 e 11 v�o ter saida 0
	XORWF PORTB ;inverte valores logicos
	;Rotina para recuperar contexto (sa�da da interrup��o)
	MOVLW .30
	MOVWF counter1 ;restaura o valor do contador(tem que ser fora de OUT_INT para n�o resetar durante o decremento)
OUT_INT
	MOVLW .0
	MOVWF TMR0
	SWAPF AUXSTATUS,W
	MOVWF STATUS ;recupera valor de registrador STATUS
	SWAPF AUXW,W ;recupera valor de registrador W
	BCF INTCON,2 ;garantir que o flag vai ser zerado ao sair
	RETFIE

INICIO
	BANK1
	MOVLW B'00000010'
	MOVWF TRISA
	MOVLW B'00000000'
	MOVWF TRISB
	MOVLW B'10000110'
	MOVWF OPTION_REG ;configura OPTION_REG

	BANK0
	MOVLW B'00000111' ;desabilita comparadores anal�gicos e configura pinos do PORTA como E/S digitais
	MOVWF CMCON
	MOVLW B'01100100';bit 7(int. geral)desligado para que possa ser modificado no c�digo main
	MOVWF INTCON ;configura interrup��o
	MOVLW .0 ;move a literal 10d para work
	MOVWF TMR0 ;inicializa TMR0 em 0d
	MOVLW .30 ;move a literal 30D para work
	MOVWF counter1 ;inicializa counter1 em 30d
	MOVLW B'00000101'
	MOVWF PORTB ;move para portb os leds que ficar�o acesos e apagados no estado inicial
MAIN
	BTFSS PORTA,1 ; TESTA BOT�O RA1 E DIRECIONA PARA FUN��ES
	CALL NOT_PRESSED_BT
	CALL PRESSED_BT	
PRESSED_BT
	BCF INTCON,7 ;desabilita todas as interrup��es
	GOTO MAIN
NOT_PRESSED_BT
	BSF INTCON,7 ;habilita as interrup��es
	GOTO MAIN
END

;<LABORATORIO 3><EMBEDED_SYSTEMS><DR� LETICIA ARAUJO>
;<LUCAS DA SILVA NUNES E VITOR BRUNOR>