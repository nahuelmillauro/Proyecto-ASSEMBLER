.8086
.model small
.stack 100h

.data
	numeroReg db 0
	binario_en_reg db 0b
	multiplicador db 100, 10, 1
	divisor db 100, 10, 1
	salto db 0dh, 0ah, 24h
	salidaError db 'Lo ingresado no es un número hexadecimal', 0dh, 0ah, 24h
	tabla db 'A .-    B -...   C -.-.   D -..    E .     F ..-.', 0dh, 0ah, \
			 'G --.   H ....   I ..     J .---   K -.-   L .-..', 0dh, 0ah, \
			 'M --    N -.     O ---    P .--.   Q --.-  R .-.', 0dh, 0ah, \
			 'S ...   T -      U ..-    V ...-   W .--   X -..-', 0dh, 0ah, \
			 'Y -.--  Z --..', 0dh, 0ah, 24h


.code

public numeroReg
public imprimirSalto
public asciiToReg
public regToAscii
public binToAscii
public asciiToBin
public asciiToHexa
public impresion
public carga
public mayusculizador
public contarEspacios
public contarCaracteresSt
public mostrarTabla
public punto
public raya
public delay_corto
public delay_largo
public playCodigo
public copyString

	copyString proc
	;dx = tiene la referencia de la palabra fuente
	;bx = tiene la refefrencia de la palabra de destino
	push ax
	push bx
	push dx
	push si

	mov si, dx 					;Se mueve la referencia a SI para poder usarlo como índide en memoria
	checkLetter:
		mov al, [si]
		cmp al, 24h				;Si encuentra el $ se va de la funcion
		je return_checkLetter
		mov [bx], al
		inc bx
		inc si
		jmp checkLetter
	return_checkLetter:
		pop si
		pop ax
		pop dx
		pop bx
		ret
	copyString endp

	imprimirSalto proc
		mov ah, 9
		lea dx, salto
		int 21h
		ret
	imprimirSalto endp


	impresion proc
		push ax
		push bx

		mov ah, 9
		lea dx, [bx]
		int 21h

		pop bx
		pop ax
		ret
	impresion endp


	carga proc
		push ax
		push bx

		proceso:
			mov ah, 1
			int 21h
			cmp al, 0dh
			je finCarga
			mov [bx], al
			inc bx
			jmp proceso


		finCarga:
			pop bx
			pop ax
			ret
	carga endp


	asciiToReg proc					; La función recibe en bx el offset de numeroAscii para devolverlo como registro
		;push ax
		push si
		push cx
		push bx

		mov ax, 0
		mov numeroReg, 0
		mov si, 0
		mov cx, 3

		proceso0:
			mov al, [bx]
			sub al, 30h
			mov dl, multiplicador[si]
			mul dl
			add numeroReg, al
			inc bx
			inc si
			mov ax, 0
			loop proceso0
		
		mov ah, 0
		mov al, numeroReg

		pop bx
		pop cx
		pop si
		;pop ax		
		ret
	asciiToReg endp


	regToAscii proc					; La función recibe en bx el offset de numeroReg para devolverlo como ASCII
		push ax
		push si
		push cx
		push bx

        mov ah, 0					; Estas dos instrucciones las uso
        ;mov al, numeroReg			; solamente si no tengo el número en ax
		mov si, 0
		mov cx, 3

		proceso2:
			mov dl, divisor[si]
			div dl
			add al, 30h
			mov [bx], al
			mov al, ah
			mov ah, 0
			inc bx
			inc si
			loop proceso2

		pop bx
		pop cx
		pop si
		pop ax		
		ret
	regToAscii endp


	binToAscii proc
		;mov al, binario_en_reg
		push ax
		push bx
		push cx
		mov cx, 8

		;mov binario_en_reg, al

		proceso1:
			shl al, 1				; Desplazo un bit a la izquierda
			jc esUno				; Si hay carry, el bit era 1 (si no, era 0)
			mov byte ptr [bx], '0'
			inc bx
			jmp siguiente

		esUno:
			mov byte ptr [bx], '1'
			inc bx

		siguiente:
			loop proceso1

		pop cx
		pop bx
		pop ax
		ret
	binToAscii endp


	asciiToBin proc
		push bx
		push cx
		mov si, 0
		mov cx, 8

		proceso4:
			shl si, 1
			cmp byte ptr [bx], '1'
			jne siguiente0
			inc si

		siguiente0:
			inc bx
			loop proceso4

		mov ax, si
		mov ah, 0
		;mov binario_en_reg, al
		pop cx
		pop bx
		ret
	asciiToBin endp


	asciiToHexa proc
		push bx
		push dx

		mov numeroReg, 0
		mov ax, 0

		primerDigito:
			mov al, [bx]

			cmp al, '0'
			jb mostrarError          ; Si es menor que '0', error
			cmp al, '9'
			jbe esNumero

			cmp al, 'a'
			jb mostrarError          ; Si es menor que 'a', error
			cmp al, 'f'
			ja mostrarError          ; Si es mayor que 'f', error

			; Procesar letras a-f
			sub al, 'a'
			add al, 10               ; Convertir letras a-f a 10-15
			jmp calcularPrimerDigito

			esNumero:
				sub al, '0'              ; Convertir caracteres '0'-'9' a 0-9

			calcularPrimerDigito:
				mov dl, 16
				mul dl                   ; Multiplicar primer dígito por 16
				add numeroReg, al

		; Procesar segundo dígito
		segundoDigito:
			inc bx
			mov al, [bx]

			cmp al, '0'
			jb mostrarError
			cmp al, '9'
			jbe esNumero2

			cmp al, 'a'
			jb mostrarError
			cmp al, 'f'
			ja mostrarError

			; Procesar letras a-f
			sub al, 'a'
			add al, 10               ; Convertir letras a-f a 10-15
			jmp calcularSegundoDigito

		esNumero2:
			sub al, '0'              ; Convertir caracteres '0'-'9' a 0-9

		calcularSegundoDigito:
			add numeroReg, al        ; Sumar segundo dígito sin multiplicar


		finHexa:
			mov ah, 0
			mov al, numeroReg        ; Mover el resultado final a AX
			pop dx
			pop bx
			ret

		mostrarError:
			mov ah, 9
			lea dx, salidaError
			int 21h
			jmp finHexa

	asciiToHexa endp


	contarEspacios proc
		push bx
		mov ax, 0

		proceso3:
			cmp byte ptr [bx], 24h
			je finContarEspacios
			cmp byte ptr [bx], 20h
			je contarEspacio
			inc bx
			jmp proceso3

		contarEspacio:
			inc ax
			inc bx
			jmp proceso3

		finContarEspacios:
			pop bx
			ret
	contarEspacios endp


    mayusculizador proc

        proceso5:

            cmp byte ptr [bx], 0dh
            je finConversion

            primeraCondicion:                       ; Etiqueta para evaluar la primera condición (mayor o igual que 'a')
                mov dl, [bx]
                cmp dl, 61h                         ; Comparo el carácter con 'a'
                jae segundaCondicion
                inc bx
                jmp proceso5

            segundaCondicion:                       ; Etiqueta para evaluar la segunda condición (menor o igual que 'z')
                mov dl, [bx]
                cmp dl, 7ah                         ; Comparo el carácter con 'z'
                jbe cambiarLetra
                inc bx
                jmp proceso5

            cambiarLetra:
                sub dl, 20h                         ; Si es letra minúscula, la paso a mayúscula
                mov [bx], dl                        ; Muevo la letra mayúscula a donde apunta BX
                inc bx
                jmp proceso5

        finConversion:
            ret
    mayusculizador endp


    contarCaracteresSt proc
		push bp
		mov bp, sp
		push bx

        mov bx, [ss:bp+4]
        mov ax, 0

        procesoContar:
            cmp byte ptr [bx], 24h
            je finProcesoContar
            inc ax
            inc bx
            jmp procesoContar

        finProcesoContar:
            pop bx
            pop bp
            ret 2
    contarCaracteresSt endp

	mostrarTabla proc
	push bx
		call imprimirSalto
		lea bx, tabla
		call impresion
	pop bx
		ret
	mostrarTabla endp


    punto proc

        ; Configurar el PIT para tono
        mov al, 00110100b  ; 34h - select channel 2, binary mode
        out 43h, al        ; Enviar el comando al PIT

        ; Establecer la frecuencia (ejemplo: 440 Hz)
        mov ax, 6000      ; Calcular el valor (1193180 / frecuencia)
        out 42h, al        ; Enviar parte baja
        mov al, ah         ; Enviar parte alta
        out 42h, al

        ; Habilitar el altavoz
        mov al, 03h        ; Activar el altavoz
        out 61h, al

        ; Esperar un segundo (puedes ajustar el tiempo) = 0FFFh
        mov cx, 0333h
    delay:
        mov dx, 0333h
    delay_loop:
        nop
        dec dx
        jnz delay_loop
        dec cx
        jnz delay

        ; Apagar el altavoz
        mov al, 00h        ; Desactivar el altavoz
        out 61h, al

        ret
    punto endp


    raya proc

        ; Configurar el PIT para tono
        mov al, 00110100b  ; 34h - select channel 2, binary mode
        out 43h, al        ; Enviar el comando al PIT

        ; Establecer la frecuencia (ejemplo: 440 Hz)
        mov ax, 6000      ; Calcular el valor (1193180 / frecuencia)
        out 42h, al        ; Enviar parte baja
        mov al, ah         ; Enviar parte alta
        out 42h, al

        ; Habilitar el altavoz
        mov al, 03h        ; Activar el altavoz
        out 61h, al

        ; Esperar un segundo (puedes ajustar el tiempo) = 0FFFh
        mov cx, 0999h
    delay2:
        mov dx, 0999h
    delay_loop2:
        nop
        dec dx
        jnz delay_loop2
        dec cx
        jnz delay2

        ; Apagar el altavoz
        mov al, 00h        ; Desactivar el altavoz
        out 61h, al

        ret
    raya endp


    delay_corto proc
        ; Un delay corto entre punto y raya
        mov cx, 0333h      ; Puedes ajustar este valor para un delay adecuado
    delay_corto_loop:
        mov dx, 0FFFh
    delay_corto_inner:
        nop
        dec dx
        jnz delay_corto_inner
        dec cx
        jnz delay_corto_loop

        ret
    delay_corto endp


    delay_largo proc
        ; Un delay largo entre letras
        mov cx, 0999h      ; Puedes ajustar este valor para un delay adecuado
    delay_largo_loop:
        mov dx, 0FFFh
    delay_largo_inner:
        nop
        dec dx
        jnz delay_largo_inner
        dec cx
        jnz delay_largo_loop

        ret
    delay_largo endp


    playCodigo proc

        recorrerCodigo:
            cmp byte ptr [bx], '.'
            je playPunto
            cmp byte ptr [bx], '-'
            je playRaya
            cmp byte ptr [bx], ' '
            je playDelayLargo
			cmp byte ptr [bx], '*'
			je silencio								; Esto lo ponemos porque, si no, reproduce un punto cuando hay asterisco
            cmp byte ptr [bx], 24h
            je fin

        playPunto:
            call punto
            call delay_corto
            inc bx
            jmp recorrerCodigo

        playRaya:
            call raya
            call delay_corto
            inc bx
            jmp recorrerCodigo

		silencio:
			inc bx
			jmp recorrerCodigo

        playDelayLargo:
            call delay_largo
            inc bx
            jmp recorrerCodigo

		fin:
        	ret
    playCodigo endp

end