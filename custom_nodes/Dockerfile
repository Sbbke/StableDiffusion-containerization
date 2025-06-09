FROM python:3.12.3 AS base
FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
# ENV UV_LINK_MODE=copy

# ENV UV_SYSTEM_PYTHON=1
# COPY uv.lock pyproject.toml /app/
#RUN git clone https://github.com/comfyanonymous/ComfyUI.git /stable-diffusion-comfyui

COPY custom_nodes /app/custom_nodes

WORKDIR /app
RUN uv venv -p 3.12
ENV PATH="/app/.venv/bin:$PATH"\
    UV_PYTHON=/app/.venv/bin/python
#COPY .venv/lib/python3.12/site-packages/ /app/.venv/lib/python3.12/site-packages/


COPY dist/*.whl ./dist/

# RUN uv pip install setuptools torch
# RUN uv pip install torch
#RUN --mount=type=bind,source=uv.lock,target=uv.lock \
#     --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
#     uv pip install ./dist/custom_nodes-0.1.0-py3-none-any.whl 
#     uv sync --frozen --no-install-project
RUN uv pip install "git+https://github.com/WASasquatch/cstr.git"
RUN uv pip install ./dist/custom_nodes-0.1.0-py3-none-any.whl 

# COPY uv.lock pyproject.toml /app/
# COPY . /app/
# COPY custom_nodes/SageAttention /app/custom_nodes/SageAttention

# RUN --mount=type=cache,target=/root/.cache/uv \
#     uv sync --extra build --extra compile
# COPY . /app
# RUN --mount=type=cache,target=/root/.cache/uv \
#     uv sync --frozen --no-dev --no-build-isolation

# FROM base
# COPY --from=builder /app /app
# ENV PATH="/app/.venv/bin:$PATH"
