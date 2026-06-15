%{
#include <sstream>
#include <cstdlib>
#include "Parser.hpp"
#include "Lexer.hpp"

using namespace std;

#undef YY_DECL
#define YY_DECL int C1::Lexer::lex(C1::Parser::semantic_type *yylval)
%}

%option c++
%option noyywrap
%option outfile="Lexer.cpp"
%option yyclass="Lexer"

ID   [a-zA-Z_][a-zA-Z0-9_]*
NUM  [0-9]+(\.[0-9]+)?
WSPC [ \t\n\r]+

%%

"int"     { return C1::Parser::token::INT; }
"float"   { return C1::Parser::token::FLOAT; }
"if"      { return C1::Parser::token::IF; }
"else"    { return C1::Parser::token::ELSE; }
"while"   { return C1::Parser::token::WHILE; }

"+"       { return C1::Parser::token::MAS; }
"-"       { return C1::Parser::token::MENOS; }
"*"       { return C1::Parser::token::MUL; }
"/"       { return C1::Parser::token::DIV; }
"="       { return C1::Parser::token::ASIG; }
";"       { return C1::Parser::token::PYC; }
","       { return C1::Parser::token::COMA; }
"("       { return C1::Parser::token::PARIZQ; }
")"       { return C1::Parser::token::PARDER; }
"{"       { return C1::Parser::token::LLAVEIZQ; }
"}"       { return C1::Parser::token::LLAVEDER; }

{ID}      { return C1::Parser::token::IDENTIFICADOR; }
{NUM}     { return C1::Parser::token::NUMERO; }
{WSPC}    { /* Ignorar espacios y saltos de línea */ }

.         { cout << "Error léxico: carácter inválido '" << yytext << "'" << endl; }

<<EOF>>   { yyterminate(); }

%%
