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
    - `-t`: target
    - `-c`: config

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

## 5. Basic Pipeline
- `cd basic/basic-pipeline`
- `fly -t tutorial set-pipeline -c pipeline.yml -p hello-world`
    - `-p`: alias for `--pipeline`
- To unpause: `fly -t tutorial unpause-pipeline -p hello-world`
- To trigger: click on `job-hello-world` & then the `+`

## 6. Pipeline Resources
- All inputs that are stored externally from concourse
- Pre-defined types: https://resource-types.concourse-ci.org/
    - ex: `git`, `docker-image`, `slack-notifier`

- To run:
    - `cd ../pipeline-resources`
    - Set pipeline: `fly -t tutorial sp -c pipeline.yml -p hello-world`
    - To unpause: `fly -t tutorial up -p hello-world`

- The `hello-world` Task has access to the `resource-tutorial` git Resource
    - Under the `resource-tutorial/` path

## 7. Job Outputs in Terminal
- Can view output of a job with `watch --job` (or just `-j`)
- ex: `fly -t tutorial watch --job hello-world/job-hello-world`
    - Can add `--build NUM` for specific build
    - leave off `--job` to see one-offs

- To see all builds: `fly -t tutorial builds`

## 8. Triggering Jobs
- Clicking `+` in the web UI
- Input resource triggering a job
- `fly trigger-job -j pipeline/jobname` command
- Sending a `POST` request to Concourse API

Test: 
- `fly -t tutorial trigger-job -j hello-world/job-hello-world`
- To see logs in terminal: `fly -t tutorial watch -j hello-world/job-hello-world`
- Or trigger & watch in one command:
    - `fly -t tutorial trigger-job -j hello-world/job-hello-world -w`
    
## 9. Triggering Jobs with Resources
- When resource changes, cause a job to trigger
    - `trigger: true`
- `cd tutorials/basic/triggers/`
- `fly sp -t tutorial -c pipeline.yml -p hello-world`
- `fly up -t tutorial -p hello-world`
- Solid line: trigger resource

## 10. Destroying Pipelines
`fly -t tutorial destroy-pipeline -p hello-world`

## 11. Resource Inputs in Job Tasks
- To run tests for a simple app:
    - task `image` with dependencies
    - input `resource` with task script for running test
    - input `resource` containing app source code
    
- Ex:
    - `cd ../job-inputs`
    - `fly -t tutorial sp -p simple-app -c pipeline.yml`
    - `fly -t tutorial up -p simple-app`
    - Navigate to: http://127.0.0.1:8080/teams/main/pipelines/simple-app
 
 ## 12. Passing Task Outputs to Task Inputs
- Task `outputs`
- Task `inputs` can consume by same name as previous task `outputs` name
- Output creates a directory with same name

-Ex:
   - `cd ../task-outputs-to-inputs`
   - `fly -t tutorial sp -p pass-files -c pipeline.yml`
   - `fly -t tutorial up -p pass-files`
   - `fly -t tutorial trigger-job -j pass-files/job-pass-files -w`
 
## 13. Publishing Outputs
- Push modified git repo to a remote endpoint
- Gist: https://gist.github.com/mallett002/ff05df0e99ea7369a5e29b1199d01601
- private key: `~/.ssh/id_rsa_concourse`
    - copy and past into `tutorials/basic/publishing-outputs/pipeline.yml`
    - `cd ../publishing-outputs`
    - `fly -t tutorial sp -p publishing-outputs -c pipeline.yml`
    - `fly -t tutorial up -p publishing-outputs`
    
- Output from the `task: bump-timestamp-file` is input for `resource-gist`

## 14. Parameters
- ((parameter))
- Test:
    - `cd ../parameters`
    - `fly -t tutorial sp -p parameters -c pipeline.yml`
    - `fly -t tutorial up -p parameters`
    - Will fail: `fly -t tutorial trigger-job -j parameters/show-animal-names -w` (no vars set)
    - Will pass using `-v` to set variables: `fly -t tutorial sp -p parameters -c pipeline.yml -v cat-name=garfield -v dog-name=odie`
    
- Storing parameters in local file
    - `--load-vars-from` flag (aliased `-l`)
    - ex: `fly -t tutorial sp -p parameters -c pipeline.yml -l credentials.yml`

- Updating `publishing-outputs` pipeline:
    - `cd ../publishing-outputs`
    - `fly -t tutorial sp -p publishing-outputs -c pipeline-parameters.yml -l credentials.yml`
    - `fly -t tutorial up -p publishing-outputs`
    - `fly -t tutorial trigger-job -j publishing-outputs/job-bump-date`
