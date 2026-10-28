
#include <stdio.h>

int main() {
    int n = 1000;
    long long iterations = 0;

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            iterations++;
        }
    }

    printf("Project 19 - Performance Analysis\n");
    printf("Nested loop depth: 2\n");
    printf("Estimated iterations: %lld\n", iterations);

    if (iterations >= 1000000) {
        printf("Bottleneck risk: HIGH - investigate performance\n");
    } else {
        printf("Bottleneck risk: LOW - continue analysis\n");
    }

    return 0;
}
