@echo off
setlocal enabledelayedexpansion

echo ================================================================================
echo   PROJECT 19: END-TO-END WORKFLOW EXECUTION
echo ================================================================================

echo.
echo [Step 1/5] Compiling C Compiler Analyzer Application...
gcc -std=c11 -Wall -Wextra -O2 -Isrc src/main.c src/source_analyzer.c src/control_flow.c src/data_flow.c src/feature_extractor.c src/ml_model.c src/code_optimizer.c src/benchmark_validator.c src/report_generator.c -o project19.exe -lm
if %ERRORLEVEL% NEQ 0 (
    echo [FATAL] C Compilation failed!
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] project19.exe compiled.

echo.
echo [Step 2/5] Compiling and Running Unit Test Suite...
gcc -std=c11 -Wall -Wextra -O2 -Isrc tests/test_suite.c src/source_analyzer.c src/control_flow.c src/data_flow.c src/feature_extractor.c src/ml_model.c src/code_optimizer.c src/benchmark_validator.c src/report_generator.c -o tests\test_suite.exe -lm
if %ERRORLEVEL% NEQ 0 (
    echo [FATAL] Test suite compilation failed!
    exit /b %ERRORLEVEL%
)
.\tests\test_suite.exe
if %ERRORLEVEL% NEQ 0 (
    echo [FATAL] One or more unit tests failed!
    exit /b %ERRORLEVEL%
)

echo.
echo [Step 3/5] Generating Scientific Compiler Feature Dataset...
python scripts\generate_dataset.py

echo.
echo [Step 4/5] Training Machine Learning Model and Exporting Weights...
python scripts\train_model.py

echo.
echo [Step 5/5] Recompiling project19.exe with updated ML model weights...
gcc -std=c11 -Wall -Wextra -O2 -Isrc src/main.c src/source_analyzer.c src/control_flow.c src/data_flow.c src/feature_extractor.c src/ml_model.c src/code_optimizer.c src/benchmark_validator.c src/report_generator.c -o project19.exe -lm

echo.
echo ================================================================================
echo   ANALYZING SCIENTIFIC PROGRAM SAMPLES IN BATCH
echo ================================================================================
.\project19.exe --batch samples\01_simple_loop.c samples\02_nested_loops.c samples\03_matrix_addition.c samples\04_matrix_multiplication.c samples\05_loop_invariant_calc.c samples\06_efficient_blocked.c samples\07_branchy_calls.c samples\08_stencil_2d.c samples\09_pointer_chasing.c samples\10_reduction_sum.c

echo.
echo ================================================================================
echo [FINISHED] Project 19 execution completed.
echo Check the 'reports/' folder for generated TXT, CSV, and HTML reports.
echo ================================================================================
