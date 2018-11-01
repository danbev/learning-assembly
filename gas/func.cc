#include <iostream>
extern "C" int dot(int x);

int main(int argc, char** argv) {
  int ret = dot(10);
  std::cout << ret << '\n';
  return 0;
}
