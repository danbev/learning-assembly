#include <stdio.h>

void return_input (void) {
   char array[30];
   gets (array);
   printf("%s\n", array);
}

int main() {
   return_input();
   return 0;
}
