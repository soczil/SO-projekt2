#include <stdio.h>
#include <stdlib.h>
#include "pix.h"

void pixtime(uint64_t clock_tick) {
  fprintf(stderr, "%016lX\n", clock_tick);
}

int main() {
    const int N = 8;
    uint32_t table[N];
    uint64_t index = 0;
    pix(table, &index, N);
    
    for (int i = 0; i < N; i++) {
        printf("%u\n", table[i]);
    }

    return 0;
}
