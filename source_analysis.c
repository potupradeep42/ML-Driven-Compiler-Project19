
#include <stdio.h>
#include <string.h>

int main(void) {
    char filename[256];
    char line[1024];

    int for_count = 0;
    int while_count = 0;
    int line_number = 0;

    printf("=== Project 19: Source Code Analyzer ===\n");
    printf("Enter C source filename: ");

    if (scanf("%255s", filename) != 1) {
        printf("Error reading filename.\n");
        return 1;
    }

    FILE *file = fopen(filename, "r");

    if (file == NULL) {
        printf("Error: Cannot open file '%s'.\n", filename);
        printf("Check that the file exists in this folder.\n");
        return 1;
    }

    while (fgets(line, sizeof(line), file) != NULL) {
        line_number++;

        if (strstr(line, "for") != NULL) {
            for_count++;
            printf("Line %d: Possible FOR loop detected.\n",
                   line_number);
        }

        if (strstr(line, "while") != NULL) {
            while_count++;
            printf("Line %d: Possible WHILE loop detected.\n",
                   line_number);
        }
    }

    fclose(file);

    printf("\n=== Analysis Results ===\n");
    printf("Lines analyzed: %d\n", line_number);
    printf("Possible FOR loops: %d\n", for_count);
    printf("Possible WHILE loops: %d\n", while_count);
    printf("Total possible loops: %d\n", for_count + while_count);

    if (for_count + while_count >= 2) {
        printf("Potential risk: Multiple loops detected.\n");
        printf("Recommendation: Inspect loop nesting and workload.\n");
    } else {
        printf("Potential risk: No multiple-loop pattern detected.\n");
    }

    printf("\nNote: This is a basic text-based prototype.\n");
    printf("It does not yet perform full compiler or ML analysis.\n");

    return 0;
}
