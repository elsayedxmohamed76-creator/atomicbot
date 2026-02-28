package ai.atomicbot.android.node

import android.os.Build
import ai.atomicbot.android.BuildConfig
import ai.atomicbot.android.SecurePrefs
import ai.atomicbot.android.gateway.GatewayClientInfo
import ai.atomicbot.android.gateway.GatewayConnectOptions
import ai.atomicbot.android.gateway.GatewayEndpoint
import ai.atomicbot.android.gateway.GatewayTlsParams
import ai.atomicbot.android.protocol.AtomicBotCanvasA2UICommand
import ai.atomicbot.android.protocol.AtomicBotCanvasCommand
import ai.atomicbot.android.protocol.AtomicBotCameraCommand
import ai.atomicbot.android.protocol.AtomicBotLocationCommand
import ai.atomicbot.android.protocol.AtomicBotScreenCommand
import ai.atomicbot.android.protocol.AtomicBotSmsCommand
import ai.atomicbot.android.protocol.AtomicBotCapability
import ai.atomicbot.android.LocationMode
import ai.atomicbot.android.VoiceWakeMode

class ConnectionManager(
  private val prefs: SecurePrefs,
  private val cameraEnabled: () -> Boolean,
  private val locationMode: () -> LocationMode,
  private val voiceWakeMode: () -> VoiceWakeMode,
  private val smsAvailable: () -> Boolean,
  private val hasRecordAudioPermission: () -> Boolean,
  private val manualTls: () -> Boolean,
) {
  companion object {
    internal fun resolveTlsParamsForEndpoint(
      endpoint: GatewayEndpoint,
      storedFingerprint: String?,
      manualTlsEnabled: Boolean,
    ): GatewayTlsParams? {
      val stableId = endpoint.stableId
      val stored = storedFingerprint?.trim().takeIf { !it.isNullOrEmpty() }
      val isManual = stableId.startsWith("manual|")

      if (isManual) {
        if (!manualTlsEnabled) return null
        if (!stored.isNullOrBlank()) {
          return GatewayTlsParams(
            required = true,
            expectedFingerprint = stored,
            allowTOFU = false,
            stableId = stableId,
          )
        }
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      // Prefer stored pins. Never let discovery-provided TXT override a stored fingerprint.
      if (!stored.isNullOrBlank()) {
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = stored,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      val hinted = endpoint.tlsEnabled || !endpoint.tlsFingerprintSha256.isNullOrBlank()
      if (hinted) {
        // TXT is unauthenticated. Do not treat the advertised fingerprint as authoritative.
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      return null
    }
  }

  fun buildInvokeCommands(): List<String> =
    buildList {
      add(AtomicBotCanvasCommand.Present.rawValue)
      add(AtomicBotCanvasCommand.Hide.rawValue)
      add(AtomicBotCanvasCommand.Navigate.rawValue)
      add(AtomicBotCanvasCommand.Eval.rawValue)
      add(AtomicBotCanvasCommand.Snapshot.rawValue)
      add(AtomicBotCanvasA2UICommand.Push.rawValue)
      add(AtomicBotCanvasA2UICommand.PushJSONL.rawValue)
      add(AtomicBotCanvasA2UICommand.Reset.rawValue)
      add(AtomicBotScreenCommand.Record.rawValue)
      if (cameraEnabled()) {
        add(AtomicBotCameraCommand.Snap.rawValue)
        add(AtomicBotCameraCommand.Clip.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(AtomicBotLocationCommand.Get.rawValue)
      }
      if (smsAvailable()) {
        add(AtomicBotSmsCommand.Send.rawValue)
      }
      if (BuildConfig.DEBUG) {
        add("debug.logs")
        add("debug.ed25519")
      }
      add("app.update")
    }

  fun buildCapabilities(): List<String> =
    buildList {
      add(AtomicBotCapability.Canvas.rawValue)
      add(AtomicBotCapability.Screen.rawValue)
      if (cameraEnabled()) add(AtomicBotCapability.Camera.rawValue)
      if (smsAvailable()) add(AtomicBotCapability.Sms.rawValue)
      if (voiceWakeMode() != VoiceWakeMode.Off && hasRecordAudioPermission()) {
        add(AtomicBotCapability.VoiceWake.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(AtomicBotCapability.Location.rawValue)
      }
    }

  fun resolvedVersionName(): String {
    val versionName = BuildConfig.VERSION_NAME.trim().ifEmpty { "dev" }
    return if (BuildConfig.DEBUG && !versionName.contains("dev", ignoreCase = true)) {
      "$versionName-dev"
    } else {
      versionName
    }
  }

  fun resolveModelIdentifier(): String? {
    return listOfNotNull(Build.MANUFACTURER, Build.MODEL)
      .joinToString(" ")
      .trim()
      .ifEmpty { null }
  }

  fun buildUserAgent(): String {
    val version = resolvedVersionName()
    val release = Build.VERSION.RELEASE?.trim().orEmpty()
    val releaseLabel = if (release.isEmpty()) "unknown" else release
    return "AtomicBotAndroid/$version (Android $releaseLabel; SDK ${Build.VERSION.SDK_INT})"
  }

  fun buildClientInfo(clientId: String, clientMode: String): GatewayClientInfo {
    return GatewayClientInfo(
      id = clientId,
      displayName = prefs.displayName.value,
      version = resolvedVersionName(),
      platform = "android",
      mode = clientMode,
      instanceId = prefs.instanceId.value,
      deviceFamily = "Android",
      modelIdentifier = resolveModelIdentifier(),
    )
  }

  fun buildNodeConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "node",
      scopes = emptyList(),
      caps = buildCapabilities(),
      commands = buildInvokeCommands(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "atomicbot-android", clientMode = "node"),
      userAgent = buildUserAgent(),
    )
  }

  fun buildOperatorConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "operator",
      scopes = listOf("operator.read", "operator.write", "operator.talk.secrets"),
      caps = emptyList(),
      commands = emptyList(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "atomicbot-control-ui", clientMode = "ui"),
      userAgent = buildUserAgent(),
    )
  }

  fun resolveTlsParams(endpoint: GatewayEndpoint): GatewayTlsParams? {
    val stored = prefs.loadGatewayTlsFingerprint(endpoint.stableId)
    return resolveTlsParamsForEndpoint(endpoint, storedFingerprint = stored, manualTlsEnabled = manualTls())
  }
}
