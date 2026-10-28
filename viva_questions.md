# Project 19: Comprehensive Viva Questions & Answers

**ML-Driven Compiler for Automatic Detection of Performance Bottlenecks in Scientific Programs**

---

### Category 1: Compiler Design & Frontend Analysis

**Q1: What is the difference between lexical analysis and syntax analysis?**  
**A:**  
- **Lexical Analysis (Scanning/Tokenization)** transforms raw source code characters into a stream of categorized *Tokens* (e.g., keywords, identifiers, literals, operators). It strips comments and whitespace, handles string escaping, and tracks line numbers.
- **Syntax Analysis (Parsing)** consumes the token stream and verifies that it adheres to the formal grammar of the language (Context-Free Grammar). It constructs an **Abstract Syntax Tree (AST)** that represents the hierarchical structure of expressions, statements, loops, and function declarations.

**Q2: Why is simple keyword searching (e.g., `strstr(line, "for")`) inadequate for compiler analysis?**  
**A:**  
Simple text searching causes massive false positives:
1. `printf("Waiting for completion...\n");` contains "for" inside a string literal.
2. `// Loop for computing velocity` contains "for" inside a comment.
3. `int performance_factor;` contains "for" inside a variable identifier.
A true lexical scanner strips comments, parses strings as literals, and matches keywords only when they appear as standalone grammatical tokens.

**Q3: What type of parser is implemented in Project 19?**  
**A:**  
Project 19 implements a **Recursive-Descent Parser** with operator-precedence handling. It parses compound statement blocks, `for`/`while` loops, conditional `if-else` branches, array indexing expressions, function calls, and variable declarations directly into an Abstract Syntax Tree (`ASTNode`).

---

### Category 2: Control Flow Graphs (CFG) & Complexity

**Q4: What is a Basic Block in a compiler?**  
**A:**  
A Basic Block is a maximal sequence of straight-line instructions with:
1. A **single entry point**: control enters only at the first instruction of the block.
2. A **single exit point**: control leaves the block only at the final instruction (no jumps/branches to the middle of the block).

**Q5: What is Cyclomatic Complexity, and how is it calculated from a CFG?**  
**A:**  
McCabe Cyclomatic Complexity measures the number of linearly independent execution paths through a program. From the Control Flow Graph, it is calculated as:
$$M = E - N + 2P$$
Where:
- $E$ = Number of directed CFG edges.
- $N$ = Number of Basic Blocks (nodes).
- $P$ = Number of connected components (typically $P=1$ for a single procedure).
Higher cyclomatic complexity indicates complex branching, nested loops, and higher testing and optimization difficulty.

**Q6: How does the compiler statically estimate loop iteration bounds?**  
**A:**  
For standard `for (int i = start; i < bound; i += step)` loops:
- If `start`, `bound`, and `step` are constant integers, the exact iteration count is:
  $$\text{Trip Count} = \left\lceil \frac{\text{bound} - \text{start}}{\text{step}} \right\rceil$$
- If `bound` is a symbolic variable or macro (e.g., `N`), the analyzer searches for local variable definitions. If unresolved, it records the bound as a symbolic estimate with a scientific benchmark baseline ($N \approx 1000$).
- For nested loops, total workload is computed as the product of all nesting trip counts: $\text{Workload} = \prod \text{Trip Count}_l$.

---

### Category 3: Data Flow Analysis & Memory Hierarchy

**Q7: What is Def-Use analysis and why is it important for scientific programs?**  
**A:**  
Def-Use analysis connects every definition (write/store) of a variable to all of its subsequent uses (reads/loads). It identifies:
1. Variable lifetimes and register allocation pressure.
2. Loop induction variables (variables incremented once per iteration).
3. Data dependencies (Read-After-Write, Write-After-Read) that determine whether loop iterations can be executed in parallel or vectorized via SIMD.

**Q8: Explain what a Non-Unit Memory Stride is and why it causes severe bottlenecks in C.**  
**A:**  
In the C programming language, multidimensional arrays are laid out in **row-major order**: elements in the same row are contiguous in physical memory ($A[i][0], A[i][1], A[i][2], \dots$).
- When the innermost loop increments the **last** subscript ($A[i][j]$ with inner loop $j$), memory access is **Unit Stride** ($\text{stride} = 1$). Each memory fetch loads a 64-byte cache line containing multiple consecutive elements, achieving high spatial locality.
- When the innermost loop increments the **first** subscript ($A[j][i]$ or $B[k][j]$ with inner loop $k$), the access jumps by $\text{COLS} \times \text{sizeof(element)}$ bytes per iteration. This is a **Non-Unit / Strided Access**. Almost every read incurs an L1/L2 data cache miss, stalling the CPU on main DRAM latency.

**Q9: What is Loop-Invariant Code Motion (LICM)?**  
**A:**  
Loop-Invariant Code Motion is a compiler optimization that identifies expressions inside a loop body whose operands never change across iterations (e.g., `double temp = 2.0 * alpha / gamma;`). Instead of recomputing this value millions of times inside the inner loop, the compiler hoists the computation out of the loop into a pre-header block, executing it exactly once.

---

### Category 4: Feature Engineering & Machine Learning

**Q10: What are the 16 features extracted by the Project 19 compiler?**  
**A:**  
1. `total_loops`: Total number of `for` and `while` loops.
2. `max_nesting_depth`: Deepest loop nesting level.
3. `est_iterations_log`: $\log_{10}(\text{iterations} + 1)$ workload order of magnitude.
4. `arithmetic_ops`: Count of arithmetic operations ($+$, $-$, $*$, $/$, $\%$).
5. `memory_reads`: Array and variable loads in loops.
6. `memory_writes`: Array and variable stores in loops.
7. `total_memory_ops`: Sum of memory loads and stores.
8. `arithmetic_intensity`: Ratio of compute operations to memory operations (FLOPs / byte proxy).
9. `non_unit_strides`: Count of transposed or column-major array accesses.
10. `indirect_accesses`: Count of gather/scatter array accesses ($A[B[i]]$).
11. `loop_invariants`: Count of redundant computations inside loop scopes.
12. `branch_count`: Conditional branches (`if`/`else`) inside loop bodies.
13. `func_calls`: Non-inlined function calls inside loop scopes.
14. `cyclomatic_complexity`: CFG McCabe complexity.
15. `basic_block_count`: Total number of CFG basic blocks.
16. `total_statements`: Total statement and instruction count.

**Q11: Why is a Random Forest model suitable for compiler bottleneck detection?**  
**A:**  
1. **Non-linear Feature Interactions**: Compiler properties interact non-linearly (e.g., nesting depth $\ge 3$ combined with non-unit strides causes catastrophic slowdowns, whereas nesting depth 1 with unit strides is harmless).
2. **Tabular Robustness**: Decision trees require no feature scaling or normalization.
3. **Overfitting Resistance**: Bootstrap aggregating (bagging) over multiple randomized trees prevents the model from overfitting to small benchmark variations.
4. **Interpretability & Feature Attribution**: Tree structures allow direct inspection of which split conditions contributed to the final prediction.

**Q12: How is the ML model deployed into the pure C application without requiring Python at runtime?**  
**A:**  
The Python training script (`scripts/train_model.py`) exports the learned ensemble trees as static C structures in `src/model_weights.h`. Each node contains:
- `feature_index`: Feature to inspect (0 to 15, or -1 for leaf).
- `threshold`: Split value.
- `left_child` / `right_child`: Array indices of children.
- `class_prob_high`: Probability of High Risk at the leaf.
The C inference function (`ml_model.c`) traverses these structs in microsecond time with zero dependencies on external shared libraries.

---

### Category 5: Optimization & High-Performance Computing (HPC)

**Q13: What is Loop Interchange, and how does it fix matrix multiplication bottlenecks?**  
**A:**  
In naive matrix multiplication ($C[i][j] += A[i][k] * B[k][j]$ with loop order $i \to j \to k$), the innermost loop increments $k$. This accesses $B[k][j]$ along columns with a stride of $N \times 8$ bytes, causing severe cache thrashing.  
By applying **Loop Interchange** to reorder the loops as $i \to k \to j$, the innermost loop now increments $j$. This accesses both $C[i][j]$ and $B[k][j]$ in continuous row-major order with unit stride ($\text{stride} = 1$), reducing L1 cache misses by over $10\times$.

**Q14: What is Cache Tiling / Blocking?**  
**A:**  
Cache Tiling divides large matrices (which cannot fit in CPU L1/L2 caches) into small $B \times B$ sub-matrices (tiles) that comfortably fit within the cache. All operations on a tile are completed before loading the next tile, maximizing temporal data reuse and avoiding repeated DRAM round-trips.

**Q15: What prevents a compiler from auto-vectorizing an inner loop?**  
**A:**  
Common vectorization inhibitors include:
1. **Divergent Branches (`if-else`)**: Cause SIMD execution lanes to mask and serialize.
2. **Function Calls**: Unless inlined, the compiler cannot issue SIMD vector instructions across function call boundaries.
3. **Pointer Aliasing**: If pointers might point to overlapping memory, vectorization could violate data dependencies.
4. **Loop-Carried Dependencies**: When iteration $i$ requires the output of iteration $i-1$ (e.g., scalar reduction without associativity relaxation).
