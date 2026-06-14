#include <stdio.h>

extern int add(int a, int b);

int main(void)
{
    int a = 10;
    int b = 20;
    int res = add(a, b);
    printf("%d + %d = %d\n", a, b, res);
}
