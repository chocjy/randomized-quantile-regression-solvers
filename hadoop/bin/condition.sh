COND_METHOD=$1
FILENAME=$2
DIR=$3
SUBDIR=$4
NUM_REDUCER=$5
NUM_COL=$6
HDFS_DIR=$7

echo "start conditioning at $(date +"%c")" >> $SUBDIR/proc.log

hadoop fs -rmr $HDFS_DIR/$COND_METHOD/PA

    case $COND_METHOD in
        sc | spc1)
            if [ $COND_METHOD == "sc" ]; then
                dumbo start $DIR/src/cauchy.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/PA -file $DIR/src/utils.py -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1
            else
                dumbo start $DIR/src/spc.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/PA -file $DIR/src/utils.py -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1
            fi

            #fetch data back
            mkdir -p $SUBDIR/PA
            rm $SUBDIR/PA/*
            for((i=0; i<NUM_REDUCER; i++)); do
                dumptb $HDFS_DIR/$COND_METHOD/PA/part-000$(printf %02d $i) > $SUBDIR/PA/PA_000$(printf %02d $i).tb
            done

            #convert PA and compute QR
            python $DIR/src/cond.py $SUBDIR/PA $NUM_REDUCER
            ;;
        spc2 | spc3)
            hadoop fs -rmr $HDFS_DIR/$COND_METHOD/PA0
            dumbo start $DIR/src/spc.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/PA0 -file $DIR/src/utils.py -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1

            mkdir -p $SUBDIR/PA0
            rm $SUBDIR/PA0/*
            for((i=0; i<NUM_REDUCER; i++)); do
                dumptb $HDFS_DIR/$COND_METHOD/PA0/part-000$(printf %02d $i) > $SUBDIR/PA0/PA_000$(printf %02d $i).tb
            done
            python $DIR/src/cond.py $SUBDIR/PA0 $NUM_REDUCER

            echo "finish subspace embedding at $(date +"%c")" >> $SUBDIR/proc.log

            hadoop fs -rmr $HDFS_DIR/$COND_METHOD/L0
            dumbo start $DIR/src/quantreg_comp_lev.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/L0 -file $DIR/src/utils.py -file $SUBDIR/PA0/N.txt -param mtx=N.txt -numreducetasks 1 -jobconf mapred.reduce.slowstart.completed.maps=1

            mkdir -p $SUBDIR/L0
            rm $SUBDIR/L0/*
            dumptb $HDFS_DIR/$COND_METHOD/L0/part* > $SUBDIR/L0/partial_sums.tb
            python $DIR/src/convert_lev.py $SUBDIR/L0

            echo "finish computing leverage scores at $(date +"%c")" >> $SUBDIR/proc.log

            dumbo start $DIR/src/quantreg_sample.py -input $HDFS_DIR/data/$FILENAME.txt -output $HDFS_DIR/$COND_METHOD/PA -file $DIR/src/utils.py -file $SUBDIR/L0/sum_lev.txt -file $SUBDIR/PA0/N.txt -param sl=sum_lev.txt -param mtx=N.txt -numreducetasks $NUM_REDUCER -jobconf mapred.reduce.slowstart.completed.maps=1

            #fetch data back
            mkdir -p $SUBDIR/PA
            rm $SUBDIR/PA/*
            for((i=0; i<NUM_REDUCER; i++)); do
                dumptb $HDFS_DIR/$COND_METHOD/PA/part-000$(printf %02d $i) > $SUBDIR/PA/PA_000$(printf %02d $i).tb
            done

            if [ $COND_METHOD == "spc2" ]; then
                python $DIR/src/cond_spc2.py $SUBDIR/PA $NUM_REDUCER
                echo "As = importdata('$SUBDIR/PA/As.txt');" > cond_spc2.m
                echo "[Bs, R] = condition(As, 1);" >> cond_spc2.m
                echo "N = inv(R);" >> cond_spc2.m
                echo "save(fullfile('$SUBDIR/PA', 'N.txt'), 'N', '-ascii');" >> cond_spc2.m
                echo "addpath(genpath('$DIR/src'));" >> startup.m 
                matlab -nodisplay -nodesktop -nosplash -r "cond_spc2; exit" 
                rm startup.m
                rm cond_spc2.m
            else
                python $DIR/src/cond_spc3.py $SUBDIR/PA $NUM_REDUCER
            fi
            ;;
        noco)
            mkdir -p $SUBDIR/PA
            rm $SUBDIR/PA/*
            python $DIR/src/gen_id.py $SUBDIR/PA $NUM_COL
            ;;

      esac

echo "finish conditioning at $(date +"%c")" >> $SUBDIR/proc.log
echo "------------------------------" >> $SUBDIR/proc.log
 
