### using uv for python dependency management and building
+ The case is that we need to build the package beforehand. The reason why we don't build the package directly in the docker file is because that it require GPU usage for compilation, but in docker build stage, the use of GPU is blocked for security reason.

## adding local or pre-biuld package into project.toml
+ Adding an local package (in this case I tried to build and install sageattention) into uv project

```bash
uv add <path-to-project>
```
+ The project.toml will looked like this
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
```
+ then run
```bash
uv lock
```

+ But there is a dependency error occurred
```bash
ModuleNotFoundError: No module named 'torch'

      hint: This error likely indicates that `sageattention @
      file://<path>/SageAttention`
      depends on `torch`, but doesn't declare it
      as a build dependency. If `sageattention @
      file://<path>/SageAttention`
      is a first-party package, consider adding `torch` to its
      `build-system.requires`. Otherwise, `uv pip install torch` into the
      environment and re-run with `--no-build-isolation`.
  help: If you want to add the package regardless of the failed resolution,
        provide the `--frozen` flag to skip locking and syncing.
```
+ Even though it can be simply fixed by adding the package with --no-build-isolation flag, but when we build the project into wheel file (whl), and pass the file into docker to build, the same error will still occurred. Honestly, using uv for container dependency build management is way more complicated than I thought it will be.

## building the project and pass it into docker
+ first I build the project into wheel file using [uv build](https://docs.astral.sh/uv/guides/package/) command, this will generate whl file under /dist 
```bash
uv build
```
+ check the dependency integrity 
```bash
uv lock
```

+ Than copy the whl file into docker to install the dependencies
```bash
RUN uv venv -p 3.12
ENV PATH="/app/.venv/bin:$PATH"\
    UV_PYTHON=/app/.venv/bin/python
    
COPY dist/*.whl ./dist/
RUN uv pip install ./dist/<yout-whl-name>.whl 
```
+ In pyproject.toml, I have dependency on a git project
```bash
cstr = { git = "https://github.com/WASasquatch/cstr.git" }
```
+ While install process in docker, it scream
```bash
× No solution found when resolving dependencies:                        
            ╰─▶ Because cstr was not found in the package registry
```
+ I think is something wrong in [uv build] resulting the generated whl file didn't contain the cstr package?, however cstr is listed in the egg-info/requires.txt. Anyway, I manually install cstr package in dockerfile. 
```bash
RUN uv pip install "git+https://github.com/WASasquatch/cstr.git"
```

+ One thing worth to notice is that while uv installing dependency from whl file, interesting enough is that in the console it is downloading the packages, instead directly using the installed package from the host, the process makes me wonder what is the point of installed dependency on the host than build a project.toml. I think the advantage of it is for other user tried to replicate the project, all they need is a single whl file copy into their docker file then thay are good to go (only for python dependency of course).

+ the current approach is to build the package on the host, and add its local source into pyproject.toml, with this approach, the host is required to pull the package, build and install on the host, the specify the path to the local source package in to pyprojecy, when collaborate with docker, it requirs the local source being copy into the docker as well. Since this package (sageattention) is from git repo, I think uv build backend should be able to specify the build process in pyproject therefore doesn'y require the host to build it first.

