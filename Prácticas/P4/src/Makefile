CXX      = g++
CXXFLAGS = -std=c++17 -g -Wall -Iheaders
FLEX     = flex++
BISON    = bison

SRCS   = main.cpp
OBJS   = main.o Parser.o Lexer.o
TARGET = comp

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

# Generar Parser con Bison
Parser.cpp Parser.hpp: parser.yy
	$(BISON) parser.yy

# Generar Lexer con Flex
Lexer.cpp: lexer.ll Parser.hpp
	$(FLEX) lexer.ll

# Compilar archivos objeto
main.o: main.cpp Parser.hpp
	$(CXX) $(CXXFLAGS) -c main.cpp

Parser.o: Parser.cpp
	$(CXX) $(CXXFLAGS) -c Parser.cpp

Lexer.o: Lexer.cpp Parser.hpp
	$(CXX) $(CXXFLAGS) -c Lexer.cpp

# Correr con el archivo de prueba
run: $(TARGET)
	./$(TARGET) prueba

clean:
	rm -f $(TARGET) $(OBJS) Parser.cpp Parser.hpp Lexer.cpp

.PHONY: all run clean
