# Jenkins Slack Notification
A bash script to notify slack about jenkins jobs status...

## Configuration
### Prepare slack
In your account go to apps -> build and coustom integration for your team. Here you have the Incoming WebHooks link...
Something like this: https://<YOUR TEAM>.slack.com/apps/build/custom-integration and create a new one for the channel where you want the notifications.
### Configure the script
Replace:
```
HOOK_URL="https://hooks.slack.com/services/SLACK/HASH/BLABLABLA"
#Jenkins hosts plus port if neceseary
JENKINS_HOST="127.0.0.1:1234"
JOB_PATH="/job/path/"
JENKINS_USER="user"
#Token is in JENKINS_HOST/user/dropcar/configure
API_TOKEN="token"
```
with your data.

### Test
For test the configuration you can:
```
chmod +x script.bash
./script.bash
```

You should see the notification in slack.

## Configure in jenkins
Create a new freestyle project in `Build Triggers` select _Build after other projects are built_ and complete with the name of the job you want to control. Also check _Trigger even if the build fails_. 

In **Build** section add a shell step and copy/paste the bash script.

This is all.
