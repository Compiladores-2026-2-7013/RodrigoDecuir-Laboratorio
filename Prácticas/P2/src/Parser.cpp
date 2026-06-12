#include "headers/Parser.hpp"
#include <iostream>

namespace C_1
{
  Parser::Parser(/* args */)
  {
  }

  Parser::Parser(Lexer *lexer)
  {
    this->lexer = lexer;
  }

  Parser::~Parser()
  {
  }

  void Parser::programa(){
    declaraciones();
    sentencias();
  }

  /************************************************************************/
  /**                                                                    **/
  /**                       Funciones por cada NT                        **/
  /**                                                                    **/
  /************************************************************************/


  Token Parser::eat(){
    return (Token) lexer->yylex();
  }

  void Parser::error(string msg){
    cout << "ERROR DE SINTAXIS " << msg << " en la línea "<< lexer->getLine() <<endl;
  }

  void Parser::parse(){
    token = eat();
    programa();
    if(token == 0)
      cout << "La cadena es aceptada" << endl;
    else
      cout << "La cadena no pertenece al lenguaje generado por la gramática" << endl;
  }

  /**
   * declaraciones -> declaracion declaraciones'
   *
   * FIRST(declaracion) = { int, float }
   */
  void Parser::declaraciones()
  {
    declaracion();
    declaraciones_prima();
  }

  /**
   * declaraciones' -> declaracion declaraciones' | ε
   *
   * Se repite mientras el token actual sea int o float.
   */
  void Parser::declaraciones_prima()
  {
    if (token == t_int || token == t_float)
    {
      declaracion();
      declaraciones_prima();
    }
    // ε : no hacer nada
  }

  /**
   * declaracion -> tipo lista_var ;
   */
  void Parser::declaracion()
  {
    tipo();
    lista_var();
    if (token == t_punto_y_coma)
      token = eat();
    else
      error("se esperaba ';' al final de la declaración");
  }

  /**
   * tipo -> int | float
   */
  void Parser::tipo()
  {
    if (token == t_int)
      token = eat();
    else if (token == t_float)
      token = eat();
    else
      error("se esperaba 'int' o 'float'");
  }

  /**
   * lista_var -> identificador lista_var'
   */
  void Parser::lista_var()
  {
    if (token == t_id)
      token = eat();
    else
      error("se esperaba un identificador en la lista de variables");
    lista_var_prima();
  }

  /**
   * lista_var' -> , identificador lista_var' | ε
   *
   * Se repite mientras el token actual sea ','.
   */
  void Parser::lista_var_prima()
  {
    if (token == t_coma)
    {
      token = eat(); // consume ','
      if (token == t_id)
        token = eat();
      else
        error("se esperaba un identificador después de ','");
      lista_var_prima();
    }
    // ε : no hacer nada
  }

  /**
   * sentencias -> sentencia sentencias'
   *
   * FIRST(sentencia) = { identificador, if, while }
   */
  void Parser::sentencias()
  {
    sentencia();
    sentencias_prima();
  }

  /**
   * sentencias' -> sentencia sentencias' | ε
   *
   * Se repite mientras el token actual pueda iniciar una sentencia.
   */
  void Parser::sentencias_prima()
  {
    if (token == t_id || token == t_if || token == t_while)
    {
      sentencia();
      sentencias_prima();
    }
    // ε : no hacer nada
  }

  /**
   * sentencia -> identificador = expresion ;
   *            | if ( expresion ) sentencias else sentencias
   *            | while ( expresion ) sentencias
   */
  void Parser::sentencia()
  {
    if (token == t_id)
    {
      /* identificador = expresion ; */
      token = eat(); // consume identificador
      if (token == t_asig)
        token = eat(); // consume '='
      else
        error("se esperaba '=' después del identificador");
      expresion();
      if (token == t_punto_y_coma)
        token = eat(); // consume ';'
      else
        error("se esperaba ';' al final de la asignación");
    }
    else if (token == t_if)
    {
      /* if ( expresion ) sentencias else sentencias */
      token = eat(); // consume 'if'
      if (token == t_par_izq)
        token = eat(); // consume '('
      else
        error("se esperaba '(' después de 'if'");
      expresion();
      if (token == t_par_der)
        token = eat(); // consume ')'
      else
        error("se esperaba ')' después de la expresión en 'if'");
      sentencias();
      if (token == t_else)
        token = eat(); // consume 'else'
      else
        error("se esperaba 'else'");
      sentencias();
    }
    else if (token == t_while)
    {
      /* while ( expresion ) sentencias */
      token = eat(); // consume 'while'
      if (token == t_par_izq)
        token = eat(); // consume '('
      else
        error("se esperaba '(' después de 'while'");
      expresion();
      if (token == t_par_der)
        token = eat(); // consume ')'
      else
        error("se esperaba ')' después de la expresión en 'while'");
      sentencias();
    }
    else
    {
      error("se esperaba una sentencia (identificador, 'if' o 'while')");
    }
  }

  /**
   * expresion -> termino expresion'
   */
  void Parser::expresion()
  {
    termino();
    expresion_prima();
  }

  /**
   * expresion' -> + termino expresion' | - termino expresion' | ε
   */
  void Parser::expresion_prima()
  {
    if (token == t_mas)
    {
      token = eat(); // consume '+'
      termino();
      expresion_prima();
    }
    else if (token == t_menos)
    {
      token = eat(); // consume '-'
      termino();
      expresion_prima();
    }
    // ε : no hacer nada
  }

  /**
   * termino -> factor termino'
   */
  void Parser::termino()
  {
    factor();
    termino_prima();
  }

  /**
   * termino' -> * factor termino' | \ factor termino' | ε
   */
  void Parser::termino_prima()
  {
    if (token == t_mult)
    {
      token = eat(); // consume '*'
      factor();
      termino_prima();
    }
    else if (token == t_div)
    {
      token = eat(); // consume '\'
      factor();
      termino_prima();
    }
    // ε : no hacer nada
  }

  /**
   * factor -> identificador | numero | ( expresion )
   */
  void Parser::factor()
  {
    if (token == t_id)
    {
      token = eat(); // consume identificador
    }
    else if (token == t_numero)
    {
      token = eat(); // consume numero
    }
    else if (token == t_par_izq)
    {
      token = eat(); // consume '('
      expresion();
      if (token == t_par_der)
        token = eat(); // consume ')'
      else
        error("se esperaba ')' para cerrar la expresión");
    }
    else
    {
      error("se esperaba un factor: identificador, número o '('");
    }
  }

}
