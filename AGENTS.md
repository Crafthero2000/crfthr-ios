# AGENTS

- Всегда отвечай на русском.
- Использовать только GNU bash из Git for Windows: /c/Program\ Files/Git/bin/bash.exe.
- Явно запрещено использовать: /c/Program\ Files/Git/git-bash.exe, PowerShell, cmd.exe.
- Все shell-команды должны быть неинтерактивными и bash-совместимыми.
- Использовать только POSIX-пути.
- Коммит считается завершённым только после успешного git push.
- Если upstream ветки нет — выполнять: git push -u origin <current-branch>.
- Перед предложением запускать CI обязательно проверять:
  - git status --porcelain
  - git log -1
  - git log origin/HEAD -1
- Запуск CI запрещён, если remote HEAD не обновлён.
