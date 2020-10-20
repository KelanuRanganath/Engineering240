# Engineering240

I've only tested this code on Linux, but you can compile it from the source for any machine.

Tuple Transpose:

I needed a way to transpose the elements of 2 tuples in an arrayy for calculating Riemann sums.

Main:

Main is the source file for actually calculating the data needed for the tensile lab. It takes 5 command line arguments: 'Preload (N)' 'Gauge Length (m)' 'Diameter (m)' 'Slope Deviation*' 'file location', enter the arguments without apostorphes and seperated by spaces.

Example usage: ./Main 100 0.033 0.0031 0.1 Lab/Data/BrassData.csv

Flags:
-d -- tells it to use the default Pasco values
  ./main -d Lab/Data/BrassData.csv
-m -- provide a .txt file of file locations to do multiple analysies at once
  ./main -d -m locations.txt
-s -- tells it to search all sub directories and perform multiple analysies on all csv files that are found (automatically uses default values).
  ./Main -s

The slope deviation calculates the perecnt difference in the slope change from the slope of the initial data point, this value is needed to calculate the linear portion of the data.
