.8086
.model small
.stack 100h

.data
	tabla db 'A .-    B -...   C -.-.   D -..    E .     F ..-.', 0dh, 0ah, \
			 'G --.   H ....   I ..     J .---   K -.-   L .-..', 0dh, 0ah, \
			 'M --    N -.     O ---    P .--.   Q --.-  R .-.', 0dh, 0ah, \
			 'S ...   T -      U ..-    V ...-   W .--   X -..-', 0dh, 0ah, \
			 'Y -.--  Z --..', 0dh, 0ah, 24h
	cartelJugador db 'Ingrese el codigo morse correspondiente de la palabra '
	palabra db 255 dup (24h), 0dh, 0ah, 24h
	lineaALeer dw 0
	numeroRandom dw 0
	largoArchivo dw ?
	cartelJugadorInverso db 'Ingrese la palabra correspondiente al codigo:', 0dh, 0ah, 24h
	codigo db 255 dup(24h), 0dh, 0ah, 24h; palabra en morse codificada por la función que traduce
	codigoImprimible db 255 dup(24h), 0dh, 0ah, 24h
	cartelSonido db 'Ingrese el sonido reproducido', 0dh, 0ah, 24h
	cartelSonido2 db 'Ingrese la palabra correspondiente al sonido reproducido', 0dh, 0ah, 24h
	cartelModalidad db 	'Seleccione modalidad:', 0dh, 0ah, \
				   	    '1. Codificar palabra (con tabla de referencia)', 0dh, 0ah, \
				        '2. Codificar palabra (sin tabla de referencia)', 0dh, 0ah, \
				   		'3. Decodificar codigo morse escrito (con tabla de referencia)', 0dh, 0ah, \
				   		'4. Decodificar codigo morse escrito (sin tabla de referencia)', 0dh, 0ah, \
				   		'5. Escribir codigo morse a partir de sonidos', 0dh, 0ah, \
				   		'6. Decodificar codigo morse en sonido (con tabla de referencia)', 0dh, 0ah, \
				   		'7. Decodificar codigo morse en sonido (sin tabla de referencia)', 0dh, 0ah, \
						'0. Salir', 0dh, 0ah, 24h
	cartel6 db 'SE REPRODUCE SONIDO Y EL USUARIO DEBE ESCRIBIR LA PALABRA (MOSTRANDO TABLA)', 0dh, 0ah, 24h
	cartel7 db 'SE REPRODUCE SONIDO Y EL USUARIO DEBE ESCRIBIR LA PALABRA (SIN TABLA)', 0dh, 0ah, 24h
	cartelNoValido db 'Opción no válida', 0dh, 0ah, 24h
	cartelError db 'Intente de nuevo', 0dh, 0ah, 24h
	cartelExito db 'Felicitaciones', 0dh, 0ah, 24h
	palabraUsuario db 255 dup(24h), 0dh, 0ah, 24h; la entrada del usuario
	alfabeto db 'abcdefghijklmnopqrstuvwxyz', 0dh, 0ah, 24h
	morse db '.-**', '-...', '-.-.', '-..*', '.***', '..-.', '--.*', '....', '..**', '.---', '-.-*', '.-..', '--**', '-.**', '---*', '.--.', '--.-', '.-.*', '...*', '-***', '..-*', '...-', '.--*', '-..-', '-.--', '--..', 0dh, 0ah, 24h
	caracter db ' ', 0dh, 0ah, 24h
	longitud db 0
	longitudUsuario db 0
	longitudAscii db '000', 0dh, 0ah, 24h

.code

extrn imprimirSalto:proc
extrn impresion:proc
extrn carga:proc
extrn mayusculizador:proc
extrn regToAscii:proc
extrn mostrarTabla:proc
extrn punto:proc
extrn raya:proc
extrn delay_corto:proc
extrn delay_largo:proc
extrn playCodigo:proc
extrn copyString:proc
extrn SelectWord:proc
extrn GetFileLength:proc

main proc
	mov ax, @data
	mov ds, ax

	call GetFileLength
	mov largoArchivo, si
	call menu
		
	fin:
		mov ax, 4c00h
		int 21h
main endp


menu proc
	elegirModalidad:
		call imprimirSalto
		lea bx, codigo
		call limpiarPalabra
		lea bx, palabra
		call limpiarPalabra
		lea bx, palabraUsuario
		call limpiarPalabra

		lea bx, cartelModalidad
		call impresion

		mov ah, 1
		int 21h
		int 99h
		cmp al, '1'
		je modalidad1
		cmp al, '2'
		je modalidad2
		cmp al, '3'
		je modalidad3
		cmp al, '4'
		je modalidad4
		cmp al, '5'
		je modalidad5
		cmp al, '6'
		je modalidad6
		cmp al, '7'
		je modalidad7
		cmp al, '0'
		je fin

		lea bx, cartelNoValido
		call impresion
		jmp elegirModalidad

		modalidad1:
			call imprimirSalto
			call mostrarTabla
			call cargaUsuario
			jmp elegirModalidad
		
		modalidad2:
			call imprimirSalto
			call cargaUsuario
			jmp elegirModalidad

		modalidad3:
			call imprimirSalto
			call mostrarTabla
			call cargaUsuarioInversa
			lea bx, codigoImprimible				; Limpiamos "codigoImprimible" para que se llene bien cuando volvamos a llamar a esta modalidad
			call limpiarPalabra
			jmp elegirModalidad

		modalidad4:
			call imprimirSalto
			call cargaUsuarioInversa
			lea bx, codigoImprimible
			call limpiarPalabra		
			jmp elegirModalidad

		modalidad5:
			call imprimirSalto
			call traduccion
			lea bx, cartelSonido
			call impresion
			lea bx, codigo
			call playCodigo
			;call cargaUsuario
			call compararSonido
			jmp elegirModalidad

		modalidad6:
			call imprimirSalto
			call mostrarTabla
			call cargaUsuarioSonido
			jmp elegirModalidad

		modalidad7:
			call imprimirSalto
			call cargaUsuarioSonido
			jmp elegirModalidad

	ret
menu endp


cargaUsuario proc

    lea bx, cartelJugador
    call impresion

    call traduccion
	lea bx, palabra
	call impresion 
    call imprimirSalto
    lea bx, codigo
    push bx
    call contarCaracteresSt		    		; Se cuentan los caracteres de "codigo" para después hacer la comparación
    mov ah, 0
    mov longitud, al

    lea bx, longitudAscii					; Esto es para ver si se están contando bien los caracteres
    call regToAscii
    lea bx, longitudAscii
    call impresion

    mov ax, 0
    mov si, 0

    cargaMorse:
        mov ah, 1
        int 21h
        cmp al, 0dh
        je preComparacion
        cmp al, 20h
        je tokenizarMorse

        analizarPunto:
            cmp al, '.'
            je meterPunto

        analizarRaya:
            cmp al, '-'
            je meterRaya

		jmp cargaMorse

        meterPunto:
            mov palabraUsuario[si], al
			call punto
            inc si
            jmp cargaMorse

		meterRaya:
            mov palabraUsuario[si], al
			call raya
            inc si
            jmp cargaMorse

        tokenizarMorse:
            mov dl, 4                       ; Muevo 4 a dl
            mov ax, si                      ; Muevo si a ax
            div dl                          ; Divido si por 4 para quedarme con el resto (resto = cantidad de rayas y puntos del símbolo morse)
            cmp ah, 0
            je cargaMorse
            sub dl, ah                      ; Eso se lo resto a 4 para tener la cantidad de espacios (queda guardada en dl)
            mov ch, 0
            mov cl, dl                      ; Guardo en cx la cantidad de espacios
            completarAsteriscos:
                mov palabraUsuario[si], '*'
                inc si
                loop completarAsteriscos
            jmp cargaMorse

    preComparacion:
        mov ax, si
        mov ah, 0
        mov longitudUsuario, al              ; Almacenamos cantidad de caracteres de lo que ingresó el usuario

        mov si, 0
        mov ch, 0
        mov cl, longitud                     ; Almacenamos la cantidad de caracteres de "codigo" en CX para hacer el loop
            
    comparacion:
        mov dl, palabraUsuario[si]
        cmp dl, codigo[si]
        jne salidaNo
        inc si
        loop comparacion

    mov ah, 0                               ; Esto se hace para ver si el usuario se pasó de caracteres
    mov al, longitudUsuario                 ; Si la longitud es distinta al contador SI, es porque metió caracteres de más
    cmp si, ax
    jne salidaNo

    salidaSi:
        lea bx, cartelExito
        call impresion
        jmp finCargaUsuario

    salidaNo:
        lea bx, cartelError
        call impresion

    finCargaUsuario:
		lea bx, palabraUsuario
		call impresion
	ret

cargaUsuario endp


imprimirCodigo proc
	lea bx, codigo
	lea si, codigoImprimible
	mov cx, 0

	procesoParaImprimir:
		cmp byte ptr [bx], 24h
		je finImprimirCodigo

		cmp byte ptr [bx], '*'
		je ignorarSimbolo

		cmp cx, 4
		je meterEspacio

		mov al, byte ptr [bx]		; Si no es asterisco, muevo lo que está a codigoImprimible (punto o raya)
		mov byte ptr [si], al

		inc si
		inc cx
		jmp avanzar

		ignorarSimbolo:
			inc cx
			jmp avanzar

	meterEspacio:					; Después de cuatro caracteres, hay un espacio
		mov byte ptr [si], 20h
		inc si
		mov cx, 0
		jmp procesoParaImprimir

	avanzar:
		inc bx
		jmp procesoParaImprimir

	finImprimirCodigo:
		mov byte ptr [si], 0
		lea bx, codigoImprimible
		call impresion
		ret
imprimirCodigo endp


cargaUsuarioInversa proc
    call traduccion

    lea bx, cartelJugadorInverso
    call impresion

	call imprimirCodigo

    call imprimirSalto

    lea bx, palabra
    push bx
    call contarCaracteresSt		    		; Se cuentan los caracteres de "codigo" para después hacer la comparación
    mov ah, 0
;    sub al, 2						; Le resto 2 caracteres (0dh y 0ah)
    mov longitud, al

    lea bx, longitudAscii					; Esto es para ver si se están contando bien los caracteres
    call regToAscii
    lea bx, longitudAscii
    call impresion

    mov ax, 0
    mov si, 0
    lea bx, palabraUsuario

    cargaAlfabeto:
        mov ah, 1
        int 21h
        cmp al, 0dh
        je preComparacionInversa
		mov [bx], al
		inc bx
		inc si
		jmp cargaAlfabeto

    preComparacionInversa:
        mov ax, si
        mov ah, 0
        mov longitudUsuario, al              ; Almacenamos cantidad de caracteres de lo que ingresó el usuario

        mov si, 0
        mov ch, 0
        mov cl, longitud                     ; Almacenamos la cantidad de caracteres de "codigo" en CX para hacer el loop
            
    comparacionInversa:
        mov dl, palabraUsuario[si]
        cmp dl, palabra[si]
        jne salidaInversaNo
        inc si
        loop comparacionInversa

    mov ah, 0                               ; Esto se hace para ver si el usuario se pasó de caracteres
    mov al, longitudUsuario                 ; Si la longitud es distinta al contador SI, es porque metió caracteres de más
    cmp si, ax
    jne salidaInversaNo

    salidaInversaSi:
        lea bx, cartelExito
        call impresion
        jmp finCargaUsuario

    salidaInversaNo:
        lea bx, cartelError
        call impresion

    finCargaUsuarioInversa:
		lea bx, palabraUsuario
		call impresion
	ret

cargaUsuarioInversa endp


compararSonido proc							; Es igual a cargaUsuario, pero sin las primeras líneas (porque no hay que mostrar la palabra)
    lea bx, codigo
    push bx
    call contarCaracteresSt		    		; Se cuentan los caracteres de "codigo" para después hacer la comparación
    mov ah, 0
    mov longitud, al

    lea bx, longitudAscii					; Esto es para ver si se están contando bien los caracteres
    call regToAscii
    lea bx, longitudAscii
    call impresion

    mov ax, 0
    mov si, 0

    cargaMorse2:
        mov ah, 1
        int 21h
        cmp al, 0dh
        je preComparacion2
        cmp al, 20h
        je tokenizarMorse2

        analizarPunto2:
            cmp al, '.'
            je meterPunto2

        analizarRaya2:
            cmp al, '-'
            je meterRaya2

		jmp cargaMorse2

        meterPunto2:
            mov palabraUsuario[si], al
			call punto
            inc si
            jmp cargaMorse2

		meterRaya2:
            mov palabraUsuario[si], al
			call raya
            inc si
            jmp cargaMorse2

        tokenizarMorse2:
            mov dl, 4                       ; Muevo 4 a dl
            mov ax, si                      ; Muevo si a ax
            div dl                          ; Divido si por 4 para quedarme con el resto (resto = cantidad de rayas y puntos del símbolo morse)
            cmp ah, 0
            je cargaMorse2
            sub dl, ah                      ; Eso se lo resto a 4 para tener la cantidad de espacios (queda guardada en dl)
            mov ch, 0
            mov cl, dl                      ; Guardo en cx la cantidad de espacios
            completarAsteriscos2:
                mov palabraUsuario[si], '*'
                inc si
                loop completarAsteriscos2
            jmp cargaMorse2

    preComparacion2:
        mov ax, si
        mov ah, 0
        mov longitudUsuario, al              ; Almacenamos cantidad de caracteres de lo que ingresó el usuario

        mov si, 0
        mov ch, 0
        mov cl, longitud                     ; Almacenamos la cantidad de caracteres de "codigo" en CX para hacer el loop
            
    comparacion2:
        mov dl, palabraUsuario[si]
        cmp dl, codigo[si]
        jne salidaNo2
        inc si
        loop comparacion2

    mov ah, 0                               ; Esto se hace para ver si el usuario se pasó de caracteres
    mov al, longitudUsuario                 ; Si la longitud es distinta al contador SI, es porque metió caracteres de más
    cmp si, ax
    jne salidaNo2

    salidaSi2:
        lea bx, cartelExito
        call impresion
	; mov bx, numeroRandom
	; mov lineaALeer, bx			    ; Para cambiar de palabra aleatoria
        jmp finCargaUsuario2

    salidaNo2:
        lea bx, cartelError
        call impresion

    finCargaUsuario2:
		lea bx, palabraUsuario
		call impresion
		ret
compararSonido endp


cargaUsuarioSonido proc							; Es igual a cargaUsuarioInversa, pero sin imprimir "codigo" sino reproduciéndolo
	call traduccion

    lea bx, codigo
    call playCodigo

    lea bx, cartelSonido2
    call impresion

    call imprimirSalto

    lea bx, palabra
    push bx
    call contarCaracteresSt		    		; Se cuentan los caracteres de "codigo" para después hacer la comparación
    mov ah, 0
    ;sub al, 2						; Le resto 2 caracteres (0dh y 0ah)
    mov longitud, al

    lea bx, longitudAscii					; Esto es para ver si se están contando bien los caracteres
    call regToAscii
    lea bx, longitudAscii
    call impresion

    mov ax, 0
    mov si, 0
    lea bx, palabraUsuario

    cargaAlfabeto2:
        mov ah, 1
        int 21h
        cmp al, 0dh
        je preComparacionSonido
		mov [bx], al
		inc bx
		inc si
		jmp cargaAlfabeto2

    preComparacionSonido:
        mov ax, si
        mov ah, 0
        mov longitudUsuario, al              ; Almacenamos cantidad de caracteres de lo que ingresó el usuario

        mov si, 0
        mov ch, 0
        mov cl, longitud                     ; Almacenamos la cantidad de caracteres de "codigo" en CX para hacer el loop
            
    comparacionSonido:
        mov dl, palabraUsuario[si]
        cmp dl, palabra[si]
        jne salidaSonidoNo
        inc si
        loop comparacionSonido

    mov ah, 0                               ; Esto se hace para ver si el usuario se pasó de caracteres
    mov al, longitudUsuario                 ; Si la longitud es distinta al contador SI, es porque metió caracteres de más
    cmp si, ax
    jne salidaSonidoNo

    salidaSonidoSi:
        lea bx, cartelExito
        call impresion
        jmp finCargaUsuarioSonido

    salidaSonidoNo:
        lea bx, cartelError
        call impresion

    finCargaUsuarioSonido:
		lea bx, palabraUsuario
		call impresion
	ret

cargaUsuarioSonido endp


traduccion proc
	mov bx, numeroRandom
	mov si, largoArchivo
    call obtenerLineaRandom
    mov ax, lineaALeer
    push ax
	;;;
    call SelectWord								;deja en dx la palabra leida

    lea bx, palabra
	call copyString								;Toma la palabra de dx y caracter a caracter la pasa a bx
	mov dx, 0
    lea di, codigo								; di: índice para recorrer "codigo" (palabra codificada)    
    lea bx, palabra								; por algun motivo tengo que volver a asignar palabra o no anda la correccion

	recorrerPalabra:
		mov dl, [bx]							; Muevo a dl el carácter al que apunta bx
		cmp dl, 24h
		je imprimir
		mov si, 0								; si: índice para recorrer alfabeto
		mov ax, 0

		recorrerAlfabeto:
			cmp si, 26
			je siguienteCaracter
			cmp dl, alfabeto[si]
			je codificar
			inc si
			jmp recorrerAlfabeto

		codificar:								; El registro si tiene guardado el índice del alfabeto (ej.: 'a' = 0, 'z' = 25)
			escribirSimbolo:
				mov caracter, dl				; Movemos a "caracter" lo que está en dl (el carácter a codificar)
				mov dl, 4 						; Movemos 4 a dl para multiplicar el índice de si
				mov ax, si  					; Movemos a ax el índice de si (porque dl multiplica por ax)
				mul dl							; Multiplicamos si por 4
				mov si, ax						; Muevo a si lo que está en ax (el índice multiplicado por 4)
				add al, 4   					; Sumo 4 al índice para ponerlo como condición de salida

				bucleMorse:
					cmp si, ax					; Si si = ax, significa que se terminó de codificar la letra
					je siguienteCaracter
					mov dh, morse[si]			; Muevo a dh un carácter de un símbolo morse
					mov [di], dh				; Guardo el codigo morse correspondiente a ese índice en la variable "codigo"
					inc di
					inc si
					jmp bucleMorse

		siguienteCaracter:
			inc bx
			jmp recorrerPalabra


    imprimir:
	;mov ah, 9
	;lea dx, codigo
	;int 21h

    ret
traduccion endp

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


limpiarPalabra proc
	push ax
	push dx
	call imprimirSalto
	mov ah,9
	mov dx, bx
	int 21h
	call imprimirSalto
	resetear:
		cmp byte ptr [bx], 24h
		je finLP
		
	reemplazar:
		mov byte ptr [bx], 24h
		inc bx
		jmp resetear
	finLP:
	pop ax
	pop dx
	ret	
limpiarPalabra endp


obtenerLineaRandom proc
	push ax
	push si
	push dx
	push cx

    ; call GetFileLength

	mov ah, 2Ch
	int 21h

	;Vamos modificando numero random
	add bh, dh
	sub bl, dl
	mov bh, bl
	mov bh,0
	mov numeroRandom, bx

	;Obtenemos el numero final
	xor ax, ax	
	mov al, bl
	xor dx, dx
	mov dx, si
	div dl
	mov al,ah
	mov ah,0

	;Linea a leer será el numero
	mov lineaALeer, ax

	pop cx
	pop dx
	pop si
	pop ax
	ret
obtenerLineaRandom endp



end