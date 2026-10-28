# Project 19: ML-Driven Compiler for Automatic Detection of Performance Bottlenecks
# Makefile for MSYS2 UCRT64 / GCC on Windows

CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -O2 -Isrc
LDFLAGS = -lm

SRC = src/main.c \
      src/source_analyzer.c \
      src/control_flow.c \
      src/data_flow.c \
      src/feature_extractor.c \
      src/ml_model.c \
      src/code_optimizer.c \
      src/benchmark_validator.c \
      src/report_generator.c

TARGET = project19.exe
TEST_TARGET = tests/test_suite.exe

TEST_SRC = tests/test_suite.c \
           src/source_analyzer.c \
           src/control_flow.c \
           src/data_flow.c \
           src/feature_extractor.c \
           src/ml_model.c \
           src/code_optimizer.c \
           src/benchmark_validator.c \
           src/report_generator.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)
	@echo "Build complete: $(TARGET)"

test: $(TEST_TARGET)
	@echo "Running test suite..."
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_SRC)
	$(CC) $(CFLAGS) $(TEST_SRC) -o $(TEST_TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET) $(TEST_TARGET) *.o
	@echo "Clean complete."

.PHONY: all test clean
