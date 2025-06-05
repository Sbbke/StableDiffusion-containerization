FROM python:3.12-slim-bookworm AS base
FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /app
COPY uv.lock pyproject.toml /app/
COPY custom_nodes/SageAttention /app/custom_nodes/SageAttention
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-build-isolation

FROM base
COPY --from=builder /app /app
ENV PATH="/app/.venv/bin:$PATH"
