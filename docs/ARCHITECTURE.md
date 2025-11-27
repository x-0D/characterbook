# Архитектура приложения

```bash
<корневой каталог проекта>
├── .github/                 # Конфигурация GitHub Actions
│   └── workflows/
│       └── dart.yml        # CI/CD пайплайн
├── docs/                   # Документация приложения
│   ├── ARCHITECTURE.md     # Этот файл
│   ├── FEATURES.md         # Описание функциональности
│   ├── INSTALLATION.md     # Инструкции по установке
│   └── MANUAL.md           # Руководство пользователя
├── android/                # Платформо-специфичная конфигурация для Android
│   ├── app/               # Конфигурация приложения
│   │   ├── src/           # Исходный код Android
│   │   └── build.gradle.kts
│   ├── gradle/            # Система сборки Gradle
│   └── keystore.jks       # Ключ для подписи приложения
├── assets/                 # Статические ресурсы приложения
│   ├── fonts/             # Шрифты
│   ├── github-mark.png    # Иконка GitHub
│   ├── icon.svg           # Иконка приложения (SVG)
│   ├── iconapp.png        # Иконка приложения (PNG)
│   └── underdeveloped.png # Заглушка для недоразвитых функций
├── ios/                   # Платформо-специфичная конфигурация для iOS
├── lib/                   # Основная кодовая база на Dart
│   ├── adapters/          # Адаптеры для внешних сервисов
│   │   └── custom_field_adapter.dart
│   ├── extensions/        # Расширения для встроенных классов
│   │   └── color_extension.dart
│   ├── gen/              # Сгенерированные файлы (assets)
│   │   └── assets.gen.dart
│   ├── generated/         # Автоматически сгенерированные файлы
│   │   └── intl/         # Локализация
│   │       ├── messages_all.dart
│   │       ├── messages_en.dart
│   │       ├── messages_ru.dart
│   │       └── l10n.dart
│   ├── l10n/             # Файлы локализации
│   │   ├── intl_en.arb
│   │   └── intl_ru.arb
│   ├── models/           # Модели данных
│   │   ├── character_model.dart
│   │   ├── template_model.dart
│   │   ├── custom_field_model.dart
│   │   ├── folder_model.dart
│   │   ├── note_model.dart
│   │   └── race_model.dart
│   ├── providers/        # State Providers для управления состоянием
│   │   ├── locale_provider.dart
│   │   └── theme_provider.dart
│   ├── services/         # Сервисы бизнес-логики
│   │   ├── backup_service.dart
│   │   ├── character_service.dart
│   │   ├── clipboard_service.dart
│   │   ├── default_templates.dart
│   │   ├── file_handler.dart
│   │   ├── file_handler_wrapper.dart
│   │   ├── file_picker_service.dart
│   │   ├── folder_service.dart
│   │   ├── hive_service.dart
│   │   ├── initialization_service.dart  # НОВЫЙ: сервис инициализации приложения
│   │   ├── race_service.dart
│   │   ├── pdf_export_manager.dart
│   │   ├── pdf_export_service.dart
│   │   ├── migration_service.dart
│   │   ├── notification_service.dart
│   │   ├── race_service.dart
│   │   └── template_service.dart
│   └── ui/              # Компоненты пользовательского интерфейса
│       ├── cards/       # Карточки для отображения данных
│       │   └── character_modal_card.dart
│       ├── dialogs/     # Диалоговые окна
│       ├── handlers/    # Обработчики UI событий
│       │   └── unsaved_changes_handler.dart
│       ├── pages/       # Страницы приложения
│       │   ├── character_list_page.dart
│       │   ├── character_management_page.dart
│       │   ├── folder_list_page.dart     
│       │   ├── note_list_page.dart
│       │   ├── note_management_page.dart
│       │   ├── race_list_page.dart
│       │   ├── race_management_page.dart
│       │   ├── template_edit_page.dart
│       │   ├── templates_page.dart
│       │   ├── home_page.dart
│       │   ├── home_screen.dart
│       │   ├── random_number_page.dart
│       │   ├── search_page.dart
│       │   └── settings_page.dart
│       └── widgets/     # Переиспользуемые виджеты
│           ├── appbar/  # Виджеты AppBar
│           │   ├── common_edit_app_bar.dart
│           │   └── custom_app_bar.dart
│           ├── desktop/ # НОВЫЙ: виджеты для десктопной версии
│           │   ├── app_title.dart
│           │   ├── desktop_app_frame.dart
│           │   ├── desktop_title_bar.dart
│           │   └── window_controls.dart
│           ├── fields/  # Поля ввода
│           │   ├── custom_fields_editor.dart
│           │   ├── custom_text_field.dart
│           │   ├── gender_selector_field.dart
│           │   ├── image_picker_field.dart
│           │   └── race_selector_field.dart
│           ├── items/   # Элементы списков
│           │   ├── character_card.dart
│           │   ├── folder_card.dart
│           │   ├── note_card.dart
│           │   ├── race_card.dart
│           │   ├── search_result_card.dart
│           │   └── template_card.dart
│           ├── list/    # Виджеты списков
│           ├── mixins/  # Миксины для виджетов
│           │   ├── list_page_mixin.dart
│           │   └── tag_mixin.dart
│           ├── performance/ # Виджеты производительности
│           ├── sections/    # Секции настроек
│           │   ├── about_section.dart
│           │   ├── acknowledgements_section.dart
│           │   ├── backup_section.dart
│           │   ├── build_section.dart
│           │   ├── expandable_section.dart
│           │   ├── image_gallery_section.dart
│           │   ├── import_section.dart
│           │   ├── language_section.dart
│           │   ├── licenses_section.dart
│           │   ├── settings_section.dart
│           │   ├── tags_and_folder_section.dart
│           │   └── theme_section.dart
│           ├── states/  # Виджеты состояний
│           ├── tags/    # Виджеты тегов
│           └── отдельные виджеты (avatar_picker_widget.dart и др.)
├── linux/               # Конфигурация для Linux
├── macos/               # Конфигурация для macOS
├── test/                # Модульные и виджет-тесты
├── web/                 # Конфигурация для Web
└── windows/             # Конфигурация для Windows

main.dart                # Точка входа в приложение
```

## 📐 Технологический стек

### Основные технологии

**Фреймворк:**
- **Flutter** 3.13+ - кроссплатформенный UI фреймворк
- **Dart** 3.7.2+ - язык программирования

**Управление состоянием:**
- **Provider** - для простого state management
- **Flutter Bloc** - для сложной бизнес-логики

**Локальное хранилище:**
- **Hive** 2.2.3 - быстрая NoSQL база данных
- **Shared Preferences** - для настроек приложения

**Управление окнами (десктоп):**
- **Window Manager** - управление окнами для десктопных платформ

**Вспомогательные пакеты:**
- **PDF** - генерация документов
- **File Selector** - работа с файловой системой
- **URL Launcher** - интеграция с ОС
- **Google Sign-In** - будущая аутентификация

### Структура зависимостей

```yaml
dependencies:
  # State Management
  provider: ^6.0.5
  flutter_bloc: ^8.1.3
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.5.3
  
  # File Operations
  pdf: ^3.10.0
  printing: ^5.9.1
  file_selector: ^1.0.3
  
  # Platform Integration
  window_manager: ^0.5.1
  msix: ^3.16.10
```

## 🏗️ Модульная структура

Приложение следует принципам **чистой архитектуры** с разделением на:

- **Модели** (`models/`) - структуры данных
- **Сервисы** (`services/`) - бизнес-логика и инициализация
- **Провайдеры** (`providers/`) - управление состоянием
- **UI компоненты** (`ui/`) - представление данных

### Новые модули после рефакторинга:

**InitializationService** (`services/initialization_service.dart`):
- Централизованная инициализация Hive и Window Manager
- Определение платформы (десктоп/мобильная)
- Управление жизненным циклом приложения

**Desktop UI Components** (`ui/widgets/desktop/`):
- `desktop_app_frame.dart` - основной фрейм десктопного приложения
- `desktop_title_bar.dart` - кастомная панель заголовка
- `window_controls.dart` - кнопки управления окном
- `app_title.dart` - заголовок приложения с иконкой

Каждый модуль отвечает за свою зону ответственности, что обеспечивает поддерживаемость и тестируемость кода.

## 🎯 Архитектурные улучшения

### 1. Централизация инициализации
- Вынесена логика инициализации в отдельный сервис
- Упрощен main.dart
- Улучшена читаемость кода запуска приложения

### 2. Разделение UI по платформам
- Четкое разделение мобильных и десктопных компонентов
- Переиспользуемые десктопные виджеты
- Упрощена навигация между платформами

### 3. Улучшенная структура виджетов
- Логическая группировка десктопных компонентов
- Упрощенное поддержание кода
- Легкое расширение функциональности

## 🗃️ Модели данных

### Character (Персонаж)
- **Тип Hive**: `typeId: 0`
- **Назначение**: Основная сущность приложения для хранения данных о персонажах
- **Ключевые поля**:
  - `id` - уникальный идентификатор
  - `name`, `age`, `gender` - базовые атрибуты
  - `biography`, `personality`, `appearance` - текстовые описания
  - `imageBytes`, `referenceImageBytes`, `additionalImages` - система изображений
  - `customFields` - расширяемая система полей
  - `race` - связь с расой
  - `folderId`, `tags` - система организации

### CustomField (Пользовательское поле)
- **Тип Hive**: `typeId: 1`
- **Назначение**: Хранение пользовательских полей типа ключ-значение
- **Ключевые поля**:
  - `key` - название поля
  - `value` - значение поля

### Note (Заметка)
- **Тип Hive**: `typeId: 2`
- **Назаначение**: Система заметок, связанных с персонажами
- **Ключевые поля**:
  - `title`, `content` - содержимое заметки
  - `characterIds` - привязка к персонажам
  - `folderId`, `tags` - организация

### Race (Раса)
- **Тип Hive**: `typeId: 3`
- **Назначение**: Хранение данных о расах персонажей
- **Ключевые поля**:
  - `name`, `description`, `biology`, `backstory` - описания
  - `logo` - изображение расы
  - `folderId`, `tags` - организация

### QuestionnaireTemplate (Шаблон анкеты)
- **Тип Hive**: `typeId: 4`
- **Назначение**: Шаблоны для быстрого создания персонажей
- **Ключевые поля**:
  - `name` - название шаблона
  - `standardFields` - список стандартных полей
  - `customFields` - пользовательские поля шаблона

### Folder (Папка)
- **Тип Hive**: `typeId: 5`
- **Назначение**: Организация контента в папки
- **Ключевые поля**:
  - `name`, `type` - название и тип содержимого
  - `parentId` - поддержка вложенности
  - `contentIds` - список ID содержимого
  - `colorValue` - цветовое кодирование

### FolderType (Тип папки)
- **Тип Hive**: `typeId: 6`
- **Назначение**: Перечисление типов контента для папок
- **Значения**: `character`, `race`, `note`, `template`

### Особенности моделей:
- Все модели поддерживают **Hive** для локального хранения
- Реализованы методы `toJson()`/`fromJson()` для сериализации
- Поддержка копирования через `copyWith()`
- Система тегов и папок для организации контента
- Расширяемая система через `CustomField`

## 🔄 Жизненный цикл приложения

### Инициализация:
1. Инициализация WidgetsBinding
2. Параллельная инициализация Window Manager и Hive
3. Настройка FileHandler
4. Запуск MultiProvider с провайдерами состояния

### Управление состоянием:
- **ThemeProvider** - управление светлой/темной темой
- **LocaleProvider** - управление локализацией
- **NotificationService** - управление уведомлениями

### Десктоп-специфичные функции:
- Кастомная панель заголовка
- Кнопки управления окном (свернуть/развернуть/закрыть)
- Автоматическое определение платформы
- Адаптивный UI в зависимости от платформы