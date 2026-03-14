
.section .text
.globl factorial

factorial:

    li t0, 1 #resultado
    li t1, 1 #contador

loop:

    mul t0, t0, t1
    addi t1, t1, 1
    ble t1, a0, loop #si t1 es menor o igual a a0, loop

    mv a0, t0
    ret