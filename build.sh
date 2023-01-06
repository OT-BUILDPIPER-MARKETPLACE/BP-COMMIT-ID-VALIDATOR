#!/bin/bash

source functions.sh
source log-functions.sh

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
done < <( cat commit.json | jq .comment[]|egrep -o 'https://[^ ]+/commit/[a-f0-9]*'|cut -d "/" -f 8 )

if [ $GLOBAL_STATUS == 0 ]
then
     generateOutput  COMMIT_MESSAGE_VALIDATOR true "Congratulations build succeeded!!!"
     logInfoMessage "Commit message is matches to Jira task description."
     logInfoMessage "commit message validator sucessfull"

else
     generateOutput COMMIT_MESSAGE_VALIDATOR false "Commit message validation is failed please check!!!!!"
     if [[ $VALIDATION_FAILURE_ACTION == "FAILURE" ]]
     then
          logErrorMessage "Commit message doesn't match to Jira task description"
          logErrorMessage "commit message validator unsucessfull"
          exit 1

     else
          logWarningMessage "Commit id's doesn't match to Jira task description please check!!!!!"
     fi
fi