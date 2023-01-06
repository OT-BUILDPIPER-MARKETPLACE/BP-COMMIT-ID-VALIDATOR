FROM alpine
RUN apk add --no-cache --upgrade bash
RUN apk add jq
RUN apk add git
COPY commit.json .
COPY build.sh . 
RUN chmod +x build.sh
COPY BP-BASE-SHELL-STEPS . 
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION FAILURE
ENV ACTIVITY_SUB_TASK_CODE COMMIT_MESSAGE_VALIDATOR
ENTRYPOINT [ "./build.sh" ]