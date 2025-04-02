FROM ubuntu:22.04

EXPOSE 7860


ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_COMMAND="pip install torch torchvision"

RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://free.nchc.org.tw/ubuntu|' /etc/apt/sources.list
RUN apt update && apt install -y python3 python3-pip git wget curl aria2 nano vim clang lldb lld pciutils google-perftools
RUN apt install -y libgl1 libglib2.0-0
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

#torch environment
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126
RUN pip3 install git+https://github.com/openai/CLIP.git
RUN pip3 install open_clip_torch

# checking environment requirements
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /stable-diffusion-comfyui
WORKDIR /stable-diffusion-comfyui
RUN pip3 install -r requirements.txt
RUN pip3 install GitPython

RUN apt update && apt upgrade -y
RUN apt install -y ffmpeg

#RUN pip3 install numba numexpr simpleeval facexlib insightface basicsr
#RUN pip3 install piexif openmim segment-anything ultralytics scikit-image 

# essential custom nodes
WORKDIR /stable-diffusion-comfyui/custom_nodes
### motion lora training
#RUN git clone https://github.com/kijai/ComfyUI-ADMotionDirector.git 
#RUN pip3 install -r ComfyUI-ADMotionDirector/requirements.txt

### performance monitoring
RUN git clone https://github.com/crystian/ComfyUI-Crystools.git
RUN pip3 install -r ComfyUI-Crystools/requirements.txt

### comfyui impact pack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git 
RUN pip3 install -r ComfyUI-Impact-Pack/requirements.txt

### animatediff evolved
RUN git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git ComfyUI-AnimateDiff-Evolved

### comfyui manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager ComfyUI-Manager
RUN pip3 install -r ComfyUI-Manager/requirements.txt
# RUN python3 /stable-diffusion-webui/launch.py --no-download-sd-model --skip-torch-cuda-test --exit

### was node suite
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git 
RUN pip3 install -r was-node-suite-comfyui/requirements.txt

### reactor node
RUN git clone https://codeberg.org/Gourieff/comfyui-reactor-node.git ComfyUI-ReActor
RUN pip3 install -r ComfyUI-ReActor/requirements.txt
RUN pip3 install onnxruntime-gpu

### IPadapter
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
RUN pip3 install insightface
# CMD python3 /stable-diffusion-webui/webui.py --listen --xformers --no-download-sd-model --enable-insecure-extension-access --api
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

RUN git clone https://github.com/rgthree/rgthree-comfy.git

RUN git clone https://github.com/cubiq/ComfyUI_FaceAnalysis.git
RUN pip3 install -r ComfyUI_FaceAnalysis/requirements.txt

RUN git clone https://github.com/cubiq/ComfyUI_InstantID.git
RUN pip3 install -r ComfyUI_InstantID/requirements.txt

RUN git clone https://github.com/farizrifqi/ComfyUI-Image-Saver.git
RUN pip3 install -r ComfyUI-Image-Saver/requirements.txt

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
RUN pip3 install -r ComfyUI-Impact-Subpack/requirements.txt

RUN git clone https://github.com/city96/ComfyUI-GGUF.git
RUN pip3 install -r ComfyUI-GGUF/requirements.txt

RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git
RUN pip3 install -r comfyui_controlnet_aux/requirements.txt

RUN git clone https://github.com/cubiq/ComfyUI_essentials.git
RUN pip3 install -r ComfyUI_essentials/requirements.txt

RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git
RUN pip3 install -r ComfyUI-KJNodes/requirements.txt

RUN git clone https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git

### for wan video
RUN git clone https://github.com/FlyingFireCo/tiled_ksampler.git

RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
RUN pip3 install -r ComfyUI-WanVideoWrapper/requirements.txt

RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
RUN pip3 install -r ComfyUI-VideoHelperSuite/requirements.txt

### for flux
RUN git clone https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git
RUN pip3 install -r ComfyUI_PuLID_Flux_ll/requirements.txt

RUN git clone https://github.com/jags111/efficiency-nodes-comfyui.git
RUN pip3 install -r efficiency-nodes-comfyui/requirements.txt
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
