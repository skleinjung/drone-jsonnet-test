local configurePipelines(steps) = [
  {
    // optional, applies to each step
    environment: {
      GREETEE_NAME: 'default name',
    },
    // optional
    git: {
      // defaults to email of last commmitter
      authorEmail: 'anything@example.com',
      // defaults to name of last committer
      authorName: 'Mary Sue',
    },

    steps: [
      steps.custom('generic', {
        image: 'node',
        commands: ['echo "*** Hello, $${GREETEE_NAME}!"'],
      }),
      steps.custom('generic-with-custom-environment', {
        image: 'node',
        environment: {
          GREETEE_NAME: 'generic override',
        },
        commands: [
          'echo "*** Hello, $${GREETEE_NAME}!"'
        ],
      }),
      steps.yarn('install'),
      steps.yarn('build'),

//      steps.publish({
//        // optional, defaults to 'publish'
//        baseStepName: 'publish',
//
//        // optional, defaults to 'master'
//        branch: 'master',
//
//        // optional, defaults to 'release:pre'
//        prereleaseScriptName: 'release:pre',
//        // optional, defaults to 'release:graduate'
//        releaseScriptName: 'release:graduate',
//
//        // optional, defaults to 'NPM_PUBLISH_TOKEN'
//        tokenSecret: 'NPM_PUBLISH_TOKEN',
//
//        // each entry is a prerelease tag/branch names combo
//        configurations: [
//          {
//            branches: ['master'],
//            prerelease: 'alpha',
//          },
//          {
//            branches: ['develop'],
//            prerelease: 'qa',
//            canary: true,
//          },
//          {
//            branches: {
//              exclude: ['master', 'develop'],
//            },
//            prerelease: 'unstable',
//            canary: true,
//          },
//        ],
//      }),
    ],

    trigger: {
      event: {
        include: ['push'],
      }
    }
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local __createPublishStep(image, baseStepName, publishConfig, environment = {}) = function(publish) {
  local prereleaseScriptName =
    if std.objectHas(publishConfig, 'prereleaseScriptName')
    then publishConfig.prereleaseScriptName
    else 'release:pre',

  local releaseScriptName =
    if std.objectHas(publishConfig, 'releaseScriptName')
    then publishConfig.releaseScriptName
    else 'release:graduate',

  local releaseName = if std.objectHas(publish, 'prerelease') then publish.prerelease else 'production',
  local scriptName = if std.objectHas(publish, 'prerelease')
    then prereleaseScriptName
    else releaseScriptName,
  local isCanary = std.objectHas(publish, 'canary') && publish.canary,

  name: std.join('-', [baseStepName, releaseName]),
  image: image,
  environment: environment + if std.objectHas(publish, 'prerelease') then { PRERELEASE_ID: publish.prerelease } else {},
  commands: [
    ': *** publishing: ' + releaseName,
    std.join(' ', ['yarn', scriptName, if isCanary then '--canary']),
  ],
  when: {
    branch: publish.branches,
  }
};
local __publish(publishConfig = {}) = {
  local baseStepName =
    if std.objectHas(publishConfig, 'baseStepName')
    then publishConfig.baseStepName
    else 'publish',

  local tokenSecret =
    if std.objectHas(publishConfig, 'tokenSecret')
    then publishConfig.tokenSecret
    else 'NPM_PUBLISH_TOKEN',

  builder: function (pipelineConfig)
    (if std.objectHas(publishConfig, 'configurations') then [
      {
        name: std.join('-', [baseStepName, 'npm-auth']),
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: tokenSecret,
          }
        },
      },
    ] else []) +
    (if std.objectHas(publishConfig, 'configurations')
      then std.map(__createPublishStep(
        pipelineConfig.nodeImage,
        baseStepName,
        publishConfig), publishConfig.configurations)
      else []) +
    (if std.objectHas(publishConfig, 'promotion')
      then [{
//        name: std.join('-', ['promote', '${DRONE_DEPLOY_TO}']),
//          image: pipelineConfig.nodeImage,
//          environment: pipelineConfig.environment + { RELEASE_TYPE: '${DRONE_DEPLOY_TO}' },
//          commands: [': *** promoting release to ${DRONE_DEPLOY_TO}']
//          ],
      }] else [])
};

/**
 * Thrashplay helper library
 */
local __t = {
  castArray(value): if (__t.isArray(value)) then value else [value],
  execIf(predicate, action, default): if predicate then action() else default,
  hasNonEmptyArray(container, propertyName):
    std.objectHas(container, propertyName)
      && __t.isArray(container[propertyName])
      && std.length(container[propertyName]) > 0,
  isArray(value): std.type(value) == 'array',
  nullIfEmpty(array): if std.length(array) == 0 then null else array,

  /**
   * Validates a set of conditions, returning an array of error messages or null.
   *
   * The 'conditions' parameter is an object with arbitrary keys, each is mapped to a boolean value. If any of the
   * booelean values are false, then the key will be used as a returned error message. If every condition is true, then
   * function returns null.
   */
  assertAll(conditions):
    __t.nullIfEmpty(__t.withoutNulls(std.map((function (key) if !conditions[key] then key), conditions))),

  withoutNulls(array): std.filter((function(value) value != null), array),
};

/**
 * PipelineConfiguration
 *
 * Configures global options for a pipeline. See __defaultPipelineConfiguration
 * for information on it's properties, and what values are used as defaults.
 */

local __defaultPipelineConfiguration = {
  /**
   * Defines environment variables that will be injected into every step.
   */
  environment: {},

  /**
   * Name of the pipeline
   */
  name: 'default',

  /**
   * Default Node image tag to use for this pipeline.
   */
  nodeImage: 'node:lts',

  /**
   * List of step builders
   */
  stepBuilders: [],

  /**
   * Trigger conditions for this pipeline.
   * Must be an object matching the Drone trigger specification. See
   * https://docker-runner.docs.drone.io/configuration/trigger/ for more
   * information.
   */
  trigger: {}
};

/**
 * Builders
 *
 * A builder is a function that takes arbitrary parameters, and returns an
 * object that must have 'build' function. The build function must take a
 * 'PipelineConfiguration' object, and return a single Step object, or an array
 * of Step objects.
 *
 * Step objects should match the Step configuration requirements for the version
 * of Drone in use. See https://docker-runner.docs.drone.io/configuration/steps/
 * for available options.
 *
 * In addition to to the required 'build' function, a Step may optionally define
 * a 'validate' function. This method is used to validate the step's
 * configuration, and generate messages describing invalid options. The validate
 * function must return an array of strings. If any step has errors, then the
 * pipeline will abort, logging the messages generated by Steps.
 */

/**
 * Creates a custom, named step from an arbitrary Step configuration.
 * See https://docker-runner.docs.drone.io/configuration/steps/ for information
 * on valid configuration options.
 */
local __customStepBuilder(name = null, config = {}) = {
  validate: function (pipelineConfig) [
    if name == null then 'Custom step definition is missing a "name".',
    if !std.objectHas(config, 'image') then 'Step "' + name + '" is missing a container image.'
  ],

  build: function (pipelineConfig) [
    config + {
      name: name,
    }
  ],
};

/**
 * Creates a step that executes one or more Yarn commands.
 */
local __yarnStepBuilder(name, scripts = [name], config = {}) = {
  createCommand(script):: std.join(' ', ['echo', 'yarn', script]),

  build: function (pipelineConfig) [
    config + (function (createCommand) {
      name: name,
      image: pipelineConfig.nodeImage,
      commands:
        [': *** yarn -- running commands: [' + std.join(', ', scripts) + ']'] +
        std.map(createCommand, scripts),
    })(self.createCommand)
  ],
};

local __releaseStepBuilder(releaseConfig = {}) = {
  buildVersionSteps(pipelineConfig)::
    if !std.objectHas(releaseConfig, 'version')
      then []
      else __yarnStepBuilder('tag-version', ['version']).build(pipelineConfig),

  build: function (pipelineConfig)
    self.buildVersionSteps(pipelineConfig)
};

local __initGitStepBuilder() = {
  build: function (pipelineConfig) {
    local defaultEmail = "`git log -1 --pretty=format:'%ae'`",
    local defaultName = "`git log -1 --pretty=format:'%an'`",
    local authorEmail =
      if std.objectHas(pipelineConfig, 'git') then
        if std.objectHas(pipelineConfig.git, 'authorEmail') then pipelineConfig.git.authorEmail else defaultEmail
      else
        defaultEmail,

    local authorName =
      if std.objectHas(pipelineConfig, 'git') then
        if std.objectHas(pipelineConfig.git, 'authorName') then pipelineConfig.git.authorName else defaultName
      else
        defaultName,

    name: 'init-git',
    image: 'alpine/git',
    commands: [
      ': *** Initializing git user information...',
      'git config --local user.email "' + authorEmail + '"',
      'git config --local user.name "' + authorName + '"',
    ]
  },
};

local __pipelineFactory() = {
  local pipelineFactory = self,

  /**
   * Apply default configurations to a pipeline config.
   */
  withDefaults(configuration = {}):: configuration + {
    local defaultEnvironment = {},
    environment: defaultEnvironment + if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
    steps: if std.objectHas(configuration, 'steps') then configuration.steps else [],
    trigger: if std.objectHas(configuration, 'trigger') then configuration.trigger else {},
  },

  withEnvironment(pipelineConfig):: function (step) { environment: pipelineConfig.environment } + step,

  getStartNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'startMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-start',
          settings: {
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.startMessage,
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
          }
        }
      ]
      else [],

  getCompleteNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'completeMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-complete',
          settings: {
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.completeMessage,
          },
          when: {
            status: [ 'success', 'failure' ]
          }
        }
      ]
      else [],

  validateSteps(pipelineConfig, stepBuilders):
    local validateStep(pipelineConfig) = function (stepBuilder)
      if std.objectHas(stepBuilder, 'validate')
        then __t.castArray(stepBuilder.validate(pipelineConfig))
        else [];
    __t.withoutNulls(
      std.flattenArrays(
        std.map(validateStep(pipelineConfig), stepBuilders))),

  /**
   * Called when one or more steps have invalid configuration, and is supplied
   * with the validation messages. Should generate a pipeline that terminates
   * without building, but informs the user what was wrong.
   */
  createErrorSteps(pipelineConfig, errors)::
    __customStepBuilder('log-configuration-errors', {
      image: 'alpine',
      commands: [
        ': *** There were errors in the build pipeline configuration:',
        ': '
      ] + std.map((function(message) ': ' + std.escapeStringBash(message)), errors)
      + ['exit 1']
    }).build(pipelineConfig),

  /**
   * Given an array of zero or more builders, attempts to create an array of corresponding steps.
   *
   * This methods returns an object with two properties:
   *   - errors: If the configuration is invalid, this will be an array of messages describing the errors. Otherwise, null.
   *   - steps: If the configuration is valid, this is a flattened array of 'step' objects. Otherwise, it will be null.
   */
  createStepsFromBuilders(pipelineConfig, stepBuilders):: {
    local conditions(stepBuilder) = {
      'Builder is missing a "build" method.': std.objectHas(stepBuilder, 'build')
    },

    local getValidationErrors(stepBuilder) = __t.assertAll(conditions(stepBuilder)),
    local stepBuilderErrors = pipelineFactory.validateSteps(pipelineConfig, stepBuilders),
    local validationErrors = __t.nullIfEmpty(
      __t.withoutNulls(std.map(getValidationErrors, stepBuilders) + stepBuilderErrors)),

    errors: validationErrors,
    steps: if validationErrors == null
      then std.map((function (stepBuilder) stepBuilder.build(pipelineConfig)), stepBuilders)

//  createSteps(pipelineConfig):: function (step)
//    std.map(
//      pipelineFactory.withEnvironment(pipelineConfig),
//      if (std.objectHas(step, 'build')) then step.build(pipelineConfig) else []),
  },

  createPipeline(defaultInitStepBuilders): function (configuration = {}) {
    local config = pipelineFactory.withDefaults(configuration),
    local errors = __t.assertAll({
      ["Pipeline '" + config.name + "' did not have any steps."]: __t.hasNonEmptyArray(config, 'steps'),
    }),

    local builderResult = if errors != null
      then { errors: errors, steps: null }
      else pipelineFactory.createStepsFromBuilders(config, defaultInitStepBuilders + config.steps),

    kind: 'pipeline',
    name: config.name,

    steps:
      if builderResult.errors != null then
        pipelineFactory.createErrorSteps(config, builderResult.errors)
      else
        builderResult.steps,
        //pipelineFactory.getCompleteNotificationSteps(config),

    trigger: config.trigger,
  },
};

local __defaultInitStepBuilders = [
  __initGitStepBuilder()
];

local __stepBuilderFactory = {
  custom: __customStepBuilder,
  yarn: __yarnStepBuilder,
};

local obj = [
{
    myKey: 2,
}];
local a = std.trace("obj content: %s" % [obj], obj);
std.map(__pipelineFactory().createPipeline(__defaultInitStepBuilders), configurePipelines(__stepBuilderFactory))

