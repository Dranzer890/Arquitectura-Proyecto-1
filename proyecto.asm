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
	mov a1, [text_config+122]
	mov byte [tipo_orde], a1

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


	mov word [bubletimes],0d	;se limpia el contador
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
	mov byte al, [textdat +rbx ]

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
