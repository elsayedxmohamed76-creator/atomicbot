package ai.atomicbot.android.ui

import androidx.compose.runtime.Composable
import ai.atomicbot.android.MainViewModel
import ai.atomicbot.android.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
