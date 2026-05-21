%{
#include <stdio.h>
#include <stdlib.h>

long long suma = 0;
%}

LB 0b[01]+

%%

{LB} {
  long long valor_en_decimal = strtoll(yytext + 2, NULL, 2);
  suma += valor_en_decimal;
}

.|\n {

}

%%

int yywrap() {
  return 1;
}

int main() {
  printf("Ingresa tus literales binarias (usa Ctrl+D para indicar el fin de la entrada):\n");
  yylex();
  printf("\nSuma de todas las literales binarias (LB): %lld\n", suma);
  return 0;
}
