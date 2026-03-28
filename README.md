# Getting Started

This repository is designed to help you get started with the Dacier Scheduler.
You can use this repository as a template to create your own Dacier Scheduler repository or, copy the definitions from here into your repository.

## Get an Instance

The first step is to get an instance of the Dacier Scheduler that is associated with your Azure credentials.
If you don't have an instance, go to TBS or contact your sales person.

## Install our CLI

The Dacier Scheduler has a command line interface (CLI) that is packaged as a NuGet tool. You can install the tool like this:

```bash
dotnet tool install -g Dacier.SchedulerCLI
```

## Configuration

After you have an instance of the Dacier Scheduler you need to do some configuration. The first step is to decide
what "Organizational Units" you want to use. An organizational unit (OU) is exactly what it sounds like, a way to
organize your jobs. Some people use OUs for "Production", "Test" and "Development". Others decide to use an OU for
each application. You could also do a combination of the two.

Another option is to use multiple instances of the Dacier Scheduler but, for now, we will talk as if you have a single instance.

One thing to consider is how you have organized your source control repositories. The Dacier Scheduler is designed to fit
into common project management workflows. A Dacier OU contains information about the source repository that is used to store
job definitions. You can configure:

- Provider
- Owner
- Repository
- Branch
- Path

With these values set, you can use our "sync" CLI command in your CI/CD processes to synchronize your source code with the
deployments to the Dacier Scheduler database.

## Organizational Unit

We will look at the OUDev.yaml file, piece by piece.

```yaml
apiVersion: 1.0
kind: organizationalUnit
metadata:
  name: Dev
  description: Development
  tags:
spec:
```

All Dacier definitions begin with some standard attributes. The "apiVersion" should be set to 1.0. It is provided to "future proof" the definitions.

The "kind" attribute identifies what kind of object will be defined in the "spec" attribute.

The "metadata" contains common attributes including the name of the object, a description and a list of tags.

The "spec:" is the object itself.

The initial portion of the Dev OU definition defines the simple properties of the OU including source code managment (SCM) settings and the theme to be used in the UI when looking at this OU:

```yaml
  scmProvider: GitHub
  scmOwner: daciertech
  scmRepository: SchedulerStartup
  scmBranch: dev
  scmPath: Entities
  themeName: Blue
```

The next section of the OU is a collection of "Variables" with one Variable defined. Variables defines in the OU will
be inherited by all objects defined in the OU:

```yaml
  variables:
  -
    variableName: AppEnvironment
    value: Development
    readOnly: true
    locked: true
    hidden: true
```

The next section of the OU is a collection of "Actions". An action can start a job, react to a job or react to another action. We will step through each action defined in this OU.

The first action is a CompletedJob action. As you might guess, it fires when a job completes. It defines the summary and details messages for the action. In this case, "enabled" is set to false so messages are not sent when a job completes but, if you do have an important job and you want to be notified every time it completes, you can just add a completedJob action with "enabled" set to true. Everything else will be inherited from the completedJob action on the OU. Note that action inheritence depends on the action name matching.

```yaml
  - action: completedJob
    name: CompletedJob
    matchTags: [Default]
    enabled: false
    summaryMessage: 'Job {Job.Name} completed'
    detailedMessage: |
      # Job Completed

      The job {Job.Name} has completed with status {Job.Status}.

```

The next action is a FailedJob action. It is just like the CompletedJob action except it only fires when a job fails. Notice in the detailed message the "{ActiveLink}" value. When the message fires, this will be replace with the URL to pull up the detail view of the active job that failed.

```yaml
  - action: failedJob
    name: FailedJob
    matchTags: [Default]
    summaryMessage: 'Job {Job.Name} failed'
    detailedMessage: |
      # Job Failed

      The job {Job.Name} has failed.
      Details are available here: [Active Link]({ActiveLink}).
```

The CompletedJob and FailedJob actions are "Initiators", they initiate action based on some event. When an action is initiated, we take the match tags from the action initiator and look for a matching "response". The next action is an email action which is a response action. Note the "replyToAddress" property, make sure you set that to an address that will work for your company.

```yaml
  - action: email
    name: EMail
    matchTags: [Default]
    replyToAddress: 'Support@ThisIsYourCompany.com'
```

The last action in this OU is a CronSchedule action. You probably don't want to put a full CronSchedule in an OU because you
normally don't want all of your jobs to run on the same schedule. But, it is a good idea to put a CronSchedule action on an OU so that you can set "enabled" to false on the OU to turn off all CronSchedules. You might want to do this in production during a maintenance period or you might want cron schedules always disabled in a development environment.

## Dynamic Properties

Another thing you might want to configure is "Dynamic Properties". By default, all properties of an entity (folder, job etc.) are set by the yaml that you maintain under source control. We will show you those properties in the web UI but you can't modify them.
You can configure properties as "dynamic" which means that they are allowed to be changes in the web UI and, when importing the definition from yaml, the dynamic properties are *not* overwritten.

You configure dynamic properties by specifying the name of the property in a DynamicConfiguration:

```yaml
apiVersion: 1.0
kind: dynamicProperties
metadata:
  name: DynamicProperties
  description: Root Dynamic Properties
spec:
  organizationalUnit: [Description]
  folder: []
  job: [actions, variables]
  runner: []
  credential: []  
```

When you set dynamicProperties it applies to all organizational units. But, you can also set dynamicProperties at the OU level
so, you can have different dynamic properties in Dev vs. Prod etc.

## Applying YAML Files

Configuration settings (OU, DynamicProperties etc.) must be manually applied. They are not automatically synced with source control.

Before you can do aything with the SchedulerCLI tool you must login with a command like:

```bash
schedulercli login
```

This will initiate Azure login.

Once logged in, you apply yaml files with a commands like:

```bash
schedulercli apply OUDev.yaml
schedulercli apply DynamicProperties.yaml
schedulercli apply DynamicPropertiesDev.yaml --targetFolder \\Dev
```

## Entities

You may recall that the Dev OU is configured to have entities in the Entities folder of the Dev branch. In our Entities folder, you will see a Samples folder and a SamplesFolder.yaml file. You do *not* need to have a yaml file for each folder. When we sync
with source control we will add the same folder structure that you have in source control. You may want to have a yaml file for
some folders so that you can add variables or actions to the folder.

For example, you may want to customize the failed job message for all jobs in a folder. You could do that by adding an action similar to this:

```yaml
  - action: failedJob
    name: FailedJob
    detailedMessage: |
      {DetailedMessage}

      Support team is:
      - Scott (203) 555-1212
      - John (614) 555-2121
```

This will inherit the FailedJob from the OU but change the detailed message to the existing detailed message ({DetailedMessage}) plus some additional information.

### Syncing

You can sync the source control with your instance of the Dacier Scheduler with a command like:

```bash
schedulercli sync Dev
```

## Deploy a Runner

Before you can run jobs you have to deploy at least one runner.

### Azure Runners

You can deploy a runner is Azure by doing *TBS*.

### Unix/Linux Runners

To deploy a runner on a Unix or Linux server (or VM), download an installer from *TBS*.

### Windows Runners

To deploy a runner on a Windows server (or VM), download an installer from *TBS*.
