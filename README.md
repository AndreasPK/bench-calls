# What is the overhead of using safe vs unsafe ffi calls:

unsafe ffi calls have to main properties:
* The ability to induce grey hairs in the users when the RTS get's locked
up for reasons not immediatly obvious after a refactor.
* They are faster.

This repo contains a micro benchmark measuring the overhead of using
safe ffi calls to allow a more informed decision on this point.

## Results:

This was measured on a `Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz` with unknown RAM timings.

benchmarking 1.1:minimal safe call overhead
time                 90.66 ns   (90.44 ns .. 90.91 ns)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 90.51 ns   (90.24 ns .. 90.73 ns)
std dev              797.9 ps   (644.4 ps .. 1.050 ns)

benchmarking 1.2:minimal unsafe call overhead
time                 6.907 ns   (6.894 ns .. 6.921 ns)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 6.903 ns   (6.897 ns .. 6.912 ns)
std dev              22.56 ps   (16.66 ps .. 30.71 ps)

benchmarking 2.1:something safe call overhead
time                 96.30 ns   (96.05 ns .. 96.61 ns)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 96.09 ns   (96.02 ns .. 96.29 ns)
std dev              363.1 ps   (156.2 ps .. 690.9 ps)

benchmarking 2.2:something unsafe call overhead
time                 10.47 ns   (10.46 ns .. 10.47 ns)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 10.46 ns   (10.46 ns .. 10.47 ns)
std dev              5.920 ps   (2.316 ps .. 11.69 ps)

## What does this mean?

The raw overhead of unsafe calls is less then 40 cycles/10ns which is *fast*.

The overhead of safe calls clocks in somewhere in the 300-400 cycle range which
while still fast can be enough to warrant use of unsafe calls in some cases.

The `something` benchmark shows that even a trivial amount of work already makes
a significant impact on runtime compared to call overhead.

Any C call with expected runtime that can be measured in us should just use safe
calls to avoid headaches in the future as the overhead from safe will already no
longer matter at this point.