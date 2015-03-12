#!/bin/bash

# This script computes the solution to large-scale quantile regression on Hadoop.
# Below are some conditions and parameters needed to be set before running.
#   - DIR is the variable specifying the absolute directory of the current folder.
#   - HDFS_DIR is the directory in HDFS used to store data and results for experiments.
#   - ORDER is used to denote the order of the current experiment. Results (e.g. relative errors)
#       will be stored locally in folder $DIR/results/empirical_reuslts$ORDER.
#   - The data in plain text format should be stored in folder "$HDFS_DIR/data" in HDFS
#       specified by variable FILENAME below.
#   - The options for COND_METHOD are: spc1, spc2, spc3, sc, noco and unif.
#   - The source codes should be placed in folder $DIR/src.
#   - All the outputs in HDFS will be stored in folder $HDFS_DIR/$COND_METHOD.
#   - The script will compute the relative errors. The optimal solutions and objective
#     values should be provided in $DIR/data with name "$FILENAME_x_opt.txt" and "$FILENAME_f_opt.txt"
#   - Number of reducers to be used, sampling size and number of independent trials for
#       sampling can be specified in NUM_REDUCER, SAMPLING_SIZE and NX.
#
# Author: Jiyan Yang (jiyan@stanford.edu)

#set global variables
ORDER=1
FILENAME="skewed_25e8_51"
NUM_ROW=2500000000
NUM_COL=51
#FILENAME="test2"
#NUM_ROW=5000000
#NUM_COL=11
COND_METHOD=spc2
NUM_REDUCER=50
SAMPLING_SIZE=10000
NX=20

DIR="$HOME/quantreg"
HDFS_DIR="quantreg"
SUBDIR=$DIR/results/empirical_results$ORDER
mkdir -p $SUBDIR

echo "NUM_REDUCER = $NUM_REDUCER" > $SUBDIR/info.txt
echo "FILENAME = $FILENAME" >> $SUBDIR/info.txt
echo "COND_METHOD = $COND_METHOD" >> $SUBDIR/info.txt
echo "SAMPLING_SIZE = $SAMPLING_SIZE" >> $SUBDIR/info.txt
echo "NX = $NX" >> $SUBDIR/info.txt

#--------------------------------------------

if [ $COND_METHOD == "unif" ]; then 
    echo " "
else

    #performing conditioning step
    ./condition.sh $COND_METHOD $FILENAME $DIR $SUBDIR $NUM_REDUCER $NUM_COL $HDFS_DIR

    #--------------------------------------------

    #constructing well-conditioned basis and computing sampling probabilities
    ./compute_lev.sh $COND_METHOD $FILENAME $DIR $SUBDIR $HDFS_DIR

fi

#--------------------------------------------

./solve.sh $COND_METHOD $FILENAME $DIR $SUBDIR $NUM_REDUCER $NX $SAMPLING_SIZE $NUM_ROW $HDFS_DIR

#--------------------------------------------

./objective.sh $COND_METHOD $FILENAME $DIR $SUBDIR $NUM_REDUCER $HDFS_DIR

