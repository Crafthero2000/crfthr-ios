# crfthr-ios

Офлайн iOS-ассистент для чата, запускающий локальные LLM на устройстве через MLX Swift.

## Обзор
- Нативное приложение iOS на SwiftUI (без облачных API)
- MLX Swift + MLXLMCommon для загрузки модели и потоковой генерации
- Загрузка/импорт моделей, постоянная история чата и экспорт в JSON

## Форматы моделей
Приложение ожидает MLX-совместимые репозитории Hugging Face (например, `mlx-community/...`), в которых есть:
- `config.json`
- один или несколько `*.safetensors`
- файлы токенизатора (например, `tokenizer.json`, `tokenizer_config.json`, `special_tokens_map.json`)
- необязательный `generation_config.json`

Если в репозитории чего-то из этого нет, приложение сообщит об ошибке загрузки (например, нет токенизатора или структура несовместима).

Ссылки:
- https://github.com/ml-explore/mlx-swift
- https://github.com/ml-explore/mlx-swift-lm
- https://github.com/ml-explore/mlx-lm

## Использование приложения
1) Откройте вкладку **Models** и скачайте модель по ID репозитория Hugging Face (рекомендуется: `mlx-community/Qwen2.5-1.5B-Instruct-4bit`).
2) Перейдите в **Settings** и выберите скачанную модель.
3) На вкладке **Chat** отправляйте запросы и смотрите потоковый ответ.

### Импорт модели
Используйте **Models > Import from Files**, чтобы скопировать локальную папку модели MLX в песочницу приложения. Папка должна содержать MLX-совместимые файлы.

### Где хранятся модели
Скачанные модели кешируются в директории cache песочницы, которую использует MLX Hub.
Импортированные модели копируются в директорию app support по пути `Crfthr/ImportedModels`.

### Экспорт истории
В **Chat** нажмите **Export**, чтобы сохранить JSON в формате:
```json
[{"role":"user","content":"..."}, {"role":"assistant","content":"..."}]
```

## Сборка в GitHub Actions
В репозитории есть workflow сборки iOS:
- Запускается вручную из **Actions > iOS Build > Run workflow** или при пуше в `main`.
- Собирает unsigned Release приложение и загружает `Runner-unsigned.ipa` как артефакт.

## Скрипт запуска workflow
Требования:
- Установить GitHub CLI (`gh`)
- Выполнить `gh auth login`

Запуск:
```bash
./tools/ci_build.sh
```

Артефакты сохраняются в `$HOME/Downloads/crfthr-builds`.

## Установка IPA (sideload)
Вы можете установить unsigned IPA с помощью:
- AltStore
- Sideloadly

Общие шаги:
1) Скачайте артефакт `Runner-unsigned.ipa` из GitHub Actions.
2) Используйте ваш sideload-инструмент, чтобы установить IPA на устройство.

## Автокоммит
Примеры запуска:
```bash
./tools/autocommit.sh --force --message "chore: autosave before CI"
./tools/autocommit.sh --force --message "feat: ..." --push
```

## Заметки
- Веса модели не входят в репозиторий и должны быть загружены или импортированы во время работы приложения.
- Длинные диалоги суммируются моделью по строгому шаблону (Факты/Контекст/Стиль), чтобы оставаться в пределах контекстного окна.
