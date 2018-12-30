FROM nvidia/cuda:9.0-base-ubuntu16.04
ARG NB_USER="umutcan"
ARG NB_UID="1000"
ARG NB_GID="100"
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        libcudnn7=7.2.1.38-1+cuda9.0 \
        libnccl2=2.2.13-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
        apt-get install nvinfer-runtime-trt-repo-ubuntu1604-4.0.1-ga-cuda9.0 && \
        apt-get update && \
        apt-get install libnvinfer4=4.1.2-1+cuda9.0

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -y \
    python \
    python-pip \
    python3-pip

COPY --from=sagemath/sagemath:latest /home/sage /home/sage
ARG SAGE_ROOT=/home/sage/sage
RUN ln -s "$SAGE_ROOT/sage" /usr/bin/sage
RUN sage -pip install sklearn matplotlib tensorflow
WORKDIR /home/sage/sage
# Configure environment
ENV SAGE_DIR=/home/sage \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$SAGE_DIR/bin:$PATH \
    HOME=/home/$NB_USER

#RUN apt-get update && apt-get -yq dist-upgrade \
# && apt-get install -yq --no-install-recommends \
#    wget \
#    bzip2 \
#    ca-certificates \
#    sudo \
#    locales \
#    fonts-liberation \
# && rm -rf /var/lib/apt/lists/*

#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
#    locale-gen
ADD fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions
# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chown $NB_USER:$NB_GID $SAGE_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions $SAGE_DIR
USER $NB_UID
#CMD ["sage"] 

