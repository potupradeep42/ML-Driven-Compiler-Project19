@echo off
echo ================================================================================
echo   Building Project 19 with GCC (MSYS2 UCRT64)
echo ================================================================================

gcc -std=c11 -Wall -Wextra -O2 -Isrc src/main.c src/source_analyzer.c src/control_flow.c src/data_flow.c src/feature_extractor.c src/ml_model.c src/code_optimizer.c src/benchmark_validator.c src/report_generator.c -o project19.exe -lm

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] project19.exe built successfully.
) else (
    echo [ERROR] Build failed with error code %ERRORLEVEL%.
)
