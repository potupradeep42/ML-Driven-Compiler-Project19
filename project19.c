/**
 * Project 19: ML-Driven Compiler for Automatic Detection of Performance Bottlenecks
 * in Scientific Programs.
 * 
 * Root driver forwarding directly to the modular implementation in src/.
 * To build: run 'build.bat' or 'make' or:
 *   gcc -std=c11 -Wall -Wextra -O2 -Isrc src/*.c -o project19.exe -lm
 */

#include "src/common.h"
#include "src/source_analyzer.h"
#include "src/control_flow.h"
#include "src/data_flow.h"
#include "src/feature_extractor.h"
#include "src/ml_model.h"
#include "src/report_generator.h"

/* Forward to main defined in src/main.c */
int main(int argc, char* argv[]);
