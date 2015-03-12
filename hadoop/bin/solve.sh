COND_METHOD=$1
FILENAME=$2
DIR=$3
SUBDIR=$4
NUM_REDUCER=$5
NX=$6
SAMPLING_SIZE=$7
NUM_ROW=$8
HDFS_DIR=$9

echo "start solving the subproblem at $(date +"%c")" >> $SUBDIR/proc.log

if [ $COND_METHOD == "unif" ]; then
    hadoop fs -rmr $HDFS_DIR/$COND_METHOD/X
    dumbo start $DIR/src/quantreg_unifsamp_solve.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/unif/X -file $DIR/src/utils.py -file $DIR/src/quantreg.py -file $DIR/src/rqfnb.so -param s=$SAMPLING_SIZE -param nx=$NX -param num_row=$NUM_ROW -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1

else
    #sampling and solving subproblems
    hadoop fs -rmr $HDFS_DIR/$COND_METHOD/X
    dumbo start $DIR/src/quantreg_samp_solve.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/X -file $DIR/src/utils.py -file $SUBDIR/L/sum_lev.txt -file $DIR/src/quantreg.py -file $DIR/src/rqfnb.so -file $SUBDIR/PA/N.txt -param mtx=N.txt -param s=$SAMPLING_SIZE -param nx=$NX -param sl=sum_lev.txt -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1

fi

#fectch the solutions back and convert X
mkdir -p $SUBDIR/X
rm $SUBDIR/X/*
for((i=0; i<NUM_REDUCER; i++)); do
   dumptb $HDFS_DIR/$COND_METHOD/X/part-000$(printf %02d $i) > $SUBDIR/X/X_000$(printf %02d $i).tb
done
python $DIR/src/convert_X.py $SUBDIR/X $NUM_REDUCER

#computing the relative error of vectors
python $DIR/src/comp_sol_relerr.py $DIR/data/${FILENAME}_x_opt.txt $SUBDIR

echo "finish solving the subproblem at $(date +"%c")" >> $SUBDIR/proc.log
echo "------------------------------" >> $SUBDIR/proc.log

