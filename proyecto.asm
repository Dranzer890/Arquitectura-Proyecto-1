;proyecto 1 de arquitectura de computadoras
;2017121733 Julio Andrés Casco Murillo

%include "linux64.inc"

section .data
;se selecciona los archivos a leer con los datos de los alumnos y las notas de aprobación
	archivo_config db "configuracion.txt",0	;nombre del archivo con la configuración
	archivo_ar db "archivo.txt",0	;nombre del archivo con los datos


	x  db "x "
	espaciox2 db "  "
	espacioyenter db " ",10
	finaldefila db "|"
	espaciox4 db "    "
	cien db"100 "
	verde db 0x1b, "[32m"
	rojo db 0x1b,"[31m"
	blanco db 0x1b,"[37m"
	amarillo db 0x1b,"[33m"
	

section .bss
; se reservan espacios de memoria para las variables

	text_config resb 150 ;espacio para configuracion.txt
	text_ar resb 1000 ;espacio para archivo.txt
	config_alma resb 150 ; espacio de almacenamiento de configuracion.txt
	ar_alma resb 1000 ;espacio para almacenar archivo.txt

	byteactual resw 1 ;contador para indicar la posición que se lee
	finalf1 resw 1 ;indica donde esta el final de la fila
	iniciof1 resw 1	;indica la posición donde inicia la fila 1
	iniciof2 resw 1	;indica la posición  donde inicia la fila 2
	finalf2 resw 1	;indica la posición  donde finaliza la fila 2


	bytefinaltext resw 1	;almacena la posicion donde finaliza el documento con los datos
	contadorletras resw 1
	copiadorfilas resw 1

	tamanof1 resw 1		;almacena  el tamaño de la fila 1
	tamanof2 resw 1		;almacena el tamaño de la fila 2

	bubble resw 1
	contadorfilas resw 1


	arreglo_notas resb 100		;almacena las notas en el eje x
	arreglo_estudiantes resb 100	;alcena la cantidad de estudiantes por grupo de notas


	nota resb 1
	num1 resb 2
	num2 resb 2

	todaslasnotas resb 100


;variables del archivo configuracion
	aprov resb 3 ; almacena la nota de aprobacion
	reprov resb 2 ; almacena la nota de  reposicion
	tam_gnota resb 2 ; almacena  el tamaño de los grupos de notas
	escala_g resb 2 ; almacena la escala del grafico
	tipo_orde resb 1; almacena el tipo de ordenamiento
	
;variables para la comparación

	letra1 resb 1
	letra2 resb 1
	copiafila1 resb 40 ;almacena fila 1
	copiafila2 resb 40 ;almacena fila 2

;variables histograma
	cantidady resw 1
	cantidadx resw 1
	edgb resb 1
	residuoy resb 1
	residuox resb 1
	tdgnb resb 1
	arrayaxisy resb 100

 section .text
	global _start
	_start:
	

	;configuracion.txt
	mov rax, SYS_OPEN
	mov rdi, archivo_config
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_config
	mov rdx, config_alma
	syscall
	mov rax, SYS_CLOSE
	pop rdi
	syscall

	print text_config


	;extraccion del texto
	mov ax, [text_config+21]; almacena en ax
	mov word [aprov],ax ;almacena en aprov los datos de ax
	mov ax, [text_config+45]
	mov word [reprov], ax
	mov ax, [text_config+105]
	mov word [escala_g],ax
	mov al, [text_config+122]
	mov byte [tipo_orde], al

	;archivo.txt
	mov rax, SYS_OPEN
	mov rdi, archivo_ar
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_ar
	mov rdx, ar_alma
	syscall
	mov rax, SYS_CLOSE
	pop rdi
	syscall
	print text_ar


	mov word [bubble],0d	;se limpia el contador
	clear:
	mov word [byteactual],0d
	mov word [iniciof1],0d
	mov word [finalf1],0d
	mov word [iniciof2],0d
	mov word [finalf2],0d

	mov word [bytefinaltext],900d
	mov word [contadorletras],0d
	mov word [copiadorfilas],0d
	mov word [tamanof1],0d
	mov word [tamanof2],0d
	mov word [contadorfilas],1d

bublesort:

        mov word bx,[byteactual]; carga la letra actual para iniciar la fila 1
	mov byte al, [text_ar +rbx ]

	mov word r10w,[copiadorfilas]
	mov byte [copiafila1+r10],al
	add word r10w,1d
	mov word [copiadorfilas],r10w
        mov word cx,[byteactual]
	mov word  [finalf1], cx

	mov word [byteactual],cx
	add word cx, 1d
	mov word [byteactual],cx


	cmp byte al,10d ; compara letra actual
	jne bublesort
	mov word r9w,[copiadorfilas]
	mov word [tamanof1],r9w
	mov word [copiadorfilas],0d


	mov word [iniciof2],cx
	mov word r11w,[contadorfilas]
	add word r11w, 1d
	mov word [contadorfilas],r11w

Efila2:
	mov word ax,[byteactual]
	mov byte bl,[text_ar+rax]
	mov word r8w,[copiadorfilas]
	mov byte [copiafila2+r8],bl

	add word r8w,1d
	mov word [copiadorfilas],r8w

	mov word [finalf2],ax
	add word ax,1d
	mov word [byteactual],ax

        mov byte r13b,[text_ar+rax]
        cmp byte r13b,0d
        jne igualenter
        mov word  [bytefinaltext],ax
	mov word [bytefinaltext],ax

igualenter:
	cmp byte bl,10d
        jne Efila2

antesdeordenamiento:
	mov word r8w,[copiadorfilas]
	mov word [tamanof2],r8w
	mov word [copiadorfilas],0d

ordenamiento:
	;alfabetico
	mov byte al, [tipo_orde]
	cmp byte al, 65d
	je alfabetico
	mov byte al, [tipo_orde]
	cmp byte al, 97d
	je alfabetico
	
	;por nota
	mov word ax, [finalf1]
	mov word bx, [finalf2]
	sub word ax, 1d
	sub word bx, 1d
	mov byte c1, [text_ar + rax]
	mov byte d1, [text_ar + rbx]
	mov byte [num1+1], c1
	mov byte [num2+1], d1

	mov byte al, [num1]
	mov byte bl, [num2]
	cmp byte a1,b1
	jg letra1menor
	jb letra1mayor
	mov byte al, [num1+1]
	mov byte bl, [num2+1]
	cmp byte al,bl
	jg letra1menor
	jb letra1mayor



alfabetico:
	mov word ax, [iniciof1]
	add word ax, [contadorletras]
	mov byte cl,[text_ar+rax]
	mov byte [letra1],cl

        mov word ax,[iniciof2]
        add word ax,[contadorletras]
        mov byte cl,[text_ar+rax]
        mov byte [letra2],cl


	mov word dx,[contadorletras]
	add word dx,1d
	mov word [contadorletras],dx

	mov byte al,[letra1]
	mov byte bl,[letra2]
	cmp byte al,bl
	je alfabetico


	;limpiar 
	mov byte [contadorletras],0d
	mov byte [copiadorfilas],0d


	jg  letra1mayor


letra1menor:
	; iniciof1=iniciof2
	mov word r12w,[iniciof2]
	mov word [iniciof1],r12w

	;byteactual=iniciof2
	mov word [byteactual],r12w
	jmp finaldelremplazo

letra1mayor:
	mov word bx,[copiadorfilas]
	mov byte al,[copiafila2+rbx]

	add word bx,[iniciof1]
	mov byte [text_ar+rbx],al

	mov word dx,[copiadorfilas]
	add word dx,1d
	mov word [copiadorfilas],dx

	mov word ax,[tamanof2]
	cmp word dx,ax
	jb letra1mayor

	mov word ax,[copiadorfilas]
	add ax,[iniciof1]
	mov word [byteactual],ax

        mov word [copiadorfilas],0d


copyf1: 
	mov word bx,[copiadorfilas]
	mov byte al,[copiafila1+rbx]

	add word bx,[byteactual]
	mov byte [text_ar+rbx],al

	mov word bx,[copiadorfilas]
	add word bx,1d
	mov word [copiadorfilas],bx

	mov word ax,[tamanof1]
	cmp word bx,ax
	jb copyf1

	mov word [copiadorfilas],0d

	mov word ax,[byteactual]
	mov word [iniciof1],ax


finaldelremplazo:
	mov word ax,[finalf2]
	mov word bx, [bytefinaltext]
	cmp word ax,bx

	jb bublesort

	mov word ax,[bubbles]
	add word ax,1d
	mov word [bubbless],ax
	mov word bx,[contadorfilas]
	mov word [contadorfilas],0d
	cmp word ax,bx
	jb limpiarvariables

;Histograma

	mov byte ah, [escala_g]
	mov byte al,[escala_g+1]
	mov byte [num1],ah
	mov byte [num2],al
	call _wascii2dec
	mov byte [escala_g],al

	mov word [canty],1d
	mov byte [arrayaxisy],0d
	xor rcx,rcx
calculoejey:
	mov word ax,[canty]
	add byte cl,[escala]
	mov byte [arrayaxisy+rax],cl
	add word ax,1d
	mov word [canty],ax
	;se compara que el dato sea menor que 100
	cmp byte cl,100d
	jb calculoejey

;tamaño del grupo de notas
	mov byte ah,[text_config+80]
	mov byte al,[text_config+81]
        mov byte [tdgn], ah
	mov byte [tdgn+1],al
	mov byte [num1],ah
	mov byte [num2],al
	call _wascii2dec
	mov byte [tdgnb],al
	
	xor rax,rax
	xor rbx,rbx

        mov byte al, 100d
        mov byte bl,[tdgnb]
        div byte bl
        mov byte [cantidadx],al

;Calcular residuox
        mov byte [residuox],ah
	mov byte bl,[residuox]
	cmp bl,0d
	je residuo2
	mov byte al,[cantidadx]
	add byte al,1d
	mov byte [cantidadx],al

residuo2:
	mov byte bl, [residuoy]
	cmp bl,0d
	je finalresiduo
	mov byte al,[cantidady]
	add byte al,1d
	mov byte [cantidady],al

finalresiduo:
	mov byte dl,0d
limpiarnotas:
	mov byte [arraynotas+rdx],0d
	mov byte [arrayestudiantes+rdx],0d
	cmp byte dl,100d
	add byte dl,1d
	jb limpiarnotas

	mov byte dl,1d ; el registro dl es un contador
	mov byte r9b,[cantidadx]
	mov byte bl,[tdgnb]
	mov byte [nota],0d
asignarnotas:
	mov byte al,dl
	mul byte bl
	mov byte [nota],al
	mov byte al,dl
	sub byte al,1d
	mov byte r14b,[nota]
	mov byte [arraynotas+rax],r14b
	add byte dl,1d
	mov byte r10b,dl
	cmp byte r10b,r9b
	jbe asignarnotas
	mov word [contadorfilas],0d
	mov word [byteactual],0d

findnotes:
	mov word bx,[byteactual]
	mov byte al,[text_ar+rbx]	
	add word bx,1d
	mov word [byteactual],bx
	cmp byte al, 10d
	jne findnotes

		
enter:		
	mov word cx,[contadorfilas]
	add word cx,1d
	mov word [contadorfilas],cx
	mov word bx,[byteactual]
	sub word bx,2d
	mov byte al,[text_ar+rbx]
	mov byte [num1+1],al
	sub word bx,1d
	mov byte al,[text_ar+rbx]
	cmp byte al,32	
	jne nospace
	mov byte al,48d

nospace:	
	mov byte [num1],al
	mov  byte ah,[num1]
	mov byte al,[num1+1]
	call _wascii2dec

	mov word bx,[contadorfilas]
	sub word bx,1d
	mov byte [todaslasnotas+rbx],al
	mov word ax,[bubbles]
	mov word bx,[contadorfilas]
	cmp  word ax,bx
	jg findnotes
	mov word [contadorfilas],0d

	mov byte r10b,0d

contarnotas:
	mov word bx,[contadorfilas]
	mov byte al,[todaslasnotas+rbx]
	mov byte bl,r10b
	mov byte dl,[arraynotas+rbx]
	add byte r10b,1d
	cmp byte al,dl

s1:		
	jg contarnotas
	mov byte bl,r10b
	sub byte bl,1d
	mov byte al,[arrayestudiantes+rbx]
	add byte al,1d
	mov byte [arrayestudiantes+rbx],al
	mov byte r10b,0d
	mov word ax,[contadorfilas]
	add word ax,1d
	mov word [contadorfilas],ax
	mov word bx,[bubbles]
	cmp word ax,bx
		
s2:		
	jb contarnotas
	mov byte r10b,0d

	mov byte al, 100
	mov byte bl,[bubbles]
	div byte bl
	mov byte r9b,al  
finalnotas:

	mov byte bl,r10b
	mov byte al,[arrayestudiantes+rbx]
	mul byte r9b
	mov byte [arrayestudiantes+rbx],al
	add byte r10b,1d
	mov byte al,[bubbles+1]
	cmp byte bl,al
	jb finalnotas

	mov rax, 1
 	mov rdi, 1
 	mov rsi, 10d
 	mov rdx, 2
 	syscall

	print text_ar
	mov rax, 1
	mov rdi, 1
 	mov rsi, 10d
 	mov rdx, 2
 	syscall

;limpiar contador
	mov word [contadorfilas],1d
	mov word [tamanof1],0d	

loopimpresion:
	xor rax,rax
	xor rdx,rdx
	mov word cx,[contadorfilas] 
	cmp word cx,1d		
	jne continuarejey
	add word cx,1d
	mov word [contadorfilas],cx
	jmp loopimpresion

continuarejey:
	mov word bx,[cantidady]
	sub word bx,cx
	add word bx,1d
	mov byte al,[arrayaxisy+rbx]
	cmp byte al,100d
	jb nocien

	mov rax, 1
        mov rdi, 1
        mov rsi, cien
        mov rdx, 4
        syscall

	mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 4
        syscall
	jmp imprimirx

nocien:
	mov byte al,[arrayaxisy+rbx]
	call _wdeci2ascii

        mov rax, 1
        mov rdi, 1
        mov rsi, num1
        mov rdx, 1
        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, num2
        mov rdx, 1
        syscall

	mov rax, 1
        mov rdi, 1
        mov rsi, espaciox2
        mov rdx, 2
        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 2
        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, espaciox2
        mov rdx, 2
        syscall

imprimirx:
;cargar dato
	mov word bx,[tamanof1]
	mov byte dl ,[arrayestudiantes+rbx]
	mov word ax, [cantidady]	
	sub word ax,[contadorfilas]
	mov byte bl,[arrayaxisy+rax]
	cmp byte dl,bl	
	jb noprintx

	mov byte ah,[aprov]
	mov byte al,[aprov+1]
	mov byte [num1],ah
	mov byte [num2],al
	call _wascii2dec

bp4:	
	mov word bx,[tamanof1]	
	mov byte cl,[arraynotas+rbx]

bp3:	
	cmp byte cl,al
	jg letrasverdes	

bp1:	
	mov byte ah,[reprov]
	mov byte al,[reprov+1]
	mov byte [num1],ah
	mov byte [num2],al

	call _wascii2dec
	mov word bx,[tamanof1]
	mov byte cl,[arraynotas+rbx]
bp2:	
	cmp byte al,cl
	jb letrasamarillas
        mov rax, 1
        mov rdi, 1
        mov rsi, rojo
        mov rdx, 5
        syscall
	jmp imprimircolor

letrasamarillas:
        mov rax, 1
        mov rdi, 1
        mov rsi, amarillo
        mov rdx, 5
        syscall
	jmp imprimircolor


letrasverdes:
        mov rax, 1
        mov rdi, 1
        mov rsi, verde
        mov rdx, 5
        syscall

imprimircolor:
	mov rax, 1
	mov rdi, 1
	mov rsi, x
	mov rdx, 2
	syscall
	mov rax, 1
        mov rdi, 1
        mov rsi, espaciox4
        mov rdx, 4
        syscall
	jmp compararx

noprintx:
        mov rax, 1
        mov rdi, 1
        mov rsi, espaciox2
        mov rdx, 2
        syscall
        mov rax, 1
        mov rdi, 1
        mov rsi, espaciox4
        mov rdx, 4
        syscall
compararx:
        mov rax, 1
        mov rdi, 1
        mov rsi, blanco
        mov rdx, 5
        syscall
	mov word ax,[tamanof1]
	add word ax, 1d
	mov word [tamanof1],ax
	cmp word ax,[cantidadx]
	jb imprimirx

	mov word [tamanof1],0d

        mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 1
        syscall

	mov rax, 1
        mov rdi, 1
        mov rsi, espacioyenter
        mov rdx, 2
        syscall

	mov word ax,[contadorfilas]
	add word ax,1d
	mov word [contadorfilas],ax

	mov word bx,[cantidady]
	add word bx,1d
	cmp word ax,bx
	jb loopimpresion

        mov rax, 1
        mov rdi, 1
        mov rsi, espacioyenter
        mov rdx, 2
        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, espaciox4
        mov rdx, 4
        syscall

  	mov rax, 1
        mov rdi, 1
        mov rsi, espaciox4
        mov rdx, 4
        syscall
	mov word [contadorfilas],0d
imprimirejex:
	mov word bx,[contadorfilas]
	mov byte al,[arraynotas+rbx]
	cmp  byte al, 100d
	jb nocien2
        mov rax, 1
        mov rdi, 1
        mov rsi,cien
        mov rdx, 4
        syscall

	jmp finalhistograma


nocien2:
	mov byte al,[arraynotas+rbx]

	call _wdeci2ascii

        mov rax, 1
        mov rdi, 1
        mov rsi, num1
        mov rdx, 1
        syscall
        mov rax, 1
        mov rdi, 1
        mov rsi,num2
        mov rdx, 1
        syscall
	mov rax, 1
        mov rdi, 1
        mov rsi,espaciox4
        mov rdx, 4
        syscall
	mov word ax,[contadorfilas]
	add word ax,1d
	mov word [contadorfilas],ax
	cmp word ax,[cantidadx]
	jb imprimirejex

finalhistograma:
	mov rax, 1
        mov rdi, 1
        mov rsi,espacioyenter
        mov rdx, 2
        syscall
        mov rax, 1
        mov rdi, 1
        mov rsi, dobleespacio
        mov rdx, 2
        syscall


	.finalprograma: 
		mov rax,60	
		mov rdi,0	
		syscall		
_wascii2dec:
	mov byte al, [num1]
	mov byte bl,[num2]
	sub byte al,48d
	sub byte bl,48d
	mov byte cl,al
	add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
	add byte al,bl
	ret

_wdeci2ascii:
	mov byte cl,al
	mov byte bl,10d
	div byte bl
	add byte al,48d
	mov byte [num1],al
	sub byte al,48d
	mul byte bl
	sub byte cl,al
	add byte cl,48d
	mov byte [num2],cl
	ret
