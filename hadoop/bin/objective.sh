COND_METHOD=$1
FILENAME=$2
DIR=$3
SUBDIR=$4
NUM_REDUCER=$5
HDFS_DIR=$6

echo "start computing the obejective values at $(date +"%c")" >> $SUBDIR/proc.log

hadoop fs -rmr $HDFS_DIR/$COND_METHOD/F
dumbo start $DIR/src/quantreg_func.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/F -file $DIR/src/utils.py -file $DIR/src/quantreg_lf.py -file $SUBDIR/X/X.txt -file $SUBDIR/X/tv.txt -param X=X.txt -param tau_vec=tv.txt -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1

#fetch objective values back and convert them
mkdir -p $SUBDIR/F
rm $SUBDIR/F/*
for((i=0; i<NUM_REDUCER; i++)); do
   dumptb $HDFS_DIR/$COND_METHOD/F/part-000$(printf %02d $i) > $SUBDIR/F/F_000$(printf %02d $i).tb
done
python $DIR/src/convert_F.py $SUBDIR/F $NUM_REDUCER

#computing the relative error of value
python $DIR/src/comp_obj_relerr.py $DIR/data/${FILENAME}_f_opt.txt $SUBDIR

echo "finish computing the obejective values at $(date +"%c")" >> $SUBDIR/proc.log
echo "------------------------------" >> $SUBDIR/proc.log

