
# Use GCP batch jobs to complete tasks

## TLDR

- Copy the template directory `TEMPLATE_DIR/`
- read the files
- follow the instructions

## Implementation

The idea is fairly simple,
When defiing a batch job, you set these two arguments:

1. `TASK_COUNT`: Optional. The number of tasks for the job. The value must be a whole number between 1 and 10000. If the taskCount field is not specified, the value is set to 1.
2. `PARALLELISM`: Optional. The number of tasks the job runs concurrently. The number cannot be larger than the number of tasks and must be a whole number between 1 and 1000. If the parallelism field is not specified, the value is set to 1.

So, lets say for 4 tasks and parallelism 2, you would be assigned
2 "computers", computer 1 would run tasks 0 and 1, computer 2 would run tasks 2 and 3.

These will be available as env variables using:
- `${BATCH_TASK_INDEX}`
- `${BATCH_TASK_COUNT}`, this will always be 4 in our example

Therefore, if we have a large number of tasks that we want to divide
X-ways (say .... 7000, in 20 computers), we can make a file that contains
the arguments for each task, get that into a bucket and have
each computer read it.

This creates a bucket, writes to it X files (20 in this example),
each file containing on each line the arguments for execution.


## Usage

Preparation:
1. Select a name for your bucket ...
2. Make an args.txt file containing all the arguments (1000 instructions).
3. Select the numer of ways you want to split it.

Note: It requires split from coreutils, not the mac bundled version...

```
BUCKET_NAME="MYSUPERCOOLBUCKET"
FOLD_WAYS=10

# Use split if you are under linux ...
# Will add support for it in the future
gsplit --number=l/${FOLD_WAYS} --numeric-suffixes=0 --suffix-length=3 args.txt job.

gsutil mb gs://${BUCKET_NAME}
gsutil cp job.* gs://${BUCKET_NAME}

```

Within each worker ... this would run

```
job_name="job.$( printf "%03d\n" $BATCH_TASK_INDEX )"
gsutil cp gs://BUCKET_NAME/${job_name} .

for arg in `cut -d$'\n' -f1 ${job_name}`; do
    echo $arg
done
```

Which we bundle as part of "template_job.bash"

```
CODE_PLACEHOLDER=$(cat assets/template_job.bash) 
CODE_PLACEHOLDER=$CODE_PLACEHOLDER TASK_COUNT=$FOLD_WAYS envsubst < assets/placeholder_script.json | tee script.json
```


### Main build script

```
BUCKET_NAME="MYSUPERCOOLBUCKET"
JOB_NAME="SUPERTESTING"
FOLD_WAYS=10

# Use split if you are under linux ...
# Will add support for it in the future
gsplit --number=l/${FOLD_WAYS} --numeric-suffixes=0 --suffix-length=3 args.txt job.

gsutil mb gs://${BUCKET_NAME}
gsutil cp job.* gs://${BUCKET_NAME}

CODE_PLACEHOLDER=$(cat assets/template_job.bash) 
CODE_PLACEHOLDER=$CODE_PLACEHOLDER TASK_COUNT=$FOLD_WAYS envsubst < assets/placeholder_script.json | tee script.json

gcloud beta batch jobs submit ${JOB_NAME} \  
  --location us-central1 \
  --config script.json
```
