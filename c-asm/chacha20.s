
.section .text

.globl quarter_round


quarter_round:

    # recibe state, a, b, c, d

    # a0 = state
    # a1 = indice a
    # a2 = indice b
    # a3 = indice c
    # a4 = indice d

    # Obtenemos la direccion de state[a]
    slli t0, a1, 2      # t0 = a * 4
    add  t0, a0, t0     # t0 = state + offset

    # Guardamos en t1 lo de state[a]
    lw   t1, 0(t0)      # t1 = state[a]

    # Obtenemos la direccion de state[b]
    slli t0, a2, 2      # t0 = b * 4
    add  t0, a0, t0     # t0 = state + offset

    # Guardamos en t2 lo de state[i]
    lw   t2, 0(t0)      # t2 = state[b]

    # Obtenemos la direccion de state[c]
    slli t0, a3, 2      # t0 = c * 4
    add  t0, a0, t0     # t0 = state + offset

    # Guardamos en t3 lo de state[i]
    lw   t3, 0(t0)      # t3 = state[c]

    # Obtenemos la direccion de state[d]
    slli t0, a4, 2      # t0 = d * 4
    add  t0, a0, t0     # t0 = state + offset

    # Guardamos en t4 lo de state[d]
    lw   t4, 0(t0)      # t4 = state[d]

    # Una vez con los valores cargados en los registros 
    # temporales, iniciamos con las operaciones del 
    # quarter round

    add t1, t1, t2 # a = a + b
    xor t4, t4, t1 # d xor a

    #Para rotateleft, hacemos n shift left, totalbit - n shift right
    # y los utilizamos OR, para que reemplacen los ceros que quedaron

    slli t5, t4, 16
    srli t6, t4, 16 #(32-16 = 16)
    or t4, t5, t6

    #Segunda ronda del quarter round

    add t3, t3, t4 # c = c + d
    xor t2, t2, t3 # b xor c

    # b <<< 12
    slli t5, t2, 12
    srli t6, t2, 20 #(32-12 = 20)
    or t2, t5, t6

    #Tercera ronda del quarter round

    add t1, t1, t2 # a = a + b
    xor t4, t4, t1 # d xor a

    # d <<< 8
    slli t5, t4, 8
    srli t6, t4, 24 #(32-8 = 24)
    or t4, t5, t6

    #Finalmente, cuarta ronda del quarter round

    add t3, t3, t4 # c = c + d
    xor t2, t2, t3 # b xor c

    # b <<< 12
    slli t5, t2, 12
    srli t6, t2, 20 #(32-12 = 20)
    or t2, t5, t6

    # Ahora hay que actualizar el state con los nuevos
    # a, b, c y de

    # Obtenemos la direccion de state[a]
    slli t0, a1, 2      # t0 = a * 4
    add  t0, a0, t0     # t0 = state + offset
    # Guardamos a
    sw t1, 0(t0)   

    # Obtenemos la direccion de state[b]
    slli t0, a2, 2      # t0 = b * 4
    add  t0, a0, t0     # t0 = state + offset   
    # Guardamos b
    sw t2, 0(t0)  

    # Obtenemos la direccion de state[c]
    slli t0, a3, 2      # t0 = c * 4
    add  t0, a0, t0     # t0 = state + offset
    # Guardamos c
    sw t3, 0(t0) 

    # Obtenemos la direccion de state[d]
    slli t0, a4, 2      # t0 = d * 4
    add  t0, a0, t0     # t0 = state + offset
    # Guardamos d
    sw t4, 0(t0) 

    ret
