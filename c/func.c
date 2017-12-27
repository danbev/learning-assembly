// clang -g -o func func.c
int doit(int i) {
  return i;
}

int main(int argc, char** argv) {
  int i = doit(6);
}
