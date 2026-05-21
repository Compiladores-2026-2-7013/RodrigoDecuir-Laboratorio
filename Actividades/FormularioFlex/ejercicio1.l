%{
#include <stdio.h>
#include <stdbool.h>
bool foo = true;
%}

%option yylineno

%%

^. {
  if (foo) {
    printf("%d ", yylineno);
    foo = false;
  }
  ECHO;
}

\n {
  ECHO;
  foo = true;
}

. {
  ECHO;
}

%%

int yywrap() {
  return 1;
}

int main(int argc, char **argv) {
  if (argc > 1) {
    FILE *f = fopen(argv[1], "r");
    if (f == NULL) {
      perror("Error al leer el archivo.");
      return 1;
    }
    yyin = f;
  }

  yylex();
  return 0;
}
