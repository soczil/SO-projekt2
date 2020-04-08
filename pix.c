#include <stdio.h>
#include <stdlib.h>
#include "pix.h"

int main() {
    const int N = 8;
    uint32_t table[N];
    uint64_t index = 0;
    uint64_t jol = pix(table, &index, N);

    printf("%lu\n", jol);
    
    for (int i = 0; i < N; i++) {
        printf("%u\n", table[i]);
    }

    return 0;
}
