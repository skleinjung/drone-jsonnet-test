local createPipelines(steps) = [
  {
    environment: {
      GREETEE_NAME: 'default name',
    },
    git: {
      random: 'rabor',
    },
//    npmPublish: {
//      tokenSecretName: 'NPM_PUBLISH_TOKEN',
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
      steps.yarn('build', ['install $${GREETEE_NAME}', 'bootstrap', 'build'])
    ]
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local __pipelineFactory = {
  /**
   * Apply default configurations to a pipeline config.
   */
  withDefaults(configuration = {}):: configuration + {
    environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
    steps: if std.objectHas(configuration, 'steps') then configuration.steps else [],
  },

  createStep(pipelineConfig):: function (step) {
      name: step.name,
      environment: pipelineConfig.environment,
    } + if (std.objectHas(step, 'builder'))
        then (if (std.objectHas(step, 'config')) then step.config else {}) + step.builder(pipelineConfig)
        else {},

  getInitSteps(pipelineConfig):: std.flattenArrays([
    [
      {
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
        image: 'bitnami/git:latest',
        commands: [
          ': *** Initializing git user information...',
          'git config --global user.email "' + authorEmail + '"',
          'git config --global user.name "' + authorName + '"',
        ],
      },
    ],
    if std.objectHas(pipelineConfig, 'npmPublish') then [
      {
        name: 'init-npm-auth',
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: pipelineConfig.npmPublish.tokenSecretName,
          }
        },
      }
    ] else [],
  ]),

  createPipeline(configuration = {}): {
    local config = __pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps: std.flattenArrays([
      __pipelineFactory.getInitSteps(config),
      std.map(__pipelineFactory.createStep(config), config.steps)
    ]),
  },

  configBuilders:: {
    custom: {
      getStepConfig(name, config = {}): {
        name: name,
        config: config,
        builder: __pipelineFactory.configBuilders.custom.buildStep,
      },

      // use provided configuration, without augmenting it
      buildStep(pipelineConfig): {},
    },

    yarn: {
      getStepConfig(name, scripts, config = {}): {
        name: name,
        config: config,
        builder: __pipelineFactory.configBuilders.yarn.buildStep({ scripts: scripts }),
      },

      buildStep(stepConfig): function (pipelineConfig) {
        image: pipelineConfig.nodeImage,
        commands: std.map(__pipelineFactory.configBuilders.yarn.createCommand, stepConfig.scripts),
      },

      createCommand(script):: std.join(' ', ['echo', 'yarn', script]),
    },
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __pipelineFactory.configBuilders.custom.getStepConfig,
  yarn: __pipelineFactory.configBuilders.yarn.getStepConfig,
}))