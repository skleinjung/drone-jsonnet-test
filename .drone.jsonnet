local environment = import 'environment.libsonnet';

local Pipeline() = {
  kind: 'pipeline',
  name: 'default',
  steps: [
    {
      name: 'say-hi',
      image: 'node:10',
      environment: environment,
      commands: [
        'echo ">>> Hello, ${GREETEE_NAME}!"'
      ],
    },
  ],
};

[
  Pipeline(),
]