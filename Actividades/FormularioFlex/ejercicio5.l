%{
#include <stdio.h>
#include <stdlib.h>

char tablero[3][3];
int filas = 0;
int columnas = 0;

void evaluar_tablero() {
    int gana_X = 0;
    int gana_O = 0;
    int espacios_vacios = 0;

    // filas...
    for (int i = 0; i < 3; i++) {
        if (tablero[i][0] == 'X' && tablero[i][1] == 'X' && tablero[i][2] == 'X') gana_X = 1;
        if (tablero[i][0] == '0' && tablero[i][1] == '0' && tablero[i][2] == '0') gana_O = 1;

        for (int j = 0; j < 3; j++) {
            if (tablero[i][j] == '_') espacios_vacios++;
        }
    }

    // columnas...
    for (int j = 0; j < 3; j++) {
        if (tablero[0][j] == 'X' && tablero[1][j] == 'X' && tablero[2][j] == 'X') gana_X = 1;
        if (tablero[0][j] == '0' && tablero[1][j] == '0' && tablero[2][j] == '0') gana_O = 1;
    }

    // diagonales...
    if (tablero[0][0] == 'X' && tablero[1][1] == 'X' && tablero[2][2] == 'X') gana_X = 1;
    if (tablero[0][2] == 'X' && tablero[1][1] == 'X' && tablero[2][0] == 'X') gana_X = 1;

    if (tablero[0][0] == '0' && tablero[1][1] == '0' && tablero[2][2] == '0') gana_O = 1;
    if (tablero[0][2] == '0' && tablero[1][1] == '0' && tablero[2][0] == '0') gana_O = 1;

    if (gana_X) {
        printf("gana X\n");
    } else if (gana_O) {
        printf("gana 0\n");
    } else if (espacios_vacios == 0) {
        printf("empate\n");
    } else {
        printf("sin ganador\n");
    }
}
%}

%%

[X0_] {
        if (filas < 3) {
            tablero[filas][columnas] = yytext[0];
            columnas++;

            if (columnas == 3) {
                columnas = 0;
                filas++;
                if (filas == 3) {
                    evaluar_tablero();
                    filas = 0;
                }
            }
        }
      }
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
        printf("Ingresa una cuadrícula de 3x3 usando X, 0 y _ (Finaliza con Ctrl+D):\n");
    }

    yylex();
    return 0;
}
