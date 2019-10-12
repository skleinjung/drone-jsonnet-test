local environment = {
  GREETEE_NAME: 'person',
};

// !!! BEGAN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local helpers = {
  CreatePipeline(): {
    kind: 'pipeline',
    name: 'default',
    steps: [
      {
        name: 'say-hi',
        image: 'node:10',
        environment: if std.objectHas($, 'environment') then $.environment else {},
        commands: [
          'echo ">>> Hello, $${GREETEE_NAME}!"'
        ],
      },
    ],
  }
};

function() [
   helpers.CreatePipeline(),
]
