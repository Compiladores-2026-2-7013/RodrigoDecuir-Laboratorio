%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int n_lineas = 1;

int verificar_extension(const char *nombre_archivo, const char *extension) {
    const char *punto = strrchr(nombre_archivo, '.');
    return (punto && strcmp(punto, extension) == 0);
}
%}

ENTERO          [0-9]+
REAL            [0-9]+\.[0-9]+
IDENTIFICADOR   [a-zA-Z_][a-zA-Z0-9_]*
CADENA          \"([^\"\\\n]|\\.)*\"
OP_ARITMETICO   "+"|"-"|"*"|"/"|"%"
OP_RELACIONAL   ">"|"<"|"<>"|"="
OP_ASIGNACION   ":="
SIMB_ESPECIAL   "("|")"|"{"|"}"|";"|","
ESPACIOS        [ \t\r]+

%%

{ESPACIOS} { }
\n { n_lineas++; }
"--"[^\n]* { }
"<*" {
        int c;
        while ((c = input()) != 0) {
        if (c == '\n') {
          n_lineas++;
        } else if (c == '*') {
          if ((c = input()) == '>') break;
            unput(c);
          }
        }
      }

"if"|"then"|"else"|"while"|"do"|"case"|"is"|"void"|"true"|"false"|"begin"|"end"|"not" {
  fprintf(yyout, "<palabra_reservada, %s>\n", yytext);
}

{IDENTIFICADOR} { fprintf(yyout, "<identificador, %s>\n", yytext); }
{REAL}          { fprintf(yyout, "<numero_real, %s>\n", yytext); }
{ENTERO}        { fprintf(yyout, "<numero_entero, %s>\n", yytext); }
{CADENA}        { fprintf(yyout, "<cadena_caracteres, %s>\n", yytext); }
{OP_ASIGNACION} { fprintf(yyout, "<op_asignacion, %s>\n", yytext); }
{OP_RELACIONAL} { fprintf(yyout, "<op_relacional, %s>\n", yytext); }
{OP_ARITMETICO} { fprintf(yyout, "<op_aritmetico, %s>\n", yytext); }
{SIMB_ESPECIAL} { fprintf(yyout, "<simbolo_especial, %s>\n", yytext); }
. { fprintf(stderr, "Error léxico: Carácter inválido '%s' en la línea %d\n", yytext, n_lineas); }

%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Uso correcto: %s <archivo_entrada.art> <archivo_salida.tokens>\n", argv[0]);
        return 1;
    }

    if (!verificar_extension(argv[1], ".art")) {
        fprintf(stderr, "Error: El archivo de entrada debe tener la extensión '.art'\n");
        return 1;
    }

    if (!verificar_extension(argv[2], ".tokens")) {
        fprintf(stderr, "Error: El archivo de salida debe tener la extensión '.tokens'\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error al abrir el archivo de entrada");
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
