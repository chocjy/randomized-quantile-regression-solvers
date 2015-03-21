# Randomized Solvers for Large-scale Quantile Regression Problems
These codes provide implementations of solvers for large-scale quantile regression problems using randomized numerical linear algebra.

## About
Quantile regression is a method to estimate the quantiles of the conditional distribution of a response variable, and as such it permits a much more accurate portrayal of the relationship between the response variable and observed covariates than methods such as Least-squares or Least Absolute Deviations regression. It can be expressed as a linear program, and, with appropriate preprocessing, interior-point methods can be used to find a solution for moderately large problems. Dealing with very large problems, e.g. involving data up to and beyond the terabyte regime, remains a challenge. This work shows a randomized algorithm that runs in nearly linear time in the size of the input and that, with constant probability, computes a $(1+\epsilon)$ approximate solution to an arbitrary quantile regression problem.

## Codes
Implementations in MATLAB and Hadoop are provided in `matlab/` and `hadoop/`, respectively.

## References
J. Yang, X. Meng, and M. W. Mahoney, [Quantile Regression for Large-scale applications](http://web.stanford.edu/~jiyan/publications/quantreg_icml.pdf). *Proc. of the 30th ICML Conference (2013)*.

J. Yang, X. Meng, and M. W. Mahoney. [Quantile Regression for Large-scale applications](http://web.stanford.edu/~jiyan/publications/quantreg_sisc.pdf). *SIAM J. Scientific Computing, 36(5), S78-S110, 2014*.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
