### using uv for python dependency management and building
+ The case is that we need to build the package beforehand. The reason why we don't build the package directly in the docker file is because that it require GPU usage for compilation, but in docker build stage, the use of GPU is blocked for security reason.

## edit project.toml
+ The key here is to the package we're trying to build require no build isolation, and according to [uv documents](https://docs.astral.sh/uv/concepts/projects/config/#required-environments), quote, 'Installing packages without build isolation requires that the package's build dependencies are installed in the project environment prior to installing the package itself. This can be achieved by separating out the build dependencies and the packages that require them into distinct extras.' 
```bash
[project]
name = "test"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "gitpython>=3.1.44",
    "triton>=3.3.1",
]


[tool.uv.sources]
sageattention = { path = "custom_nodes/SageAttention" }

[project.optional-dependencies]
build = ["setuptools","torch"]
compile = ["sageattention"]

[tool.uv]
no-build-isolation-package = ["sageattention"]
```
+ then we build the package
```bash
uv sync --extra build
```
