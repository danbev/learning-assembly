// CFLAGS="-g -o0
// clang -g -O0 while.c -o while
int main() {
    bool flag = true;
    int a = 5;
    do {
        if (a == 5) {
            flag = false;
        }
        a++;
    } while(flag == true);
    return 0;
}
