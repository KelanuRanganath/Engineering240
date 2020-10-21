# Engineering240

I've only tested this code on Linux, but you can compile it from the source for any machine.

Tuple Transpose:

I needed a way to transpose the elements of 2 tuples in an array for calculating Riemann sums.

Main:

Main is the source file for actually calculating the data needed for the tensile lab. It takes 5 command line arguments: 'Preload (N)' 'Gauge Length (m)' 'Diameter (m)' 'Slope Deviation*' 'file location', enter the arguments without apostorphes and seperated by spaces.

Example usage: ./Main 100 0.033 0.0031 0.1 Lab/Data/BrassData.csv

| -f | Description                                                              | Example                                               |
|----|--------------------------------------------------------------------------|-------------------------------------------------------|
| -m | include a CSV with material data and file locations                      | ./Main -m locations.csv or ./Main -d -m locations.csv |
| -s | search sub-directories for CSV files (automatically uses default values) | ./Main -s                                             |
| -d | use default values, can be combined with -m                              | ./Main -d data.csv                                    |

The slope deviation calculates the perecnt difference in the slope change from the slope of the initial data point, this value is needed to calculate the linear portion of the data.
