
JOB_NAME="job.$( printf %03d $BATCH_TASK_INDEX )"
echo ${job_name}


main () {
  echo ">>>>>>>>" $@ "<<<<<<<<<"
}

file="mnt/share/${JOB_NAME}"

while read -r arg; do
    main $arg | tee --append /mnt/share/output_task_${BATCH_TASK_INDEX}.txt
done <$file

