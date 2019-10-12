local pipelines = [
  node.createPipeline({
    environment: {
      GREETEE_NAME: 'guyo',
    },
  }),
  node.createPipeline({
    name: 'pipeline-2',
    environment: {
      GREETEE_NAME: 'guyo',
    },
  }),
];

// !!! BEGAN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local node = {
  _withDefaults(configuration = {}): {
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
  },

  createPipeline(configuration = {}): {
    local config = _helpers.WithDefaults(configuration),

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

pipelines