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
$ export WORKDIR="/root/llama-on-power"
$ export MODEL="${WORKDIR}/models/Meta-Llama-3-8B-Instruct/Meta-Llama-3-8B.Q8_0.gguf"
$ export PYTHON_VERSION=3.11
$ export CONDA_DIR="/opt/conda"
$ mkdir -p ${CONDA_DIR}

$ mkdir -p ${WORKDIR}
$ cd ${WORKDIR}

$ dnf groupinstall -y "Development Tools" && \
    dnf config-manager --enable crb && \
    dnf install -y openblas-devel git

$ curl -Ls https://micro.mamba.pm/api/micromamba/linux-ppc64le/latest | \
    tar -xvj --strip-components=1 bin/micromamba && \
    PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
    if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
    ./micromamba install \
        --root-prefix="${CONDA_DIR}" \
        --prefix="${CONDA_DIR}" \
        --yes \
        ############################################################
        # channels
        --channel rocketce \
        --channel defaults \
        ############################################################
        # core packages (most dependencies)
        "${PYTHON_SPECIFIER}" \
        pytorch-cpu \
        numpy \
        sentencepiece \
        "conda-forge::gguf"

$ git clone -b b1544 https://github.com/ggerganov/llama.cpp.git

$ cd ${WORKDIR}/llama.cpp

$ dnf install cmake -y; \
    mkdir build; \
    cd build; \
    cmake -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS ..; \
    cmake --build . --config Release;

$ chmod +x ${WORKDIR}/llama.cpp/build/bin/server

$ cd ${WORKDIR}

$ huggingface-cli download QuantFactory/Meta-Llama-3-8B-GGUF Meta-Llama-3-8B.Q8_0.gguf --local-dir models/Meta-Llama-3-8B-Instruct

$ ${WORKDIR}/llama.cpp/build/bin/server --host 0.0.0.0 -m ${MODEL} -c 4096
```
