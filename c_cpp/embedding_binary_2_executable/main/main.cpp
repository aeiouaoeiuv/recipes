#include <iostream>

#ifdef __cplusplus
extern "C" {
#endif
extern const char _binary_test_png_end[];
extern const int  _binary_test_png_size;
extern const char _binary_test_png_start[];
#ifdef __cplusplus
}
#endif

int main(int argc, char *argv[]) {
    std::cout << "png size: " << _binary_test_png_end - _binary_test_png_start << std::endl;

    return 0;
}
