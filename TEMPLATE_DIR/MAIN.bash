################################
# 0. Make a copy of this directory ...
# 1. Modify these variables
# 2. Modify the args.txt file
# 3. Modify the placeholder_script.json
# 4. When you are ready to go, set the RUN variable

set -e # stops on error
# set -x # shows calls

BUCKET_NAME="simpetestingbucket$(echo $RANDOM | md5sum | head -c 4)" # needs to be low case alnum
JOB_NAME="supertesting$(echo $RANDOM | md5sum | head -c 4)" # Needs to be lowcase  ^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$
FOLD_WAYS=3

############################### DONT CHANGE AFTER HERE
# Use split if you are under linux ...
# Will add support for it in the future
mkdir -p jobs
gsplit --number=l/${FOLD_WAYS} --numeric-suffixes=0 --suffix-length=3 args.txt jobs/job.

# Remove consecutive newlines, extra spacing, replace newlines for semicolons
TASK_COUNT=${FOLD_WAYS}
echo "Replacing $TASK_COUNT,$BUCKET_NAME"
export BUCKET_NAME
export TASK_COUNT
envsubst '${TASK_COUNT},${BUCKET_NAME}' < placeholder_script.json | tee script.json

if [ -z "$RUN" ]; then
  # If run is empty prints, else executes
  echo "gsutil mb gs://${BUCKET_NAME}"
  echo "gsutil cp jobs/job.* gs://${BUCKET_NAME}"
  ls -lcth jobs/job.*
  echo "gsutil cp RUN.bash gs://${BUCKET_NAME}"
  ls -lcth RUN.bash
  echo "gcloud beta batch jobs submit ${JOB_NAME} --location us-central1 --config script.json"
  printf ">>>>>>>>>>>>>>>> THIS WAS A DRY RUN <<<<<<<<<<<<<<<<<<<<\n"
else
  read -p "Are you sure you want to continue? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]] ; then
    gsutil mb gs://${BUCKET_NAME}
    gsutil cp jobs/job.* gs://${BUCKET_NAME}
    gsutil cp RUN.bash gs://${BUCKET_NAME}

    # https://cloud.google.com/sdk/gcloud/reference/beta/batch/jobs/submit#--script-file-path
    gcloud beta batch jobs submit ${JOB_NAME} --location us-central1 --config script.json --script-text="$(cat RUN.bash)"
  fi
fi

