#!/bin/bash

source functions.sh
source log-functions.sh

logInfoMessage "I'll validated the git commit id and Jira issue commit id for the [$CODEBASE_DIR] repository."
sleep  $SLEEP_DURATION

GIT_COMMIT_ID=$(git log --pretty=format:"%H")

GLOBAL_STATUS=1
while IFS= read  line; do
	LOCAL_STATUS=1
	for i in ${GIT_COMMIT_ID[@]} 
	do
		if [ $line == $i ] 
		then
			LOCAL_STATUS=0	
		fi
	done	
	GLOBAL_STATUS=$(( GLOBAL_STATUS&LOCAL_STATUS ))	
done < <( cat /bp/data/pipeline_context_param | jq .comment[]|egrep -o 'https://[^ ]+/commit/[a-f0-9]*'|cut -d "/" -f 8 )

if [ $GLOBAL_STATUS == 0 ]
then
     generateOutput  COMMIT_ID_VALIDATOR true "Congratulations build succeeded!!!"
     logInfoMessage "Commit id is matches to Jira issue commit id."
     logInfoMessage "Commit id validatation sucessfull"

else
     generateOutput COMMIT_ID_VALIDATOR false "Commit id validation is failed please check!!!!!"
     if [[ $VALIDATION_FAILURE_ACTION == "FAILURE" ]]
     then
          logErrorMessage "Commit id doesn't match to Jira issue commit id"
          logErrorMessage "Commit id validatation unsucessfull"
          exit 1

     else
          logWarningMessage "Commit id doesn't match to Jira issue commit id please check!!!!!"
     fi
fi
