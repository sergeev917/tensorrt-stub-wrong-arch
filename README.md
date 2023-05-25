Description
===========

This script checks stub archive libraries architecture in a TensorRT DEB
repository package.

The sample output which displays unexpected architecture for arm package:
```
-: OK
INFO: unpacking into /tmp/tmp.g2wsJEdImQ
INFO: unpacking /tmp/tmp.g2wsJEdImQ/var/nv-tensorrt-local-repo-ubuntu2004-8.6.1-cuda-12.0/libnvinfer-dev_8.6.1.6-1+cuda12.0_arm64.deb into /tmp/tmp.g2wsJEdImQ
/tmp/tmp.g2wsJEdImQ/usr/lib/aarch64-linux-gnu/stubs/libcublasLt_static_stub_trt/stub.o   Advanced Micro Devices X86-64
/tmp/tmp.g2wsJEdImQ/usr/lib/aarch64-linux-gnu/stubs/libcublas_static_stub_trt/stub.o   Advanced Micro Devices X86-64
/tmp/tmp.g2wsJEdImQ/usr/lib/aarch64-linux-gnu/stubs/libcudnn_static_stub_trt/stub.o   Advanced Micro Devices X86-64
All stubs are checked, unpacked files remain in /tmp/tmp.g2wsJEdImQ!
```
