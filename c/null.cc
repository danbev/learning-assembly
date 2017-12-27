// $ clang++ -c null.cc -std=c++11
extern "C" {
  int* something = nullptr;
}

int main(int argc, char** argv) {
  int* one = nullptr;
  return 0;
}
