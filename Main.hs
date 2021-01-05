module Main where

import Text.CSV (parseCSVFromFile, Record)
import Data.Either.Combinators (fromRight')
import Data.List.Split (splitOn)
import System.Environment (getArgs)
import Statistics.LinearRegression (linearRegression)
import Data.Vector.Unboxed (fromList)
import Control.Monad (join, liftM2)
import Data.Bifunctor (bimap)
import Control.Monad.Logic (interleave)
--import Data.Data (constrFields, toConstr)
import Data.List.Grouping (splitEvery)
import TupleTranspose (transpose)

data Input = Input {
    preload :: Double,
    gaugeLength :: Double,
    diameter :: Double,
    slopeDeviation :: Double,
    fileLocation :: FilePath
} deriving (Show)

data Model = Model {
    youngsModulus :: Double,
    tensileStrength :: Double,
    energyCapacity :: Double
}

instance Show Model where 
    show (Model youngsModulus energyCapacity tensileStrength) = 
        show "Young's Modulus:" ++ show youngsModulus ++ "\n" ++
        show "Elastic Energy Capacity:" ++ show energyCapacity ++ "\n" ++
        show "Tensile Strength:" ++ show tensileStrength ++ "\n"

--These functions parse the input and set up the values to be used by the rest of the functions

parseArguments :: [String] -> Input
parseArguments ls = Input {
    preload = read.(!!0) $ ls,
    gaugeLength = read.(!!1) $ ls,
    diameter = read.(!!2) $ ls,
    slopeDeviation = read.(!!3) $ ls,
    fileLocation = (ls!!4)
}

takeInput :: IO Input
takeInput = fmap parseArguments getArgs

importCSV :: Input -> IO [Record]
importCSV = fmap (init . drop 2 . fromRight') . parseCSVFromFile . fileLocation

--Converts Strings into Doubles that might be in scientific notation

fromSci :: String -> Double
fromSci t 
    | (elem 'E') t = (\ld -> (ld!!0)*(10)**(ld!!1)) $ 
        Prelude.map (read) $ splitOn "E" t :: Double
    | (== "") t = 0
    | otherwise = read t :: Double

--Creates a list of tuples of the Force vs. Elongation series from the CSV data; it also removes data before force was applied, and after the sample breaks
type Force = Double
type Elongation = Double

positionAndForce :: [Record] -> [(Elongation, Force)]
positionAndForce = (map (\x -> (fromSci.(!!2) $ x , fromSci.(!!3) $ x))).(filter')

filter' :: [[String]] -> [[String]]
filter' = filter $ liftM2 (&&) ((>0).fromSci.(!!3)) ((>0).fromSci.(!!2))

--Given the diamater of the test sample, the pre-load force and a data point it produces an engineering stress value
type Stress = Double

engineeringStress :: Input -> (Elongation, Force) -> Stress
engineeringStress i fe = (4*(snd fe + preload i))/(pi*(diameter i)^2)

--Given a data point and the gaugeLength length it produces the engineering strain
type Strain = Double

engineeringStrain :: Input -> (Elongation, Force) -> Strain
engineeringStrain = flip ((/) . fst) . gaugeLength

stressStrainSeries :: Input -> [(Elongation, Force)] -> [(Strain,Stress)]
stressStrainSeries i = map (\x -> (engineeringStrain i x, engineeringStress i x))

--Given a series of data points this function calculates the area underneath it using LH riemman sums
type Area = Double

--If I'm allowed to have a favorite function area is it, it combines all the coolest functions I know as well as my own function; calculating the area under a curve in one line, it's pretty fucking awesome.

area :: [(Double, Double)] -> Area
area = sum.map (product.map (abs.uncurry (-))).splitEvery 2.transpose.liftM2 interleave init tail

--Given a data series and an deviation tolerance this function produces a subset of that series that is determined to have a linear relationship to eachother

linearSeries :: Input -> [(Elongation, Force)] -> [(Elongation, Force)]
linearSeries i lef = filter (( < slopeDeviation i).(percentDiff lef).slope) lef
    where
        slope = uncurry (flip (/))
        initSlope = slope . head
        percentDiff x ls = flip (/) (initSlope x) $ (subtract $ initSlope x) ls

--Given the linear series as an input this function produces Young's Modulus and the error value associated with the slope : (YM, Error)
--This function works in two passes, first to convert the tuple to a tuple of arrays, then again to convert the arrays to vectors. I should replace this with a single pass function.

trendLineSlope :: [(Double,Double)] -> (Double, Double)
trendLineSlope = uncurry linearRegression . join bimap fromList . unzip

--Young's Modulus

eM :: Input -> IO Double
eM i = fmap (fst.trendLineSlope.stressStrainSeries i.linearSeries i.positionAndForce) $ importCSV i

--Tensile Strength

tS :: Input -> IO Stress
tS i = fmap (maximum.snd.unzip.stressStrainSeries i.positionAndForce) $ importCSV i

--Energy capacity

eC :: Input -> IO Area
eC i = fmap (area.linearSeries i.positionAndForce) $ importCSV i

main :: IO ()
main = do
    input <- takeInput
    ym <- eM input
    ts <- tS input
    ec <- eC input

    print $ model ym ts ec
        where 
                model ym ts ec = Model {
        youngsModulus = ym,
        tensileStrength = ts,
        energyCapacity = ec
    }
