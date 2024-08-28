# LLM on IBM POWER Setup

- [Description](#description)
- [Usage](#usage)
  - [onnxruntime](#onnxruntime)
  - [Llama CPP](#llama-cpp)


## Description

Sample setup for a Large Language Model (LLM) on IBM POWER10 (ppc64le).

## Usage

Different backends are provided in subfolders to utilise different runtimes.
There is always a shell script, which can be customised and executed to set up the environment.
A `Dockerfile` is provided as an alternative.

Build arguments for the container images can be passed via `--build-arg <key>=<value>`.

### onnxruntime

```shell
$ export MODEL="TinyLlama/TinyLlama-1.1B-Chat-v1.0"
$ docker image build -t llm-ppc64le-onnxruntime --build-arg MODEL=${MODEL} onnxruntime/
$ docker container run --rm -itd \
    --name llm-ppc64le-onnxruntime \
    -p 8000:8000 \
    llm-ppc64le-onnxruntime
```

Supported build arguments:

- `MODEL`: Huggingface model repository (default: `TinyLlama/TinyLlama-1.1B-Chat-v1.0`)

### Llama CPP

- [README.md](/llama.cpp/README.md)
