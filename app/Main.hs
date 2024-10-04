{-# LANGUAGE MagicHash #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE UnliftedFFITypes #-}

{-# OPTIONS_GHC -fproc-alignment=64 #-}
-- {-# OPTIONS_GHC -dumpdir dumps -ddump-stg -ddump-to-file -ddump-cmm #-}


module Main where

import Criterion.Main
import GHC.Exts

foreign import ccall unsafe "foo" u_foo :: Int# -> Int# -> Int#
foreign import ccall safe   "foo" s_foo :: Int# -> Int# -> Int#
foreign import ccall unsafe   "simulated_wrapper" u_foo_wrapper :: Int# -> Int# -> Int#

bench_min_safe :: Int -> Int
bench_min_safe (I# x) = I# (s_foo x 1#)
bench_min_unsafe :: Int -> Int
bench_min_unsafe (I# x) = I# (u_foo x 1#)

bench_min_unsafe_wrapper :: Int -> Int
bench_min_unsafe_wrapper (I# x) = I# (u_foo_wrapper x 1#)

foreign import ccall unsafe "bar" u_bar :: Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int#
foreign import ccall safe   "bar" s_bar :: Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int# -> Int#

{-# NOINLINE bench_something_safe #-}
bench_something_safe :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int
bench_something_safe (I# x1) (I# x2) (I# x3) (I# x4) (I# x5) (I# x6) (I# x7) (I# x8) (I# x9) =
     case (s_bar x1 x2 x3 x4 x5 x6 x7 x8 x9) of
        r -> I# (r +# x1 +# x2 +# x3 +# x4 +# x5 +# x6 +# x7 +# x8 +# x9)

{-# NOINLINE bench_something_unsafe #-}
bench_something_unsafe :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int
bench_something_unsafe (I# x1) (I# x2) (I# x3) (I# x4) (I# x5) (I# x6) (I# x7) (I# x8) (I# x9) =
     case (u_bar x1 x2 x3 x4 x5 x6 x7 x8 x9) of
        r -> I# (r +# x1 +# x2 +# x3 +# x4 +# x5 +# x6 +# x7 +# x8 +# x9)


-- Our benchmark harness.
main :: IO ()
main = defaultMain
    [ bench "1.1:minimal safe call overhead"  $ whnf bench_min_safe 1
    , bench "1.2:minimal unsafe call overhead"  $ whnf bench_min_unsafe 2

    , bench "1.3:minimal unsafe wrapper call overhead"  $ whnf bench_min_unsafe_wrapper 2

    , bench "2.1:something safe call overhead"  $ whnf (bench_something_safe 1 2 3 4 5 6 7 8) 1
    , bench "2.2:something unsafe call overhead"  $ whnf (bench_something_unsafe 1 2 3 4 5 6 7 8) 1

    -- optionally run them twice if you are paranoid:
    -- , bench "1.2:minimal safe call overhead"  $ whnf bench_min_safe 1
    -- , bench "2.2:minimal unsafe call overhead"  $ whnf bench_min_unsafe 1

  ]