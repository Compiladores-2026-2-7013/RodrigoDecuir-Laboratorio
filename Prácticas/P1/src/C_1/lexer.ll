%{
#include <iostream>
#include <string>
using namespace std;

#include "tokens.hpp"
#include "Lexer.hpp"

%}

%option c++
%option outfile="Lexer.cpp"
%option yyclass="C_1::Lexer"
%option case-insensitive

DIG [0-9]
LETRA [a-zA-Z]
ID ({LETRA}|_)({LETRA}|{DIG}|_)*
NUMERO {DIG}+(\.{DIG}+)?([eE][+-]?{DIG}+)?
ESPACIO [ \t\n]+
%%
"if" { return IF; }
"int" { return INT; }
"while" { return WHILE; }
"else" { return ELSE; }
"float" { return FLOAT; }

"+" { return MAS; }
"-" { return MENOS; }
"*" { return MUL; }
"/" { return DIV; }
"=" { return ASIG; }
"(" { return LPAR; }
")" { return RPAR; }
"," { return COMA; }
";" { return PYC; }

{ID} { return ID; }
{NUMERO} { return NUMERO; }

{ESPACIO} { /*return ESP;*/ }

. { cout << "ERROR LEXICO" << yytext << endl;}

%%

int yyFlexLexer::yywrap(){
    return 1;
}
