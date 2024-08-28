ARG ROOT_CONTAINER=almalinux:9.3
FROM $ROOT_CONTAINER

ARG PYTHON_VERSION=3.11
ARG PYTORCH=pytorch-cpu
ARG PYTORCH_VERSION=2.0.1
ARG TENSORFLOW=tensorflow-cpu
ARG TENSORFLOW_VERSION=2.13.0
ARG MICRO_MAMBA_TARGETARCH=ppc64le
ARG MODEL="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash
ENV PATH="${CONDA_DIR}/bin:${PATH}"

USER root

RUN mkdir /app

RUN dnf -y install \
        dnf-plugins-core \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm \
    && \
    dnf makecache --refresh && \
    dnf -y upgrade && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
        bzip2 \
        libxcrypt-compat \
        openssl \
        && \
    dnf clean all && rm -rf /var/cache/dnf/* && rm -rf /var/cache/yum

WORKDIR /tmp

RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-ppc64le/latest | \
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
        "${PYTORCH}=${PYTORCH_VERSION}" \
        "${TENSORFLOW}=${TENSORFLOW_VERSION}" \
        'blas=*=openblas' \
        # additional packages (alphabetical order)
        'arrow' \
        'bcrypt' \
        'fastapi' \
        'httptools' \
        'numpy' \
        'onnx' \
        'onnxruntime' \
        'pandas' \
        'protobuf' \
        'pyarrow' \
        'tensorboard' \
        'tensorflow-datasets' \
        'tensorflow-hub' \
        'tensorflow-io' \
        'tensorflow-probability' \
        'tf2onnx' \
        'transformers' \
        'ujson' \
        'uvicorn' \
        # ----        
    && \
    pip install --prefer-binary --no-cache-dir \
        ##################
        # pip packages
        "git+https://github.com/mgiessing/optimum.git@quant_ppc64le"

EXPOSE 8000

WORKDIR /app

# download and convert model to onnx
RUN optimum-cli export onnx --model ${MODEL} model_onnx/

COPY main.py main.py

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
