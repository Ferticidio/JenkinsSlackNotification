#!/bin/bash

# Send notification using Slack API
# will send to https://hooks.slack.com/services/BLA/BLA/BLAA

## Configuration:

HOOK_URL="https://hooks.slack.com/services/SLACK/HASH/BLABLABLA"
#Jenkins hosts plus port if neceseary
JENKINS_HOST="127.0.0.1:1234"
JOB_PATH="/job/path/"
JENKINS_USER="user"
#Token is in JENKINS_HOST/user/dropcar/configure
API_TOKEN="token"

## End Configuration

URL="http://"$(echo $JENKINS_USER)":"$(echo $API_TOKEN)"@"$(echo ${JENKINS_HOST}${JOB_PATH})""
JOB_URL="http://$(echo ${JENKINS_HOST}${JOB_PATH})"
NEW_URL="$(echo $URL)""api/json"

# Get the built info json
API=$(curl --insecure $NEW_URL)

LAST_BUILD=$(python -c "import sys, json; print json.loads('$API')['builds'][0]['number']")
LAST_BUILD_API=$(echo ${URL}${LAST_BUILD})"/api/json"
LAST_BUILD_JSON=$(curl $LAST_BUILD_API)

#replace \ in the comments
LAST_BUILD_JSON=$(sed -r 's|\\||g' <<< $LAST_BUILD_JSON)

#We use python to parse de json
NAME=$(python -c "import sys, json; print json.loads('$LAST_BUILD_JSON')['fullDisplayName']")
STATUS=$(python -c "import sys, json; print json.loads('$LAST_BUILD_JSON')['result']")
DURATION=$(python -c "import sys, json; print json.loads('$LAST_BUILD_JSON')['duration']")
DURATION=$(($DURATION/1000))

CHANGES=$(python -c "import sys, json; print len(json.loads('$LAST_BUILD_JSON')['changeSet']['items'])")

CHANGESET=$(python -c "import sys, json; print json.loads('$LAST_BUILD_JSON')['changeSet']['items']")

CHANGESET=""

i="0"
while [ $i -lt $CHANGES ]
do
CHANGESET=$CHANGESET" "$(python -c "# -*- coding: utf-8 -*-; 
import sys, json; 
print u''.join(
json.loads('$LAST_BUILD_JSON')['changeSet']['items'][$i]['author']['"fullName"'] 
+ ': ' 
+ json.loads('$LAST_BUILD_JSON')['changeSet']['items'][$i]['comment']).encode('utf-8')")
i=$[$i+1]
done

CHANGESET=$(sed -r "s|'|\'|g" <<< $CHANGESET)

LAST_JOB_URL=$(echo ${JOB_URL}${LAST_BUILD})

if [ "$STATUS" = "SUCCESS" ]; then 
    COLOR="#00D000"
    MSG="It ran successfully with a duration of: '$(echo $DURATION)' seconds"
else
    COLOR="#D00000"
    MSG="Failed Embarrassingly after: '$(echo $DURATION)' seconds"
fi;

CHANGEFIELD=""
if [ ${#CHANGESET} -gt 0 ]; then 
   CHANGEFIELDS=',{
               "title": "Changes",
               "value": "'$(echo $CHANGESET)'",
               "short": true
            }'
  echo $CHANGEFIELDS
fi;

MESSAGE='{
   "attachments":[
      {
         "fallback":"Last JOB: <'$(echo $LAST_JOB_URL)'>",
         "pretext":"Last JOB: <'$(echo $LAST_JOB_URL)'>",
         "color":"'$(echo $COLOR)'",
         "fields":[
            {
               "title":"'$(echo $NAME)'",
               "value":"'$(echo $MSG)'",
               "short":false
            }'$(echo $CHANGEFIELDS)'
         ]
      }
   ]
}'

curl -X POST -H 'Content-type: application/json' --data "$(echo $MESSAGE)" $HOOK_URL
