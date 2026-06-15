#include "headers/ParserLL.hpp"

ParserLL::ParserLL(Lexer *lexer)
{
    this->lexer = lexer;
}

ParserLL::~ParserLL()
{
}

void ParserLL::loadSyms()
{
    /*********************************************
     * 4. Agregar todos los símbolos (N'∪T) de G'*
     *********************************************/
    // Esta función típicamente mapea los enums a strings para depuración o inicializa
    // estructuras internas si el framework base lo requiere.
    // Si tu estructura base no mapea strings, se puede dejar en blanco ya que los
    // enums de Symbols.hpp ya son visibles globalmente en el Parser.
}

void ParserLL::loadProds()
{
    /************************************************
     * 5. Agregar todas las producciones (P') de G' *
     ************************************************/
    // Asignamos un identificador numérico a cada producción (P') de la gramática.
    // Usaremos un mapeo indexado por el ID de la producción hacia su cuerpo (vector de Símbolos).

    // programa -> declaraciones sentencias
    prods[1] = { Symbol(nt_declaraciones), Symbol(nt_sentencias) };

    // declaraciones -> declaracion declaraciones'
    prods[2] = { Symbol(nt_declaracion), Symbol(nt_declaraciones_prima) };

    // declaraciones' -> declaracion declaraciones'
    prods[3] = { Symbol(nt_declaracion), Symbol(nt_declaraciones_prima) };
    // declaraciones' -> epsilon
    prods[4] = { Symbol(strEmpty) };

    // declaracion -> tipo lista_var ;
    prods[5] = { Symbol(nt_tipo), Symbol(nt_lista_var), Symbol(t_punto_y_coma) };

    // tipo -> int
    prods[6] = { Symbol(t_int) };
    // tipo -> float
    prods[7] = { Symbol(t_float) };

    // lista_var -> identificador lista_var'
    prods[8] = { Symbol(t_id), Symbol(nt_lista_var_prima) };

    // lista_var' -> , identificador lista_var'
    prods[9] = { Symbol(t_coma), Symbol(t_id), Symbol(nt_lista_var_prima) };
    // lista_var' -> epsilon
    prods[10] = { Symbol(strEmpty) };

    // sentencias -> sentencia sentencias'
    prods[11] = { Symbol(nt_sentencia), Symbol(nt_sentencias_prima) };

    // sentencias' -> sentencia sentencias'
    prods[12] = { Symbol(nt_sentencia), Symbol(nt_sentencias_prima) };
    // sentencias' -> epsilon
    prods[13] = { Symbol(strEmpty) };

    // sentencia -> identificador = expresion ;
    prods[14] = { Symbol(t_id), Symbol(t_asig), Symbol(nt_expresion), Symbol(t_punto_y_coma) };
    // sentencia -> if ( expresion ) sentencias else sentencias
    prods[15] = { Symbol(t_if), Symbol(t_par_izq), Symbol(nt_expresion), Symbol(t_par_der), Symbol(nt_sentencias), Symbol(t_else), Symbol(nt_sentencias) };
    // sentencia -> while ( expresion ) sentencias
    prods[16] = { Symbol(t_while), Symbol(t_par_izq), Symbol(nt_expresion), Symbol(t_par_der), Symbol(nt_sentencias) };

    // expresion -> termino expresion'
    prods[17] = { Symbol(nt_termino), Symbol(nt_expresion_prima) };

    // expresion' -> + termino expresion'
    prods[18] = { Symbol(t_mas), Symbol(nt_termino), Symbol(nt_expresion_prima) };
    // expresion' -> - termino expresion'
    prods[19] = { Symbol(t_menos), Symbol(nt_termino), Symbol(nt_expresion_prima) };
    // expresion' -> epsilon
    prods[20] = { Symbol(strEmpty) };

    // termino -> factor termino'
    prods[21] = { Symbol(nt_factor), Symbol(nt_termino_prima) };

    // termino' -> * factor termino'
    prods[22] = { Symbol(t_mult), Symbol(nt_factor), Symbol(nt_termino_prima) };
    // termino' -> / factor termino'
    prods[23] = { Symbol(t_div), Symbol(nt_factor), Symbol(nt_termino_prima) };
    // termino' -> epsilon
    prods[24] = { Symbol(strEmpty) };

    // factor -> identificador
    prods[25] = { Symbol(t_id) };
    // factor -> numero
    prods[26] = { Symbol(t_numero) };
    // factor -> ( expresion )
    prods[27] = { Symbol(t_par_izq), Symbol(nt_expresion), Symbol(t_par_der) };
}

void ParserLL::loadTable()
{
    /*************************************************
     ** 6. Cargar la tabla de AS predictivo    **
     *************************************************/
    // La tabla se modela comunmente como: map<NoTerm, map<Token, int>> table;
    // Vincula cada par [NoTerminal][Terminal Token] con el ID numérico de su producción.

    // nt_programa
    table[nt_programa][t_int] = 1;
    table[nt_programa][t_float] = 1;

    // nt_declaraciones
    table[nt_declaraciones][t_int] = 2;
    table[nt_declaraciones][t_float] = 2;

    // nt_declaraciones_prima
    table[nt_declaraciones_prima][t_int] = 3;
    table[nt_declaraciones_prima][t_float] = 3;
    table[nt_declaraciones_prima][t_id] = 4;
    table[nt_declaraciones_prima][t_if] = 4;
    table[nt_declaraciones_prima][t_while] = 4;

    // nt_declaracion
    table[nt_declaracion][t_int] = 5;
    table[nt_declaracion][t_float] = 5;

    // nt_tipo
    table[nt_tipo][t_int] = 6;
    table[nt_tipo][t_float] = 7;

    // nt_lista_var
    table[nt_lista_var][t_id] = 8;

    // nt_lista_var_prima
    table[nt_lista_var_prima][t_punto_y_coma] = 10;
    table[nt_lista_var_prima][t_coma] = 9;

    // nt_sentencias
    table[nt_sentencias][t_id] = 11;
    table[nt_sentencias][t_if] = 11;
    table[nt_sentencias][t_while] = 11;

    // nt_sentencias_prima
    table[nt_sentencias_prima][t_id] = 12;
    table[nt_sentencias_prima][t_if] = 12;
    table[nt_sentencias_prima][t_while] = 12;
    table[nt_sentencias_prima][t_else] = 13;
    table[nt_sentencias_prima][t_eof] = 13;

    // nt_sentencia
    table[nt_sentencia][t_id] = 14;
    table[nt_sentencia][t_if] = 15;
    table[nt_sentencia][t_while] = 16;

    // nt_expresion
    table[nt_expresion][t_id] = 17;
    table[nt_expresion][t_numero] = 17;
    table[nt_expresion][t_par_izq] = 17;

    // nt_expresion_prima
    table[nt_expresion_prima][t_else] = 20;
    table[nt_expresion_prima][t_mas] = 18;
    table[nt_expresion_prima][t_menos] = 19;
    table[nt_expresion_prima][t_par_der] = 20;
    table[nt_expresion_prima][t_punto_y_coma] = 20;

    // nt_termino
    table[nt_termino][t_id] = 21;
    table[nt_termino][t_numero] = 21;
    table[nt_termino][t_par_izq] = 21;

    // nt_termino_prima
    table[nt_termino_prima][t_else] = 24;
    table[nt_termino_prima][t_mas] = 24;
    table[nt_termino_prima][t_menos] = 24;
    table[nt_termino_prima][t_mult] = 22;
    table[nt_termino_prima][t_div] = 23;
    table[nt_termino_prima][t_par_der] = 24;
    table[nt_termino_prima][t_punto_y_coma] = 24;

    // nt_factor
    table[nt_factor][t_id] = 25;
    table[nt_factor][t_numero] = 26;
    table[nt_factor][t_par_izq] = 27;
}

int ParserLL::parse()
{
    /**************************************************
     ** 7. Implementar el algoritmo de AS predictivo **
     **************************************************/

    // Inicialización de estructuras utilizando tus variables comentadas
    loadSyms();
    loadProds();
    loadTable();

    std::stack<Symbol> pila;
    std::map<Token, int>::iterator accion;
    std::vector<Symbol> body; // Modificado ligeramente el tipo para contener los objetos de la producción
    Symbol X;

    // Inicializar pila con el símbolo de fin de archivo ($) y el símbolo inicial (nt_programa)
    pila.push(Symbol(t_eof));
    pila.push(Symbol(nt_programa));

    // Obtener primer token desde el Lexer
    Token tokenActual = eat();

    while (!pila.empty()) {
        X = pila.top();

        // CASO 1: X es un Token Terminal
        if (X.isTerminal()) {
            if (X.getToken() == tokenActual) {
                pila.pop();
                // Si llegamos exitosamente al final de la entrada
                if (tokenActual == t_eof) {
                    aceptar("¡Análisis Sintáctico Exitoso! El archivo de prueba es válido.");
                    return 0;
                }
                tokenActual = eat(); // Consumir y avanzar token
            } else {
                error("Error Sintáctico: Se esperaba un token diferente en la entrada.");
            }
        }
        // CASO 2: X es un Símbolo No Terminal
        else {
            NoTerm nt = X.getNoTerm();

            // Buscar si existe una entrada válida en la tabla predictiva para [nt][tokenActual]
            if (table.find(nt) != table.end() && table[nt].find(tokenActual) != table[nt].end()) {
                int prodId = table[nt][tokenActual];
                pila.pop(); // Remover el No Terminal expandido

                body = prods[prodId];
                // Insertar los elementos del cuerpo en la pila en orden inverso
                // Siempre que no se trate de una derivación vacía (epsilon / strEmpty)
                if (!(body.size() == 1 && body[0].isEpsilon())) {
                    for (auto it = body.rbegin(); it != body.rend(); ++it) {
                        pila.push(*it);
                    }
                }
            } else {
                error("Error Sintáctico: Token inesperado '" + std::to_string(tokenActual) + "' no tiene transición válida.");
            }
        }
    }

    error("Error Sintáctico: La pila se vació antes de consumir toda la entrada.");
    return 1;
}

void ParserLL::error(string msg)
{
    cout << msg << endl;
    exit(EXIT_FAILURE);
}

Token ParserLL::eat()
{
    return (Token) lexer->yylex();
}

void ParserLL::aceptar(string msg)
{
    cout << msg << endl;
}
