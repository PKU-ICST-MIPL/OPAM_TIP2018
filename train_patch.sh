#!/usr/bin/env sh

TOOLS=/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools

$TOOLS/caffe train --solver=./vgg19_patch_solver.prototxt --weights=./models/vgg19_cvgj_iter_300000.caffemodel --gpu=1 2>&1 | tee models/vgg19_patch_log.txt
