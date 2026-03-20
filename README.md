# Chacha20 en RISC V

## Descripción del proyecto

Este proyecto consiste en la implementación del algoritmo de cifrado Chacha20, implementando sus funciones principales mediante ensamblador con **RISC V**, en conjunto con código en **C**, ejecutado en un entorno **bare mental** mediante QEMU.
Las funciones principales del algoritmo que fueron desarrolladas son:
- `quarter_round` (operación básica del algoritmo)
- `chacha20_block` (función para generar el keystream de 64 bytes)
- `chacha20_encrypt` (función de cifrado de mensajes)

El sistema nos permite cifrar y descifrar mensajes utilizando el mismo proceso, validando el correcto funcionamiento con los vectores oficiales de prueba proporcionados por el RFC 8439.

---

## Estructura del Proyecto

├── Documentación.md # Documentación técnica del proyecto
├── Dockerfile # Entorno con toolchain, QEMU y GDB
├── run.sh # Script para iniciar el contenedor
├── README.md # Documentación del proyecto
└── c-asm/
    ├── main.c # Código principal en C (pruebas y ejecución)
    ├── chacha20.s # Implementación en ensamblador de Chacha20 
    ├── startup.s # Inicialización del entorno bare mental
    ├── build.sh # Script de compilación
    └── run.sh # Script de ejecución en QEMU

## Requisitos previos a la ejecución

Para poder ejecutar este proyecto se necesita tener instalado Docker, las demás herramientas están dentro del contenedor (Toolchain, QEMU y GBD)

---

## Instrucciones para construir y ejecutar el Docker

1. Primero, para construir el docker, abrimos la terminal desde la carpeta donde esté el proyecto, una vez ahí necesita ejecutar:
```bash 
./run.sh
```
Nota: Este comando la primera vez descargará todo el contenido necesario e iniciará el docker, ya las siguientes veces lo utilizaremos para iniciar y acceder a el docker .

2. Vamos al directorio del proyecto:
```bash
cd /home/rvqemu-dev/workspace/c-asm
```

3. Compilamos el proyecto:
```bash
./build.sh
```

4. Ejecutamos en QEMU:
```bash 
./run-qemu.sh
```
---

## Ejecución de las pruebas con GBD
Ahora, para probar que las implementaciones funcionen, abrimos otra terminal (con el docker inicializado y todos los pasos previamente mencionados ya realizados) y seguimos los siguientes pasos:

1. Accedemos al contenedor:
```bash
docker exec -it rvqemu /bin/bash
```
2. Vamos al proyecto:
```bash
cd /home/rvqemu-dev/workspace/c-asm
```

3. Ejecutamos GBD:
```bash
gdb-multiarch main.elf
```

4. Nos conectamos a QEMU:
```bash
target remote :1234
```

---

## Casos de prueba y verificación (RFC 8439)
Una vez conectados a QEMU, escribimos el comando:
```bash
continue
```
Esto para ejecutar las pruebas implementadas en el documento main.c, más adelante se muestran ejemplos de comandos para depuración desde GBD.
Ahora, para validar la implementación se utilizaron los vectores de prueba oficiales del RFC.

### 1. Prueba de `quarter_round`

Se utilizaron los valores de prueba para a, b, c, d del RFC
- a = 0x11111111
- b = 0x01020304
- c = 0x9b8d6f43
- d = 0x01234567

Resultados esperados después de la ejecución de quarter_round:
- a = 0xea2a92f4
- b = 0xcb1cf8ce
- c = 0x4581472e
- d = 0x5881c4bb

Como quarter_round cambia justo en posiciones especificas del state o keystream, entonces utlizamos esos valores de prueba de a, b, c y d en el mismo, y así confirmamos que cambien de manera correcta y que haya sido en la posición correcta.

- **State (16 words)**

state[0] = 0x11111111
state[1] = 0x3320646e
state[2] = 0x79622d32
state[3] = 0x6b206574

state[4] = 0x01020304
state[5] = 0x07060504
state[6] = 0x0b0a0908
state[7] = 0x0f0e0d0c

state[8] = 0x9b8d6f43
state[9] = 0x17161514
state[10] = 0x1b1a1918
state[11] = 0x1f1e1d1c

state[12] = 0x01234567

state[13] = 0x00000000
state[14] = 0x4a000000
state[15] = 0x00000000

Utilizando quarter_round(state, 0,4,8,12)
Verificamos que cambiaron las posiciones 0, 4, 8 y 12 por los valores correctos

---

### 2. Prueba de `chacha20_block`

Se utilizó el vector de prueba oficial del RFC:

- **Key (256 bits):**

00 01 02 03 04 05 06 07
08 09 0a 0b 0c 0d 0e 0f
10 11 12 13 14 15 16 17
18 19 1a 1b 1c 1d 1e 1f


- **Nonce (96 bits):**

00 00 00 09
00 00 00 4a
00 00 00 00


- **Counter:**

1


Se verificó que el bloque generado coincide con el esperado del RFC:

e4e7f110  15593bd1  1fdd0f50  c47120a3
c7f4d1c7  0368c033  9aaa2204  4e6cd4c3
466482d2  09aa9f07  05d7c214  a2028bd9
d19c12b5  b94e16de  e883d0cb  4e3c50a2

---

### 3. Prueba de cifrado (`chacha20_encrypt`)

Se utilizó el siguiente plaintext:

Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.

Una vez ejecutado el cifrado, el ciphertext debe ser el siguiente

6e 2e 35 9a 25 68 f9 80 41 ba 07 28 dd 0d 69 81  
e9 7e 7a ec 1d 43 60 c2 0a 27 af cc fd 9f ae 0b 
f9 1b 65 c5 52 47 33 ab 8f 59 3d ab cd 62 b3 57 
16 39 d6 24 e6 51 52 ab 8f 53 0c 35 9f 08 61 d8  
07 ca 0d bf 50 0d 6a 61 56 a3 8e 08 8a 22 b6 5e  
52 bc 51 4d 16 cc f8 06 81 8c e9 1a b7 79 37 36  
5a f9 0b bf 74 a3 5b e6 b4 0b 8e ed f2 78 5e 42  
87 4d     


**Parámetros utilizados:**

- Key: misma del RFC  
- Nonce:
00 00 00 00
00 00 00 4a
00 00 00 00

- Counter: 1  

---

### 4. Verificación de cifrado

Se verificó que:

- El ciphertext se genera correctamente mediante:
ciphertext[i] = plaintext[i] ^ keystream[i]


- El keystream corresponde al generado por `chacha20_block` (último bloque en esta implementación)

---

### 5. Prueba de descifrado

Se validó la propiedad reversible del algoritmo:
plaintext = ciphertext ^ keystream


Aplicando nuevamente la función `chacha20_encrypt` sobre el ciphertext, se recupera el plaintext original.

---

##  Conclusión de pruebas

Las pruebas realizadas confirman que:

- `quarter_round` funciona correctamente
- `chacha20_block` genera el keystream esperado
- `chacha20_encrypt` cifra correctamente mensajes de múltiples bloques
- El proceso es reversible, permitiendo descifrado correcto

## Comandos útiles para depuración

- Colocar breakpoints en asm (ejemplo):
```bash
break chacha20_encrypt
break chacha20_block 
...
```
Si se quiere colocar un breakpoint en una posición en específico en el código, se puede obtener la dirección exacta con:
```bash
disassemble chacha20_encypt
disassemble chacha20_block
...
```
Nota: Puede ser cualquier otra etiqueta del codigo, no solo chacha20_encrypt o chacha20_block

Ahora, viendo las direcciones, para colocar el break point hacemos lo siguiente:
```bash
break *0xDIRECCION
```

Reemplazar 0xDIRECCION por la direccion como tal.

- Ejecutar el programa:
```bash
continue 
stepi
```

- Ver registros:
```bash
info registers
info registers a0
...
```
- Ver memoria:
```
x/16xw $a0 # Para palabras
x/64xb $a1 # Para bytes

- Eliminar breakpoints
```bash
delete
delete 1
```

- Ver breakpoints colocados
```bash
info breakpoints
```

- Para desactivar breakpoints
```bash
disable 1
disable 2
...
```
