<p  align="center">
  <img  width="200"  src="https://www.fciencias.unam.mx/sites/default/files/logoFC_2.png"  alt="">  <br>Compiladores  2026-2 <br>
  Práctica 4: Analizadores sintácticos con Yacc/Bison <br> Profesora: Ariel Adara Mercado Martínez
</p>

### Objetivos:
1. Aprender a definir una gramática en _Yacc/Bison_.
2. Implementar una gramática con _Yacc/Bison_.
3. Unir un programa generado con _Lex/Flex_ y el programa generado con _Yacc/Bison_.

### Introducción:
* _Yacc_ es un generador de analizadores sintácticos del tipo ascendente, especı́ficamente __LALR(1)__.
* Bison es la versión *GNU* de _Yacc_.
  1. Es compatible con yacc.
  2. Mejora algunas de las presentaciones de yacc.
* Generalmente _Yacc/Bison_ se utilizan en conjunto con _Lex/Flex_
  1. Lex/Flex genera un analizador léxico: ```yylex()```
  2. Yacc/Bison genera el analizador sintáctico: ```yyparse()```


### Estructura de un archivo en Bison

```
%{
  Declaraciones en C++
%}
Declaraciones en Yacc
%%
Sección de Gramática
%%
Código en C++
```

#### Sección de declaraciones en C++
1. Definiciones de macros.  
2. Declaraciones de variables.  
3. Declaraciones de funciones.  
4. Directivas de preprocesamiento.

#### Sección de declaraciones en Yacc

1. El tipo de la variable ```yylval``` (_lexical value_). Dicha variable está relacionda con los tokens que generan las llamadas a ```yylex()``` y los símbolos de la gramática. 

```c++
%union {
  char *sval;
  char ival;
}
```
2. Los terminales ```%token[<campo_union>] <lista_terminales>```
```yacc
%token<sval> ID
%token<ival> ENTERO
%token IF ELSE
```

3. Los no terminales ```%type[<campo_union>] <lista_no_terminales>```. Generalmente los no terminales no se declaran a no ser que requieran de un tipo. 
```yacc
%type<sval> expresion termino factor
```

4. El símbolo inicial ```%start S```
```yacc
%start expresion
```
5. La asociatividad y precedencia de los operadores (%left, %right, %nonassoc). La precedencia de menor a mayor.
```yacc
%left MAS
%left MUL
%nonassoc LPAR RPAR
```

#### Sección de gramática 
1. Utiliza la notación BNF simplificada
```yacc

/* Una sola regla */
simboloNoTerminal : simb1 [{acción}] sim2 [{acción}] ... [{acción}] simN [{acción}] ;

/* Varias reglas */
simboloNoTerminal : regla 1 [{acción 1}] ;
                  | regla 2 [{acción 1}] ;
                  ...
                  | regla N [{accion N}] 
                  ;

/* Regla vacía */
simboloNoTerminal : /* vacío */ [{acción}] ;
                  | %empty [{acción}]
                  ;           
```


2. Acciones
  a. Se escriben usando código en lenguage _C++_.
  b. Para hacer referencia a los símbolos gramaticales, se utilizan pseudovariables: ```$1```, ```$2```,...,```$$```
  c. ```$$``` representa el encabezado de la produccióna.
  d. ```$1``` representa el primer símbolo gramatical del lado derecho de la producción, $2 representa el segundo y así sucesivamente. 


#### Sección de código en C++
Hay tres funciones que eben siempre aparecer:
1. ```main``` función principal que invoca la función de análisis sintáctico. 
2. ```yylex``` función invocada desde el analizador sintáctico para obtener un nuevo _token_.
3. ```error``` función invocadad desde el analizador sintáctico cuando ocurre un error.



### Ejemplo: Una calculadora escrita en Flex, Bison y C++
<details>
  <summary>Haz click para ver el ejemplo</summary>
	
* ```lexer.ll```
	
```lex
%{
#include <sstream>
#include <cstdlib>

#include "Parser.hpp"
#include "Lexer.hpp"

using namespace std;

#undef YY_DECL // Buena práctica
#define YY_DECL int calc::Lexer::lex(calc::Parser::semantic_type *yylval) // Referencia a 1 en Lexer.hpp
%}

%option c++
%option noyywrap
%option outfile="Lexer.cpp"
%option yyclass="Lexer"


DIG [0-9]
WSPC [ \t]+

%%


"+"	{
	 cout << "Terminal + detectado" << endl;	
	 return Parser::token::MAS;
	}

"*"	{
	 cout << "Terminal * detectado" << endl;	
	 return Parser::token::MUL;
	}

"("	{
	 cout << "Terminal ( detectado" << endl;	
	 return Parser::token::PARIZQ;
	}

")"	{
	 cout << "Terminal ) detectado" << endl;	
	 return Parser::token::PARDER;
	}

{DIG}+	{
	 cout << "Terminal numérico " << yytext << " detectado" << endl;
	 yylval->numero.ival = atoi(yytext);
	 yylval->numero.tipo = 1; /* 1: Entero, 2: Flotante */
	 return Parser::token::NUM;
	}

{WSPC}  { /* Ignoramos espacios en blanco */ }

.	{
	  cout << "Error léxico en la línea: " << yylineno << endl;
	}


<<EOF>> {	
         yyterminate();
        }


%%

```
* ```calculadora.yy```
```yacc
%{
#include <iostream>
#include <fstream>
#include <string>
#include <FlexLexer.h>
using namespace std;
%}

%language "C++"
%require "3.2"
%defines "Parser.hpp"
%output "Parser.cpp"
 
%define api.parser.class {Parser}
%define api.namespace {calc}
%parse-param {Lexer* lexer}

%code requires
{
    namespace calc {
        class Lexer;
    } // namespace calc
} // %code requires
 
%code
{
 #include "Lexer.hpp"
 #define yylex(x) lexer->lex(x) // Referencia a 1 en Lexer.hpp
}

%union {
  struct { //declarado para manejar los tipos de número posibles: 1.- entero, 2.- flotante.
    int ival; //valor 
    int tipo;
  } numero;
}

%token<numero> NUM

%left MAS
%left MUL

%nonassoc PARIZQ
%nonassoc PARDER

%type<numero> expresion

%start line

%%

line: expresion { cout << "Análisis léxico y sintáctico terminado.\nEl valor de la expresión ya evaluada es: " << $1.ival << endl; };

expresion : expresion MAS expresion { $$.ival = $1.ival + $3.ival; };
	  | expresion MUL expresion { $$.ival = $1.ival * $3.ival; };
	  | PARIZQ expresion PARDER { $$ = $2; };
	  | NUM { $$ = $1; };

%%

void calc::Parser::error(const std::string& msg) {
    std::cerr << msg << '\n';
}


#include <iostream>
#include <string>
#include <fstream>

int main(int argc, char *argv[]){
    if(argc < 2){
        cout<<"Faltan argumentos "<<endl;
        return EXIT_FAILURE;
    }
    filebuf fb;
    fb.open(string(argv[1]), ios::in);
    istream in(&fb);
    calc::Lexer lexer(&in);
    calc::Parser parser(&lexer);
    parser.parse();
    fb.close();
    return 0;
    /*
    calc::Lexer scanner{ std::cin, std::cerr };
    calc::Parser parser{ &scanner };
    //std::cout.precision(10);
    parser.parse();*/
}

```


* ```Lexer.hpp```
```c++
#ifndef __LEXER_HPP__
#define __LEXER_HPP__

#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

namespace calc { 
 
  class Lexer : public yyFlexLexer {
  public:
    Lexer(std::istream& arg_yyin, std::ostream& arg_yyout):
      yyFlexLexer(arg_yyin, arg_yyout) {};
    
    Lexer(std::istream* arg_yyin = nullptr, std::ostream* arg_yyout = nullptr):
      yyFlexLexer(arg_yyin, arg_yyout) {};
    
    int lex(Parser::semantic_type *yylval); // 1.- Este prototipo es necesario para el uso de yylex(x) en Parser.cpp
  };
 
} // namespace calc


#endif /* __LEXER_HPP__ */

```
	
</details>

#### Compilación
  1. ```flex++ lexer.ll```
  2. ```bison calculadora.yy```
  3. ```g++ Parser.cpp Lexer.cpp -o calculadora```

#### Ejecución
  * ```./calculadora prueba```
	
	
### Ejercicios
1. Modificar el código fuente para que la calculadora pueda operar con flotantes, no solamente enteros. 
2. Modificar el código fuente para que la calculadora pueda reconocer más líneas con expresiones en el archivo de entrada.
3. Modificar el código fuente para que la calculadora pueda operar con restas y divisiones.
4. Modificar el código fuente para que la calculadora admita números negativos.

#### Para la gramática G = ( N, Σ, P, S), descrita por las siguientes producciones: 
> P = {
>> programa → declaraciones sentencias <br>
>> declaraciones → declaraciones declaracion | declaracion <br>
>> declaracion → tipo lista-var **;** <br>
>> tipo → **int** | **float** <br>
>> lista_var → lista_var **,** _**identificador**_ | _**identificador**_ <br>
>> sentencias → sentencias sentencia | sentencia <br>
>> sentencia → _**identificador**_ **=** expresion **;** | **if** **(** expresion **)** **{** sentencias **}** **else** **{** sentencias **}** | **while** **(** expresión **)** **{** sentencias **}** <br>
>> expresion → expresion **+** expresion | expresion **-** expresion | expresion __\*__ expresion | expresion **/** expresión | _**identificador**_ | **_numero_** <br>
>> expresion → **(** expresion **)** <br>
}
<br>

3. Crear una carpeta llamada C_1 para alojar el analizador léxico y el analizador sintáctico de dicha gramática. <br>
    a. Basándose en la estructura del código de la calculadora, transcribir el archivo de Flex de la práctica 2 en un archivo de Flex. <br>
    b. Escribir en un archivo de Bison la gramática definida. <br>
    c. Proponer un mensaje de error sintáctico más explícito. <br>
    d. Proponer archivos de prueba con derivaciones válidas. <br>
	
	
#### Extras

13. Documentar el código.
14. Proponer 4 archivos de prueba nuevos, 2 válidos y 2 inválidos.

#### Estructura del directorio
```c++
p5
├── ejemplo
│   └── src
│       ├── calculadora.yy
│       ├── Lexer.hpp
│       ├── lexer.ll
│       └── prueba
└── README.md
```





