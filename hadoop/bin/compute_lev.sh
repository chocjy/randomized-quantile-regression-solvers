COND_METHOD=$1
FILENAME=$2
DIR=$3
SUBDIR=$4
HDFS_DIR=$5

echo "start computing leverage scores at $(date +"%c")" >> $SUBDIR/proc.log

    #constructing well-conditioned basis and computing sampling probabilities
    hadoop fs -rmr $HDFS_DIR/$COND_METHOD/L
    dumbo start $DIR/src/quantreg_comp_lev.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/L -file $DIR/src/utils.py -file $SUBDIR/PA/N.txt -param mtx=N.txt -numreducetasks 1 -jobconf mapred.reduce.slowstart.completed.maps=1 

    mkdir -p $SUBDIR/L
    rm $SUBDIR/L/*
    dumptb $HDFS_DIR/$COND_METHOD/L/part* > $SUBDIR/L/partial_sums.tb

    python $DIR/src/convert_lev.py $SUBDIR/L

echo "finsh computing leverage scores at $(date +"%c")" >> $SUBDIR/proc.log
echo "------------------------------" >> $SUBDIR/proc.log

