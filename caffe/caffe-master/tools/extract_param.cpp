// Copyright 2013 Yangqing Jia
//
// This is a simple script that allows one to quickly test a network whose
// structure is specified by text format protocol buffers, and whose parameter
// are loaded from a pre-trained network.
// Usage:
//    test_net net_proto pretrained_net_proto iterations [CPU/GPU]

#include <cuda_runtime.h>

#include <cstring>
#include <cstdlib>
#include <string>
#include <iostream>
#include <vector>
#include <map>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <fstream>
#include "caffe/caffe.hpp"

using namespace caffe;
using namespace std;

int main(int argc, char** argv) {
	if(argc<5){
		LOG(ERROR)
				<< "extract_param net_proto caffemodel layer_name weight_file_path";
		return 1;
	}
	//Caffe::set_phase(Caffe::TEST);
	Caffe::set_mode(Caffe::GPU);
	cudaSetDevice(0);
	//char* protopath = "/home/junchao/hashing/caffe-bsdh/examples/bsdh/configure/cifar10/cifar10_bsdh_feature_vggf_12b.prototxt";
	//char* modelpath = "/media/sdb1/junchao/bsdh/models/12bit_model/cifar10/vggf_bsdh/cifar10_bsdh_iter_8000.caffemodel";
	//char* outpath = "/media/sdb1/junchao/bsdh/models/12bit_model/cifar10/vggf_bsdh/cifar10_bsdh_iter_8000_weight_hash.weight";
	char* protopath = argv[1];
	char* modelpath = argv[2];
	char* layer_name = argv[3];
	char* outpath = argv[4];
	
	Phase phase = TEST;
	Net<float> test_net(protopath, phase);
	test_net.CopyTrainedLayersFrom(modelpath);
	
	NetParameter test_net_param;
	ReadNetParamsFromBinaryFileOrDie(modelpath, &test_net_param);
	
	printf("extracting [%s] parameters from [%s] \n\tas proto [%s] ...\n",layer_name, modelpath, protopath);

	printf("layers num : %d\n", test_net_param.layer_size());
	//int index = 24;
	//test_net_param.layer(index);
	//printf("Layer [%d]: layer_name [%s], layer type [%s]\n", index, test_net_param.layer(index).name().c_str(),
	//	test_net_param.layer(index).type().c_str());
	
	//vector < shared_ptr<Layer<float> > > layers = test_net.layers();
	//printf("test_net layer num: %d\n",layers.size());
	//ElementWiseProductLayer<float> *elewiselayer =
	//		dynamic_cast<ElementWiseProductLayer<float>*>(layers[index].get());
	std::string str_layer_name(layer_name);
	CHECK(test_net.has_layer(str_layer_name));
	shared_ptr <Layer<float> > query_layer = test_net.layer_by_name(str_layer_name);
	printf("query layer type: %s\n",query_layer->type());

	vector < shared_ptr<Blob<float> > > myblobs = query_layer->blobs();
	//ElementWiseProductLayer<float> *elewiselayer =
	//		dynamic_cast<ElementWiseProductLayer<float>*>(query_layer.get());
	//CHECK(elewiselayer);
	//printf("query layer type: %s\n",elewiselayer->type());
	
	//vector < shared_ptr<Blob<float> > > &myblobs = elewiselayer->blobs();
	
	float* weight = myblobs[0]->mutable_cpu_data();
	float* bias = myblobs[1]->mutable_cpu_data();
	int num = myblobs[0]->num();
	int dim = myblobs[0]->count()/num;
	printf("weights blob size: %d, %d, %d, %d, <==> %d, %d\n",myblobs[0]->num(), myblobs[0]->channels(), myblobs[0]->height(), myblobs[0]->width(), num, dim);
	//CHECK_EQ(myblobs[0]->height(),1);
	//CHECK_EQ(myblobs[0]->width(),1);
	ofstream fout(outpath);
	for(int i=0;i<num;i++){
	   for(int j=0;j<dim;j++){
		//printf("%f ",weight[i*dim+j]);
		fout<<weight[i*dim+j]<<" ";
           }
           //printf("\n");
           fout<<endl;
	}
	printf("The bias is:\n");
	for(int j=0;j<myblobs[1]->count();j++){
		printf("%f ", bias[j]);
	}
	printf("\n");
	fout.flush();
	fout.close();
	printf("file [%s] save done.\n",outpath);
	return 0;
}

