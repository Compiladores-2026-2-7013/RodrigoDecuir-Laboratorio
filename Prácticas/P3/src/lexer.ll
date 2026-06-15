%{
#include <iostream>
#include <string>
using namespace std;

#include "headers/Symbols.hpp"
#include "headers/Lexer.hpp"

int line=1;
%}

%option c++
%option outfile="Lexer.cpp"
%option yyclass="Lexer"

LETRA   [a-zA-Z_]
DIGITO  [0-9]
ID      {LETRA}({LETRA}|{DIGITO})*
NUMERO  {DIGITO}+(\.{DIGITO}+)?

%%

[ \t\r]+ {}
"\n" 	 { line++; }

"int"       { return t_int; }
"float"     { return t_float; }
"if"        { return t_if; }
"else"      { return t_else; }
"while"     { return t_while; }

{ID}        { return t_id; }
{NUMERO}    { return t_numero; }

"+"         { return t_mas; }
"-"         { return t_menos; }
"*"         { return t_mult; }
"\\"        { return t_div; }
"="         { return t_asig; }
"("         { return t_par_izq; }
")"         { return t_par_der; }
";"         { return t_punto_y_coma; }
","         { return t_coma; }

.    	 { cout << "ERROR LEXICO " << yytext << endl;}

%%

int yyFlexLexer::yywrap(){
    return 1;
}

int Lexer::getLine()
{
    return line;
}
