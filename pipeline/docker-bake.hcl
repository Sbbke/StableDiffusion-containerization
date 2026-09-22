// Build all three layers with one command:
//   docker buildx bake
// or a single target:
//   docker buildx bake comfy-custom
//
// Registry-based cache (useful in CI, where local BuildKit cache mounts
// don't persist across runners) - set REGISTRY and uncomment cache_from/to.

variable "REGISTRY" {
  default = "andrew/comfy"
}

variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["comfy-custom"]
}

target "comfy-runtime-base" {
  dockerfile = "Dockerfile.base"
  tags       = ["comfy-runtime-base:cuda12.8-py312"]
  # cache-from = ["type=registry,ref=${REGISTRY}/runtime-base:cache"]
  # cache-to   = ["type=registry,ref=${REGISTRY}/runtime-base:cache,mode=max"]
}

target "comfy-base" {
  dockerfile = "Dockerfile.comfy"
  contexts   = { comfy-runtime-base = "target:comfy-runtime-base" }
  tags       = ["comfy-base:cuda12.8-py312-comfy"]
  args = {
    # Pinned to the latest stable ComfyUI release tag - see the note in
    # Dockerfile.comfy for why this isn't "master". Bump this deliberately
    # when a newer stable tag comes out, don't let it float.
    COMFYUI_COMMIT = "v0.37.0"
  }
  # cache-from = ["type=registry,ref=${REGISTRY}/base:cache"]
  # cache-to   = ["type=registry,ref=${REGISTRY}/base:cache,mode=max"]
}

target "comfy-custom" {
  dockerfile = "Dockerfile.nodes"
  contexts   = { comfy-base = "target:comfy-base" }
  tags       = ["comfy-custom:${TAG}"]
  # cache-from = ["type=registry,ref=${REGISTRY}/custom:cache"]
  # cache-to   = ["type=registry,ref=${REGISTRY}/custom:cache,mode=max"]
}
