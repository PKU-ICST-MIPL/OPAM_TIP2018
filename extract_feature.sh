RUN_BIN=/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools

TOTAL_NUM=8041
BATCH_NUM=16

FEA_NUM=`expr $TOTAL_NUM / $BATCH_NUM + 1`
GPU_ID=0
GLOG_logtostderr=0

# for ori
PROTO=./configure/VGG19_patch.prototxt
MODEL_NAME=./models/patch.caffemodel 
FEA_DIR=./feature/patch
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} fc8_cub ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID

# for object
PROTO=./configure/VGG19_bbox.prototxt
MODEL_NAME=./models/vgg19_bbox_iter_40000.caffemodel 
FEA_DIR=./feature/bbox
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} fc8_cub_bbox ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID

# for part
PROTO=./configure/VGG19_part1.prototxt
MODEL_NAME=./models/vgg19_part_iter_60000.caffemodel 
FEA_DIR=./feature/part1
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} fc8_cub_part ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID

PROTO=./configure/VGG19_part2.prototxt
MODEL_NAME=./models/vgg19_part_iter_60000.caffemodel 
FEA_DIR=./feature/part2
${RUN_BIN}/extract_features_txt.bin ${MODEL_NAME} ${PROTO} fc8_cub_part ${FEA_DIR} ${FEA_NUM} lmdb GPU $GPU_ID
