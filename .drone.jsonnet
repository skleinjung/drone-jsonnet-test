local Pipeline() = {
  kind: pipeline,
  name: default,
  steps: [
    {
      name: 'say-hi',
      image: 'node:10',
      commands: [
        'echo ">>> Hello, world!"'
      ],
    },
  ],
};

[
  Pipeline(),
]