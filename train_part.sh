#!/usr/bin/env sh

TOOLS=/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/build/tools

$TOOLS/caffe train --solver=./vgg19_part_solver.prototxt --weights=models/patch.caffemodel --gpu=3 2>&1 | tee models/vgg19_part_log.txt
