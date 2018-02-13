#!/usr/bin/env sh

TOOLS=/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools

$TOOLS/caffe train --solver=./vgg19_bbox_solver.prototxt --weights=./models/patch.caffemodel --gpu=2 2>&1 | tee models/vgg19_bbox_log.txt

