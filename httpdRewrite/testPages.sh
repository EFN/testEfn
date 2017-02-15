#!/bin/bash

nCases=0
nSuccess=0

quiet=false
abort=false

#Get options
while getopts 'qa' val
do
  case $val in
    q) quiet=true ;;
    a) abort=true ;;
    ?) exit 1;
  esac
done
let nopts=OPTIND-1
shift ${nopts}

shopt -s extglob

tot_time=0

while [ -n "$1" ]
do
  while read line
  do
    case "$line" in
      \#*)
        continue
      ;;
      *( |	))
        continue
      ;;
    esac
    URL=$(echo $line | cut -d\  -f2)
    EXPECTED_CODE=$(echo $line | cut -d\  -f1)
    EXPECTED_RESULT=$(echo $line | cut -d\  -f3)
    run_start=$(date +%s.%N)
    RES=$(curl -k -D - -s -o /dev/null -c test_jar "$URL")
    run_end=$(date +%s.%N)
    CODE=$(echo "$RES" | head -n 1 | cut -d\  -f2)
    case $CODE in
    200|404|405)
      unset RESULT
      ;;
    301|302|307)
      RESULT=$(echo "$RES" | grep ^Location | cut -d: -f2- | cut -d\;  -f1| sed 's/\s*$//g' | sed 's/^ *//g')
      ;;
    esac
    if [ "${CODE}" = "${EXPECTED_CODE}" -a "$RESULT" = "$EXPECTED_RESULT" ]
    then
      ${quiet} || echo GOOD $URL
      let nSuccess++
    else
      echo FAIL $URL
      echo Got "$CODE:" "$RESULT", expected "$EXPECTED_CODE:" "$EXPECTED_RESULT"
      echo "$RES"
      ${abort} && exit 1
    fi
    run_time=$(echo $run_end - $run_start | bc)
    tot_time=$(echo $tot_time + $run_time | bc)
    echo Run time: ${run_time}s
    let nCases++
  done < "$1"
  shift
done

echo Total runtime: ${tot_time}s
echo ${nSuccess} successes out of ${nCases} cases
