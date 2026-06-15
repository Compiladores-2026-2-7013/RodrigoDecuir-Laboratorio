#ifndef __LEXER_HPP__
#define __LEXER_HPP__

#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "Parser.hpp"

namespace C1 {

  class Lexer : public yyFlexLexer {
  public:
    Lexer(std::istream& arg_yyin, std::ostream& arg_yyout)
      : yyFlexLexer(arg_yyin, arg_yyout) {};

    Lexer(std::istream* arg_yyin = nullptr, std::ostream* arg_yyout = nullptr)
      : yyFlexLexer(arg_yyin, arg_yyout) {};

    // 1.- Prototipo necesario para yylex(x) en Parser.cpp
    int lex(Parser::semantic_type *yylval);
  };

} // namespace C1

#endif /* __LEXER_HPP__ */
