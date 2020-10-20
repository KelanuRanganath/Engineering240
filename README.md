# Engineering240

I've only tested this code on Linux, but you can compile it from the source for any machine.

Tuple Transpose:

I needed a way to transpose the elements of 2 tuples in an arrayy for calculating Riemann sums.

Main is the source file for actually calculating the data needed for the tensile lab. It takes 5 command line arguments: 'Preload (N)' 'Gauge Length (m)' 'Diameter (m)' 'Slope Deviation*' 'file location', enter the arguments without apostorphes and seperated by spaces.

Example usage: ./Main 100 0.033 0.0031 0.1 Lab/Data/BrassData.csv

* The slope deviation calculates the perecnt difference in the slope change from the slope of the initial data point, this value is needed to calculate the linear portion of the data.
