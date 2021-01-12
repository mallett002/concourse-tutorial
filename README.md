# concourse-tutorial

## 1. Up and Running
- At root of project: `docker-compose up -d`
- Open http://127.0.0.1:8080/ in your browser:
    -  click download fly-cli
    - `sudo mkdir -p /usr/local/bin`
    - `sudo mv ~/Downloads/fly /usr/local/bin`
    - `sudo chmod 0755 /usr/local/bin/fly`
    - If getting an error when trying to open fly run: `xattr -d com.apple.quarantine /usr/local/bin/fly`
- Set a target to make auth requests via fly:
    - `fly —target my-target login —concourse-url http://127.0.0.1:8080 -u admin -p admin`
    - `fly --target tutorial sync` to match the version of fly
    - can see target saved: `cat ~/.flyrc`
    - Or run `fly targets` to see a list of them

## 2. Running Tasks
- Can run from command line or within a pipeline job
- Command line:
    - `cd tutorials/basic/task-hello-world`
    - `fly -t tutorial execute -c task_hello_world.yml`
        - `-t`: target
        - `-c`: config
- In a pipeline job as defined in a `pipeline.yml`
- Every task runs in a container
    - `image_resource`: Pre-baked dependencies for the task
        - ex: `dcind` for docker-compose

## 3. Task Inputs
- Supports image inputs (`image_resource`) & `inputs` for files/folders
- `cd tutorials/basic/task-inputs`
- Try `fly -t tutorial e -c inputs_required.yml` (e: `execute`)
- Try `fly -t tutorial e -c inputs_required.yml -i some-important-input=.`
    - `-i` (input) sets variable to current dir
    - `-i name=value`
- If `inputs` value is same as current dir name, don't need `-i`
    - ex: `fly -t tutorial e -c input_parent_dir.yml`

## 4. Task Scripts
- `inputs` supports 2 types:
    - requirements/dependencies (Like #3)
    - scripts to be executed
- `cd ../task-scripts`
- `fly -t tutorial e -c task_show_uname.yml`
- `task-scripts/task_show_uname.sh` is made available through the `inputs` from current dir

## 5. Basic Pipeline
- `cd basic/basic-pipeline`
- `fly -t tutorial set-pipeline -c pipeline.yml -p hello-world`
    - `-p`: alias for `--pipeline`
- To unpause: `fly -t tutorial unpause-pipeline -p hello-world`
- To trigger:
  - In web ui, click on `job-hello-world` & then the `+`
  - or trigger from command line: `fly -t tutorial trigger-job --job hello-world/job-hello-world`

## 6. Pipeline Resources
- All inputs that are stored externally from concourse
- Pre-defined resource types: https://resource-types.concourse-ci.org/
    - ex: `git`, `docker-image`, `slack-notifier`

- To run:
    - `cd ../pipeline-resources`
    - Set pipeline: `fly -t tutorial sp -c pipeline.yml -p hello-world`
    - To unpause: `fly -t tutorial up -p hello-world`
    - Trigger: `fly -t tutorial trigger-job --job hello-world/job-hello-world`

- The `hello-world` Task has access to the `resource-tutorial` git Resource
    - Under the `resource-tutorial/` path

## 7. Job Outputs in Terminal
- Can view output of a job with `watch --job` (or just `-j`)
- ex: 
    - trigger: `fly -t tutorial trigger-job --job hello-world/job-hello-world`
    - watch: `fly -t tutorial watch --job hello-world/job-hello-world`
    - Or trigger & watch in one command:
        - `fly -t tutorial trigger-job -j hello-world/job-hello-world -w`
    - To see all builds: `fly -t tutorial builds`
    - Can add `--build NUM` for specific build
        - ex: `fly -t tutorial watch --build 1` to see build #1
    - leave off `--job` to see one-offs

## 8. Triggering Jobs with Resources
- When resource changes, cause a job to trigger: `trigger: true`
    - ex:
        - A git repo has a new commit
        - A GitHub project cuts a new release
        - Time resource reports new version
- `cd tutorials/basic/triggers/`
- `fly sp -t tutorial -c pipeline.yml -p hello-world`
- `fly up -t tutorial -p hello-world`
- Solid line: trigger resource

## 9. Destroying Pipelines
`fly -t tutorial destroy-pipeline -p hello-world`

## 10. Resource Inputs in Job Tasks
- Resources needed to run tests for a simple app:
    - task `image` with dependencies (Go programming language)
    - input `resource` with task script for running test
    - input `resource` containing app source code

- Ex:
    - `cd ../job-inputs`
    - `fly -t tutorial sp -p simple-app -c pipeline.yml`
    - `fly -t tutorial up -p simple-app`
    - Navigate to: http://127.0.0.1:8080/teams/main/pipelines/simple-app
 
 ## 11. Passing Task Outputs to Task Inputs
- A task's inputs can also come from the outputs of previous tasks
- Task `outputs`
- Input from same name as output
- Output creates a directory with same name

-Ex:
   - `cd ../task-outputs-to-inputs`
   - `fly -t tutorial sp -p pass-files -c pipeline.yml`
   - `fly -t tutorial up -p pass-files`
   - `fly -t tutorial trigger-job -j pass-files/job-pass-files -w`
 
## 12. Publishing Outputs
- Push modified git repo to a remote endpoint
- Gist: https://gist.github.com/mallett002/ff05df0e99ea7369a5e29b1199d01601
- private key: `~/.ssh/id_rsa_concourse`
    - copy and past into `tutorials/basic/publishing-outputs/pipeline.yml`
    - `cd ../publishing-outputs`
    - `fly -t tutorial sp -p publishing-outputs -c pipeline.yml`
    - `fly -t tutorial up -p publishing-outputs`
    
- Output from the `task: bump-timestamp-file` is input for `resource-gist`

## 13. Parameters
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

## 14. Passing Resources Between Jobs
- `passed`: Only trigger and fetch resources that succeed through given list
- ex:
    - `cd ../pipeline-jobs`
    - `fly -t tutorial sp -p publishing-outputs -c pipeline.yml -l ../publishing-outputs/credentials.yml`
    - `fly -t tutorial trigger-job -w -j publishing-outputs/job-bump-date`
