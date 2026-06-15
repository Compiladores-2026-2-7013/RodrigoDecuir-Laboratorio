%language "C++"
%require "3.2"
%defines "headers/Parser.hpp"
%output "Parser.cpp"

%define api.parser.class {Parser}
%define api.namespace {C1}
%parse-param {Lexer* lexer}

%code requires {
    #include <string>
    #include <iostream>
    #include <vector>
    #include <stack>
    #include "Attributes.hpp"
    #include "TypeTab.hpp"
    #include "SymTab.hpp"
    #include "PilaTs.hpp"

    namespace C1 {
        class Lexer;
    }
}

%code {
    #include "headers/Lexer.hpp"

    // Definir yylex para que Bison llame a nuestro Lexer
    #define yylex(yylval) lexer->lex(yylval)

    // ========================================================
    // Variables globales del esquema de traducción
    // ========================================================
    TypeTab tablaTipos;         // Tabla de tipos global
    PilaTs pilaTs;              // Pila de tablas de símbolos
    std::stack<int> pilaDir;    // Pila de direcciones
    int dir = 0;                // Dirección actual de memoria

    // Variable auxiliar para propagar L.tipo (atributo heredado)
    int currentType = 0;

    // Variable para el tipo de retorno de funciones
    int tipoReturnFunc = 0;

    // Lista de tipos de parámetros (para F.lista)
    std::vector<int> listaParams;
}

// ========================================================
// Unión de valores semánticos
// ========================================================
%union {
    int ival;              // Para números enteros (NUM)
    char* sval;            // Para identificadores (ID)
    struct {
        int tipo;          // Tipo resultante
        int base;          // Tipo base (heredado en A)
    } attr;                // Para T, B, A
}

// ========================================================
// Tokens (terminales)
// ========================================================
%token <sval> ID
%token <ival> NUM
%token INT FLOAT REGISTER
%token DEF
%token SEMICOLON COMMA
%token LBRACKET RBRACKET LBRACE RBRACE LPAREN RPAREN

// ========================================================
// Tipos de los no-terminales
// ========================================================
%type <attr> T B A

// ========================================================
// Símbolo inicial
// ========================================================
%start P

%%

// ============================================================
// EJERCICIO 3: Implementar las acciones semánticas
// ============================================================

// P → D
// Regla semántica: dir ← 0, inicializar pila con tabla global
P : {
        dir = 0;
        pilaTs.push(new SymTab());
    }
    D
    {
        // Al finalizar, imprimir resultados (Ejercicio 5)
        std::cout << std::endl;
        tablaTipos.print();
        std::cout << std::endl;
        std::cout << "Tabla de simbolos global:" << std::endl;
        pilaTs.top()->print();
    }
    ;

// D → T L ; D
//   | def T id ( F ) { S } D
//   | ε
D : T L SEMICOLON D
    {
        // Regla semántica: L.tipo = T.tipo
        // (ya se propagó vía currentType al reducir T)
    }
  // ----------------------------------------------------------------
  // D → def T id ( F ) { S } D
  // ----------------------------------------------------------------
  | DEF T ID
    {
        // Acción intermedia (mid-rule action) antes de procesar los parámetros y el bloque
        std::string id = $3;
        if (!pilaTs.bottom()->existe(id)) {
            pilaTs.push(new SymTab());          // a) Nuevo alcance local para la función
            pilaDir.push(dir);                  // b) Guardar dir actual del padre
            dir = 0;                            // c) Reiniciar dir para el entorno local
            tipoReturnFunc = $2.tipo;           // d) Guardar tipo de retorno
        } else {
            std::cerr << "Error semántico: El id '" << id << "' ya fue declarado anteriormente en el alcance global." << std::endl;
        }
    }
    LPAREN F RPAREN LBRACE S RBRACE
    {
        std::string id = $3;
        SymTab* tsFunc = pilaTs.pop();          // Retirar tabla de la función de la pila
        delete tsFunc;                          // Liberar la tabla local si no se requiere persistencia

        dir = pilaDir.top();                    // Restaurar la dirección del padre
        pilaDir.pop();

        // Registrar la función en la tabla de símbolos global (bottom)
        pilaTs.bottom()->addSym(id, -1, $2.tipo, "func", listaParams);
        listaParams.clear();                    // Limpiar la lista para la siguiente función

        if ($3) free($3);
    }
    D
    {
        // Continuar con más declaraciones
    }
  | /* ε */
    {
        // Producción vacía, no hacer nada
    }
  ;

// T → B A
// Regla semántica: T.tipo = A.tipo, A.base = B.tipo
T : B A
    {
        $$.tipo = $2.tipo;          // Propagar: T.tipo = A.tipo
        currentType = $$.tipo;      // Actualizar para que L lo use
    }
  // T → register { D }
  | REGISTER LBRACE
    {
        pilaTs.push(new SymTab());  // 1. Empujar nueva tabla de símbolos para los campos
        pilaDir.push(dir);          // 2. Guardar dir actual
        dir = 0;                    // 3. Reiniciar dir para calcular tamaño interno del struct
    }
    D RBRACE
    {
        int tam_struct = dir;              // 1. El tamaño del struct es el valor acumulado en dir
        SymTab* tsStruct = pilaTs.pop();   // 2. Retirar la tabla del struct
        delete tsStruct;

        // 3. Registrar el struct en tablaTipos y obtener su ID
        $$.tipo = tablaTipos.addStructType(tam_struct);
        currentType = $$.tipo;             // 5. Actualizar currentType

        dir = pilaDir.top();               // 4. Restaurar dir del padre
        pilaDir.pop();
    }
  ;

// B → int
// Regla semántica: B.tipo = tablaTipos.getId("int")
B : INT
    {
        $$.tipo = tablaTipos.getId("int");
        $$.base = $$.tipo;                 // Se usará como herencia para A.base
    }
  // B → float
  // Regla semántica: B.tipo = tablaTipos.getId("float")
  | FLOAT
    {
        $$.tipo = tablaTipos.getId("float");
        $$.base = $$.tipo;                 // Se usará como herencia para A.base
    }
  ;

// A → [ NUM ] A₁
A : LBRACKET NUM RBRACKET
    {
        // Acción intermedia para propagar el atributo heredado de forma ascendente segura.
        // Copiamos la base del elemento previo al corchete de apertura en la pila semántica de Bison.
        $<attr>$.base = $<attr>0.base;
    }
    A
    {
        if ($2 > 0) {
            // Nota: debido a la acción intermedia en la posición 4, la sub-regla A pasa a ser $5
            $$.tipo = tablaTipos.addArrayType($2, $5.tipo);
        } else {
            std::cerr << "Error semántico: El índice del arreglo (" << $2 << ") debe ser mayor a cero." << std::endl;
            $$.tipo = -1;
        }
    }
  // A → ε
  // Regla semántica: A.tipo = A.base
  | /* ε */
    {
        // Recuperamos el valor heredado usando la posición relativa en la pila semántica
        $$.tipo = $<attr>0.base;
    }
  ;

// ----------------------------------------------------------------
// F → T id , F | T id | ε
// ----------------------------------------------------------------
F : T ID COMMA F
    {
        std::string id = $2;
        if (!pilaTs.top()->existe(id)) {
            pilaTs.top()->addSym(id, dir, $1.tipo, "param");
            dir += tablaTipos.getTam($1.tipo);

            // Insertar al inicio para preservar el orden correcto de parámetros (de izq a der)
            listaParams.insert(listaParams.begin(), $1.tipo);
        } else {
            std::cerr << "Error semántico: El parámetro '" << id << "' ya fue declarado en este ámbito." << std::endl;
        }
        if ($2) free($2);
    }
  | T ID
    {
        std::string id = $2;
        if (!pilaTs.top()->existe(id)) {
            pilaTs.top()->addSym(id, dir, $1.tipo, "param");
            dir += tablaTipos.getTam($1.tipo);

            listaParams.insert(listaParams.begin(), $1.tipo);
        } else {
            std::cerr << "Error semántico: El parámetro '" << id << "' ya fue declarado en este ámbito." << std::endl;
        }
        if ($2) free($2);
    }
  | /* ε */
    {
        // Sin parámetros, no hace nada
    }
  ;

// ----------------------------------------------------------------
// S → (cuerpo de sentencias - simplificado para esta práctica)
// ----------------------------------------------------------------
S : /* ε - placeholder para cuerpo de función */
    {
        // El cuerpo de sentencias se implementará en prácticas posteriores
    }
  ;

// L → L , id
L : L COMMA ID
    {
        std::string id = $3;
        if (!pilaTs.top()->existe(id)) {
            pilaTs.top()->addSym(id, dir, currentType, "var");
            dir += tablaTipos.getTam(currentType);
        } else {
            std::cerr << "Error semántico: La variable '" << id << "' ya fue declarada en este alcance." << std::endl;
        }
        if ($3) free($3);
    }
  // L → id
  | ID
    {
        std::string id = $1;
        if (!pilaTs.top()->existe(id)) {
            pilaTs.top()->addSym(id, dir, currentType, "var");
            dir += tablaTipos.getTam(currentType);
        } else {
            std::cerr << "Error semántico: La variable '" << id << "' ya fue declarada en este alcance." << std::endl;
        }
        if ($1) free($1);
    }
  ;

%%

// Manejo de errores de Bison
void C1::Parser::error(const std::string& msg) {
    std::cerr << "Error de sintaxis: " << msg << std::endl;
}
