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
    // optional
//    npmPublish: {
//      tokenSecret: 'NPM_PUBLISH_TOKEN',
//    },
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

      steps.publish(),
    ]
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

local __custom(name, config = {}) = {
  builder: function (pipelineConfig) [
    config + {
      name: name,
    }
  ],
};

local __createCommand(script) = std.join(' ', ['echo', 'yarn', script]);
local __yarn(name, scripts = [name], config = {}) = {
  builder: function (pipelineConfig) [
    config + {
      name: name,
      image: pipelineConfig.nodeImage,
      commands: [': *** yarn -- running commands: [' + std.join(', ', scripts) + ']'] + std.map(__createCommand, scripts),
    }
  ],
};

local __createReleaseStep(image, baseStepName, stepName, scriptName, branch, environment = {}) = {
  name: std.join('-', [baseStepName, stepName]),
  image: image,
  environment: environment,
  commands: [
    ': *** publishing release',
    std.join(' ', ['echo', 'yarn', scriptName]),
  ],
  when: {
    branch: [branch]
  }
};
local __createPrereleaseStep(prereleaseConfig, image, baseStepName, scriptName, environment = {}) = function(prereleaseName) {
  name: std.join('-', [baseStepName, 'prerelease', prereleaseName]),
  image: image,
  environment: environment + { PRERELEASE_ID: prereleaseName },
  commands: [
    ': *** publishing pre-release: ' + prereleaseName,
    std.join(' ', ['echo', 'yarn', scriptName]),
  ],
  when: {
    branch: prereleaseConfig[prereleaseName]
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

  local prereleaseScriptName =
    if std.objectHas(publishConfig, 'prereleaseScriptName')
    then publishConfig.prereleaseScriptName
    else ['release:pre'],

  local releaseScriptName =
    if std.objectHas(publishConfig, 'releaseScriptName')
    then publishConfig.releaseScriptName
    else ['release:graduate'],

  local releaseBranch =
    if std.objectHas(publishConfig, 'branch')
    then publishConfig.branch
    else 'master',

  builder: function (pipelineConfig)
    [
      {
        name: std.join('-', [baseStepName, 'npm-auth']),
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: tokenSecret,
          }
        },
      },
      __createReleaseStep(pipelineConfig.nodeImage, baseStepName, 'release', releaseScriptName, releaseBranch),
    ] +
    if std.objectHas(pipelineConfig, 'prereleases')
      then std.map(__createPrereleaseStep(
        pipelineConfig.prereleases,
        pipelineConfig.nodeImage,
        baseStepName,
        releaseScriptName), pipelineConfig.prereleases)
      else []
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
  },

  withEnvironment(pipelineConfig):: function (step) { environment: pipelineConfig.environment } + step,

  getInitSteps(pipelineConfig)::
    [
      __initGitHubStep(pipelineConfig)
    ] + if std.objectHas(pipelineConfig, 'npmPublish') then
    [
      {
        name: 'init-npm-auth',
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: pipelineConfig.npmPublish.tokenSecret,
          }
        },
      }
    ] else [],

  createSteps(pipelineConfig):: function (step)
    std.map(
      __pipelineFactory.withEnvironment(pipelineConfig),
      if (std.objectHas(step, 'builder')) then step.builder(pipelineConfig) else []),

  createPipeline(configuration = {}): {
    local config = __pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps:
      __pipelineFactory.getInitSteps(config) +
      std.flattenArrays(std.map(__pipelineFactory.createSteps(config), config.steps)),
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __custom,
  publish: __publish,
  yarn: __yarn,
}))