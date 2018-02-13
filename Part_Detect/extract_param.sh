NET_PROTO=../configure/param_extract.prototxt
LAYER_NAME=conv5_3
NET_MODEL_DIR=../models
NET_MODEL_NAME=patch
NET_MODEL_PATH=${NET_MODEL_DIR}/${NET_MODEL_NAME}.caffemodel
/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools/extract_param.bin $NET_PROTO ${NET_MODEL_PATH} ${LAYER_NAME} param
