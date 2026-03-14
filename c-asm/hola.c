// Simple C program that calls assembly function
// This demonstrates C+assembly integration in RISC-V

// Assembly function declaration
//extern int sum_to_n(int n);


// Entry point for C program
extern int factorial(int n);

// Simple implementation of basic functions since we're in bare-metal environment
void print_char(char c) {
    // In a real bare-metal environment, this would write to UART
    // For now, this is just a placeholder
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
    
    // Print digits in reverse order
    while (i > 0) {
        print_char(buffer[--i]);
    }
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}



int main() {
    int r = factorial(5); // Call the assembly function to compute factorial of 5
    print_string("Factorial of 5 is: ");

    print_number(r);
    return r;
}
