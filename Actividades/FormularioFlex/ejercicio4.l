%{
#include <stdio.h>
#include <stdlib.h>
%}

%%

[a-z] { fprintf(yyout, "%c", yytext[0] - 'a' + 'A'); }
\n { fprintf(yyout, "%s", yytext); }
. { fprintf(yyout, "%s", yytext); }

%%

int yywrap() {
  return 1;
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Uso correcto: %s <archivo_entrada> <archivo_salida>\n", argv[0]);
    return 1;
  }

  yyin = fopen(argv[1], "r");
  if (!yyin) {
    perror("Error al leer el archivo de entrada");
    return 1;
  }
  yyout = fopen(argv[2], "w");
  if (!yyout) {
    perror("Error al crear el archivo de salida");
    fclose(yyin);
    return 1;
  }

  yylex();

  fclose(yyin);
  fclose(yyout);

  return 0;
}
