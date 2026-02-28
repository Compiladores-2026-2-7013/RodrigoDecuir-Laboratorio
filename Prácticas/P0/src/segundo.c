#include <stdio.h>
#include <stdlib.h>

#define ll long long
#define max(a,b) (a<b?b:a)
#define abs(x) (x<0?(-x):x)
#define FOR(i,a,b) for (int i = (a); i < (b); ++i)

/**
 * Compiladores 2026-2
 */
int main(void) {
  FOR(i,1,10) printf("-");
  printf("\nNúmero más grande entre abs(-1000000000000000000) y 3000000000000000000\n");
  FOR(i,1,10) printf("-");
  printf("\n");

  ll numero_negativo = -1000000000000000000LL;
  ll numero_positivo = 3000000000000000000LL;

  ll resultado = max(abs(numero_negativo), numero_positivo);
  printf("Resultado : %lld\n", resultado);
  return 0;
}
