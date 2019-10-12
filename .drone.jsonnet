local pipelines = [
  {
    environment: {
      GREETEE_NAME: 'guyo',
    },
  },
  {
    name: 'pipeline-2',
    environment: {
      GREETEE_NAME: 'other one',
    },
  },
];

// !!! BEGAN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local _pipelineFactory = {
  _withDefaults(configuration = {}): {
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
  },

  createPipeline(configuration = {}): {
    local config = _pipelineFactory.WithDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps: [
      {
        name: 'say-hi',
        image: 'node:10',
        environment: config.environment,
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
    ],
  },
};

std.map(_pipelineFactory.createPipeline, pipelines)
