# crfthr-ios

Offline iOS chat assistant that runs local LLMs on-device with MLX Swift.

## Overview
- Native iOS SwiftUI app (no cloud APIs)
- MLX Swift + MLXLMCommon for model loading and streaming generation
- Model download/import, persistent chat history, and JSON export

## Model formats
This app expects MLX-compatible Hugging Face repos (e.g. `mlx-community/...`) that include:
- `config.json`
- one or more `*.safetensors`
- tokenizer files (e.g. `tokenizer.json`, `tokenizer_config.json`, `special_tokens_map.json`)
- optional `generation_config.json`

If a repo is missing any of the above, the app will report a loading error (e.g. missing tokenizer or incompatible structure).

References:
- https://github.com/ml-explore/mlx-swift
- https://github.com/ml-explore/mlx-swift-lm
- https://github.com/ml-explore/mlx-lm

## Using the app
1) Open the **Models** tab and download a model by Hugging Face repo ID (default suggestion: `mlx-community/Qwen2.5-1.5B-Instruct-4bit`).
2) Switch to **Settings** and select the downloaded model.
3) Use the **Chat** tab to send prompts and watch streaming output.

### Importing a model
Use **Models > Import from Files** to copy a local MLX model folder into the app sandbox. The folder must contain MLX-compatible files.

### Where models are stored
Downloaded models are cached in the app sandbox cache directory managed by MLX Hub downloads.
Imported models are copied into the app support directory under `Crfthr/ImportedModels`.

### Exporting history
In **Chat**, use the **Export** button to save JSON in the format:
```json
[{"role":"user","content":"..."}, {"role":"assistant","content":"..."}]
```

## GitHub Actions build
This repository includes an iOS build workflow:
- Trigger manually from **Actions > iOS Build > Run workflow**, or push to `main`.
- The workflow builds an unsigned Release app and uploads `Runner-unsigned.ipa` as an artifact.

## Installing the IPA (sideload)
You can sideload the unsigned IPA using tools such as:
- AltStore
- Sideloadly

General steps:
1) Download the `Runner-unsigned.ipa` artifact from GitHub Actions.
2) Use your sideloading tool to install the IPA onto your device.

## Notes
- The model weights are not included in the repo and must be downloaded or imported at runtime.
- Long conversations are summarized by the model using a strict template (Факты/Контекст/Стиль) to stay within context limits.
