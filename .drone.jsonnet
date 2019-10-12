local environment = {
  GREETEE_NAME: 'Sean'
};

// !!! BEGAN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local Pipeline(options = {}) = {
  kind: 'pipeline',
  name: 'default',
  steps: [
    {
      name: 'say-hi',
      image: 'node:10',
      environment: if std.objectHas(options, 'environment') then options.environment else {},
      commands: [
        'echo ">>> Hello, $${GREETEE_NAME}!"'
      ],
    },
  ],
};

[
  Pipeline({
    environment: environment,
  }),
]