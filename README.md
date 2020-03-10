# DD-CNN
[Hyperspectral Image Denoising With Dual Deep CNN](https://ieeexplore.ieee.org/document/8913500)

# Abstract
  A new hyperspectral image denoising algorithm, called the dual deep convolutional neural network (DD-CNN), is proposed in this paper. In contrast to internal denoising methods that utilize only the features from the target noisy image, the DD-CNN extensively explores the similarities between the target noisy image and the clean reference image from other bands. As external data, the reference images are selected based on the structural similarity index metric (SSIM). The DD-CNN is composed of two CNNs: one is responsible for extracting the features of the target image, and the other is responsible for extracting features from the reference image. A new activation function is proposed that activates the two types of features in the DD-CNN. Based on the dual structure and the new activation function, the external features extracted from the reference images are thoroughly integrated into the internal features of the target noise image. We experimented on different datasets with different noise levels; we also tested special cases for reference images with extra or undesirable features. The DD-CNN algorithm can effectively utilize the similarity between the external image and the target image. When the noise level is high, the advantages of the DD-CNN are obvious.
  
# Requirements
This code does not require a GPU to run, but you should install Matconvnet first. 
* MATLAB R2015b
* MatConvNet

# Citation
@article{shan2019hyperspectral,
  title={Hyperspectral Image Denoising With Dual Deep CNN},<br> 
  author={Shan, Wei and Liu, Peng and Mu, Lin and Cao, Caihong and He, Guojin},<br> 
  journal={IEEE Access},<br> 
  volume={7},<br> 
  pages={171297--171312},<br> 
  year={2019},<br> 
  publisher={IEEE}<br> 
}
