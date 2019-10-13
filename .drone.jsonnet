local createPipelines(steps) = [
  {
    // optional, applies to each step
    environment: {
      GREETEE_NAME: 'default name',
    },
    // optional
    git: {
      // defaults to email of last commmitter
      authorEmail: 'anything@example.com',
      // defaults to name of last committer
      authorName: 'Mary Sue',
    },

    steps: [
      steps.custom('generic', {
        image: 'node',
        commands: ['echo ">>> Hello, $${GREETEE_NAME}!"'],
      }),
      steps.custom('generic-with-custom-environment', {
        image: 'node',
        environment: {
          GREETEE_NAME: 'generic override',
        },
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      }),
      steps.yarn('install'),
      steps.yarn('build'),

//      steps.publish({
//        // optional, defaults to 'publish'
//        baseStepName: 'publish',
//
//        // optional, defaults to 'master'
//        branch: 'master',
//
//        // optional, defaults to 'release:pre'
//        prereleaseScriptName: 'release:pre',
//        // optional, defaults to 'release:graduate'
//        releaseScriptName: 'release:graduate',
//
//        // optional, defaults to 'NPM_PUBLISH_TOKEN'
//        tokenSecret: 'NPM_PUBLISH_TOKEN',
//
//        // each entry is a prerelease tag/branch names combo
//        configurations: [
//          {
//            branches: ['master'],
//            prerelease: 'alpha',
//          },
//          {
//            branches: ['develop'],
//            prerelease: 'qa',
//            canary: true,
//          },
//          {
//            branches: {
//              exclude: ['master', 'develop'],
//            },
//            prerelease: 'unstable',
//            canary: true,
//          },
//        ],
//      }),
    ],

//    notifications: {
//      slack: {
//        webhookSecret: 'SLACK_NOTIFICATION_WEBHOOK',
//        channel: 'deployments',
//
//        startMessage: |||
//          :arrow_forward: Started <https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|{{repo.name}} build #{{build.number}}> on _{{build.branch}}_
//        |||,
//
//        completeMessage: |||
//          {{#success build.status}}
//            :+1: *<https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|BUILD SUCCESS: #{{build.number}}>*
//          {{else}}
//            :octagonal_sign: *<https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|BUILD FAILURE: #{{build.number}}>*
//          {{/success}}
//
//          Project: *{{repo.name}}*
//          Triggered by: commit to _{{build.branch}}_ (*<https://drone.thrashplay.com/link/thrashplay/{{repo.name}}/commit/{{build.commit}}|{{truncate build.commit 8}}>*)
//
//          ```{{build.message}}```
//        |||
//      },
//    },

    trigger: {
      event: {
        include: ['push'],
      }
    }
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local __initGitHubStep(pipelineConfig) = {
   local defaultEmail = "`git log -1 --pretty=format:'%ae'`",
   local defaultName = "`git log -1 --pretty=format:'%an'`",
   local authorEmail =
     if std.objectHas(pipelineConfig, 'git') then
       if std.objectHas(pipelineConfig.git, 'authorEmail') then pipelineConfig.git.authorEmail else defaultEmail
     else
       defaultEmail,

  local authorName =
     if std.objectHas(pipelineConfig, 'git') then
       if std.objectHas(pipelineConfig.git, 'authorName') then pipelineConfig.git.authorName else defaultName
     else
       defaultName,

   name: 'init-git',
   image: 'alpine/git',
   commands: [
     ': *** Initializing git user information...',
     'git config --local user.email "' + authorEmail + '"',
     'git config --local user.name "' + authorName + '"',
   ],
 };

local __createPublishStep(image, baseStepName, publishConfig, environment = {}) = function(publish) {
  local prereleaseScriptName =
    if std.objectHas(publishConfig, 'prereleaseScriptName')
    then publishConfig.prereleaseScriptName
    else 'release:pre',

  local releaseScriptName =
    if std.objectHas(publishConfig, 'releaseScriptName')
    then publishConfig.releaseScriptName
    else 'release:graduate',

  local releaseName = if std.objectHas(publish, 'prerelease') then publish.prerelease else 'production',
  local scriptName = if std.objectHas(publish, 'prerelease')
    then prereleaseScriptName
    else releaseScriptName,
  local isCanary = std.objectHas(publish, 'canary') && publish.canary,

  name: std.join('-', [baseStepName, releaseName]),
  image: image,
  environment: environment + if std.objectHas(publish, 'prerelease') then { PRERELEASE_ID: publish.prerelease } else {},
  commands: [
    ': *** publishing: ' + releaseName,
    std.join(' ', ['yarn', scriptName, if isCanary then '--canary']),
  ],
  when: {
    branch: publish.branches,
  }
};
local __publish(publishConfig = {}) = {
  local baseStepName =
    if std.objectHas(publishConfig, 'baseStepName')
    then publishConfig.baseStepName
    else 'publish',

  local tokenSecret =
    if std.objectHas(publishConfig, 'tokenSecret')
    then publishConfig.tokenSecret
    else 'NPM_PUBLISH_TOKEN',

  builder: function (pipelineConfig)
    (if std.objectHas(publishConfig, 'configurations') then [
      {
        name: std.join('-', [baseStepName, 'npm-auth']),
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: tokenSecret,
          }
        },
      },
    ] else []) +
    (if std.objectHas(publishConfig, 'configurations')
      then std.map(__createPublishStep(
        pipelineConfig.nodeImage,
        baseStepName,
        publishConfig), publishConfig.configurations)
      else []) +
    (if std.objectHas(publishConfig, 'promotion')
      then [{
//        name: std.join('-', ['promote', '${DRONE_DEPLOY_TO}']),
//          image: pipelineConfig.nodeImage,
//          environment: pipelineConfig.environment + { RELEASE_TYPE: '${DRONE_DEPLOY_TO}' },
//          commands: [': *** promoting release to ${DRONE_DEPLOY_TO}']
//          ],
      }] else [])
};

/**
 * Thrashplay helper library
 */
local __t = {
  execIf(predicate, action, default): if predicate then action() else default
};

local __customStepBuilder(name, config = {}) = {
  build: function (pipelineConfig) [
    config + {
      name: name,
    }
  ],
};

local __yarnStepBuilder(name, scripts = [name], config = {}) = {
  createCommand(script):: std.join(' ', ['echo', 'yarn', script]),

  build: function (pipelineConfig) [
    config + (function (createCommand) {
      name: name,
      image: pipelineConfig.nodeImage,
      commands::
        [': *** yarn -- running commands: [' + std.join(', ', scripts) + ']'] +
        std.map(createCommand, scripts),
    })(self.createCommand)
  ],
};

local __releaseStepBuilder(releaseConfig = {}) = {
  buildVersionSteps(pipelineConfig)::
    if !std.objectHas(releaseConfig, 'version')
      then []
      else __yarnStepBuilder('tag-version', ['version']).build(pipelineConfig),

  build: function (pipelineConfig)
    self.buildVersionSteps(pipelineConfig)
};

local __pipelineFactory = {
  /**
   * Apply default configurations to a pipeline config.
   */
  withDefaults(configuration = {}):: configuration + {
    local defaultEnvironment = {},
    environment: defaultEnvironment + if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
    steps: if std.objectHas(configuration, 'steps') then configuration.steps else [],
    trigger: if std.objectHas(configuration, 'trigger') then configuration.trigger else {},
  },

  withEnvironment(pipelineConfig):: function (step) { environment: pipelineConfig.environment } + step,

  getStartNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'startMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-start',
          settings: {
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.startMessage,
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
          }
        }
      ]
      else [],

  getCompleteNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'completeMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-complete',
          settings: {
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.completeMessage,
          },
          when: {
            status: [ 'success', 'failure' ]
          }
        }
      ]
      else [],

  getInitSteps(pipelineConfig)::
    __pipelineFactory.getStartNotificationSteps(pipelineConfig) +
    [
      __initGitHubStep(pipelineConfig)
    ],

  createSteps(pipelineConfig):: function (step)
    std.map(
      __pipelineFactory.withEnvironment(pipelineConfig),
      if (std.objectHas(step, 'build')) then step.build(pipelineConfig) else []),

  createPipeline(configuration = {}): {
    local config = __pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps:
      __pipelineFactory.getInitSteps(config) +
      std.flattenArrays(std.map(__pipelineFactory.createSteps(config), config.steps)) +
      __pipelineFactory.getCompleteNotificationSteps(config),
    trigger: config.trigger,
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __customStepBuilder,
  yarn: __yarnStepBuilder,
}))
