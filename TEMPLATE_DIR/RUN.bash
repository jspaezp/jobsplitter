
JOB_NAME="job.$( printf %03d $BATCH_TASK_INDEX )"
echo ${job_name}

cp mnt/share/RUN.bash .
cp mnt/share/${JOB_NAME} .

main () {
  echo ">>>>>>>>" $@ "<<<<<<<<<"
}

for arg in `cut -d$'\n' -f1 ${JOB_NAME}`; do
    main $arg | tee --append /mnt/share/output_task_${BATCH_TASK_INDEX}.txt
done
