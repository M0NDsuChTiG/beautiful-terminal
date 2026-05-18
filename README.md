# **🖥️ Beautiful Terminal**

Интерактивный веб-эмулятор терминала, созданный с использованием HTML, CSS и JavaScript. Проект имитирует работу реальной Linux-консоли прямо в браузере, предлагая красивый дизайн и базовый набор системных команд.

## **✨ Особенности (Features)**

* **Стильный UI:** Кастомизированный и современный дизайн консоли.
* **Имитация команд:** Поддержка базовых команд вроде `help`, `clear`, `echo` и других.
* **Встроенный TLDR:** Интегрированная справочная система `tldr` для быстрого получения примеров использования команд (написана на JS без зависимостей).
* **Легковесность:** Работает полностью на стороне клиента, не требует бэкенда или базы данных.

## **📋 Требования (Prerequisites)**

Перед установкой и запуском проекта убедитесь, что на вашем компьютере установлен **Git**, чтобы вы могли скачать исходный код.

### **Установка Git:**

* **Windows:** Скачайте установщик с [официального сайта](https://git-scm.com/download/win) или установите через командную строку (winget):
  ```console
  > winget install --id Git.Git -e --source winget
  ```

* **macOS:** Установите через пакетный менеджер Homebrew:
  ```console
  $ brew install git
  ```

* **Linux (Ubuntu / Debian / Mint):**
  ```console
  $ sudo apt update
  $ sudo apt install git
  ```

* **Linux (Arch / Manjaro):**
  ```console
  $ sudo pacman -S git
  ```

## **🚀 Установка и Запуск (Installation)**

1. **Клонируйте репозиторий** на свой компьютер, используя терминал:
   ```console
   $ git clone https://github.com/M0NDsuChTiG/beautiful-terminal.git
   ```

2. **Перейдите в папку проекта:**
   ```console
   $ cd beautiful-terminal
   ```

3. **Запустите проект:**
   Просто откройте файл `index.html` (или как называется ваш главный файл) в любом современном браузере (Chrome, Firefox, Safari).
   *Либо используйте Live Server в VS Code для удобной разработки.*

## **🤝 Вклад в проект (Contributing)**

Буду рад вашим Pull Requests! Если вы нашли баг или хотите добавить новую команду в терминал:

1. Сделайте Fork проекта.
2. Создайте свою ветку:
   ```console
   $ git checkout -b feature/AmazingFeature
   ```
3. Сделайте коммит ваших изменений:
   ```console
   $ git commit -m 'Add some AmazingFeature'
   ```
4. Запушьте изменения в ветку:
   ```console
   $ git push origin feature/AmazingFeature
   ```
5. Откройте Pull Request.

## **📄 Лицензия**

Распространяется под лицензией MIT.
