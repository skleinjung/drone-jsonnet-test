local pipelines(stepBuilder) = [
  {
    environment: {
      GREETEE_NAME: 'default name',
    },
    steps: {
      generic: {
        image: 'node',
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
      'generic-with-custom-environment': {
        image: 'node',
        environment: {
          GREETEE_NAME: 'generic override',
        },
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
      build: stepBuilder.yarn(['install $${GREETEE_NAME}', 'bootstrap', 'build'])
    }
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local _pipelineFactory = {
  withDefaults(configuration = {}):: configuration + {
    environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
    steps: if std.objectHas(configuration, 'steps') then configuration.steps else [],
  },

  buildBaseStep(stepName, pipelineConfig):: {
    name: stepName,
    environment: pipeline.environment,
  },

  createStep(pipelineConfig):: function (stepName)
    local step = pipelineConfig.steps[stepName];
    buildBaseStep(stepName, pipelineConfig)
      + if (std.objectHas(step, '__builder'))
        then (if (std.objectHas(step, '__config')) then step.__config else {}) + step.__builder(pipelineConfig, step)
        else step,

  createPipeline(configuration = {}): {
    local config = _pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps: std.flattenArrays([
//      [
//        {
//          name: 'npm-auth',
//          image: 'robertstettner/drone-npm-auth',
//          settings: {
//            token: {
//              from_secret: 'NPM_PUBLISH_TOKEN',
//            }
//          },
//        },
//      ], // std.objectFields(o)
      std.map(_pipelineFactory.createStep(config), std.objectFields(config.steps))
//      [
//        {
//          name: 'say-hi',
//          image: config.nodeImage,
//          environment: config.environment,
//          commands: [
//            'echo ">>> Hello, $${GREETEE_NAME}!"'
//          ],
//        },
//      ],
    ]),
  },

  configBuilders:: {
    yarn:: {
      buildConfig(scripts, config = {}): {
        __type: 'yarn',
        __builder: _pipelineFactory.configBuilders.yarn.buildStep,
        __config: config,
        __scripts: scripts,
      },

      buildStep(pipelineConfig, stepConfig): {
        image: pipelineConfig.nodeImage,
        commands: std.map(_pipelineFactory.configBuilders.yarn.createCommand, stepConfig.__scripts),
      },

      createCommand(script):: 'echo ">>> yarn ' + script + '"',
    },
  },
};

std.map(_pipelineFactory.createPipeline, pipelines({
  yarn: _pipelineFactory.configBuilders.yarn.buildConfig,
}))