local pipelines = [
  {
    environment: {
      GREETEE_NAME: 'other one',
    },
    steps: {
      generic: {
        image: 'node:8',
        environment: {
          GREETEE_NAME: 'generic override',
        },
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
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
  },

//  createStep(stepsConfig):: function(stepName) stepsConfig[stepName] + {
//    name: stepName,
//  },

  createStep(stepConfigs):: function (stepName) stepConfigs[stepName] + {
    name: stepName,
  },

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

std.map(_pipelineFactory.createPipeline, pipelines)
