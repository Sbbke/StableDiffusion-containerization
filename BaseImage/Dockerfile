
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04



ENV DEBIAN_FRONTEND=noninteractive


RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://free.nchc.org.tw/ubuntu|' /etc/apt/sources.list
RUN apt update && apt install -y python3 python3-pip git wget curl aria2 nano vim clang lldb lld pciutils google-perftools
RUN apt install -y libgl1 libglib2.0-0
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

#torch environment
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126
RUN pip3 install git+https://github.com/openai/CLIP.git
RUN pip3 install open_clip_torch 

