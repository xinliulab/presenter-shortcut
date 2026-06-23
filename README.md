# Presenter Shortcut

[English](#english) | [中文](#中文)

## English

Presenter Shortcut turns a simple wireless presenter into a voice-first AI control surface for Windows.

The core idea is simple: before coding agents and AI writing tools, the most important productivity shortcut was often `Ctrl+C` then `Ctrl+V`. In a voice-first AI workflow, the new high-frequency loop is becoming:

```text
start voice input -> speak -> stop voice input -> Enter
```

Or, in shortcut form:

```text
Ctrl+Shift+D + Enter
```

This project maps a presenter remote's Up/Down buttons into that loop, so you can talk to ChatGPT, Codex, or PRISM with much less mouse and keyboard use.

### What it does

Presenter Shortcut is a lightweight Windows tray app written in C#/.NET Framework. It listens for double-presses from a presenter remote that sends `ArrowUp` and `ArrowDown` keyboard events.

- Double Up starts or stops voice input.
- Double Down sends the message with `Enter`.
- Single Up/Down presses are swallowed so the remote does not accidentally scroll pages or recall command history.
- The tray menu includes Pause, Restart hook, Open log file, and Exit.

### Supported workflows

#### ChatGPT web

When a ChatGPT browser tab is active:

- Double Up sends `Ctrl+Shift+D`.
- Double Down sends `Enter`.

This matches ChatGPT web dictation, where `Ctrl+Shift+D` behaves like a start/stop voice shortcut.

#### Codex desktop app

Codex desktop uses `Ctrl+Shift+D` as a hold-to-dictate shortcut, not a normal toggle. Presenter Shortcut adapts to that:

- First Double Up presses and holds `Ctrl+Shift+D`.
- Second Double Up releases `Ctrl+Shift+D`.
- Double Down sends `Enter`.

This makes Codex feel like a toggle-based voice workflow even though its native shortcut is hold-based.

#### PRISM web

PRISM's built-in voice mode may not always work reliably. For PRISM, Presenter Shortcut uses Windows voice typing:

- Double Up finds and focuses the `Ask anything` input box, then sends `Win+H`.
- Double Down sends `Enter`.

The input focus uses Windows UI Automation instead of screen coordinates, so it is more robust across window sizes and display layouts.

### Installation

Clone or download this repository, then run PowerShell from the project folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-PresenterHotkey.ps1
```

The script uses the C# compiler already included with Windows/.NET Framework. It does not require installing the .NET SDK.

To enable start-at-login:

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-PresenterHotkey.ps1 -AtLogin
```

To stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\Stop-PresenterHotkey.ps1
```

To uninstall the startup shortcut:

```powershell
powershell -ExecutionPolicy Bypass -File .\Uninstall-PresenterHotkey.ps1
```

### Configuration

On first run, the app creates:

```text
build\presenter-hotkey.json
```

It is copied from:

```text
config.sample.json
```

Edit the generated local config for your own machine. Do not commit your local `build\presenter-hotkey.json` if it contains machine-specific settings.

Sample behavior:

```json
{
  "UpVk": "0x26",
  "DownVk": "0x28",
  "UpAction": "Ctrl+Shift+D",
  "CodexUpAction": "Ctrl+Shift+D",
  "DownAction": "Enter",
  "PrismWindowTitleContains": ["prism"],
  "PrismInputNameContains": ["ask anything", "message", "prompt", "ask"],
  "PrismUpAction": "Win+H",
  "PrismDownAction": "Enter",
  "PrismFocusDelayMs": 150,
  "DoublePressMs": 900,
  "ActionCooldownMs": 800
}
```

If PRISM has a different browser title on your machine, add another keyword to `PrismWindowTitleContains`.

### Notes and limitations

- Windows only.
- Designed for presenter remotes that emit `ArrowUp` and `ArrowDown`.
- While running, normal `ArrowUp` and `ArrowDown` keyboard events are intercepted globally. Use Pause or Exit from the tray menu when you need normal arrow-key navigation.
- If the remote suddenly starts scrolling again, right-click the tray icon and choose Restart hook.
- PRISM support depends on Windows UI Automation being able to see the input box.

### Why this matters

The point is not the remote itself. The point is the interface shift.

Copy/paste was the signature gesture of desktop productivity. Voice-controlled AI is creating a new signature gesture: open dictation, say the intent, send it. Small tools like this make that loop physical, fast, and shoulder-friendly.

---

## 中文

Presenter Shortcut 是一个 Windows 托盘小工具，可以把普通翻页激光笔/演示遥控器变成 AI 语音控制器。

核心想法很简单：在 Codex、ChatGPT 这类工具出现以前，最重要的生产力快捷键常常是 `Ctrl+C` 和 `Ctrl+V`。但在语音优先的 AI 工作流里，新的高频动作正在变成：

```text
启动语音输入 -> 说话 -> 停止语音输入 -> Enter 发送
```

也就是：

```text
Ctrl+Shift+D + Enter
```

这个项目把演示遥控器的上/下键映射成这个循环，让你可以用更少的鼠标和键盘操作来控制 ChatGPT、Codex 和 PRISM。

### 它做什么

Presenter Shortcut 是一个轻量的 Windows 托盘程序，用 C#/.NET Framework 编写。它监听遥控器发出的 `ArrowUp` 和 `ArrowDown` 键盘事件，并识别“双击”。

- 向上双击：启动或停止语音输入。
- 向下双击：发送 `Enter`。
- 单次上/下键会被吞掉，避免网页滚动或 Codex 回放历史输入。
- 托盘菜单提供 Pause、Restart hook、Open log file 和 Exit。

### 支持的三种场景

#### ChatGPT 网页版

当前台是 ChatGPT 网页时：

- 向上双击发送 `Ctrl+Shift+D`。
- 向下双击发送 `Enter`。

ChatGPT 网页里，`Ctrl+Shift+D` 可以作为听写/语音输入的开始与停止快捷键。

#### Codex 桌面应用

Codex 桌面应用里的 `Ctrl+Shift+D` 不是普通 toggle，而是 hold-to-dictate，也就是需要按住才持续听写。Presenter Shortcut 对它做了适配：

- 第一次向上双击：按住 `Ctrl+Shift+D`。
- 第二次向上双击：松开 `Ctrl+Shift+D`。
- 向下双击：发送 `Enter`。

这样 Codex 用起来就像有了一个“按一下开始、再按一下结束”的语音开关。

#### PRISM 网页版

PRISM 自带的 voice mode 有时不稳定，所以这里改用 Windows 自带语音输入：

- 向上双击：先找到并聚焦 `Ask anything` 输入框，然后发送 `Win+H`。
- 向下双击：发送 `Enter`。

输入框定位使用 Windows UI Automation，而不是屏幕坐标，因此对窗口大小和多屏布局更稳。

### 安装

下载或 clone 这个仓库后，在项目目录里运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-PresenterHotkey.ps1
```

脚本使用 Windows/.NET Framework 自带的 C# 编译器，不需要安装 .NET SDK。

如果希望开机自动启动：

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-PresenterHotkey.ps1 -AtLogin
```

停止程序：

```powershell
powershell -ExecutionPolicy Bypass -File .\Stop-PresenterHotkey.ps1
```

删除开机启动快捷方式：

```powershell
powershell -ExecutionPolicy Bypass -File .\Uninstall-PresenterHotkey.ps1
```

### 配置

第一次运行后会生成：

```text
build\presenter-hotkey.json
```

它会从下面这个示例配置复制生成：

```text
config.sample.json
```

如果你需要按自己的电脑环境调整，请改本地生成的 `build\presenter-hotkey.json`。不要把自己的本地配置提交到 GitHub。

示例配置：

```json
{
  "UpVk": "0x26",
  "DownVk": "0x28",
  "UpAction": "Ctrl+Shift+D",
  "CodexUpAction": "Ctrl+Shift+D",
  "DownAction": "Enter",
  "PrismWindowTitleContains": ["prism"],
  "PrismInputNameContains": ["ask anything", "message", "prompt", "ask"],
  "PrismUpAction": "Win+H",
  "PrismDownAction": "Enter",
  "PrismFocusDelayMs": 150,
  "DoublePressMs": 900,
  "ActionCooldownMs": 800
}
```

如果你的 PRISM 网页标题里没有 `prism`，可以把对应关键词加入 `PrismWindowTitleContains`。

### 注意事项

- 目前仅支持 Windows。
- 适合会发送 `ArrowUp` 和 `ArrowDown` 的演示遥控器。
- 程序运行时会全局拦截普通 `ArrowUp` 和 `ArrowDown`。如果你需要正常使用方向键，可以从托盘菜单 Pause 或 Exit。
- 如果遥控器突然又开始滚动网页，右键托盘图标，点击 Restart hook。
- PRISM 支持依赖 Windows UI Automation 能否识别页面输入框。

### 为什么这件事重要

重点不是激光笔本身，而是交互方式正在改变。

复制粘贴曾经是桌面生产力的标志性动作。语音控制 AI 正在创造新的标志性动作：打开语音，说出意图，发送。像 Presenter Shortcut 这样的小工具，就是把这个循环变成一个更自然、更快速、也更保护肩膀的物理动作。
