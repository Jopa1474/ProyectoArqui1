
#include <stdint.h>


extern void quarter_round(uint32_t *state, int a, int b, int c, int d);


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
    
    char hex_chars[] = "0123456789ABCDEF";
    char buffer[8];
    int i = 0;

    if (num == 0) {
        print_char('0');
        return;
    }

    while (num > 0) {
        buffer[i++] = hex_chars[num % 16];
        num /= 16;
    }

    // imprimir en orden inverso
    while (i > 0) {
        print_char(buffer[--i]);
    }
}



int main() {
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

    // state de prueba
    uint32_t state[16];

    state[0] = 0x11111111;//0x61707865;
    state[1] = 0x3320646e;
    state[2] = 0x79622d32;
    state[3] = 0x6b206574;

    state[4] = 0x01020304;//0x03020100;
    state[5] = 0x07060504;
    state[6] = 0x0b0a0908;
    state[7] = 0x0f0e0d0c;

    state[8] = 0x9b8d6f43;//0x13121110;
    state[9] = 0x17161514;
    state[10] = 0x1b1a1918;
    state[11] = 0x1f1e1d1c;

    state[12] = 0x01234567;//1;

    state[13] = 0x00000000;
    state[14] = 0x4a000000;
    state[15] = 0x00000000;

    quarter_round(state, 0, 4, 8, 12);

    for(int i=0;i<16;i++){
        print_number(i);
        print_char(':');
        print_hex(state[i]);
        print_char('\n');
    }
    print_string("Quarter round completado.");
    return 0;
}
