# Project 19: ML-Driven Compiler for Automatic Detection of Performance Bottlenecks in Scientific Programs

A production-grade, compiler-based static performance analyzer and machine learning framework designed to detect, analyze, and optimize performance bottlenecks in scientific C programs.

---

## 1. Project Overview

Scientific programs (e.g., linear algebra, physics simulations, finite-difference solvers, stencil computations) frequently suffer from severe hardware bottlenecks, including:
- **L1/L2 Cache Thrashing**: Non-unit stride, column-major memory access in row-major C storage.
- **Memory Latency Delays**: Indirect memory references ($A[B[i]]$) and pointer-chasing patterns.
- **Wasted Computational Workload**: Loop-invariant expressions trapped inside inner loop bodies.
- **Control-Flow Pipeline Stalls**: Divergent branches and un-inlined function calls preventing SIMD vectorization.
- **High Algorithmic Complexity**: Deeply nested $O(N^3)$ computational loops.

**Project 19** implements an end-to-end compiler frontend in **pure C (C11)** paired with a **Random Forest machine learning model** that statically analyzes C source code, constructs Control Flow Graphs (CFGs), performs data-flow def-use tracking and memory stride analysis, extracts a 16-dimensional numerical compiler feature vector, and predicts bottleneck risk with actionable compiler optimization recommendations (Loop Interchange, Cache Tiling, Loop-Invariant Code Motion, SIMD Vectorization).

---

## 2. System Architecture & Technologies

- **Core Implementation Language**: C (C11 standard)
- **Target Compiler**: GCC (MSYS2 UCRT64 on Windows)
- **External C Libraries**: None (Standard C library only: `stdio.h`, `stdlib.h`, `string.h`, `math.h`, `stdbool.h`)
- **Machine Learning**: Random Forest Classifier ensemble trained on empirical benchmark profiles and embedded as pure C decision trees (`src/model_weights.h`) for zero-dependency standalone execution.
- **Reporting Formats**: ANSI Color Terminal UI, Detailed College Submission Text (`.txt`), Machine-readable CSV (`.csv`), and Interactive Modern HTML Dashboard (`.html`).

```
project19/
├── src/
│   ├── common.h                  # Common macros, safe string helpers, terminal colors, path normalizer
│   ├── source_analyzer.h / .c    # Robust Lexer & AST parser (handles comments, strings, casts, loops, arrays)
│   ├── control_flow.h / .c       # Control Flow Graph (CFG) builder, BasicBlocks, Cyclomatic Complexity, trip bounds
│   ├── data_flow.h / .c          # Def-Use tracking, loop-invariant code detection, memory stride profiling
│   ├── feature_extractor.h / .c  # Standardized 16-dimensional compiler feature extractor & CSV serializer
│   ├── ml_model.h / .c           # Pure C Random Forest inference engine, risk scoring, feature attribution
│   ├── model_weights.h           # Pre-compiled / trained decision tree ensemble weights
│   ├── code_optimizer.h / .c     # Functional C code optimizer (Loop Interchange, LICM, SIMD Vectorization)
│   ├── benchmark_validator.h / .c# Automated compiler, output correctness verifier, and GCC -O2 benchmark
│   ├── report_generator.h / .c   # Multi-format report engine (Terminal, TXT, CSV, HTML Dashboard)
│   └── main.c                    # Interactive terminal UI, dynamic path reader, batch runner
├── samples/                      # 10 Scientific Benchmark C Programs
│   ├── 01_simple_loop.c          # 1D Vector Scale (DAXPY) - Unit stride, low risk
│   ├── 02_nested_loops.c         # 2D Grid Relaxation - Moderate O(N^2)
│   ├── 03_matrix_addition.c      # 2D Matrix Addition - Clean row-major streaming
│   ├── 04_matrix_multiplication.c# Naive Matrix Multiply - Severe non-unit stride B[k][j] cache bottleneck
│   ├── 05_loop_invariant_calc.c  # Invariant calculation inside inner loop - LICM candidate
│   ├── 06_efficient_blocked.c    # Cache-tiled matrix traversal - High efficiency
│   ├── 07_branchy_calls.c        # In-loop branches & function calls - SIMD blocker
│   ├── 08_stencil_2d.c           # 2D 5-point heat diffusion stencil
│   ├── 09_pointer_chasing.c      # Indirect lookup A[idx[i]] - High latency gather
│   └── 10_reduction_sum.c        # Scalar reduction accumulator
├── optimized_output/             # Transformed and validated optimized C output source files
├── dataset/
│   ├── benchmarks_metadata.csv   # Empirical wall-clock execution times and benchmark profiles
│   ├── features.csv              # Extracted 16-feature vectors with empirical labels
│   └── model.json                # Serialized Random Forest model metadata
├── scripts/
│   ├── benchmark_runner.py       # Empirical profiler (compiles samples with GCC -O2, records runtime)
│   ├── generate_dataset.py       # Feature extraction pipeline across benchmarks
│   └── train_model.py            # Python ML trainer (evaluates metrics and exports src/model_weights.h)
├── tests/
│   ├── test_suite.c              # Unit test suite covering Lexer, Parser, CFG, DataFlow, ML, Optimizer, and Validator
│   └── run_tests.bat             # Test execution batch script (23 / 23 tests)
├── reports/                      # Auto-generated analysis reports (TXT, CSV, HTML)
├── Makefile                      # Standard Makefile for MSYS2 GCC
├── build.bat                     # Windows GCC build script
├── run_project.bat               # Master one-click end-to-end execution workflow
├── project_report.md             # Complete 20-Section College Project Report
└── viva_questions.md             # Viva examination questions & comprehensive answers
```

---

## 3. Quick Start & Execution Instructions

### Prerequisites
- **Windows OS** with **MSYS2 UCRT64** installed.
- Ensure `gcc` is added to your system PATH:
  ```bash
  gcc --version
  ```
- Python 3.8+ (used for the model retraining script).

### Option A: One-Click Automated Execution
Run the master script in Command Prompt or PowerShell:
```cmd
.\run_project.bat
```
This script automatically:
1. Compiles `project19.exe` using GCC with `-O2`.
2. Builds and runs the unit test suite (`17 / 17 tests passed`).
3. Extracts compiler features from scientific benchmarks into `dataset/features.csv`.
4. Trains the Random Forest model and updates `src/model_weights.h`.
5. Recompiles `project19.exe` with the freshly trained model.
6. Runs batch analysis on all 10 sample scientific programs and writes reports to `reports/`.

---

### Option B: Manual Step-by-Step Build Commands

#### 1. Compile the Main Application
```cmd
gcc -std=c11 -Wall -Wextra -O2 -Isrc src/*.c -o project19.exe -lm
```

#### 2. Run Analysis on a Single C Program
```cmd
.\project19.exe samples/04_matrix_multiplication.c
```

#### 3. Analyze in Batch Mode (Multiple Files)
```cmd
.\project19.exe --batch samples/01_simple_loop.c samples/04_matrix_multiplication.c samples/09_pointer_chasing.c
```

#### 4. Run Interactive Mode
Simply run the executable with no arguments:
```cmd
.\project19.exe
```
Enter `samples/04_matrix_multiplication.c` when prompted.

#### 5. Compile and Run the Unit Test Suite (23 / 23 Tests)
```cmd
gcc -std=c11 -Wall -Wextra -O2 -Isrc tests/test_suite.c src/source_analyzer.c src/control_flow.c src/data_flow.c src/feature_extractor.c src/ml_model.c src/code_optimizer.c src/benchmark_validator.c src/report_generator.c -o tests/test_suite.exe -lm
.\tests\test_suite.exe
```
Or simply run:
```cmd
.\tests\run_tests.bat
```

#### 6. Run the Empirical Benchmark Profiler
```cmd
python scripts/benchmark_runner.py
```

#### 7. Retrain the Random Forest Model
```cmd
python scripts/train_model.py
```

---

## 4. Feature Vector Specification (16 Features)

| Feature | Name | Description |
|---|---|---|
| `f00` | `total_loops` | Total number of `for` and `while` loops |
| `f01` | `max_nesting_depth` | Deepest loop nesting level (1 = 1D, 2 = 2D, 3 = 3D) |
| `f02` | `est_iterations_log` | Statically estimated workload order: $\log_{10}(\text{iterations} + 1)$ |
| `f03` | `arithmetic_ops` | Total floating-point and integer additions, subtractions, multiplications, divisions |
| `f04` | `memory_reads` | Array and variable loads inside loop scopes |
| `f05` | `memory_writes` | Array and variable stores inside loop scopes |
| `f06` | `total_memory_ops` | Sum of reads and writes |
| `f07` | `arithmetic_intensity` | Ratio of compute FLOPs to total memory accesses |
| `f08` | `non_unit_strides` | Transposed / column-major memory accesses in C row-major storage |
| `f09` | `indirect_accesses` | Gather / scatter lookups: $A[B[i]]$ |
| `f10` | `loop_invariants` | Redundant computations inside loop bodies with invariant operands |
| `f11` | `branch_count` | Conditional branches (`if`/`else`) inside loop bodies |
| `f12` | `func_calls` | Non-inlined function calls inside loop scopes |
| `f13` | `cyclomatic_complexity`| Control Flow Graph McCabe complexity: $M = E - N + 2P$ |
| `f14` | `basic_block_count` | Number of CFG basic blocks |
| `f15` | `total_statements` | Total statement and instruction count |

---

## 5. Sample Analysis Output

```
================================================================================
   PROJECT 19: ML-DRIVEN SCIENTIFIC BOTTLENECK COMPILER ANALYSIS REPORT
================================================================================
Input Source File        : samples/04_matrix_multiplication.c
Total Source Lines       : 50
Measured Execution Time  : 736.00 ms (Ground Truth Empirical Profile)

--- [Module 3: Control-Flow Analysis & CFG Summary] ---
Total Basic Blocks       : 17
Total Control Flow Edges : 21
Cyclomatic Complexity (M): 6
Detected Loops Count     : 5
Maximum Nesting Depth    : 3
Estimated Workload       : ~1000000000 iters (Symbolic baseline)

--- [Module 4: Data-Flow & Memory Access Analysis] ---
Total Arithmetic Ops     : 5
Total Memory Reads       : 6
Total Memory Writes      : 6
Arithmetic Intensity     : 0.417 FLOPs/Op
Non-Unit Strides Detected: 1
  [WARNING] Line 37: Array 'B' -> Non-unit stride access (B[k][j]) in row-major C causes high L1/L2 cache miss rates.

--- [Module 6 & 7: Machine Learning Prediction & Bottleneck Analysis] ---
Predicted Bottleneck Risk: HIGH RISK (Risk Score: 96.6%)
Primary Bottleneck Class : L1/L2 Cache-Miss Bottleneck (Non-Unit Stride)

Top Contributing Features:
  1. non_unit_strides = 1 (Transposed / column-major accesses in row-major C)
  2. max_nesting_depth = 3 (Multi-level loop traversal)
  3. arithmetic_intensity = 0.417 (Low compute-to-memory ratio)

Compiler Optimization Recommendations:
  [1] Apply Loop Interchange: Swap loop nest indices so the innermost loop traverses array rows contiguously.
      Directive: #pragma GCC optimize("unroll-loops")
  [2] Apply Cache Tiling / Blocking: Partition large matrices into BxB sub-blocks fitting in L1/L2 data cache.
      Directive: #pragma omp parallel for collapse(2)
  [3] Transpose matrix B prior to loop execution to convert strided column accesses into streaming unit-stride reads.
      Directive: matrix_transpose(B, B_T, N, N);

-> Detailed Text Report saved to: reports/04_matrix_multiplication_report.txt
-> Summary record appended to   : reports/analysis_summary.csv
-> Visual HTML Dashboard saved to: reports/04_matrix_multiplication_report.html
```

---

## 6. Viewing HTML Reports in Visual Studio Code (VS Code)

Project 19 generates visual HTML reports inside the `reports/` folder (e.g. `reports/04_matrix_multiplication_report.html`). To execute and view these HTML reports inside Visual Studio Code:

### Method 1: VS Code Built-in "Simple Browser" (No extensions required)
1. In VS Code, press `Ctrl+Shift+P` (or `F1`) to open the Command Palette.
2. Type **`Simple Browser: Show`** and press **Enter**.
3. In the URL prompt, enter the path to the report:
   ```text
   file:///c:/Users/potup/OneDrive/Desktop/student_project/cd project/reports/04_matrix_multiplication_report.html
   ```
4. The interactive report dashboard renders directly inside a VS Code editor tab beside your C source code!

### Method 2: Launch in Default Browser from VS Code Terminal (Quickest)
Open the integrated terminal in VS Code (`Ctrl+\``) and execute:
```cmd
start reports\04_matrix_multiplication_report.html
```
*(On PowerShell, you can also use `Invoke-Item reports\04_matrix_multiplication_report.html`)*.
This immediately opens the report in your system's default browser (Chrome, Edge, Firefox).

### Method 3: Using the "Live Server" Extension
1. Install the **Live Server** extension (by Ritwick Dey) from the VS Code Extensions Marketplace (`Ctrl+Shift+X`).
2. In the VS Code Explorer file tree, expand the `reports/` folder.
3. Right-click any `.html` file (e.g. `04_matrix_multiplication_report.html`) and select **"Open with Live Server"** (or press `Alt+L, Alt+O`).

### Method 4: Reveal in File Explorer
1. In the VS Code Explorer sidebar, right-click `04_matrix_multiplication_report.html`.
2. Click **"Reveal in File Explorer"** (or press `Shift+Alt+R`).
3. Double-click the file in Windows Explorer to view it instantly.

---

## 7. Generated Reports & Artifacts
Every analysis automatically generates:
1. **Interactive HTML Dashboard** (`reports/<name>_report.html`): Visual dashboard displaying ML risk meters, control-flow metrics, def-use data flow, transformed code diffs, automated correctness verification status, and empirical speedup comparisons.
2. **Optimized C Source Code** (`optimized_output/<name>_optimized.c`): Production-ready, validated C source file containing applied transformations (never overwriting original files).
3. **Plain Text Report** (`reports/<name>_report.txt`): Comprehensive human-readable report designed for college submissions and viva presentations.
4. **CSV Summary Database** (`reports/analysis_summary.csv`): Cumulative dataset of all analyzed programs with extracted features, predictions, and benchmark metrics.
