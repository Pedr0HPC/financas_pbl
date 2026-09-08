# Relatório de Ambiente — AP1B Computação Móvel

## 1. Versão do Dart SDK

```text
$ dart --version
Dart SDK version: 3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on "windows_x64"

$ flutter doctor -v
[√] Flutter (Channel stable, 3.47.2, on Microsoft Windows [versão 10.0.26200.9168], locale pt-BR) [561ms]
    • Flutter version 3.47.2 on channel stable at C:\src\flutter
    • Upstream repository [https://github.com/flutter/flutter.git](https://github.com/flutter/flutter.git)
    • Framework revision d3b14c8769 (13 days ago), 2026-08-26 16:07:51 -0700
    • Engine revision a804b26164
    • Dart version 3.13.2
    • DevTools version 2.60.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, enable-record-use,
      enable-swift-package-manager, omit-legacy-version-file, enable-lldb-debugging, enable-uiscene-migration

[√] Windows Version (11 Pro 64-bit, 25H2, 2009) [1.269ms]

[√] Android toolchain - develop for Android devices (Android SDK version 36.0.0) [740ms]
    • Android SDK at C:\Users\souza\AppData\Local\Android\sdk
    • Emulator version 37.1.11.0 (build_id 15917651) (CL:N/A)
    • Platform android-37.0, build-tools 36.0.0
    • Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
      This is the JDK bundled with the latest Android Studio installation on this machine.
      To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
    • Java version OpenJDK Runtime Environment (build 25.0.2+-15348964-b329.117)
    • All Android licenses accepted.

[√] Chrome - develop for the web [340ms]
    • Chrome at C:\Program Files\Google\Chrome\Application\chrome.exe

[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.14.3) [339ms]
    • Visual Studio at C:\Program Files\Microsoft Visual Studio\2022\Community
    • Visual Studio Community 2022 version 17.14.36127.28

[√] Connected device (3 available) [392ms]
    • Windows (desktop) • windows • windows-x64    • Microsoft Windows [versão 10.0.26200.9168]
    • Chrome (web)      • chrome  • web-javascript • Google Chrome 152.0.7977.83
    • Edge (web)        • edge    • web-javascript • Microsoft Edge 152.0.4191.66

[√] Network resources [578ms]
    • All expected network resources are available.

• No issues found!

## 3. Estrutura do repositório Git

- [x] Repositório inicializado com `git init`
- [x] `.gitignore` presente na raiz, ignorando `.dart_tool/`, `.packages`,
      `build/` e artefatos temporários de compilação (ver arquivo anexo)
- [x] Histórico de commits com mensagens descritivas (não apenas
      "commit inicial" / "ajustes")
- [x] Código formatado com `dart format .` antes de cada commit relevante