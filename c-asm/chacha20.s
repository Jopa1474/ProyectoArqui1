
.section .text

.globl quarter_round
.globl chacha20_block
.globl chacha20_encrypt

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

    addi sp, sp, -32 # Guardamos espacio para ra + s0 + s1 + s2 

    sw ra, 0(sp) # Guardamos return address para no perder la referencia despues de llamar varias veces a quarter_round
    sw s0, 4(sp) # Registro para state
    sw s1, 8(sp) # Registro para working_state
    sw s2, 12(sp) # Registro para no perder el rastro de a0 (output)
    sw s3, 16(sp) # Registro para evitar problemas con el contador en inner_block
    sw s4, 20(sp) # Registro para evitar problemas con el loop de inner_block

    # Reservamos el espacio para los arrays (64 + 64 bytes)

    addi sp, sp, -128

    # Asignamos la posicion del stack que le corresponde a cada uno
    mv s0, sp
    addi s1, sp, 64


    # Creamos el state uniendo constantes + key + counter + nonce

    # Definimos las constantes y las agregamos (4 words)

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
    li t1, 16 # Referencia para detener el loop

loop_working_state:

    # Si ya se alcanzaron las 16 palabras, salimos del loop
    bge t0, t1, loop_working_state_done
    
    # Offset para ir saltando de 4 en 4 (i * 4)
    slli t2, t0, 2 

    # Obtenemos state[i]
    add t3, s0, t2
    lw t4, 0(t3)

    # Obtenemos la direccion de working state
    add t5, s1, t2

    # Guardamos state[i] en working state[i]
    sw t4, 0(t5)

    # Actualizamos el contador
    addi t0, t0, 1

    # Repetimos el loop
    j loop_working_state

loop_working_state_done:
    
    li s3, 0 # Contador para el inner inner block, para las 10 rondas
    li s4, 10

    # Para no perder la referencia a output, lo guardamos en s2
    mv s2, a0 
    # Ahora, como quarter_round usa state = a0, pasamos working_state a a0
    mv a0, s1

inner_block:

    # Si el contador llega a 10, saltamos
    bge s3, s4, inner_block_done

    # Operaciones de columna
    # quarter_round(state, 0, 4, 8, 12)
    
    li a1, 0
    li a2, 4
    li a3, 8
    li a4, 12
    # Llamamos a quarter_round con los valores previamente definidos
    call quarter_round

    # quarter_round(state, 1, 5, 9, 13)
    
    li a1, 1
    li a2, 5
    li a3, 9
    li a4, 13
    
    call quarter_round
    
    # quarter_round(state, 2, 6, 10, 14)
    
    li a1, 2
    li a2, 6
    li a3, 10
    li a4, 14
    
    call quarter_round

    # quarter_round(state, 3, 7, 11, 15)
    
    li a1, 3
    li a2, 7
    li a3, 11
    li a4, 15
    
    call quarter_round

    # Operaciones de diagonal
    # quarter_round(state, 0, 5, 10, 15)
    
    li a1, 0
    li a2, 5
    li a3, 10
    li a4, 15
    
    call quarter_round

    # quarter_round(state, 1, 6, 11, 12)
    
    li a1, 1
    li a2, 6
    li a3, 11
    li a4, 12
    
    call quarter_round

    # quarter_round(state, 2, 7, 8, 13)
    
    li a1, 2
    li a2, 7
    li a3, 8
    li a4, 13
    
    call quarter_round

    # quarter_round(state, 3, 4, 9, 14)
   
    li a1, 3
    li a2, 4
    li a3, 9
    li a4, 14
    
    call quarter_round

    addi s3, s3, 1
    j inner_block

inner_block_done:

    mv s1, a0 # Devolvemos working_state a s1

    # Ahora definimos el working_state final con:
    # working_state[i] = working_state[i] + state[i]
    
    li t0, 0
    li t1, 16

loop_working_state_final:

    bge t0, t1, loop_working_state_final_done

    # Cargamos los valores de state[i] y working_state[i] y los sumamos
    # Offset para ir saltando de 4 en 4 (i * 4)
    slli t2, t0, 2 

    # Obtenemos state[i]
    add t3, s0, t2
    lw t4, 0(t3)

    # Obtenemos working_state[i]
    add t5, s1, t2
    lw t6, 0(t5)

    # Sumamos ambos valores

    add t6, t6, t4 # working_state[i] = working_state[i] + state[i]

    # Guardamos el resultado en working_state[i]
    sw t6, 0(t5)
 
    # Aumentamos el contador y hacemos el loop
    addi t0, t0, 1
    j loop_working_state_final

loop_working_state_final_done:

    # Para finalizar con el chacha20_block, agregamos working_state
    # a output
    li t0, 0
    li t1, 16 # Referencia para detener el loop

loop_output:

    # Si ya se alcanzaron las 16 palabras, salimos del loop
    bge t0, t1, loop_output_done
    
    # Offset para ir saltando de 4 en 4 (i * 4)
    slli t2, t0, 2 

    # Obtenemos working_state[i]
    add t3, s1, t2
    lw t4, 0(t3)

    # Obtenemos la direccion de output
    add t5, s2, t2

    # Guardamos working_state[i] en working output[i]
    sw t4, 0(t5)

    # Actualizamos el contador
    addi t0, t0, 1

    # Repetimos el loop
    j loop_output

loop_output_done:

    # Para terminar, restauramos el stack y asigmanos a0 = s2

    mv a0, s2

    addi sp, sp, 128

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)

    addi sp, sp, 32
    ret

chacha20_encrypt:

    # a0 = plaintext
    # a1 = ciphertext
    # a2 = length (del plaintext ingresado)
    # a3 = keystream
    # a4 = key
    # a5 = counter
    # a6 = nonce 

    # Para chacha20_block se tenian los siguientes registros
    # a0 = output
    # a1 = key
    # a2 = counter
    # a3 = nonce
    # Entonces, guardamos esos regsitros en registros s antes de continuar, evitando desde s0 hasta s4 porque estos los utilizaba el chacha20_block

    addi sp, sp, -32 # Guardamos espacio

    sw ra, 0(sp) # Guardamos return address para no perder la referencia despues de hacer varios llamados
    sw s5, 4(sp) # Registro para plaintext [a0]
    sw s6, 8(sp) # Registro para ciphertext [a1]
    sw s7, 12(sp) # Registro para length [a2]
    sw s8, 16(sp) # Registro para keystream [a3]
    sw s9, 20(sp) # Registro para el contador de encrypt loop 
    sw s10, 24(sp) # Registro para los bloques de 64
    sw s11, 28(sp) # Registro para la direccion real

    # Cambiamos de lugar por un momento los registros
    mv s5, a0
    mv s6, a1
    mv s7, a2
    mv s8, a3
     
    # Ahora agregamos key y nonce a los registros que usa chacha20_block

    mv a0, a3 # keystream a output
    mv a1, a4 # key
    mv a2, a5 # counter
    mv a3, a6 # nonce

    # Como debemos mantener cual es la direccion real para plaintext y cipher text, la obtenemos de aca
    li s11, 0

# Va desde 0 hasta length con saltos de 64, pero si el largo queda entre medio (ej 100, que 100-64 serian 36bytes que sobran)
# entonces en ese caso, en vez de tomar 64, tomamos lo que queda de length
encrypt_loop_i:

    li s9, 0
    li s10, 64

    call chacha20_block

    # Si length es menor o igual a 64 (o 64 es mayor o igual a length)
    bge s10, s7, encrypt_loop_intermedio

    mv s8, a0 # Movemos el output a keystream

    addi a2, a2, 1 # counter = counter + 1

    addi s7, s7, -64 # Restamos los 64 que acabamos de usar al largo

encrypt_loop_j:

    # ciphertext[i] = block[i] ^ keystream[i]

    bge s9, s10, encrypt_loop_i

    slli t0, s11, 2 # Obtenemos el offset para las direcciones

    add t1, s5, t0 # Obtenemos la direccion de plaintext[i] (block[i])
    lw t2, 0(t1) # Obtenemos plaintext[i]

    add t3, s8, t0 # Obtenemos la direccion de keystream[i]
    lw t4, 0(t3) # Obtenemos keystream[i]

    xor t2, t2, t4 # block[i] XOR keystream[i]

    add t5, s6, t0 # Obtenemos la direccion de ciphertext[i]
    sw t2, 0(t5) # Agregamos ciphertext[i] a su posicion

    addi s9, s9, 1 # Actualizamos contador del loop
    addi s11, s11, 1 # Actualizamos contador de direccion real

    j encrypt_loop_j

# Ahora, en caso de que quede intermedio o igual a 64, trabajamos con el largo restante(s7) en vez de con s9
encrypt_loop_intermedio:

    # ciphertext[i] = block[i] ^ keystream[i]

    bge s9, s7, encrypt_loop_done

    slli t0, s11, 2 # Obtenemos el offset para las direcciones

    add t1, s5, t0 # Obtenemos la direccion de plaintext[i] (block[i])
    lw t2, 0(t1) # Obtenemos plaintext[i]

    add t3, s8, t0 # Obtenemos la direccion de keystream[i]
    lw t4, 0(t3) # Obtenemos keystream[i]

    xor t2, t2, t4 # block[i] XOR keystream[i]

    add t5, s6, t0 # Obtenemos la direccion de ciphertext[i]
    sw t2, 0(t5) # Guardamos ciphertext[i] en su posion

    addi s9, s9, 1
    addi s11, s11, 1

    j encrypt_loop_intermedio

encrypt_loop_done:

    # Devolvemos todo a su estado inicial

    mv a6, a3
    mv a5, a2
    mv a4, a1
    mv a3, a0

    mv a3, s8
    mv a2, s7
    mv a1, s6
    mv a0, s5

    # Restauramos los registros utilizados    

    lw ra, 0(sp) # Guardamos return address para no perder la referencia despues de hacer varios llamados
    lw s5, 4(sp) # Registro para plaintext [a0]
    lw s6, 8(sp) # Registro para ciphertext [a1]
    lw s7, 12(sp) # Registro para length [a2]
    lw s8, 16(sp) # Registro para keystream [a3]
    lw s9, 20(sp) # Registro para el contador de encrypt loop 
    lw s10, 24(sp) # Registro para los bloques de 64
    lw s11, 28(sp) # Registro para la direccion real

    addi sp, sp, 32 # Restauramos el espacio usado

    ret

