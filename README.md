# concourse-tutorial

## 1. Up and Running
- At root of project: `docker-compose up -d`
- Open http://127.0.0.1:8080/ in your browser:
    -  click download fly-cli
    - `sudo mkdir -p /usr/local/bin`
    - `sudo mv ~/Downloads/fly /usr/local/bin`
    - `sudo chmod 0755 /usr/local/bin/fly`
    - If getting an error when trying to open fly run: `xattr -d com.apple.quarantine /usr/local/bin/fly`
- `cd tutorials/basic/task-hello-world/`
- `fly -t tutorial execute -c task_hello_world.yml`


## 2. Running Tasks
- Can run from command line
    - ex: 
        - `cd concourse-tutorial/tutorials/basic/task-hello-world`
        - `fly -t tutorial execute -c task_hello_world.yml`
- Or in a pipeline job as defined in a `pipeline.yml`
- Every task runs in a container
    - `image_resource`: Pre-baked dependencies for the task

## 3. Task Inputs
- Supports image inputs (`image_resource`) & `inputs` for files/folders
- files/folder inputs:
    - `-i name=value`
        - ex: `fly -t tutorial e -c inputs_required.yml -i some-important-input=.`
    - If `inputs` value is same as current dir name, don't need `-i`
        - ex: `tutorials/basic/task-inputs/input_parent_dir.yml`

## 4. Task Scripts
- `inputs` supports 2 types:
    - requirements/dependencies (Like #3)
    - scripts to be executed
- `cd ../task-scripts`
- `fly -t tutorial e -c task_show_uname.yml`
- `task-scripts/task_show_uname.sh` is made available through the `inputs`


## 5. Basic pipeline
- `cd basic/basic-pipeline`
- `fly -t tutorial set-pipeline -c pipeline.yml -p hello-world`
- To unpause: `fly -t tutorial unpause-pipeline -p hello-world`
- To trigger: click on `job-hello-world` & then the `+`
