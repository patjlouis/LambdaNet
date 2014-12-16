module Linear
( Matrix
, RandomTransform

, rows
, cols
, dot
, mult
, hadamard
, transpose
, scalar
, combine
, reshape
, randomList
, boxMuller
, normals
, uniforms
) where

import System.Random

type Vector a = [a]
type Matrix a = [[a]]

rows :: (Num a) => Matrix a -> Int
rows = length . head

cols :: (Num a) => Matrix a -> Int
cols = length

dot :: (Num a) => Vector a -> Vector a -> a
dot u v = sum $ zipWith (*) u v

-- matrix multiplication m * n
mult :: (Num a) => Matrix a -> Matrix a -> Matrix a
mult [] n = []
mult m n = map (dot (head m)) (transpose n) : mult (drop 1 m) n

hadamard :: (Num a) => Matrix a -> Matrix a -> Matrix a
hadamard m n = zipWith (zipWith (*)) m n

-- Lovingly ripped from Data.List, type signature adjusted
transpose :: (Num a) => Matrix a -> Matrix a
transpose [] = []
transpose ([]: xss) = transpose xss
transpose ((x:xs) : xss) = (x : [h | (h:_) <- xss]) : transpose (xs : [ t | (_:t) <- xss])

scalar :: (Num a) => Matrix a -> a -> Matrix a
scalar mat n = map (map (* n)) mat

combine:: (Num a) => Matrix a -> Matrix a -> Matrix a
combine m n = if (cols m == cols n) 
               then zipWith (++) m n 
               else if (rows m == rows n) 
                      then m ++ n
                      else m
-- parameters
--   j is the number of columns of the resulting matrix
-- returns
--   i by j matrix where i is length of list / j
reshape :: (Num a) => Int -> [a] -> Matrix a
reshape j [] = []
reshape j list = [(take j list)] ++ reshape j (drop j list)

-- Random Transformations

type RandomTransform a = [a] -> [a]

-- Initialize an infinite random list list with:
randomList :: (RandomGen g, Random a, Floating a) => RandomTransform a -> g -> [a]
randomList transform = transform . randoms

-- Define a transformation on the uniform distribution to generate
-- normally distributed numbers in Haskell (the Box-Muller transform)
boxMuller :: Floating a => a -> a -> (a, a)
boxMuller x1 x2 = (z1, z2) where z1 = sqrt ((-2) * log x1) * cos (2 * pi * x2)
                                 z2 = sqrt ((-2) * log x1) * sin (2 * pi * x2)

-- Apply the Box-Muller transform
normals :: Floating a => [a] -> [a]
normals (x1:x2:xs) = z1:z2:(normals xs) where (z1, z2) = boxMuller x1 x2
normals _ = []

uniforms :: Floating a => [a] -> [a]
uniforms xs = xs
