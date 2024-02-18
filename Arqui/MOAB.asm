.data  ; Segmento de datos
AREA_DE_MEMORIA EQU 0x0800
NULL_NODE EQU 0X8000
.code  ; Segmento de código
	JMP mainProg

;------------------------------BEGIN inicializarArbol-----------------------------------------

	inicializarArbol PROC
	PUSH AX; indice del array
	PUSH BX; indice de la memoria
	MOV AX,0
	
	for_inicializarArbol:
		CMP AX,0X0800
		JAE END_inicializarArbol
		MOV BX,AX
		SHL BX,1
		MOV ES:[BX],0X8000
		INC AX
		JMP for_inicializarArbol


	END_inicializarArbol:
	POP BX
	POP AX
	RET
	inicializarArbol ENDP

;------------------------------END inicializarArbol-----------------------------------------



;------------------------------BEGIN cambiarModo--------------------------------------------
;***AGREGAR OUT
	cambiarModo PROC
		PUSH BP 
		MOV BP,SP

		PUSH AX; GUARDAR AX
				
		MOV AX, SS:[BP+4];NUEVO MODO
		MOV [2],AX;modo=nuevoModo
		MOV WORD PTR[0],0
		
		CALL inicializarArbol

		MOV AX,SS:[BP+2]
		MOV SS:[BP+4],AX
		POP AX
		POP BP
		ADD SP,2
		RET
	cambiarModo ENDP


;------------------------------END cambiarModo----------------------------------------------


;------------------------------BEGIN agregarEstatico-----------------------------------------
;***AGREGAR OUT
	agregarEstatico PROC
		PUSH BP 
		MOV BP,SP
		
		;;SALVAR CONTEXTO	
		PUSH AX
		PUSH BX
		PUSH CX


		MOV AX, SS:[BP+4]; AX= num
		MOV CX, SS:[BP+6]; BX= indice ;INDICE DEL ARRAY
		MOV BX,CX
		SHL BX,1; INDICE DE MEMORIA		

		CMP CX,0x0800
		JG error_memoria_agregarEstatico

		CMP WORD PTR ES:[BX], 0X8000 ;;;ES 0X8000 PERO AUN NO LO INICIALICE
		JZ colocar_num_agregarEstatico
		
		CMP ES:[BX], AX
		JZ error_repetido_agregarEstatico
		JG agregar_izq_agregarEstatico
		JMP agregar_der_agregarEstatico
	
	colocar_num_agregarEstatico:
			MOV ES:[BX], AX
			MOV BX,2
			MOV CX,0
			PUSH BX
			PUSH AX
			PUSH CX
			CALL printLogParam
			JMP END_agregarEstatico

	agregar_izq_agregarEstatico:
			SHL CX,1
			ADD CX,1	;indice_der=indice*2+1
			PUSH CX
			PUSH AX
			CALL agregarEstatico
			JMP END_agregarEstatico	

	agregar_der_agregarEstatico:
			SHL CX,1
			ADD CX,2	;indice_izq=indice*2+2
			PUSH CX
			PUSH AX
			CALL agregarEstatico
			JMP END_agregarEstatico
	
	error_memoria_agregarEstatico:
			MOV BX,2
			MOV CX,4
			PUSH BX
			PUSH AX
			PUSH CX
			CALL printLogParam
			JMP END_agregarEstatico
		
	error_repetido_agregarEstatico:
			MOV BX,2
			MOV CX,8
			PUSH BX
			PUSH AX
			PUSH CX
			CALL printLogParam
			JMP END_agregarEstatico
		
	END_agregarEstatico:
		POP CX
		POP BX
		MOV AX, SS:[BP+2]
		MOV SS:[BP+6],AX
		POP AX
		POP BP
		ADD SP,4
		RET
		
	agregarEstatico ENDP

;------------------------------END agregarEstatico-----------------------------------------


;------------------------------BEGIN agregarDinamico-----------------------------------------
;***AGREGAR OUT
	agregarDinamico PROC
		PUSH BP 
		MOV BP,SP
		
		;;SALVAR CONTEXTO	
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV CX, SS:[BP+4]; CX= num
		MOV DX, SS:[BP+6]; DX= indice ;INDICE DEL ARRAY
		MOV AX,6
		MUL DX
		MOV BX,AX;;; INDICE DE MEMORIA
		
		CMP DX,0x0800
		JG error_memoria_agregarDinamico

		CMP WORD PTR ES:[BX], 0X8000 ;;;ES 0X8000 PERO AUN NO LO INICIALICE
		JZ colocar_num_agregarDinamico


		CMP ES:[BX], CX ;;;COMPARO ARRAY[i] CON NUM
		JZ error_repetido_agregarDinamico
		JG agregar_izq_agregarDinamico
		JMP agregar_der_agregarDinamico

	colocar_num_agregarDinamico:
			MOV ES:[BX], CX
			INC WORD PTR[0X0000] ;TOPE++
			MOV BX,2
			MOV AX,0
			PUSH BX
			PUSH CX
			PUSH AX
			CALL printLogParam
			JMP END_agregarDinamico

	agregar_izq_agregarDinamico:
			MOV DX,ES:[BX +2] ;INDICE DE LA IZQUIERDA
			CMP DX, 0X8000; CAMBIAR POR 0X8000
			JNE callizq_agregarDinamico
			MOV DX,[0X0000]; CX=TOPE
			MOV ES:[BX+2], DX ; IZQ=TOPE
		callizq_agregarDinamico:
			PUSH DX
			PUSH CX
			CALL agregarDinamico
			JMP END_agregarDinamico	

agregar_der_agregarDinamico:
			MOV DX,ES:[BX +4] ;INDICE DE LA DERECHA
			CMP DX, 0X8000; CAMBIAR POR 0X8000
			JNE callder_agregarDinamico
			MOV DX,[0X0000]; CX=TOPE
			MOV ES:[BX+4], DX ; DER=TOPE
		callder_agregarDinamico:
			PUSH DX
			PUSH CX
			CALL agregarDinamico
			JMP END_agregarDinamico	
	
	error_memoria_agregarDinamico:
			MOV BX,2
			MOV AX,4
			PUSH BX
			PUSH CX
			PUSH AX
			CALL printLogParam
			JMP END_agregarDinamico
		
	error_repetido_agregarDinamico:
			MOV BX,2
			MOV AX,8
			PUSH BX
			PUSH CX
			PUSH AX
			CALL printLogParam
			JMP END_agregarDinamico

	
	END_agregarDinamico:
		POP DX
		POP CX
		POP BX
		MOV AX, SS:[BP+2]
		MOV SS:[BP+6],AX
		POP AX
		POP BP
		ADD SP,4
		RET
		
	agregarDinamico ENDP

;------------------------------END agregarDinamico-----------------------------------------


;------------------------------***BEGIN agregarNodo***-----------------------------------------

	agregarNodo PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX

		MOV AX, 0
		PUSH AX
		MOV AX, SS:[BP+4]; AX= num
		PUSH AX

		CMP WORD PTR[2],0
		JZ call_AE
		
		CALL agregarDinamico
		JMP END_agregarNodo
		
	call_AE:
		CALL agregarEstatico
		
	END_agregarNodo:
		MOV AX, SS:[BP+2]	
		MOV SS:[BP+6],AX	
		POP AX
		POP BP
		ADD SP,4
		RET
	agregarNodo ENDP


;------------------------------***END agregarNodo***----------------------------------------------


;------------------------------BEGIN calcularAlturaEstatico---------------------------------------
;DEVUELVE RESULTADO EN STACK
	calcularAlturaEstatico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX ;RES
		PUSH BX
		PUSH CX ;INDICE


		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		MOV BX,CX
		SHL BX,1; BX= INDICE DE MEMORIA		
		CMP ES:[BX],0x8000
		JZ ret_0_calcularAlturaEstatico
		JMP comp_altEstatico
		
	ret_0_calcularAlturaEstatico:
		MOV AX,0; RES=0		
		JMP END_calcularAlturaEstatico
		
	comp_altEstatico:
		INC BX ; BX= INDICE IZQ
		MOV CX,BX
		INC CX ; CX= INDICE DER
		
		PUSH BX
		CALL calcularAlturaEstatico
		POP BX ; RESULTADO DE ALTURA POR IZQ

		PUSH CX
		CALL calcularAlturaEstatico
		POP CX; RESULTADO DE ALTURA POR DER		
		
		CMP BX,CX
		JG ret_alturaIzqEstatico
		JMP ret_alturaDerEstatico

	ret_alturaIzqEstatico:
		MOV AX,BX ;RES=ALTURA IZQ
		INC AX ;RES=ALTURA IZQ + 1
		JMP END_calcularAlturaEstatico

	ret_alturaDerEstatico:
		MOV AX,CX ;RES=ALTURA DER
		INC AX ;RES=ALTURA DER + 1
		JMP END_calcularAlturaEstatico

	END_calcularAlturaEstatico:
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK	
		POP CX
		POP BX
		POP AX
		POP BP
		RET

	calcularAlturaEstatico ENDP

;------------------------------END calcularAlturaEstatico-----------------------------------------

;------------------------------BEGIN calcularAlturaDinamico---------------------------------------
	;DEVUELVE RESULTADO EN STACK
	calcularAlturaDinamico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX ;RES
		PUSH BX
		PUSH CX ;INDICE


		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		CMP CX, 0X8000
		JZ ret_0_calcularAlturaDinamico
		MOV AX,6
		MUL CX
		MOV BX,AX ;BX= INDICE DE MEMORIA
		
		MOV AX,ES:[BX]; AX=NODO.num
		CMP AX,0X8000
		JZ ret_0_calcularAlturaDinamico
		JMP comp_altDinamico

	comp_altDinamico:
		MOV CX,ES:[BX+2] ;INDICE IZQ
		MOV AX,ES:[BX+4] ; INDICE DER

		PUSH CX
		CALL calcularAlturaDinamico
		POP CX ;ALTURA IZQ

		PUSH AX
		CALL calcularAlturaDinamico
		POP AX ;ALTURA DER

		CMP CX,AX
		JG ret_alturaIzqDinamico
		JMP ret_alturaDerDinamico

	ret_alturaIzqDinamico:
		MOV AX,CX
		INC AX	
		JMP END_calcularAlturaDinamico

	ret_alturaDerDinamico:
		INC AX
		JMP END_calcularAlturaDinamico

	ret_0_calcularAlturaDinamico:
		MOV AX,0; RES=0		
		JMP END_calcularAlturaDinamico

	END_calcularAlturaDinamico:
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK	
		POP CX
		POP BX
		POP AX
		POP BP
		RET

	calcularAlturaDinamico ENDP



;------------------------------END calcularAlturaDinamico-----------------------------------------

;------------------------------***BEGIN calcularAltura***----------------------------------------------
	
	calcularAltura PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX

		MOV AX, 0
		PUSH AX

		CMP WORD PTR[2],0
		JZ call_CAE
		
		CALL calcularAlturaDinamico
		JMP END_calcularAltura
		
	call_CAE:
		CALL calcularAlturaEstatico
		
	END_calcularAltura:		
		POP AX; RESULTADO
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK
		POP AX
		POP BP
		RET
	calcularAltura ENDP


;------------------------------***END calcularAltura***----------------------------------------------

;------------------------------BEGIN calcularSumaEstatico--------------------------------------------

	calcularSumaEstatico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX ;RES
		PUSH BX
		PUSH CX ;INDICE


		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		MOV BX,CX
		SHL BX,1; BX= INDICE DE MEMORIA		
		CMP ES:[BX],0x8000
		JZ ret_0_calcularSumaEstatico
		JMP sumRamasEstatico
		
	ret_0_calcularSumaEstatico:
		MOV AX,0; RES=0		
		JMP END_calcularSumaEstatico
		
	sumRamasEstatico:
		MOV AX,ES:[BX];AX=ARRAY[i]
		INC BX ; BX= INDICE IZQ i*2+1
		MOV CX,BX
		INC CX ; CX= INDICE DER i*2+2
		
		PUSH BX
		CALL calcularSumaEstatico
		POP BX ; RESULTADO DE SUMA POR IZQ

		PUSH CX
		CALL calcularSumaEstatico
		POP CX; RESULTADO DE SUMA POR DER		

		ADD AX,BX
		ADD AX,CX
		JMP END_calcularSumaEstatico

	END_calcularSumaEstatico:
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK	
		POP CX
		POP BX
		POP AX
		POP BP
		RET

	calcularSumaEstatico ENDP	

;------------------------------END calcularSumaEstatico----------------------------------------------

;------------------------------BEGIN calcularSumaDinamico--------------------------------------------
	;DEVUELVE RESULTADO EN STACK
	calcularSumaDinamico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX ;RES
		PUSH BX
		PUSH CX ;INDICE
		
		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		CMP CX, 0X8000	
		JZ ret_0_calcularSumaDinamico
		MOV AX,6
		MUL CX
		MOV BX,AX ;BX= INDICE DE MEMORIA
		
		MOV AX,ES:[BX]; AX=NODO.num
		CMP AX,0X8000
		JZ ret_0_calcularSumaDinamico
		JMP sumRamasDinamico

	sumRamasDinamico:
		MOV CX,ES:[BX+2] ;INDICE IZQ
		MOV AX,ES:[BX+4] ; INDICE DER

		PUSH CX
		CALL calcularSumaDinamico
		POP CX ;SUMA IZQ

		PUSH AX
		CALL calcularSumaDinamico
		POP AX ;SUMA DER
		
		ADD AX,ES:[BX]
		ADD AX,CX
		JMP END_calcularSumaDinamico

	ret_0_calcularSumaDinamico:
		MOV AX,0; RES=0		
		JMP END_calcularSumaDinamico

	END_calcularSumaDinamico:
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK	
		POP CX
		POP BX
		POP AX
		POP BP
		RET

	calcularSumaDinamico ENDP



;------------------------------END calcularSumaDinamico----------------------------------------------

;------------------------------***BEGIN calcularSuma***----------------------------------------------
	calcularSuma PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX

		MOV AX, 0
		PUSH AX

		CMP WORD PTR[2],0
		JZ call_CSE
		
		CALL calcularSumaDinamico
		JMP END_calcularSuma
		
	call_CSE:
		CALL calcularSumaEstatico
		
	END_calcularSuma:		
		POP AX; RESULTADO
		MOV SS:[BP+4],AX ;COLOCO EL RESULTADO EN EL STACK
		POP AX
		POP BP
		RET
	calcularSuma ENDP


;------------------------------***END calcularSuma***----------------------------------------------

;------------------------------BEGIN imprimirArbolEstatico----------------------------------------------
	imprimirArbolEstatico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX 
		PUSH BX
		PUSH CX ;INDICE
		PUSH DX ;ORDEN
		
		MOV DX,SS:[BP+6]; DX=ORDEN
		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		CMP CX,0X0800
		JAE END_imprimirArbolEstatico
		MOV BX,CX
		SHL BX,1; BX= INDICE DE MEMORIA		
		CMP ES:[BX],0x8000
		JZ END_imprimirArbolEstatico
		JMP compararOrdenEstatico
		
	compararOrdenEstatico:
		
		MOV AX,ES:[BX];AX=ARRAY[i]
		INC BX ; BX= INDICE IZQ i*2+1
		MOV CX,BX
		INC CX ; CX= INDICE DER i*2+2
		CMP DX, 0
		JZ imprimirAscendenteEstatico
		JMP imprimirDescendenteEstatico

	imprimirAscendenteEstatico:
			
		PUSH DX
		PUSH BX
		CALL imprimirArbolEstatico
		
		OUT 21, AX
		
		PUSH DX
		PUSH CX
		CALL imprimirArbolEstatico

		JMP END_imprimirArbolEstatico

	imprimirDescendenteEstatico:		

		PUSH DX
		PUSH CX
		CALL imprimirArbolEstatico
		
		OUT 21, AX
		
		PUSH DX
		PUSH BX
		CALL imprimirArbolEstatico


		JMP END_imprimirArbolEstatico

	END_imprimirArbolEstatico:
		MOV AX,SS:[BP+2] ;IP
		MOV SS:[BP+6],AX ;COPIO IP ABAJO DEL TODO
		POP DX
		POP CX
		POP BX
		POP AX
		POP BP
		ADD SP,4
		RET
	imprimirArbolEstatico ENDP
;------------------------------END imprimirArbolEstatico----------------------------------------------


;------------------------------BEGIN imprimirArbolDinamico----------------------------------------------
	imprimirArbolDinamico PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX 
		PUSH BX
		PUSH CX ;INDICE
		PUSH DX
		
		MOV CX,SS:[BP+4]; CX= INDICE DE ARRAY (PARAMETRO)
		MOV DX,SS:[BP+6]; DX= ORDEN
		CMP CX, 0X8000
		JZ END_imprimirArbolDinamico
		MOV BX,DX
		MOV AX,6
		MUL CX
		MOV DX,BX
		MOV BX,AX ;BX= INDICE DE MEMORIA
		
		MOV AX,ES:[BX]; AX=NODO.num
		CMP AX,0X8000
		JZ END_imprimirArbolDinamico
		JMP compararOrdenDinamico

	compararOrdenDinamico:
		CMP DX,0
		JZ imprimirAscendenteDinamico
		JMP imprimirDescendenteDinamico
		
	imprimirAscendenteDinamico:	
		MOV CX,ES:[BX+2] ;INDICE IZQ
		PUSH DX
		PUSH CX
		CALL imprimirArbolDinamico

		OUT 21,AX

		MOV CX,ES:[BX+4] ;INDICE DER
		PUSH DX
		PUSH CX	
		CALL imprimirArbolDinamico
		
		JMP END_imprimirArbolDinamico

	imprimirDescendenteDinamico:	
		MOV CX,ES:[BX+4] ;INDICE DER
		PUSH DX
		PUSH CX
		CALL imprimirArbolDinamico

		OUT 21,AX

		MOV CX,ES:[BX+2] ;INDICE IZQ
		PUSH DX
		PUSH CX	
		CALL imprimirArbolDinamico
		
		JMP END_imprimirArbolDinamico

	END_imprimirArbolDinamico:
		MOV AX,SS:[BP+2] ;IP
		MOV SS:[BP+6],AX ;COPIO IP ABAJO DEL TODO
		POP DX
		POP CX
		POP BX
		POP AX
		POP BP
		ADD SP,4
		RET
	imprimirArbolDinamico ENDP
;------------------------------END imprimirArbolDinamico----------------------------------------------


;------------------------------***BEGIN ImprimirArbol***----------------------------------------------

	imprimirArbol PROC
		PUSH BP 
		MOV BP,SP

		;;SALVAR CONTEXTO	
		PUSH AX ;ORDEN

		MOV AX,SS:[BP+6]
		PUSH AX ;ORDEN
		MOV AX,0
		PUSH AX ; INDICE INICIAL (0)
		CMP WORD PTR[2],0
		JZ call_IE
		
		CALL imprimirArbolDinamico
		JMP END_imprimirArbol
		
	call_IE:
		CALL imprimirArbolEstatico
		
	END_imprimirArbol:		
		MOV AX, SS:[BP+2] ;IP
		MOV SS:[BP+6],AX
		POP AX
		POP BP
		ADD SP,4
		RET
	imprimirArbol ENDP

;------------------------------***END ImprimirArbol***----------------------------------------------

;------------------------------***BEGIN ImprimirMemoria***----------------------------------------------
	imprimirMemoria PROC
		PUSH BP 
		MOV BP,SP


		;;SALVAR CONTEXTO	
		PUSH DX ;INDICE DE ARRAY
		PUSH BX ;INDICE DE MEMORIA
		PUSH CX 
		PUSH AX
		MOV CX,SS:[BP+4]; CX=N
		MOV DX,0
		CMP WORD PTR[2],0
		JZ for_imprimirMemoria
		MOV AX,3
		MUL CX ;DINAMICO: N*3
		MOV CX,AX

	for_imprimirMemoria:
		CMP DX,0X0800
		JAE END_imprimirMemoria
		CMP DX,CX ;COMPARO INDICE CON N
		JAE END_imprimirMemoria
		MOV BX,DX
		SHL BX,1
		MOV AX,ES:[BX]
		OUT 21,AX ;INDICE DE MEMORIA
		INC DX
		JMP for_imprimirMemoria

	END_imprimirMemoria:
			
		MOV AX,SS:[BP+2]
		MOV SS:[BP+4],AX
		POP AX
		POP CX
		POP BX	
		POP DX
		POP BP
		ADD SP,2
		RET
	imprimirMemoria ENDP
;------------------------------***END ImprimirMemoria***----------------------------------------------


;------------------------------***BEGIN printLog***----------------------------------------------
printLog PROC
		PUSH BP
		MOV BP,SP
	
		;;SALVAR CONTEXTO	
		PUSH AX
		PUSH CX 
		PUSH BX 
		PUSH DX

		MOV CX,SS:[BP+4] ;ERROR
		MOV DX,SS:[BP+6] ;OPERACION

		MOV AX,64
		OUT 22,AX ;IMPRIMIR 64
		MOV AX,DX
		OUT 22,AX ;IMPRIMIR OPERACION
		MOV AX,CX
		OUT 22,AX ;IMPRIMIR ERROR

	END_printLog:
		MOV AX,SS:[BP+2]
		MOV SS:[BP+6],AX
		POP DX
		POP BX
		POP CX
		POP AX
		POP BP
		ADD SP,4
		RET
	printLog ENDP


;------------------------------***END printLog***------------------------------------------------



;------------------------------***BEGIN printLogParam***----------------------------------------------
		
	printLogParam PROC
		PUSH BP
		MOV BP,SP
	
		;;SALVAR CONTEXTO	
		PUSH AX
		PUSH CX 
		PUSH BX 
		PUSH DX

		MOV CX,SS:[BP+4] ;ERROR
		MOV BX,SS:[BP+6] ;PARAMETRO
		MOV DX,SS:[BP+8] ;OPERACION

		MOV AX,64
		OUT 22,AX ;IMPRIMIR 64
		MOV AX,DX
		OUT 22,AX ;IMPRIMIR OPERACION
		MOV AX,BX
		OUT 22,AX ;IMPRIMIR PARAMETRO
		MOV AX,CX
		OUT 22,AX ;IMPRIMIR ERROR

	END_printLogParam:
		MOV AX,SS:[BP+2]
		MOV SS:[BP+8],AX
		POP DX
		POP BX
		POP CX
		POP AX
		POP BP
		ADD SP,6
		RET
	printLogParam ENDP
			
		

;------------------------------***END printLogParam***------------------------------------------------


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>MAIN PROGRAM<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

mainProg:					

;**** BEGIN INICIALIZACION ****						
	MOV BX,0X1000;SEGMENTO DS
	MOV DS,BX
	MOV AX,0
	MOV [0],AX; SHORT TOPE
	MOV WORD PTR[2], 0;SHORT MODO (DEFAULT 0)
	MOV WORD PTR[4], 0; SHORT SALIR
	CALL inicializarArbol
;**** END INICIALIZACION ****		

;**** BEGIN BUCLE DE PROGRAMA ****
	MOAB_bucle:
	CMP WORD PTR[4], 1 ;SALIR
	JZ END_MOAB
	JMP leerComando
	
	leerComando:
		IN AX, 20 ;LEER COMANDO
		CMP AX,1
		JZ MOAB_cambiarModo
		CMP AX,2
		JZ MOAB_agregarNodo
		CMP AX,3
		JZ MOAB_calcularAltura
		CMP AX,4
		JZ MOAB_calcularSuma
		CMP AX,5
		JZ MOAB_imprimirArbol
		CMP AX,6
		JZ MOAB_imprimirMemoria
		CMP AX, 255
		JZ MOAB_terminarPrograma
		JMP MOAB_comandoNoReconocido


	MOAB_cambiarModo:
		IN AX, 20; LEER NUEVOMODO
		CMP AX,0
		JZ ejCambiarModo
		CMP AX,1
		JZ ejCambiarModo
		MOV BX,1
		MOV CX,2
		JMP MOAB_LOG_PARAM
		ejCambiarModo:
			PUSH AX ;PUSHEO EL NUEVO MODO
			CALL cambiarModo
			MOV BX,1 ;OPERACION
			MOV CX,0 ;ERROR
			JMP MOAB_LOG_PARAM

	MOAB_agregarNodo:
		MOV AX, 0
		PUSH AX
		IN AX,20
		PUSH AX
		CALL agregarNodo
		JMP MOAB_bucle

	MOAB_calcularAltura:
		MOV AX,0
		PUSH AX
		CALL calcularAltura
		POP AX
		OUT 21,AX
		MOV BX,3
		MOV CX,0
		JMP MOAB_LOG

	MOAB_calcularSuma:
		MOV AX,0
		PUSH AX
		CALL calcularSuma
		POP AX
		OUT 21,AX
		MOV BX,4
		MOV CX,0
		JMP MOAB_LOG

	MOAB_imprimirArbol:
		IN AX,20 ;ORDEN
		CMP AX,0
		JZ ejImprimirArbol
		CMP AX,1
		JZ ejImprimirArbol
		MOV BX,5 ;OPERACION
		MOV CX,2 ;ERROR PARAMETRO INVALIDO
		JMP MOAB_LOG_PARAM

	ejImprimirArbol:
		MOV BX,AX ;PARAMETRO
		PUSH AX	;ORDEN
		MOV AX, 0 ;INDICE INICIAL
		PUSH AX
		CALL imprimirArbol
		MOV AX,BX
		MOV BX,5
		MOV CX,0
		JMP MOAB_LOG_PARAM

	MOAB_imprimirMemoria:
		IN AX,20 ;N
		MOV BX,0
		CMP BX,AX
		JZ ejImprimirMemoria
		JS ejImprimirMemoria
		MOV BX,6
		MOV CX,2
		JMP MOAB_LOG_PARAM

	ejImprimirMemoria:
		PUSH AX
		CALL imprimirMemoria
		MOV BX,6
		MOV CX,0
		JMP MOAB_LOG_PARAM

	MOAB_terminarPrograma:
		MOV WORD PTR[4], 1; SHORT SALIR
		MOV BX,255
		MOV CX,0
		JMP MOAB_LOG

	MOAB_comandoNoReconocido:
		MOV BX,AX;OPERACION
		MOV CX,1;ERROR
		JMP MOAB_LOG

	MOAB_LOG_PARAM:
		PUSH BX
		PUSH AX
		PUSH CX
		CALL printLogParam
		JMP MOAB_bucle
	
	MOAB_LOG:
		PUSH BX
		PUSH CX
		CALL printLog
	JMP MOAB_bucle

END_MOAB:

;**** END BUCLE DE PROGRAMA ****



.ports 
20: 1,0,3,1,1,3,1,0,2,4,3,1,1,2,5,3,1,0,2,100,2,128,2,60,2,40,2,20,2,22,3,1,1,2,50,2,40,2,30,2,45,2,46,2,47,2,48,3,255

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT
