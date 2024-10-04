#include <stdio.h>
#include <time.h>

#define UNLIKELY(x)  __builtin_expect (!!(x), 0)

int do_tracking = 1;
int diff = 10;

int foo(int x, int y) {
    return x + y;
}

int bar(int x1, int x2, int x3, int x4, int x5, int x6, int x7, int x8, int x9 ) {
    return x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9;
}


void simulated_wrapper(int x, int y) {
  struct timespec start;
  if (UNLIKELY(do_tracking)) {
    timespec_get(&start, CLOCK_MONOTONIC);
  }

  // actual call
  foo(x, y);

  if (UNLIKELY(do_tracking)) {
    struct timespec end;
    timespec_get(&end, CLOCK_MONOTONIC);
    if (difftime(start.tv_sec,end.tv_sec) > diff) {
      fprintf(stderr, "long stuff");
    }
  }
}
