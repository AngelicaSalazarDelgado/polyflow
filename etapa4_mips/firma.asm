# Etapa 4 - Verificacion de integridad
# Lee secuencia.txt, convierte el texto a numeros, calcula el checksum
# y escribe el resultado en firma.txt

.data
ruta_entrada:  .asciiz "/mnt/c/polyflow/salida/secuencia.txt"
ruta_salida:   .asciiz "/mnt/c/polyflow/salida/firma.txt"
buffer:        .space 1024
resultado:     .space 32
msg_error:     .asciiz "No se pudo abrir el archivo de entrada\n"
msg_checksum:  .asciiz "Checksum: "
msg_valores:   .asciiz "Valores procesados: "
salto:         .asciiz "\n"

.text
.globl main

main:
    # Abrir secuencia.txt en modo lectura
    li $v0, 13
    la $a0, ruta_entrada
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0
    bltz $s0, error

    # Leer el contenido completo al buffer
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall
    move $s1, $v0

    # Cerrar el archivo
    li $v0, 16
    move $a0, $s0
    syscall

    # s2 = checksum acumulado
    # s3 = posicion actual (empieza en 1)
    # s4 = indice dentro del buffer
    # s5 = numero que se esta armando
    # s6 = bandera: hay digitos acumulados
    li $s2, 0
    li $s3, 1
    li $s4, 0
    li $s5, 0
    li $s6, 0

recorrer:
    bge $s4, $s1, fin_recorrido

    la $t0, buffer
    add $t0, $t0, $s4
    lb $t1, 0($t0)

    # Es digito si esta entre '0' (48) y '9' (57)
    blt $t1, 48, no_digito
    bgt $t1, 57, no_digito

    # Acumular digito: numero = numero * 10 + (caracter - 48)
    addi $t1, $t1, -48
    mul $s5, $s5, 10
    add $s5, $s5, $t1
    li $s6, 1
    j siguiente

no_digito:
    # Si veniamos armando un numero, procesarlo
    beqz $s6, siguiente

    add $s2, $s2, $s5
    xor $s2, $s2, $s3
    addi $s3, $s3, 1

    li $s5, 0
    li $s6, 0

siguiente:
    addi $s4, $s4, 1
    j recorrer

fin_recorrido:
    # Procesar el ultimo numero si el archivo no termino en salto de linea
    beqz $s6, escribir

    add $s2, $s2, $s5
    xor $s2, $s2, $s3
    addi $s3, $s3, 1

escribir:
    li $v0, 4
    la $a0, msg_valores
    syscall
    li $v0, 1
    addi $a0, $s3, -1
    syscall
    li $v0, 4
    la $a0, salto
    syscall

    li $v0, 4
    la $a0, msg_checksum
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, salto
    syscall

    # Convertir el checksum a texto para escribirlo en el archivo
    move $a0, $s2
    la $a1, resultado
    jal entero_a_texto

    # Abrir firma.txt en modo escritura
    li $v0, 13
    la $a0, ruta_salida
    li $a1, 1
    li $a2, 0
    syscall
    move $s0, $v0
    bltz $s0, error

    li $v0, 15
    move $a0, $s0
    la $a1, resultado
    move $a2, $v1
    syscall

    li $v0, 16
    move $a0, $s0
    syscall

    li $v0, 10
    syscall

error:
    li $v0, 4
    la $a0, msg_error
    syscall
    li $v0, 10
    syscall

# Convierte el entero de $a0 a texto en la direccion $a1
# Devuelve en $v1 la cantidad de bytes escritos
entero_a_texto:
    move $t0, $a0
    move $t1, $a1
    li $t2, 0

    bnez $t0, contar_digitos
    li $t3, 48
    sb $t3, 0($t1)
    li $t3, 10
    sb $t3, 1($t1)
    li $v1, 2
    jr $ra

contar_digitos:
    move $t4, $t0
    li $t2, 0

ciclo_contar:
    beqz $t4, fin_contar
    div $t4, $t4, 10
    addi $t2, $t2, 1
    j ciclo_contar

fin_contar:
    add $t5, $t1, $t2
    li $t3, 10
    sb $t3, 0($t5)

    move $t4, $t0
    addi $t5, $t5, -1

ciclo_escribir:
    beqz $t4, fin_escribir
    rem $t6, $t4, 10
    addi $t6, $t6, 48
    sb $t6, 0($t5)
    div $t4, $t4, 10
    addi $t5, $t5, -1
    j ciclo_escribir

fin_escribir:
    addi $v1, $t2, 1
    jr $ra
