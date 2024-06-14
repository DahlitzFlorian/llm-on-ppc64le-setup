# set the application directory and conda prefix
export APPLICATION_DIRECTORY="${HOME}/app"
export CONDA_PREFIX="/opt/conda"

# install dev tools
dnf -y install \
    dnf-plugins-core \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm \
    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

dnf makecache --refresh
dnf -y upgrade
dnf -y groupinstall "Development Tools"
dnf -y install \
    bzip2 \
    gcc-toolset-12 \
    libxcrypt-compat \
    openssl

dnf clean all && rm -rf /var/cache/dnf/* && rm -rf /var/cache/yum

# create application directory
mkdir -p ${APPLICATION_DIRECTORY} && cd $_

# create directory for micromamba prefix
mkdir -p ${CONDA_PREFIX}

# install micromamba and activate the base environment
curl -Ls https://micro.mamba.pm/api/micromamba/linux-ppc64le/latest | \
    tar -xvj --strip-components=1 bin/micromamba && \
    mv micromamba /usr/bin/

eval "$(micromamba shell hook --shell bash)"

# configure channels for micromamba
cat > ${HOME}/.condarc <<'EOF'
# Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
auto_update_conda: false
show_channel_urls: true
channel_priority: flexible
channels:
  - rocketce
  - defaults
EOF

micromamba config append envs_dirs ${CONDA_PREFIX}
micromamba shell init --shell bash --root-prefix=${CONDA_PREFIX}
echo "micromamba activate base" >> ${HOME}/.bashrc
source ${HOME}/.bashrc

# install P10-optimized dependencies
micromamba install \
    --yes \
    'python=3.11' \
    'pytorch-cpu=2.0.1' \
    'tensorflow-cpu=2.13.0' \
    'blas=*=openblas' \
    'arrow' \
    'bcrypt' \
    'cmake' \
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
    'uvicorn'

# install optimum for converting models to onnx
pip install --prefer-binary --no-cache-dir "git+https://github.com/mgiessing/optimum.git@quant_ppc64le"

# build llama.cpp if needed
CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" pip install 'llama-cpp-python[server]'

# download model and convert it to onnx format
optimum-cli export onnx --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 tinyllama_onnx/

# start the backend
uvicorn main:app --host 0.0.0.0 --port 8000
