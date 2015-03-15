## About
This is a collection of codes of performing randomized algorithms for large-scale quantile regression problems on Hadoop.
The MapReduce framework is the *de facto* standard parallel environment for large data analysis. Apache Hadoop, an open source implementation of MapReduce, is widely-used in practice.
Since our sampling algorithm only needs several passes through the data and it is embarrassingly parallel, it is straightforward to implement it on Hadoop.
The codes are written in Python with [Dumbo](https://github.com/klbostee/dumbo) extension.

## Documentation
See [quantreg_hadoop.pdf](quantreg_hadoop.pdf).
