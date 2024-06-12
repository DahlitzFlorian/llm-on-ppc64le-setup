# LLM on IBM POWER Setup

## Description

Sample setup for a Large Language Model (LLM) on IBM POWER10 (ppc64le).

## Usage

Simply follow the steps in the `setup.sh` script or build a container image and run it:

```shell
$ docker image build -t llm-ppc64le .
$ docker container run --rm --name llm-ppc64le -itd -p 8000:8000 llm-ppc64le
```
