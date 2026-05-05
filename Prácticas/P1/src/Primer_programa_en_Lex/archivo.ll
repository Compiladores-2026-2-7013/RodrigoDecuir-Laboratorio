%{
  #include <iostream>
%}

%option c++
%option noyywrap

digito [0-9]
letra [a-zA-Z]
palabra {letra}+
espacio [ \t\n]
hexadecimal 0(x|X)[0-9a-fA-F]+
palabra_reservada (bool|if|class|struct|try)
identificador [a-zA-Z|_][a-zA-Z|0-9|_]{0,31}

%%

{identificador} {std::cout << "Encontré un identificador:" << yytext << std::endl; }
{palabra_reservada} { std::cout << "Encontré una palabra reservada:" << yytext << std::endl; }
{espacio} { std::cout << "Encontré un espacio en blanco" << yytext << std::endl; }
{digito}+ { std::cout << "Encontré un número:" << yytext << std::endl; }
{palabra} { std::cout << "Encontré una palabra:" << yytext << std::endl; }
{hexadecimal} { std::cout << "Encontré un número hexadecimal:" << yytext << std::endl; }

%%

int main() {
  FlexLexer* lexer = new yyFlexLexer;
  lexer->yylex();
}
