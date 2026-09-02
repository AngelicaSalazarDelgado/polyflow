# Prueba de lectura de archivo en MIPS
# Abre secuencia.txt y muestra su contenido tal cual

.data
ruta:       .asciiz "/mnt/c/polyflow/salida/secuencia.txt"
buffer:     .space 1024
msg_error:  .asciiz "No se pudo abrir el archivo\n"
msg_bytes:  .asciiz "Bytes leidos: "
salto:      .asciiz "\n"

.text
.globl main

main:
    li $v0, 13
    la $a0, ruta
    li $a1, 0
    li $a2, 0
    syscall

    move $s0, $v0

    bltz $s0, error

    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall

    move $s1, $v0

    li $v0, 16
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_bytes
    syscall

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 4
    la $a0, salto
    syscall

    li $v0, 4
    la $a0, buffer
    syscall

    li $v0, 10
    syscall

error:
    li $v0, 4
    la $a0, msg_error
    syscall
    li $v0, 10
    syscall
