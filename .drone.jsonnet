local configuration = {
  environment: {
    GREETEE_NAME: 'Mensch',
  },
};

// !!! BEGAN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

function () {
  local _helpers = {
    WithDefaults(configuration = {}): {
      environment: if std.objectHas(configuration, 'environment') then configuration.environment else {},
    },

    CreatePipeline(passedConfiguration = {}): {
      local config = _helpers.WithDefaults(passedConfiguration),

      kind: 'pipeline',
      name: 'default',
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
    }
  }

  [
     {
           local config = _helpers.WithDefaults(passedConfiguration),

           kind: 'pipeline',
           name: 'default',
           steps: [
             {
               name: 'say-hi',
               image: 'node:10',
               commands: [
                 'echo ">>> Hello, $${GREETEE_NAME}!"'
               ],
             },
           ],
         }
  ]
}
