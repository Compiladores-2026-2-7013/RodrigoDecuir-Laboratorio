%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void procesar_linea(char *linea) {
    int longitud = strlen(linea);

    while (longitud > 0 && (linea[longitud - 1] == '\n' || linea[longitud - 1] == '\r')) {
        longitud--;
    }

    if (longitud > 0) {
        char tipo = linea[longitud - 1];

        if (tipo == 'A') {
            long long suma = 0;
            char *token = strtok(linea, " \t");

            while (token != NULL) {
                if (strcmp(token, "A") != 0 && strcmp(token, "A\n") != 0 && strcmp(token, "A\r\n") != 0) {
                    suma += atoll(token);
                }
                token = strtok(NULL, " \t");
            }
            printf("%lld\n", suma);

        } else if (tipo == 'B') {
            printf("%s", linea);
            if (linea[strlen(linea) - 1] != '\n') {
                printf("\n");
            }
        }
    }
}
%}

LINEA ^[^\n]*[AB]\n?

%%

{LINEA}  { procesar_linea(yytext); }
\n { }
. { }

%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al leer el archivo");
            return 1;
        }
    } else {
        printf("Ingresa las líneas de números enteros separados por espacios (Termina con Ctrl+D):\n");
    }

    yylex();
    return 0;
}
