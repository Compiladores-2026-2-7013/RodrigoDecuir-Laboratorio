#ifndef PARSER_H
#define PARSER_H
#include <string>
#include "Lexer.hpp"
#include "Symbols.hpp"
using namespace std;

namespace C_1
{
  class Parser
  {

  private:
    Lexer *lexer;
    int token;

    void declaraciones();
    void declaraciones_prima();
    void declaracion();
    void tipo();
    void lista_var();
    void lista_var_prima();
    void sentencias();
    void sentencias_prima();
    void sentencia();
    void expresion();
    void expresion_prima();
    void termino();
    void termino_prima();
    void factor();

  public:
    Parser();
    Parser(Lexer *lexer);
    ~Parser();

    void programa(); //función del símbolo incial
    Token eat();
    void error(string msg);
    void parse();
  };

}


#endif
