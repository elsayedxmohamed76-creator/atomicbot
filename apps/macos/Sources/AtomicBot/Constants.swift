import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-atomicbot writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.atomicbot.mac"
let gatewayLaunchdLabel = "ai.atomicbot.gateway"
let onboardingVersionKey = "atomicbot.onboardingVersion"
let onboardingSeenKey = "atomicbot.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "atomicbot.pauseEnabled"
let iconAnimationsEnabledKey = "atomicbot.iconAnimationsEnabled"
let swabbleEnabledKey = "atomicbot.swabbleEnabled"
let swabbleTriggersKey = "atomicbot.swabbleTriggers"
let voiceWakeTriggerChimeKey = "atomicbot.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "atomicbot.voiceWakeSendChime"
let showDockIconKey = "atomicbot.showDockIcon"
let defaultVoiceWakeTriggers = ["atomicbot"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "atomicbot.voiceWakeMicID"
let voiceWakeMicNameKey = "atomicbot.voiceWakeMicName"
let voiceWakeLocaleKey = "atomicbot.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "atomicbot.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "atomicbot.voicePushToTalkEnabled"
let talkEnabledKey = "atomicbot.talkEnabled"
let iconOverrideKey = "atomicbot.iconOverride"
let connectionModeKey = "atomicbot.connectionMode"
let remoteTargetKey = "atomicbot.remoteTarget"
let remoteIdentityKey = "atomicbot.remoteIdentity"
let remoteProjectRootKey = "atomicbot.remoteProjectRoot"
let remoteCliPathKey = "atomicbot.remoteCliPath"
let canvasEnabledKey = "atomicbot.canvasEnabled"
let cameraEnabledKey = "atomicbot.cameraEnabled"
let systemRunPolicyKey = "atomicbot.systemRunPolicy"
let systemRunAllowlistKey = "atomicbot.systemRunAllowlist"
let systemRunEnabledKey = "atomicbot.systemRunEnabled"
let locationModeKey = "atomicbot.locationMode"
let locationPreciseKey = "atomicbot.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "atomicbot.peekabooBridgeEnabled"
let deepLinkKeyKey = "atomicbot.deepLinkKey"
let modelCatalogPathKey = "atomicbot.modelCatalogPath"
let modelCatalogReloadKey = "atomicbot.modelCatalogReload"
let cliInstallPromptedVersionKey = "atomicbot.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "atomicbot.heartbeatsEnabled"
let debugPaneEnabledKey = "atomicbot.debugPaneEnabled"
let debugFileLogEnabledKey = "atomicbot.debug.fileLogEnabled"
let appLogLevelKey = "atomicbot.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
