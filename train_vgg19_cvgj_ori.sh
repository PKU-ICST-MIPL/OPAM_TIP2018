#!/usr/bin/env sh

TOOLS=/home/junchao/workspace/caffe-rc3/build/tools

$TOOLS/caffe train --solver=/media/junchao/finegrain/TIP2017/Car196/vgg19_cvgj_solver_ori.prototxt --weights=vgg19_cvgj/vgg19_cvgj_iter_300000.caffemodel --gpu=3 2>&1 | tee models/vgg19_cvgj_ori_iter_log_01
