;proyecto 1 de arquitectura de computadoras
;2017121733 Julio Andrés Casco Murillo

%include "linux64.inc"

section .data
;se selecciona los archivos a leer con los datos de los alumnos y las notas de aprobación
	archconf db "configuracion.txt",0	;nombre del archivo con la configuración
	archdat db "archivo.txt",0	;nombre del archivo con los datos


	x  db "x "
	espaciox2 db "  "
	espacioyenter db " ",10
	finaldefila db "|"
	espaciox4 db "    "
	cien db"100 "
	

section .bss
; se reservan espacios de memoria para las variables

	textconf resb 150 ;espacio para configuracion.txt
	textdat resb 1000 ;espacio para archivo.txt
	ttc resb 150 ; espacio de almacenamiento de configuracion.txt
	ttd resb 1000 ;espacio para almacenar archivo.txt

	byteactual resw 1 ;contador para indicar la posición que se lee
	finalf1 resw 1 ;indica donde esta el final de la fila
	iniciof1 resw 1	;indica la posición donde inicia la fila 1
	iniciof2 resw 1	;indica la posición  donde inicia la fila 2
	finalf2 resw 1	;indica la posición  donde finaliza la fila 2


	bytefinaltext resw 1	;almacena la posicion donde finaliza el documento con los datos
	contadorletras resw 1
	copiadorfilas resw 1

	sizef1 resw 1		;almacena  el tamaño de la fila 1
	sizef2 resw 1		;almacena el tamaño de la fila 2

	bubbletimes resw 1
	contadorfilas resw 1


	arraynotas resb 100		;almacena las notas en el eje x
	arrayestudiantes resb 100	;alcena la cantidad de estudiantes por grupo de notas


	nota resb 1
	num1 resb 2
	num2 resb 2

	todaslasnotas resb 100


;variables del archivo configuracion
	nda resb 3 ; almacena la nota de aprobacion
	ndr resb 2 ; almacena la nota de  reposicion
	tdgn resb 2 ; almacena  el tamaño de los grupos de notas
	edg resb 2 ; almacena la escala del grafico
	tdo resb 1; almacena el tipo de ordenamiento
	
;variables para la comparación

	letra1 resb 1
	letra2 resb 1
	copiafila1 resb 40 ;almacena fila 1
	copiafila2 resb 40 ;almacena fila 2

