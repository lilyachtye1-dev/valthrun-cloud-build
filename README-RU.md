# Valthrun cloud build — этап 1

Этот небольшой репозиторий нужен только для облачной сборки. Visual Studio, WDK, Rust и другие инструменты на ваш компьютер устанавливать не требуется.

## Что собирает workflow

- публичный `valthrun-driver-kernel` из commit `bc8e18a27b15fbd55c4b37ebeb8252c60cec934f`;
- публичный `Valthrun_PUBG` из commit `a4e7464fc6146dc1cb145de84ade208d07583800`;
- kernel driver только с handlers initialize / process list / module list / memory read;
- без инициализации и handlers для write, input, process protection и metrics;
- `driver_interface_kernel.dll`;
- `readonly_diagnostics.exe` с обязательным ручным выбором PID;
- `pubg_controller.exe`, принимающий `kernel-driver` и требующий `PUBG_PROCESS_ID` вместо автоматического выбора последнего `TslGame.exe`.

Workflow скачивает исходники напрямую из официальных репозиториев Valthrun и применяет патчи из каталога `patches`.

## Как запустить сборку

1. Распакуйте подготовленный ZIP.
2. В созданном GitHub-репозитории выберите **Add file → Upload files**.
3. Перетащите на страницу **содержимое распакованного каталога**, включая `.github`, `patches`, `scripts` и этот README. Сам ZIP загружать не нужно.
4. Нажмите **Commit changes**.
5. Откройте **Actions → build-readonly-stage1 → Run workflow**.
6. После зелёного завершения откройте run и скачайте artifact **valthrun-readonly-stage1**.

## Важное ограничение

Это этап сборки и базовой read-only диагностики, **не готовый radar для `2611.1.1.37`**.

- Схема `2611` ещё не адаптирована и не проверена live.
- Наличие `DriverCertificate.cer` не доказывает, что Windows разрешит загрузку драйвера.
- Не запускайте `pubg_controller.exe` как рабочий radar: его текущая memory schema относится к другой версии и может возвращать ошибки или неверные данные.
- Сначала нужно штатно решить подпись/загрузку в тестовой среде и получить `READ_ONLY_DIAGNOSTICS_OK` от `readonly_diagnostics.exe`.
- UEFI mapping, stealth, injection, process writes и BattlEye bypass в этот пакет не входят.

## Файлы artifact

- `valthrun-driver.sys` — самостоятельно собранный read-only kernel driver;
- `driver_interface_kernel.dll` — интерфейс между диагностикой и драйвером;
- `readonly_diagnostics.exe` — проверка процесса, модулей и короткого чтения по вручную введённому PID;
- `run-diagnostics.ps1` — показывает PID-кандидатов, но всегда требует ручной ввод;
- `pubg_controller.exe` — собран для следующего этапа, совместимость `2611` не заявлена;
- `DriverCertificate.cer` — публичная часть self-signed сертификата сборки;
- `BUILD-INFO.txt` и `SHA256SUMS.txt` — источники, ограничения и хеши.

После завершения workflow сохраните результат или текст ошибки. Загрузку драйвера и live-проверку выполняем только следующим отдельным этапом.
