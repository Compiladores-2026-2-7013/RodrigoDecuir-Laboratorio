%{
#include <stdio.h>

long long lineas = 0;
long long palabras = 0;
long long bytes = 0;
%}

/* PALABRA definida tal cual como el comando wc */
PALABRA [^ \t\n\r\f\v]+

%%

\n        { lineas++; bytes++; }
{PALABRA} { palabras++; bytes += yyleng; }
.         { bytes++; }

%%

int yywrap() {
  return 1;
}
/* Para probarlo sin pasarle un archivo se puede:
   ejecutar, escribir una entrada y usar 'Ctrl+D',
   que es la forma de decir que ya terminaste de
   escribir la entrada (para que el programa la
   pueda procesar).
*/
int main(int argc, char *argv[]) {
  if (argc > 1) {
    FILE *archivo = fopen(argv[1], "r");
    if (!archivo) {
      perror("Error al leer el archivo");
      return 1;
    }
    yyin = archivo;
  }

  yylex();

  if (argc > 1) {
    printf(" %lld %lld %lld %s\n", lineas, palabras, bytes, argv[1]);
  } else {
    printf(" %lld %lld %lld\n", lineas, palabras, bytes);
  }

  return 0;
}
