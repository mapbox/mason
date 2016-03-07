#include <string>

#include <stdio.h>
#include <stdlib.h>

#define PRINT(name, version) printf("%s-%d\n", name, version);

int main(int argc, char *argv[]) {
  #ifdef _LIBCPP_VERSION
    PRINT("libcxx", _LIBCPP_ABI_VERSION)
  #elif __GLIBCXX__
    PRINT("libstdcxx", __GLIBCXX__)
  #endif

  exit(EXIT_SUCCESS);
}
