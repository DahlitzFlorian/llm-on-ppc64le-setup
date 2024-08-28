FROM almalinux:9 as builder  

RUN dnf groupinstall -y "Development Tools" && \
    dnf config-manager --enable crb && \
    dnf install -y openblas-devel git

RUN git clone -b b1544 https://github.com/ggerganov/llama.cpp.git

WORKDIR /llama.cpp

RUN dnf install cmake -y; \
    mkdir build; \
    cd build; \
    cmake -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS ..; \
    cmake --build . --config Release;

FROM almalinux:9

COPY --from=builder /llama.cpp/build/bin/server /usr/local/bin

RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --enable crb && \
    dnf install -y openblas-devel

RUN chmod +x /usr/local/bin/server

ENTRYPOINT ["/usr/local/bin/server", "--host", "0.0.0.0"]
