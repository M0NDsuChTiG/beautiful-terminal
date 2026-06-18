<!DOCTYPE html>
<html lang="ru" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beautiful Terminal | Экосистема Высокопроизводительных CLI-Утилит</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Использование строгих, профессиональных шрифтов Inter и Fira Code -->
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap');
        
        :root {
            --bg-main: #0a0c10;
            --bg-card: #11141b;
            --emerald: #10b981;
            --blue: #3b82f6;
            --amber: #f59e0b;
            --text-main: #e2e8f0;
            --text-dim: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-main);
            color: var(--text-main);
            line-height: 1.6;
        }

        .font-mono { font-family: 'Fira Code', monospace; }

        .chart-container {
            position: relative;
            width: 100%;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            height: 300px;
            max-height: 350px;
        }

        .tool-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(255, 255, 255, 0.03);
        }

        .tool-card:hover {
            transform: translateY(-4px);
            border-color: var(--emerald);
            box-shadow: 0 10px 30px -10px rgba(16, 185, 129, 0.2);
            background: rgba(16, 185, 129, 0.02);
        }

        .filter-btn-active {
            background-color: var(--emerald) !important;
            color: #000 !important;
        }

        /* Настройка кастомного скроллбара */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: var(--bg-main); }
        ::-webkit-scrollbar-thumb { background: #2d3748; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--emerald); }

        .glass {
            background: rgba(17, 20, 27, 0.8);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
    </style>
</head>
<body class="antialiased">

    <!-- Навигационная панель -->
    <nav class="sticky top-0 z-50 glass border-b border-white/5">
        <div class="container mx-auto px-6 h-16 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-emerald-500 rounded flex items-center justify-center shadow-[0_0_15px_rgba(16,185,129,0.4)]">
                    <i class="fa-solid fa-terminal text-black text-sm"></i>
                </div>
                <span class="font-bold text-xl tracking-tighter uppercase">Beautiful <span class="text-emerald-500">Terminal</span></span>
            </div>
            <div class="hidden md:flex gap-8 text-xs font-bold uppercase tracking-widest text-text-dim">
                <a href="#philosophy" class="hover:text-emerald-400 transition">Концепция</a>
                <a href="#stats" class="hover:text-emerald-400 transition">Аналитика</a>
                <a href="#catalog" class="hover:text-emerald-400 transition">Каталог утилит</a>
                <a href="#mastery" class="hover:text-emerald-400 transition">Руководство</a>
            </div>
        </div>
    </nav>

    <main class="container mx-auto px-6 py-12">
        
        <!-- Секция: Концепция и Философия -->
        <section id="philosophy" class="mb-24">
            <div class="max-w-4xl">
                <h1 class="text-5xl md:text-7xl font-bold mb-8 leading-[1.1]">Модернизация <br><span class="text-emerald-500 italic">рабочего окружения.</span></h1>
                <p class="text-xl text-text-dim leading-relaxed mb-10">
                    Стандартные UNIX-утилиты, созданные десятилетия назад, не оптимизированы под современные процессоры с высокой степенью параллелизма. 
                    Наш бандл переводит вашу командную строку на высокопроизводительные альтернативы, написанные на **Rust**, **Go** и **C++20**. 
                    Оптимизируйте операции ввода-вывода и минимизируйте когнитивную нагрузку при работе в консоли.
                </p>
                <div class="flex flex-wrap gap-4">
                    <a href="#catalog" class="bg-emerald-500 hover:bg-emerald-400 text-black px-8 py-4 rounded-xl font-bold transition transform active:scale-95 shadow-lg shadow-emerald-500/20">Исследовать спецификации</a>
                    <div class="bg-card px-6 py-4 rounded-xl border border-white/5 flex items-center gap-3">
                        <span class="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></span>
                        <span class="text-sm font-bold">Релиз 2.4.0 LTS</span>
                    </div>
                </div>
            </div>
        </section>

        <!-- Секция: Аналитика и Стек -->
        <section id="stats" class="mb-32">
            <div class="mb-12">
                <h2 class="text-3xl font-bold mb-4">Техническая эффективность</h2>
                <p class="text-text-dim max-w-2xl">Сравнение скорости выполнения дисковых операций и распределение кодовой базы по языкам программирования. Оптимизация на уровне компиляции.</p>
            </div>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
                <div class="bg-card p-8 rounded-[2rem] border border-white/5">
                    <h3 class="text-sm font-bold uppercase tracking-widest text-text-dim mb-8 flex items-center gap-2">
                        <i class="fa-solid fa-bolt-lightning text-amber-500"></i> Скорость выполнения операций (мс)
                    </h3>
                    <div class="chart-container">
                        <canvas id="speedChart"></canvas>
                    </div>
                    <p class="mt-6 text-xs text-center text-text-dim italic">Тест производительности на базе последовательного сканирования 100,000 файлов на SSD накопителе NVMe.</p>
                </div>
                <div class="bg-card p-8 rounded-[2rem] border border-white/5 text-center">
                    <h3 class="text-sm font-bold uppercase tracking-widest text-text-dim mb-8 flex items-center gap-2 justify-center">
                        <i class="fa-solid fa-microchip text-blue-500"></i> Системная архитектура бандла
                    </h3>
                    <div class="chart-container">
                        <canvas id="stackChart"></canvas>
                    </div>
                </div>
            </div>
        </section>

        <!-- Секция: Каталог утилит -->
        <section id="catalog" class="mb-32">
            <div class="flex flex-col md:flex-row justify-between items-end gap-6 mb-12">
                <div>
                    <h2 class="text-4xl font-bold mb-4">Спецификация компонентов</h2>
                    <p class="text-text-dim">Интегрированные решения, распределенные по функциональным уровням операционной системы.</p>
                </div>
                <div class="flex flex-wrap gap-2" id="filter-container">
                    <button class="filter-btn filter-btn-active px-5 py-2.5 rounded-lg text-xs font-bold bg-card border border-white/5 hover:bg-white/10 transition" data-category="all">ВСЕ</button>
                    <button class="filter-btn px-5 py-2.5 rounded-lg text-xs font-bold bg-card border border-white/5 hover:bg-white/10 transition" data-category="nav">НАВИГАЦИЯ</button>
                    <button class="filter-btn px-5 py-2.5 rounded-lg text-xs font-bold bg-card border border-white/5 hover:bg-white/10 transition" data-category="mon">МОНИТОРИНГ</button>
                    <button class="filter-btn px-5 py-2.5 rounded-lg text-xs font-bold bg-card border border-white/5 hover:bg-white/10 transition" data-category="dev">РАЗРАБОТКА</button>
                    <button class="filter-btn px-5 py-2.5 rounded-lg text-xs font-bold bg-card border border-white/5 hover:bg-white/10 transition" data-category="net">СЕТЬ / ОКРУЖЕНИЕ</button>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6" id="tools-grid">
                <!-- Контент генерируется через JavaScript -->
            </div>
        </section>

        <!-- Секция: Справочник горячих клавиш -->
        <section id="mastery" class="mb-32">
            <div class="bg-emerald-500/10 border border-emerald-500/20 p-8 md:p-12 rounded-[3rem]">
                <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-8 mb-12">
                    <div>
                        <h2 class="text-4xl font-bold mb-2">Интерфейсный справочник</h2>
                        <p class="text-emerald-500/70">Быстрый поиск по сочетаниям клавиш и алиасам для оптимизации повседневных операций.</p>
                    </div>
                    <div class="relative w-full md:w-80">
                        <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-emerald-500/50"></i>
                        <input type="text" id="mastery-search" placeholder="Поиск по команде или клавише..." class="w-full bg-black/40 border border-emerald-500/20 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-emerald-500 transition placeholder:text-emerald-500/30">
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead>
                            <tr class="text-text-dim border-b border-white/5">
                                <th class="pb-6 font-bold uppercase tracking-widest text-[10px]">Модуль</th>
                                <th class="pb-6 font-bold uppercase tracking-widest text-[10px]">Команда / Сочетание</th>
                                <th class="pb-6 font-bold uppercase tracking-widest text-[10px]">Функциональный результат</th>
                            </tr>
                        </thead>
                        <tbody id="mastery-body">
                            <!-- Контент генерируется через JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- Секция: Инсталляция -->
        <section class="text-center py-24 border-t border-white/5">
            <h2 class="text-4xl font-bold mb-6">Процесс автоматического развертывания</h2>
            <p class="text-text-dim mb-12 max-w-xl mx-auto">Инсталляционный скрипт определяет тип дистрибутива, разрешает зависимости и конфигурирует конфигурационные файлы (.zshrc) в пользовательской директории.</p>
            
            <div class="inline-flex flex-col items-center gap-6">
                <div class="bg-card border border-emerald-500/30 px-8 py-6 rounded-3xl flex items-center gap-6 font-mono text-emerald-400 group relative cursor-pointer" onclick="copyInstall()">
                    <span class="text-text-dim select-none">$</span>
                    <span id="install-cmd">curl -sSL install.beautiful.sh | bash</span>
                    <i class="fa-regular fa-copy opacity-40 group-hover:opacity-100 transition"></i>
                    
                    <div class="absolute -top-12 left-1/2 -translate-x-1/2 bg-emerald-500 text-black text-xs font-bold py-2 px-4 rounded-lg opacity-0 transition-opacity pointer-events-none" id="copy-toast">
                        Скопировано в буфер обмена
                    </div>
                </div>
                <div class="flex gap-8 text-[10px] font-bold text-text-dim uppercase tracking-[0.3em]">
                    <span>Ubuntu & Debian</span>
                    <span>Arch Linux</span>
                    <span>macOS (Darwin)</span>
                </div>
            </div>
        </section>

    </main>

    <!-- Модальное окно спецификации инструментов -->
    <div id="tool-modal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/90 backdrop-blur-sm" onclick="closeModal()"></div>
        <div class="bg-card w-full max-w-2xl rounded-[2.5rem] border border-white/10 overflow-hidden relative transform transition-all scale-95 opacity-0" id="modal-content">
            <div class="p-10">
                <div class="flex justify-between items-start mb-8">
                    <div class="flex items-center gap-5">
                        <div id="modal-icon" class="w-16 h-16 rounded-3xl flex items-center justify-center text-3xl border"></div>
                        <div>
                            <h3 id="modal-name" class="text-4xl font-bold font-mono tracking-tighter"></h3>
                            <div id="modal-tag" class="inline-block mt-2 px-3 py-1 bg-white/5 rounded-lg text-[10px] font-bold tracking-widest text-text-dim uppercase"></div>
                        </div>
                    </div>
                    <button onclick="closeModal()" class="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center hover:bg-white/10 transition">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                
                <p id="modal-desc" class="text-text-dim text-lg leading-relaxed mb-10"></p>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 bg-black/40 p-6 rounded-3xl border border-white/5">
                    <div>
                        <span class="text-[10px] font-bold text-red-500/50 uppercase tracking-widest block mb-3">Стандарт POSIX / Традиционный метод</span>
                        <code id="modal-old" class="block font-mono text-sm text-red-400 bg-red-500/10 p-3 rounded-xl border border-red-500/10"></code>
                    </div>
                    <div>
                        <span class="text-[10px] font-bold text-emerald-500/50 uppercase tracking-widest block mb-3">Модернизированный аналог</span>
                        <code id="modal-new" class="block font-mono text-sm text-emerald-400 bg-emerald-500/10 p-3 rounded-xl border border-emerald-500/10 font-bold"></code>
                    </div>
                </div>
            </div>
            <div class="px-10 py-6 bg-white/2 border-t border-white/5 flex justify-end">
                <button onclick="closeModal()" class="px-8 py-3 rounded-xl font-bold bg-emerald-500 text-black hover:bg-emerald-400 transition">Закрыть спецификацию</button>
            </div>
        </div>
    </div>

    <footer class="bg-card py-16 border-t border-white/5">
        <div class="container mx-auto px-6 text-center">
            <div class="flex justify-center gap-8 mb-8 text-text-dim">
                <a href="#" class="hover:text-emerald-500 transition text-xl"><i class="fa-brands fa-github"></i></a>
                <a href="#" class="hover:text-emerald-500 transition text-xl"><i class="fa-brands fa-telegram"></i></a>
                <a href="#" class="hover:text-emerald-500 transition text-xl"><i class="fa-brands fa-discord"></i></a>
            </div>
            <p class="text-text-dim text-sm tracking-wide">© 2026 Beautiful Terminal Bundle. Спецификация свободного программного обеспечения.</p>
        </div>
    </footer>

    <script>
        // --- БАЗА ДАННЫХ ИНСТРУМЕНТОВ (Взрослые, профессиональные описания) ---
        const tools = [
            { id: 'lsd', name: 'lsd', cat: 'nav', lang: 'Rust', icon: 'fa-folder-tree', color: 'emerald', old: 'ls -la', new: 'lsd -la --tree', desc: 'Улучшенный аналог утилиты ls. Осуществляет многопоточную индексацию директорий, сопоставление типов файлов с векторными пиктограммами и построение интерактивных иерархических древовидных структур.' },
            { id: 'bat', name: 'bat', cat: 'nav', lang: 'Rust', icon: 'fa-file-code', color: 'blue', old: 'cat script.js', new: 'bat script.js', desc: 'Альтернатива классической утилите cat. Интегрирует парсер синтаксиса для более чем 150 языков программирования, выводит нумерацию строк и подсвечивает изменения в репозитории на основе git-diff.' },
            { id: 'zoxide', name: 'zoxide', cat: 'nav', lang: 'Rust', icon: 'fa-bolt', color: 'amber', old: 'cd ../../work/src', new: 'z src', desc: 'Базирующийся на алгоритме частоты и давности использования (Frecency) инструмент навигации по каталогам. Автоматизирует переход к целевой директории без необходимости ввода абсолютных путей.' },
            { id: 'fzf', name: 'fzf', cat: 'nav', lang: 'Go', icon: 'fa-filter', color: 'purple', old: 'history | grep git', new: 'fzf (Ctrl + R)', desc: 'Интерактивный фильтр нечеткого соответствия командной строки. Позволяет производить высокоскоростной конвейерный поиск по истории ввода, списку активных процессов или файловой структуре.' },
            { id: 'fd', name: 'fd', cat: 'nav', lang: 'Rust', icon: 'fa-magnifying-glass', color: 'cyan', old: 'find . -name "*.log"', new: 'fd -e log', desc: 'Многопоточный поисковый инструмент файловой системы. Игнорирует скрытые каталоги и правила .gitignore по умолчанию, демонстрируя многократное превосходство в скорости над утилитой find.' },
            
            { id: 'btop', name: 'btop++', cat: 'mon', lang: 'C++', icon: 'fa-microchip', color: 'red', old: 'top / htop', new: 'btop', desc: 'Высокопроизводительный системный TUI-монитор ресурсов в реальном времени. Отображает подробную статистику по распределению ядер процессора, системной памяти, дисковому и сетевому вводу-выводу.' },
            { id: 'procs', name: 'procs', cat: 'mon', lang: 'Rust', icon: 'fa-list-check', color: 'emerald', old: 'ps aux', new: 'procs', desc: 'Модернизированный диспетчер процессов. Формирует древовидную зависимость процессов ОС, сопоставляет PID с сетевыми портами TCP/UDP и идентифицирует утечки ресурсов.' },
            { id: 'duf', name: 'duf', cat: 'mon', lang: 'Go', icon: 'fa-hard-drive', color: 'blue', old: 'df -h', new: 'duf', desc: 'Утилита мониторинга состояния дисковых накопителей и разделов монтирования. Предоставляет форматированный вывод с цветовой разметкой пороговых значений дискового пространства.' },
            { id: 'fastfetch', name: 'fastfetch', cat: 'mon', lang: 'C', icon: 'fa-desktop', color: 'amber', old: 'neofetch', new: 'fastfetch', desc: 'Высокоэффективная кроссплатформенная утилита системной интроспекции. Собирает технические параметры аппаратного обеспечения и программной среды во время инициализации сессии.' },
            { id: 'kmon', name: 'kmon', cat: 'mon', lang: 'Rust', icon: 'fa-shield-halved', color: 'violet', old: 'dmesg', new: 'kmon', desc: 'Специализированный интерфейс для мониторинга ядра операционной системы Linux. Облегчает отладку системных вызовов dmesg и управление загружаемыми модулями ядра LKM.' },

            { id: 'lazygit', name: 'lazygit', cat: 'dev', lang: 'Go', icon: 'fa-code-branch', color: 'orange', old: 'git commit -m "..."', new: 'lg', desc: 'Многооконный консольный интерфейс для управления репозиториями Git. Оптимизирует рутинные процессы фиксации изменений, разрешения конфликтов слияния и интерактивного перебазирования (rebase).' },
            { id: 'micro', name: 'micro', cat: 'dev', lang: 'Go', icon: 'fa-keyboard', color: 'purple', old: 'nano / vim', new: 'micro', desc: 'Терминальный текстовый редактор с поддержкой современных соглашений ввода-вывода. Включает нативную интеграцию с системным буфером обмена, обработку мыши и гибкие механизмы плагинов.' },
            { id: 'tealdeer', name: 'tldr', cat: 'dev', lang: 'Rust', icon: 'fa-graduation-cap', color: 'cyan', old: 'man tar', new: 'tldr tar', desc: 'Автономный клиент справочной системы tldr на Rust. Извлекает только практические, применимые сценарии использования утилит, заменяя чтение избыточных системных мануалов.' },
            { id: 'file-org', name: 'organizer', cat: 'dev', lang: 'C++20', icon: 'fa-sitemap', color: 'yellow', old: '[manual move]', new: 'file-organizer', desc: 'Автоматизированный инструмент упорядочивания неструктурированных файловых массивов на базе C++20. Сортирует файлы по типам данных и метаданным в соответствии с заданным набором правил.' },

            { id: 'autosuggest', name: 'suggest', cat: 'net', lang: 'Zsh', icon: 'fa-wand-magic-sparkles', color: 'indigo', old: '[typing...]', new: '[gray hints]', desc: 'Модуль упреждающего ввода команд на основе истории сессии Zsh. Минимизирует количество нажатий клавиш, предлагая релевантные конструкции автодополнения в реальном времени.' },
            { id: 'highlight', name: 'syntax', cat: 'net', lang: 'Zsh', icon: 'fa-palette', color: 'pink', old: '[white text]', new: '[green/red]', desc: 'Плагин подсветки и статического анализа синтаксиса в процессе ввода. Валидирует правильность команд до вызова системного прерывания (Enter).' },
            { id: 'asn', name: 'asn', cat: 'net', lang: 'Shell', icon: 'fa-network-wired', color: 'blue', old: 'whois 8.8.8.8', new: 'asn 8.8.8.8', desc: 'Утилита сетевой диагностики и агрегации открытых источников информации (OSINT). Осуществляет трассировку BGP маршрутов, WHOIS-запросы и сопоставление ASN.' },
            { id: 'grc', name: 'grc', cat: 'net', lang: 'Python', icon: 'fa-brush', color: 'emerald', old: 'ping 1.1.1.1', new: 'grc ping 1.1.1.1', desc: 'Дженерик-колоризатор вывода системных утилит командной строки. Повышает читаемость логов, дампов трафика и сетевых утилит вроде ping, traceroute.' }
        ];

        // --- СПРАВОЧНИК ГОРЯЧИХ КЛАВИШ ---
        const mastery = [
            { tool: 'Zsh Autosuggestions', key: '→ (Стрелка вправо)', res: 'Мгновенное применение предложенной конструкции автодополнения' },
            { tool: 'FZF', key: 'Ctrl + R', res: 'Запуск интерактивного нечеткого поиска по локальной истории команд Zsh' },
            { tool: 'LSD Tree View', key: 'lsd -la --tree', res: 'Иерархический рекурсивный вывод структуры каталогов' },
            { tool: 'Bat Viewer', key: 'bat <имя_файла>', res: 'Вывод содержимого файла с подсветкой синтаксиса и разметкой git-diff' },
            { tool: 'Zoxide Navigator', key: 'z <фрагмент_пути>', res: 'Быстрый переход в наиболее релевантную целевую директорию' },
            { tool: 'Lazygit Interface', key: 'lg', res: 'Инициализация графического TUI-представления для работы с Git' },
            { tool: 'Tealdeer (tldr)', key: 'tldr <команда>', res: 'Запрос краткой технической спецификации и практических примеров' },
            { tool: 'Btop Monitor', key: 'btop', res: 'Запуск интерактивного дашборда мониторинга ресурсов системы' },
            { tool: 'Micro Editor', key: 'Ctrl + S', res: 'Сохранение изменений в активном текстовом буфере' },
            { tool: 'Procs Process', key: 'procs --tree', res: 'Отображение древовидной иерархии родительских и дочерних процессов' }
        ];

        // --- STREAMING_CHUNK: Setting up rendering pipelines for tools and mastery table... ---
        // --- ФУНКЦИИ РЕНДЕРИНГА ---
        function renderTools(filter = 'all') {
            const grid = document.getElementById('tools-grid');
            grid.innerHTML = '';
            
            const filtered = filter === 'all' ? tools : tools.filter(t => t.cat === filter);
            
            filtered.forEach(tool => {
                grid.innerHTML += `
                    <div onclick="openModal('${tool.id}')" class="tool-card bg-card p-6 rounded-[2rem] flex flex-col items-start gap-4 cursor-pointer group">
                        <div class="w-12 h-12 rounded-2xl bg-${tool.color}-500/10 flex items-center justify-center text-${tool.color}-500 text-xl border border-${tool.color}-500/20 group-hover:scale-110 transition-transform">
                            <i class="fa-solid ${tool.icon}"></i>
                        </div>
                        <div class="w-full">
                            <div class="flex items-center justify-between mb-2">
                                <h3 class="font-bold text-lg text-white font-mono tracking-tight">${tool.name}</h3>
                                <span class="text-[8px] font-bold px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-text-dim uppercase tracking-widest">${tool.lang}</span>
                            </div>
                            <p class="text-xs text-text-dim leading-relaxed line-clamp-2">${tool.desc}</p>
                            <div class="mt-4 flex items-center gap-1 text-[10px] font-bold text-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity">
                                СПЕЦИФИКАЦИЯ <i class="fa-solid fa-chevron-right text-[8px]"></i>
                            </div>
                        </div>
                    </div>
                `;
            });
        }

        function renderMastery(query = '') {
            const body = document.getElementById('mastery-body');
            body.innerHTML = '';
            
            const filtered = mastery.filter(m => 
                m.tool.toLowerCase().includes(query.toLowerCase()) || 
                m.key.toLowerCase().includes(query.toLowerCase()) ||
                m.res.toLowerCase().includes(query.toLowerCase())
            );

            filtered.forEach(m => {
                body.innerHTML += `
                    <tr class="border-b border-white/5 hover:bg-white/5 transition group">
                        <td class="py-5 font-bold text-emerald-500">${m.tool}</td>
                        <td class="py-5 font-mono"><span class="bg-black/40 px-3 py-1 rounded-lg border border-white/10 group-hover:border-emerald-500/30 transition">${m.key}</span></td>
                        <td class="py-5 text-text-dim text-xs">${m.res}</td>
                    </tr>
                `;
            });
        }

        // --- STREAMING_CHUNK: Wiring modal events and clipboard API bindings... ---
        // --- МОДАЛЬНОЕ ОКНО СПЕЦИФИКАЦИИ ---
        function openModal(id) {
            const tool = tools.find(t => t.id === id);
            if (!tool) return;

            document.getElementById('modal-name').innerText = tool.name;
            document.getElementById('modal-tag').innerText = tool.lang + " Core Module";
            document.getElementById('modal-desc').innerText = tool.desc;
            document.getElementById('modal-old').innerText = tool.old;
            document.getElementById('modal-new').innerText = tool.new;
            
            const iconWrap = document.getElementById('modal-icon');
            iconWrap.className = `w-16 h-16 rounded-3xl flex items-center justify-center text-3xl border bg-${tool.color}-500/10 text-${tool.color}-500 border-${tool.color}-500/20`;
            iconWrap.innerHTML = `<i class="fa-solid ${tool.icon}"></i>`;

            const modal = document.getElementById('tool-modal');
            const content = document.getElementById('modal-content');
            
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            setTimeout(() => {
                content.classList.remove('scale-95', 'opacity-0');
                content.classList.add('scale-100', 'opacity-100');
            }, 50);
        }

        function closeModal() {
            const content = document.getElementById('modal-content');
            content.classList.remove('scale-100', 'opacity-100');
            content.classList.add('scale-95', 'opacity-0');
            setTimeout(() => {
                const modal = document.getElementById('tool-modal');
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }, 200);
        }

        function copyInstall() {
            const cmd = document.getElementById('install-cmd').innerText;
            navigator.clipboard.writeText(cmd);
            const toast = document.getElementById('copy-toast');
            toast.classList.remove('opacity-0');
            toast.classList.add('opacity-100');
            setTimeout(() => {
                toast.classList.remove('opacity-100');
                toast.classList.add('opacity-0');
            }, 2000);
        }

        // --- STREAMING_CHUNK: Initializing Chart.js performance configurations... ---
        // --- ПОСТРОЕНИЕ ГРАФИКОВ ---
        function initCharts() {
            // График производительности (Время отклика)
            new Chart(document.getElementById('speedChart'), {
                type: 'bar',
                data: {
                    labels: ['cat vs bat', 'find vs fd', 'ls vs lsd', 'ps vs procs'],
                    datasets: [
                        { label: 'POSIX Стандарт (мс)', data: [420, 850, 310, 560], backgroundColor: 'rgba(148, 163, 184, 0.1)', borderRadius: 8 },
                        { label: 'Модернизированный стек (мс)', data: [12, 45, 18, 55], backgroundColor: '#10b981', borderRadius: 8 }
                    ]
                },
                options: {
                    maintainAspectRatio: false,
                    plugins: { legend: { labels: { color: '#94a3b8', font: { size: 10 } } } },
                    scales: {
                        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
                        x: { grid: { display: false }, ticks: { color: '#94a3b8' } }
                    }
                }
            });

            // Распределение экосистемы
            new Chart(document.getElementById('stackChart'), {
                type: 'doughnut',
                data: {
                    labels: ['Rust (Безопасность/Скорость)', 'Go (Многопоточность)', 'C++/C (Системный)', 'Shell / Zsh'],
                    datasets: [{
                        data: [50, 25, 15, 10],
                        backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6'],
                        borderWidth: 0,
                        hoverOffset: 20
                    }]
                },
                options: {
                    maintainAspectRatio: false,
                    cutout: '75%',
                    plugins: { 
                        legend: { position: 'bottom', labels: { color: '#94a3b8', padding: 20, font: { size: 11 } } } 
                    }
                }
            });
        }

        // --- ИНИЦИАЛИЗАЦИЯ ПРИЛОЖЕНИЯ ---
        document.addEventListener('DOMContentLoaded', () => {
            renderTools();
            renderMastery();
            initCharts();

            // Обработчики фильтров
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('filter-btn-active'));
                    e.target.classList.add('filter-btn-active');
                    renderTools(e.target.dataset.category);
                });
            });

            // Обработчик интерактивного поиска
            document.getElementById('mastery-search').addEventListener('input', (e) => {
                renderMastery(e.target.value);
            });
        });
    </script>
</body>
</html>
