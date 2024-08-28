# Instructions

## Docker

```shell
$ export MODEL="<path-to-model>"
$ docker image build -t llama-on-ppc64le .
$ docker container run --rm -it \
    --name llama-on-ppc64le \
    -p 8080:8080 \
    -v ${MODEL}:/models/ggml-model.gguf \
    llama-on-ppc64le \
    -m /models/ggml-model.gguf \
    -c 4096
```

The service is now available under `http://<machine_ip>:8080/v1/chat/completions` .


## Without Docker

```shell
$ export MODEL="<path-to-model>"
$ export WORKDIR="/root/llama-on-power"
$ mkdir -p ${WORKDIR}
$ cd ${WORKDIR}

$ dnf groupinstall -y "Development Tools" && \
    dnf config-manager --enable crb && \
    dnf install -y openblas-devel git

$ git clone -b b1544 https://github.com/ggerganov/llama.cpp.git

$ cd ${WORKDIR}/llama.cpp

$ dnf install cmake -y; \
    mkdir build; \
    cd build; \
    cmake -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS ..; \
    cmake --build . --config Release;

$ chmod +x ${WORKDIR}/llama.cpp/build/bin/server

$ ${WORKDIR}/llama.cpp/build/bin/server --host 0.0.0.0 -m ${MODEL} -c 4096
```
