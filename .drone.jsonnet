local pipelines(steps) = [
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
      build: steps.yarn(['install', 'bootstrap', 'build'])
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

  isConfigurationValid(configuration):: true,

  createStep(stepConfigs):: function (stepName) stepConfigs[stepName]
    + {
      name: stepName,
    }
    + if stepConfigs[stepName].type == 'yarn' then {
      image: 'node',
      commands: stepConfigs[stepName].commands
    } else {},

  stepConfigBuilder: {
    yarn(commands, config = {}): {
      type: 'yarn',
      config: config,
      commands: commands,
    },
  },

  createPipeline(configuration = {}): {
    local config = _pipelineFactory.withDefaults(configuration),
    local validConfiguration = std.assertEqual(_pipelineFactory.isConfigurationValid(config), true),

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
      if std.objectHas(config, 'steps') then std.map(_pipelineFactory.createStep(config.steps), std.objectFields(config.steps)) else [],
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
};

std.map(_pipelineFactory.createPipeline, pipelines(_pipelineFactory.stepConfigBuilder))