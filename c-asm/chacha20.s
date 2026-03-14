
.section .text

.globl quarter_round


quarter_round:

    # recibe state, a, b, c, d

    # a0 = state
    # a1 = indice a

    slli t0, a1, 2      # t0 = a * 4
    add  t0, a0, t0     # t0 = state + offset
    lw   t1, 0(t0)      # t1 = state[a]

    addi t1, t1, 4

    sw t1, 0(t0)        # devolver valor (solo para prueba)

    ret
