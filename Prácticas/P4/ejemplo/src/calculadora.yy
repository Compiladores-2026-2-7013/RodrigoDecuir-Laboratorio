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
%define api.namespace {calc}
%parse-param {Lexer* lexer}

%code requires
{
    namespace calc {
        class Lexer;
    } // namespace calc
} // %code requires
 
%code
{
 #include "Lexer.hpp"
 #define yylex(x) lexer->lex(x) // Referencia a 1 en Lexer.hpp
}

%union {
  struct { //declarado para manejar los tipos de número posibles: 1.- entero, 2.- flotante.
    int ival; //valor 
    int tipo;
  } numero;
}

%token<numero> NUM

%left MAS
%left MUL

%nonassoc PARIZQ
%nonassoc PARDER

%type<numero> expresion

%start line

%%

line: expresion { cout << "Análisis léxico y sintáctico terminado.\nEl valor de la expresión ya evaluada es: " << $1.ival << endl; };

expresion : expresion MAS expresion { $$.ival = $1.ival + $3.ival; };
	  | expresion MUL expresion { $$.ival = $1.ival * $3.ival; };
	  | PARIZQ expresion PARDER { $$ = $2; };
	  | NUM { $$ = $1; };

%%

void calc::Parser::error(const std::string& msg) {
    std::cerr << msg << '\n';
}


#include <iostream>
#include <string>
#include <fstream>

int main(int argc, char *argv[]){
    if(argc < 2){
        cout<<"Faltan argumentos "<<endl;
        return EXIT_FAILURE;
    }
    filebuf fb;
    fb.open(string(argv[1]), ios::in);
    istream in(&fb);
    calc::Lexer lexer(&in);
    calc::Parser parser(&lexer);
    parser.parse();
    fb.close();
    return 0;
    /*
    calc::Lexer scanner{ std::cin, std::cerr };
    calc::Parser parser{ &scanner };
    //std::cout.precision(10);
    parser.parse();*/
}
