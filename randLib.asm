
.8086
.model small
.stack 100h
.data
bufferLen			equ 1
arch1		db 'file.txt',0	;un archivo, debe estar en la misma carpeta del ejecutable
buffer		db 1 dup(?)		;buffer de lectura del archivo 1
cola		db '$'
collector	db 255 dup("$"),24h
errmsg		db 10,13,'error apertura archivo file.txt!',10,13,'$'
fileHandler		dw ?			; file fileHandlerr del archivo abierto

fileLength 	dw 0
salto 		db 	0dh,0ah,24h
;Esto es lo que se pushea desde el programa
;readStart	dw 0
linesRead	dw 0
linesToRead	dw 1

.code
public SelectWord
public GetFileLength

SelectWord proc
	;Recibe por stack la linea por la que debe empezar
	;devuelve por dx la palabra
	;ss:[bp+4] => Linea a leer (empieza en 0)
	;dx => Palabra leida
	push bp
	mov bp, sp
	push bx
	push ax
	push cx
	push si
	push di

	mov si,0
	resetCollector_SelectWord:
		lea di, collector

	checkEndOfString_SelectWord:
	mov byte ptr [di], 24h
	inc di
	cmp byte ptr [di], 24h
	jne checkEndOfString_SelectWord


	mov linesRead, 0
	mov linesToRead, 1
	mov ax, ss:[bp+4]
	;add ax, linesToRead
	add linesToRead, ax

	;Abre el archivo
	mov ah,3dh
	lea dx,arch1
	mov al,0
	int 21h
	mov fileHandler,ax 


	readLoop_SelectWord:	
		;Empieza a leer los caracteres y los guarda en buffer
		mov ah,3fh
		mov bx,fileHandler
		lea dx, buffer
		mov cx,bufferLen
		int 21h
		cmp ax,0  
		je return_SelectWord

		;Si no llegue a la linea que debo leer, salteo
		push bx
		mov bx, ss:[bp+4]
		; mov bx, linesToRead
		cmp bx,linesRead
		pop bx
		ja skipLine_SelectWord

	readLine_SelectWord:	
		;Si debo leer esta linea, empiezo a guardarla en el collector
		lea bx, collector
		mov al, buffer
		cmp al, 0Dh
		je hasReadLine_SelectWord
		cmp buffer,0Ah
		je hasReadLine_SelectWord
		mov [bx][si], al
		inc si
		jmp readLoop_SelectWord

	skipLine_SelectWord:	
		;Si no debo leer esta linea, solo la recorro
		lea dx, buffer
		cmp buffer,0Ah
		je hasReadLine_SelectWord
		jmp readLoop_SelectWord

	hasReadLine_SelectWord:	
		inc linesRead
		jmp checkpage_SelectWord
	checkpage_SelectWord:	
		;Verifico silas lineas leidas coinciden con las que tengo que leer
		;Para este caso linesToRead es siempre 1
		push bx
		mov bx, linesRead
		cmp bx,linesToRead
		pop bx

		jne readNextLine_SelectWord
		je return_SelectWord
		int 99h

	readNextLine_SelectWord:
		jmp readLoop_SelectWord
	return_SelectWord:	
		;Si llegué al final del archivo, lo cierro
		mov ah,3eh
		mov dx,fileHandler                                     ;close
		int 21h 
		lea dx, collector
	
	pop di
	pop si
	pop cx
	pop ax
	pop bx
	pop bp
	ret 2
SelectWord endp


GetFileLength proc
	push ax
	push dx
	push bx
	push cx

	mov fileLength,0
	;Abre el archivo 
	mov ah,3dh
	lea dx,arch1
	mov al,0
	int 21h
	mov fileHandler,ax 

	readLoop_GetFileLength:	
		;Empieza a leer los caracteres y los guarda en buffer
		mov ah,3fh
		mov bx,fileHandler
		lea dx, buffer
		mov cx,bufferLen
		int 21h
		cmp ax,0  
		je return_GetFileLength
		
		mov al, buffer
		cmp al, 0ah
		je hasReadLine_GetFileLength
		jmp readLoop_GetFileLength
		
	hasReadLine_GetFileLength:
	inc fileLength
	jmp readLoop_GetFileLength
	
	return_GetFileLength:
	mov si, fileLength
	mov ah,3eh
	mov dx,fileHandler                                     ;close
	int 21h 

	pop cx
	pop bx
	pop dx
	pop ax
	ret 
GetFileLength endp

end
