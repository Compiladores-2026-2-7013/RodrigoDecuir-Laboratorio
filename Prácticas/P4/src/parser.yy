%{
#include <iostream>
#include <fstream>
#include <string>
#include <FlexLexer.h>
using namespace std;
%}

%language "C++"
%require "3.2"
%defines "Parser.hpp"
%output "Parser.cpp"

%define api.parser.class {Parser}
%define api.namespace {C1}
%parse-param {Lexer* lexer}

/* Mensajes de error informativos automáticos */
%define parse.error detailed

%code requires
{
    namespace C1 {
        class Lexer;
    }
}

%code
{
 #include "Lexer.hpp"
 #define yylex(x) lexer->lex(x)
}

/* Tokens de la gramática */
%token INT FLOAT IF ELSE WHILE
%token IDENTIFICADOR NUMERO
%token MAS MENOS MUL DIV ASIG PYC COMA
%token PARIZQ PARDER LLAVEIZQ LLAVEDER

/* Precedencia de operadores */
%left MAS MENOS
%left MUL DIV

%start programa

%%

programa : declaraciones sentencias {
            cout << "[Sintáctico] ¡Estructura del programa totalmente válida!" << endl;
         };

declaraciones : declaraciones declaracion
              | declaracion
              ;

declaracion : tipo lista_var PYC ;

tipo : INT | FLOAT ;

lista_var : lista_var COMA IDENTIFICADOR
          | IDENTIFICADOR
          ;

sentencias : sentencias sentencia
           | sentencia
           ;

sentencia : IDENTIFICADOR ASIG expresion PYC
          | IF PARIZQ expresion PARDER LLAVEIZQ sentencias LLAVEDER ELSE LLAVEIZQ sentencias LLAVEDER
          | WHILE PARIZQ expresion PARDER LLAVEIZQ sentencias LLAVEDER
          ;

expresion : expresion MAS expresion
          | expresion MENOS expresion
          | expresion MUL expresion
          | expresion DIV expresion
          | IDENTIFICADOR
          | NUMERO
          | PARIZQ expresion PARDER
          ;

%%

void C1::Parser::error(const std::string& msg) {
    std::cerr << "Error de Sintaxis Avanzado: " << msg << '\n';
}
