#A simple makefile is a unicorn.
CXX=g++
LEX=flex++
OUTPUT_DIR=output
EXE=$(OUTPUT_DIR)/compiler

GENERATED_SRC=Lexer.cpp
SOURCES=main.cpp $(GENERATED_SRC)
OBJECTS=$(addprefix $(OUTPUT_DIR)/, $(SOURCES:.cpp=.o))

# TARGETS to test the program
# $@ is the incoming source filename
# $< is the output filename

# Compilación  +++++++++++++++++++++++++++++++++++++++
all: $(OUTPUT_DIR) $(EXE)

# Enlazar el ejecutable final
$(EXE): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(EXE)

# Regla para generar Lexer.cpp a partir de lexer.ll
$(GENERATED_SRC): lexer.ll
	$(LEX) lexer.ll

# Regla para compilar los objetos en la carpeta output
$(OUTPUT_DIR)/%.o: %.cpp
	$(CXX) -c $< -o $@
# ++++++++++++++++++++++++++++++++++++++++++++++++++++

# Ejecución ++++++++++++++++++++++++++++++++++++++++++
run: all
	./$(EXE) prueba
# ++++++++++++++++++++++++++++++++++++++++++++++++++++

${OUTPUT_DIR}: 
	mkdir -p $(OUTPUT_DIR)

.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR) $(GENERATED_SRC)
