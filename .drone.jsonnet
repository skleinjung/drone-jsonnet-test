local pipelines = [
  {
    environment: {
      GREETEE_NAME: 'guyo',
    },
    nodeImage: 'node:8',
  },
  {
    name: 'pipeline-2',
    environment: {
      GREETEE_NAME: 'other one',
    },
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local _pipelineFactory = {
  withDefaults(configuration = {}):: {
    environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
  },
  createPipeline(configuration = {}): {
    local config = _pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps: [
      {
        name: 'say-hi',
        image: config.nodeImage,
        environment: config.environment,
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
    ],
  },
};

std.map(_pipelineFactory.createPipeline, pipelines)
