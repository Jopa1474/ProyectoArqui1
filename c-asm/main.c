#include <stdint.h>

// Declaración de funciones de ensamblador
extern void quarter_round(uint32_t *state, int a, int b, int c, int d);
extern void chacha20_block(uint32_t *output, uint32_t *key, uint32_t counter, uint32_t *nonce);

// Declaración de la función de cifrado chacha20 (que utiliza chacha20_block internamente)
// para plaintext y ciphertext, al ser chacha20 un cifrado de byte a byte, los asignamos asi
extern void chacha20_encrypt(uint8_t *plaintext, uint8_t *ciphertext, uint32_t length, uint32_t *keystream, uint32_t *key, uint32_t counter, uint32_t *nonce);

// Implementación de la función memcpy para copiar memoria (usada en chacha20_encrypt)
void *memcpy(void *dest, const void *src, unsigned int n)
{   
    // Copia byte a byte
    unsigned char *d = dest;

    // Reinterpretamos src como un puntero a unsigned char para copiar byte a byte
    const unsigned char *s = src;

    // Copiamos byte a byte
    for(unsigned int i = 0; i < n; i++)
    {   
        // Copiamos el byte i-ésimo de src a dest
        d[i] = s[i];
    }

    return dest;
}

// Implementacion de las funciones de impresion para el sistema de salida (UART)
void print_char(char c) {
    
    volatile char *uart = (volatile char*)0x10000000;
    *uart = c;
}

void print_number(int num) {
    if (num == 0) {
        print_char('0');
        return;
    }
    
    if (num < 0) {
        print_char('-');
        num = -num;
    }
    
    char buffer[10];
    int i = 0;
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    // Hacer print de los dígitos en orden inverso
    while (i > 0) {
        print_char(buffer[--i]);
    }
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_hex(uint32_t num) {
    
    // Array de caracteres hexadecimales para convertir un número a su representación hexadecimal
    char hex_chars[] = "0123456789ABCDEF";

    // Buffer para almacenar los caracteres hexadecimales (8 caracteres para un uint32_t) y un índice para recorrerlo
    char buffer[8];

    // Índice para el buffer
    int i = 0;

    // Si el número es 0, imprimimos '0' directamente
    if (num == 0) {
        print_char('0');
        return;
    }

    // Convertir el número a hexadecimal, almacenando los caracteres en el buffer
    while (num > 0) {
        buffer[i++] = hex_chars[num % 16];
        num /= 16;
    }

    // imprimir en orden inverso
    while (i > 0) {
        print_char(buffer[--i]);
    }
}

// Funciones de prueba para quarter_round, chacha20_block y chacha20_encrypt

void test_quarter_round(){

    // Valores de prueba para a, b, c, d
    //a = 0x11111111
    // b = 0x01020304
    // c = 0x9b8d6f43
    // d = 0x01234567

    // Resultados esperados después de la ejecución de quarter_round:
    // a = 0xea2a92f4
    // b = 0xcb1cf8ce
    // c = 0x4581472e
    // d = 0x5881c4bb

    print_string("-------------------------------\n");

    print_string("Iniciando prueba de quarter round:\n");

    // state de prueba
    uint32_t state[16];

    state[0] = 0x11111111;
    state[1] = 0x3320646e;
    state[2] = 0x79622d32;
    state[3] = 0x6b206574;

    // key
    state[4] = 0x01020304;
    state[5] = 0x07060504;
    state[6] = 0x0b0a0908;
    state[7] = 0x0f0e0d0c;

    state[8] = 0x9b8d6f43;
    state[9] = 0x17161514;
    state[10] = 0x1b1a1918;
    state[11] = 0x1f1e1d1c;

    // Counter
    state[12] = 0x01234567;//1;

    // Nonce
    state[13] = 0x00000000;
    state[14] = 0x4a000000;
    state[15] = 0x00000000;

    quarter_round(state, 0, 4, 8, 12);

    print_string("Resultados de quarter round:\n");
    for(int i=0;i<16;i++){
        print_number(i);
        print_char(':');
        print_hex(state[i]);
        print_char('\n');
    }
    print_string("Quarter round completado.\n");

    print_char('\n');

}

void test_chacha20_block(){

    print_string("-------------------------------\n");

    print_string("Iniciando prueba de chacha20 block:\n");

    // Valores de prueba proporcionados por la pagina oficial de chacha20: https://www.ietf.org/rfc/rfc8439.html#section-2.3.2
    // Definimos el output (16 palabras = 64 bytes)
    uint32_t output[16];

    // Definimos el key (32 bytes)
    uint8_t key_bytes[32] = {
        0x00,0x01,0x02,0x03,
        0x04,0x05,0x06,0x07,
        0x08,0x09,0x0a,0x0b,
        0x0c,0x0d,0x0e,0x0f,
        0x10,0x11,0x12,0x13,
        0x14,0x15,0x16,0x17,
        0x18,0x19,0x1a,0x1b,
        0x1c,0x1d,0x1e,0x1f
    };

    // Definimos el nonce (12 bytes)
    uint8_t nonce_bytes[12] = {
        0x00,0x00,0x00,0x09,
        0x00,0x00,0x00,0x4a,
        0x00,0x00,0x00,0x00
    };

    // Reinterpretamos como palabras de 32 bits
    uint32_t *key = (uint32_t*) key_bytes;
    uint32_t *nonce = (uint32_t*) nonce_bytes;

    uint32_t counter = 1;

    // Llamamos a la función chacha20_block
    chacha20_block(output, key, counter, nonce);

    print_string("Resultados de chacha20 block:\n");
    
    for(int i=0;i<16;i++){
        print_number(i);
        print_char(':');
        print_hex(output[i]);
        print_char('\n');
    }

    print_string("Chacha20 block completado.\n");
    print_char('\n');

}

void test_chacha20_encrypt(){

    print_string("-------------------------------\n");

    print_string("Iniciando prueba de chacha20 encrypt:\n");

    // Valores de prueba proporcionados por la pagina oficial de chacha20: https://www.ietf.org/rfc/rfc8439.html#section-2.4.2

    uint8_t plaintext[] = "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.";
    uint8_t ciphertext[sizeof(plaintext)]; // El ciphertext tendrá el mismo tamaño que el plaintext

    uint32_t length = sizeof(plaintext) - 1; // Excluir el null terminator

    // Definimos el keystream del ultimo bloque (16 palabras = 64 bytes)
    //uint8_t keystream[length];
    uint32_t keystream[16];

    // Valores de prueba para key, counter y nonce

    // Definimos el key (32 bytes)
    uint8_t key_bytes[32] = {
        0x00,0x01,0x02,0x03,
        0x04,0x05,0x06,0x07,
        0x08,0x09,0x0a,0x0b,
        0x0c,0x0d,0x0e,0x0f,
        0x10,0x11,0x12,0x13,
        0x14,0x15,0x16,0x17,
        0x18,0x19,0x1a,0x1b,
        0x1c,0x1d,0x1e,0x1f
    };

    // Definimos el nonce (12 bytes)
    uint8_t nonce_bytes[12] = {
        0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x4a,
        0x00,0x00,0x00,0x00
    };

    // Reinterpretamos como palabras de 32 bits
    uint32_t *key = (uint32_t*) key_bytes;
    uint32_t *nonce = (uint32_t*) nonce_bytes;

    uint32_t counter = 1;

    // Llamamos a la función de cifrado
    chacha20_encrypt(plaintext, ciphertext, length, keystream, key, counter, nonce);

    print_string("Ciphertext:\n");

    for(int i=0;i<length;i++){
        print_hex(ciphertext[i]);
        print_char(' ');
    }

    print_char('\n');

    print_string("Keystream:\n");

   for(int i=0;i<16;i++){
        print_number(i);
        print_char(':');
        print_hex(keystream[i]);
        print_char('\n');
    }
    print_char('\n');

    uint8_t decrypted[sizeof(plaintext)];

    chacha20_encrypt(ciphertext, decrypted, length, keystream, key, counter, nonce);

    print_string("Desencriptado:\n");

    for(int i = 0; i < length; i++){
        print_char(decrypted[i]);
    }
    print_char('\n');

    print_string("\nChacha20 encrypt completado.\n");
    print_char('\n');

}

void test_chacha20_encrypt_extendido(){

    print_string("-------------------------------\n");

    print_string("Iniciando prueba de chacha20 encrypt extendido:\n");

    // Valores de prueba proporcionados por la pagina oficial de chacha20: https://www.ietf.org/rfc/rfc8439.html#section-2.4.2

    uint8_t plaintext[] = "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it. Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.";
    uint8_t ciphertext[sizeof(plaintext)]; // El ciphertext tendrá el mismo tamaño que el plaintext

    uint32_t length = sizeof(plaintext) - 1; // Excluir el null terminator

    // Definimos el keystream del ultimo bloque (16 palabras = 64 bytes)
    //uint8_t keystream[length];
    uint32_t keystream[16];

    // Valores de prueba para key, counter y nonce

    // Definimos el key (32 bytes)
    uint8_t key_bytes[32] = {
        0x00,0x01,0x02,0x03,
        0x04,0x05,0x06,0x07,
        0x08,0x09,0x0a,0x0b,
        0x0c,0x0d,0x0e,0x0f,
        0x10,0x11,0x12,0x13,
        0x14,0x15,0x16,0x17,
        0x18,0x19,0x1a,0x1b,
        0x1c,0x1d,0x1e,0x1f
    };

    // Definimos el nonce (12 bytes)
    uint8_t nonce_bytes[12] = {
        0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x4a,
        0x00,0x00,0x00,0x00
    };

    // Reinterpretamos como palabras de 32 bits
    uint32_t *key = (uint32_t*) key_bytes;
    uint32_t *nonce = (uint32_t*) nonce_bytes;

    uint32_t counter = 1;

    // Llamamos a la función de cifrado
    chacha20_encrypt(plaintext, ciphertext, length, keystream, key, counter, nonce);

    print_string("Ciphertext:\n");

    for(int i=0;i<length;i++){
        print_hex(ciphertext[i]);
        print_char(' ');
    }

    print_char('\n');

    print_string("Keystream:\n");

   for(int i=0;i<16;i++){
        print_number(i);
        print_char(':');
        print_hex(keystream[i]);
        print_char('\n');
    }

    print_char('\n');

    uint8_t decrypted[sizeof(plaintext)];

    chacha20_encrypt(ciphertext, decrypted, length, keystream, key, counter, nonce);

    print_string("Desencriptado:\n");

    for(int i = 0; i < length; i++){
        print_char(decrypted[i]);
    }
    print_char('\n');


    print_string("\nChacha20 encrypt extendido completado.\n");
    print_char('\n');

}

int main() {

    // Ejecutamos las pruebas para cada función
    test_quarter_round();
    test_chacha20_block();
    test_chacha20_encrypt();
    test_chacha20_encrypt_extendido();

    return 0;
}
