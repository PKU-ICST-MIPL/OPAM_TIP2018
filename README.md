## Introduction
This is the source code of our TIP 2018 paper "Object-Part Attention Model for Fine-grained Image Classification", Please cite the following paper if you use our code.

Yuxin Peng, Xiangteng He, and Junjie Zhao, "Object-Part Attention Model for Fine-grained Image Classification", IEEE Transactions on Image Processing (TIP), Vol. 27, No. 3, pp. 1487-1500, Mar. 2018.[【pdf】](http://59.108.48.34/tiki/download_paper.php?fileId=20185)

## Preparation
caffe: run make in ./caffe/caffe-master
Download the images and patches that we used from the [link](https://pan.baidu.com/s/1qZ2g1Bm) and unzipped to ./ folder.

## Usage
    - cd to ./CAM-master-car and execute run_demo.sh
    - cd to ./ and execute train_patch.sh
    - cd to ./Part_Detect/SelectiveSearch, execute run_ss.sh and run_filter_out.sh
    - cd to ./Part_Detect, execute extract_param.sh, detect_part.m, extract_feature.sh and part_detector_test.m
    - cd to ./, execute train_bbox.sh and train_part.sh
    - select the best models for patch, bbox and part and replace them in the file extract_feature.sh, execute extract_feature.sh
    - execute score_fusion.m to generate the final accuracy
    
## Our Related Work
If you are interested in fine-grained image classification, you can check our recently published papers about it:

Xiangteng He and Yuxin Peng, "Visual-textual Attention Driven Fine-grained Representation Learning", 2017.[【arXiv】](https://arxiv.org/abs/1709.00340)

Xiangteng He, Yuxin Peng and Junjie Zhao, "Fine-grained Discriminative Localization via Saliency-guided Faster R-CNN", 25th ACM Multimedia Conference (ACM MM), pp. 627-635, Mountain View, CA, USA, Oct. 23-27, 2017.[【pdf】](http://59.108.48.34/tiki/download_paper.php?fileId=1007)

Xiangteng He and Yuxin Peng, "Fine-grained Image Classification via Combining Vision and Language", 30th IEEE Conference on Computer Vision and Pattern Recognition (CVPR), pp. 5994-6002, Honolulu, Hawaii, USA, Jul. 21-26, 2017.[【pdf】](http://59.108.48.34/tiki/download_paper.php?fileId=372)

Xiangteng He and Yuxin Peng, "Weakly Supervised Learning of Part Selection Model with Spatial Constraints for Fine-grained Image Classification", 31th AAAI Conference on Artificial Intelligence (AAAI), pp. 4075-4081, San Francisco, California, USA, Feb. 4–9, 2017.[【pdf】](http://59.108.48.34/tiki/download_paper.php?fileId=347)

Tianjun Xiao, Yichong Xu, Kuiyuan Yang, Jiaxing Zhang, Yuxin Peng, and Zheng Zhang, "The Application of Two-level Attention Models in Deep Convolutional Neural Network for Fine-grained Image Classification", 28th IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), pp. 842-850, Boston, MA, USA, Jun. 7-12, 2015.[【pdf】](http://59.108.48.34/tiki/download_paper.php?fileId=20152)


Welcome to our [Laboratory Homepage](http://www.icst.pku.edu.cn/mipl) for more information about our papers, source codes, and datasets.

