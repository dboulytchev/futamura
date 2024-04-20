# include <stdio.h>

int p (int n, int k) {
  int r = 1;

  while (k) {
    r *= k % 2 ? n : 1;
    n *= n;
    k /= 2;
  }

  return r;
}

int main (int argc, char *argv[]) {
  for (int i = 0; i < 12; i++)
    printf ("3^%d=%d\n", i, p (3, i));

  return 0;
}
