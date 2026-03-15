
.section .text

.globl quarter_round
.globl chacha20_block


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

    # Guardamos en t2 lo de state[b]
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

    # b <<< 7
    slli t5, t2, 7
    srli t6, t2, 25 #(32-7 = 25)
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

chacha20_block:

    # a0 = output
    # a1 = key
    # a2 = counter
    # a3 = nonce

    #Antes de empezar, ocupamos 2 arrays para almacenar los datos tanto de
    #state como de working state 

    # Por convención, guardamos los registros que vamos a usar para 
    # almacenar la dirección del inicio de ambos arrays

    addi sp, sp, -16 # Guardamos 16 bytes para ambos registros (4 + 4 bytes)

    sw s0, 0(sp) # Registro para state
    sw s1, 4(sp) # Registro para working_state

    # Reservamos el espacio para los arrays (64 + 64 bytes)

    addi sp, sp, -128

    # Asignamos la posicion del stack que le corresponde a cada uno
    mv s0, sp
    addi s1, sp, 64


    # Creamos el state uniendo constantes + key + counter + nonce

    #Definimos las constantes y las agregamos (4 words)

    li t0, 0x61707865
    sw t0, 0(s0)

    li t0, 0x3320646e
    sw t0, 4(s0)

    li t0, 0x79622d32
    sw t0, 8(s0)

    li t0, 0x6b206574
    sw t0, 12(s0)

    # Ahora agregamos el key a state (256 bits = 8 palabras)

    lw t0, 0(a1) # Cargamos la llave
    sw t0, 16(s0) # La agregamos al state

    lw t0, 4(a1)
    sw t0, 20(s0)

    lw t0, 8(a1)
    sw t0, 24(s0)

    lw t0, 12(a1)
    sw t0, 28(s0)

    lw t0, 16(a1)
    sw t0, 32(s0)

    lw t0, 20(a1)
    sw t0, 36(s0)

    lw t0, 24(a1)
    sw t0, 40(s0)

    lw t0, 28(a1)
    sw t0, 44(s0)

    # Agregamos el counter (1 palabra)

    sw a2, 48(s0)

    # Finalmente, agregamos el nonce (3 palabras)

    lw t0, 0(a3)
    sw t0, 52(s0)

    lw t0, 4(a3)
    sw t0, 56(s0)

    lw t0, 8(a3)
    sw t0, 60(s0)

    # Una vez construido el state, lo copiamos en working state

    li t0, 0 # Iniciamos el contador para el loop 

loop_working_state:

    li t1, 16 # Referencia para detener el loop

    # Si ya se alcanzaron las 16 palabras, salimos del loop
    bge t0, t1, loop_working_state_done
    
    # Offset para ir saltando de 4 en 4 (i * 4)
    slli t2, t0, 2 

    # Obtenemos state[i]
    add t3, s0, t2
    lw t4, 0(t3)

    # Obtenemos la direccion de working state
    add t5, s1, s2

    # Guardamos state[i] en working state[i]
    sw t4, 0(t5)

    # Actualizamos el contador
    addi t0, t0, 1

    # Repetimos el loop
    j loop_working_state

loop_working_state_done:
    ret

