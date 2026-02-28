package ai.atomicbot.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class AtomicBotProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", AtomicBotCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", AtomicBotCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", AtomicBotCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", AtomicBotCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", AtomicBotCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", AtomicBotCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", AtomicBotCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", AtomicBotCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", AtomicBotCapability.Canvas.rawValue)
    assertEquals("camera", AtomicBotCapability.Camera.rawValue)
    assertEquals("screen", AtomicBotCapability.Screen.rawValue)
    assertEquals("voiceWake", AtomicBotCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", AtomicBotScreenCommand.Record.rawValue)
  }
}
