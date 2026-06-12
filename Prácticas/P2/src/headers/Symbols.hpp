#ifndef __SYMBOLS_HPP__
#define __SYMBOLS_HPP__

/**
 * 1. Definir en un comentario la gramática G(N, T, P, S)
 *
 * N = { programa, declaraciones, declaraciones', sentencias, sentencias'
 * declaracion, tipo, lista_var, lista_var', sentencia, expresion, expresion',
 * termino, termino', factor }
 *
 * T = { indentificador, int, float, if, (, ), while, *, -, +, \, numero,
 * else, ;, ',', = }
 *
 * P = {
 *    programa -> declaraciones sentencias
 *    declaraciones -> declaracion declaraciones’
 *    declaraciones’ -> declaracion declaraciones’ | ϵ
 *    declaracion -> tipo lista-var ;
 *    tipo -> int | float
 *    lista var -> identificador lista var’
 *    lista var’ -> , identificador lista var’ | ϵ
 *    sentencias -> sentencia sentencias’
 *    sentencias’ -> sentencia sentencias’ | ϵ
 *    sentencia -> identificador = expresion;
 *    | if (expresion) sentencias else sentencias
 *    | while (expresión) sentencias
 *    expresion -> termino expresion’
 *    expresion’ -> + termino expresion’ | - termino expresion’ | ϵ
 *    termino -> factor termino’
 *    termino’ -> * factor termino’ | \ factor termino’ | ϵ
 *    factor -> identificador | numero | (expresion)
 * }
 *
 * S = { programa }
*/

/**
 * 2. Determinar la enumeración para el conjunto T
 */
enum Token { primero, t_eof, t_id, t_int, t_float, t_if, t_par_izq,
             t_par_der, t_while, t_mult, t_menos, t_mas, t_div,
             t_numero, t_else, t_punto_y_coma, t_coma, t_asig, t_error };

/**
 * 3. Determinar la enumeración para el conjunto N
 */
enum NoTerm { strEmpty, nt_programa, nt_declaraciones, nt_declaraciones_prima,
              nt_sentencias, nt_sentencias_prima, nt_declaracion, nt_tipo,
              nt_lista_var, nt_lista_var_prima, nt_sentencia, nt_expresion,
              nt_expresion_prima, nt_termino, nt_termino_prima, nt_factor };

#endif // !__SYMBOLS_HPP__
