RUN_BIN=/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools
PROTO=./VGG19_cvgj_part1.prototxt
TOTAL_NUM=16288
BATCH_NUM=16

FEA_NUM=`expr $TOTAL_NUM / $BATCH_NUM + 1`
GPU_ID=0
echo "Begin Extract fea"

MODEL_NAME=../models/patch.caffemodel
FEA_DIR=./features/train_part_conv5_3
echo $MODEL_NAME
echo $FEA_DIR
echo $PROTO
echo "Total Feature num: ${FEA_NUM}"
GLOG_logtostderr=0
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} conv5_3 ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID

TOTAL_NUM=16082
BATCH_NUM=16
echo "begin Extract fea part 2"
PROTO=./VGG19_cvgj_part2.prototxt
FEA_DIR=./features/test_part_conv5_3
echo $MODEL_NAME
echo $FEA_DIR
echo $PROTO
echo "Total Feature num: ${FEA_NUM}"
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} conv5_3 ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID
