// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct NotchMascotStrings {
    let title: String
    let hint: String
    let visits: String
    let visitsHint: String
    let style: String
    let minimal: String
    let robot: String
    let shape: String
    let ball: String
    let egg: String
    let squircle: String
    let pill: String
    let color: String
    let pearl: String
    let mint: String
    let peach: String
    let lilac: String
    let lemon: String
    let rose: String
    let commandBar: String
    let commandBarHint: String
    let opensAs: String
    let droplet: String
    let openIsland: String
    /// The Settings preview, for VoiceOver, and what clicking it does.
    let preview: String
    let previewHint: String
    let happy: String
    let wink: String
    let love: String
    let sleepy: String
    let determined: String
    let surprised: String
    let searching: String
    let thinking: String
    let confused: String

    func style(_ style: NotchMascotStyle) -> String {
        style == .robot ? robot : minimal
    }

    func shape(_ shape: NotchMascotShape) -> String {
        switch shape {
        case .ball: return ball
        case .egg: return egg
        case .squircle: return squircle
        case .pill: return pill
        }
    }

    func palette(_ palette: NotchMascotPalette) -> String {
        switch palette {
        case .pearl: return pearl
        case .mint: return mint
        case .peach: return peach
        case .lilac: return lilac
        case .lemon: return lemon
        case .rose: return rose
        }
    }

    func commandBarStyle(_ style: NotchCommandBarStyle) -> String {
        style == .island ? openIsland : droplet
    }

    /// The name of a face. At rest it has none of its own.
    func mood(_ mood: NotchMascotMood) -> String {
        switch mood {
        case .idle: return title
        case .happy: return happy
        case .wink: return wink
        case .love: return love
        case .sleepy: return sleepy
        case .determined: return determined
        case .surprised: return surprised
        case .searching: return searching
        case .thinking: return thinking
        case .confused: return confused
        }
    }
}

extension FeatureStrings {
    static func notchMascot(_ language: AppLanguage) -> NotchMascotStrings {
        switch language {
        case .enUS: return NotchMascotStrings(
            title: "Companion",
            hint: "A little friend who lives in the island. It rests beside the camera when nothing else is there and steps aside for music, notices and activities.",
            visits: "Appear now and then",
            visitsHint: "Every few minutes it passes through the island with a short animation.",
            style: "Style", minimal: "Minimal", robot: "Robot",
            shape: "Shape", ball: "Ball", egg: "Egg", squircle: "Rounded square", pill: "Pill",
            color: "Color", pearl: "Pearl", mint: "Mint", peach: "Peach", lilac: "Lilac", lemon: "Lemon", rose: "Rose",
            commandBar: "Command Bar in the island",
            commandBarHint: "With the shortcut, the Command Bar comes out of the island with the companion as its face. It reacts while you search.",
            opensAs: "Opens as", droplet: "Drop", openIsland: "Open island",
            preview: "Companion preview", previewHint: "Click to see its faces.",
            happy: "Happy", wink: "Wink", love: "In love", sleepy: "Sleepy", determined: "Determined",
            surprised: "Surprised", searching: "Searching", thinking: "Thinking", confused: "Confused")
        case .ptBR: return NotchMascotStrings(
            title: "Companheiro",
            hint: "Um amiguinho que mora na ilha. Descansa ao lado da câmera quando não há mais nada ali e sai do caminho para música, avisos e atividades.",
            visits: "Aparecer de vez em quando",
            visitsHint: "A cada poucos minutos ele passa pela ilha com uma animação curta.",
            style: "Estilo", minimal: "Minimalista", robot: "Robô",
            shape: "Forma", ball: "Bolinha", egg: "Ovo", squircle: "Quadrado arredondado", pill: "Pílula",
            color: "Cor", pearl: "Pérola", mint: "Menta", peach: "Pêssego", lilac: "Lilás", lemon: "Limão", rose: "Rosa",
            commandBar: "Barra de comando na ilha",
            commandBarHint: "Com o atalho, a Barra de comando sai da ilha com o companheiro como ícone. Ele reage enquanto você pesquisa.",
            opensAs: "Abre como", droplet: "Gota", openIsland: "Ilha aberta",
            preview: "Prévia do companheiro", previewHint: "Clique para ver as expressões.",
            happy: "Feliz", wink: "Piscadinha", love: "Apaixonado", sleepy: "Sonolento", determined: "Determinado",
            surprised: "Surpreso", searching: "Procurando", thinking: "Pensando", confused: "Confuso")
        case .es: return NotchMascotStrings(
            title: "Compañero",
            hint: "Un amiguito que vive en la isla. Descansa junto a la cámara cuando no hay nada más y se aparta para la música, los avisos y las actividades.",
            visits: "Aparecer de vez en cuando",
            visitsHint: "Cada pocos minutos pasa por la isla con una animación corta.",
            style: "Estilo", minimal: "Minimalista", robot: "Robot",
            shape: "Forma", ball: "Bolita", egg: "Huevo", squircle: "Cuadrado redondeado", pill: "Píldora",
            color: "Color", pearl: "Perla", mint: "Menta", peach: "Melocotón", lilac: "Lila", lemon: "Limón", rose: "Rosa",
            commandBar: "Barra de comandos en la isla",
            commandBarHint: "Con el atajo, la Barra de comandos sale de la isla con el compañero como icono. Reacciona mientras buscas.",
            opensAs: "Se abre como", droplet: "Gota", openIsland: "Isla abierta",
            preview: "Vista previa del compañero", previewHint: "Haz clic para ver sus caras.",
            happy: "Feliz", wink: "Guiño", love: "Enamorado", sleepy: "Somnoliento", determined: "Decidido",
            surprised: "Sorprendido", searching: "Buscando", thinking: "Pensando", confused: "Confundido")
        case .sk: return NotchMascotStrings(
            title: "Spoločník",
            hint: "Malý kamarát, ktorý býva na ostrove. Odpočíva vedľa kamery, keď tam nič iné nie je, a uhne hudbe, upozorneniam a aktivitám.",
            visits: "Občas sa ukázať",
            visitsHint: "Každých pár minút prejde ostrovom s krátkou animáciou.",
            style: "Štýl", minimal: "Minimalistický", robot: "Robot",
            shape: "Tvar", ball: "Guľôčka", egg: "Vajíčko", squircle: "Zaoblený štvorec", pill: "Pilulka",
            color: "Farba", pearl: "Perleťová", mint: "Mätová", peach: "Broskyňová", lilac: "Orgovánová", lemon: "Citrónová", rose: "Ružová",
            commandBar: "Príkazová lišta na ostrove",
            commandBarHint: "Po stlačení skratky vyjde príkazová lišta z ostrova so spoločníkom ako tvárou. Reaguje, kým hľadáte.",
            opensAs: "Otvorí sa ako", droplet: "Kvapka", openIsland: "Otvorený ostrov",
            preview: "Ukážka spoločníka", previewHint: "Kliknutím zobrazíte jeho výrazy.",
            happy: "Šťastný", wink: "Žmurkanie", love: "Zamilovaný", sleepy: "Ospalý", determined: "Odhodlaný",
            surprised: "Prekvapený", searching: "Hľadá", thinking: "Premýšľa", confused: "Zmätený")
        case .de: return NotchMascotStrings(
            title: "Begleiter",
            hint: "Ein kleiner Freund, der in der Insel wohnt. Er ruht neben der Kamera, wenn dort nichts anderes ist, und macht Platz für Musik, Hinweise und Aktivitäten.",
            visits: "Ab und zu vorbeischauen",
            visitsHint: "Alle paar Minuten läuft er mit einer kurzen Animation durch die Insel.",
            style: "Stil", minimal: "Minimal", robot: "Roboter",
            shape: "Form", ball: "Kugel", egg: "Ei", squircle: "Abgerundetes Quadrat", pill: "Pille",
            color: "Farbe", pearl: "Perle", mint: "Minze", peach: "Pfirsich", lilac: "Flieder", lemon: "Zitrone", rose: "Rosa",
            commandBar: "Befehlsleiste in der Insel",
            commandBarHint: "Mit dem Kurzbefehl kommt die Befehlsleiste aus der Insel, mit dem Begleiter als Gesicht. Er reagiert, während du suchst.",
            opensAs: "Öffnet als", droplet: "Tropfen", openIsland: "Geöffnete Insel",
            preview: "Vorschau des Begleiters", previewHint: "Klicken, um seine Gesichter zu sehen.",
            happy: "Fröhlich", wink: "Zwinkernd", love: "Verliebt", sleepy: "Schläfrig", determined: "Entschlossen",
            surprised: "Überrascht", searching: "Suchend", thinking: "Nachdenklich", confused: "Verwirrt")
        case .fr: return NotchMascotStrings(
            title: "Compagnon",
            hint: "Un petit ami qui vit dans l’île. Il se repose à côté de la caméra quand rien d’autre n’y est affiché et laisse la place à la musique, aux notifications et aux activités.",
            visits: "Passer de temps en temps",
            visitsHint: "Toutes les quelques minutes, il traverse l’île avec une courte animation.",
            style: "Style", minimal: "Minimaliste", robot: "Robot",
            shape: "Forme", ball: "Boule", egg: "Œuf", squircle: "Carré arrondi", pill: "Pilule",
            color: "Couleur", pearl: "Perle", mint: "Menthe", peach: "Pêche", lilac: "Lilas", lemon: "Citron", rose: "Rose",
            commandBar: "Barre de commande dans l’île",
            commandBarHint: "Avec le raccourci, la Barre de commande sort de l’île avec le compagnon comme visage. Il réagit pendant que vous cherchez.",
            opensAs: "S’ouvre en", droplet: "Goutte", openIsland: "Île ouverte",
            preview: "Aperçu du compagnon", previewHint: "Cliquez pour voir ses expressions.",
            happy: "Joyeux", wink: "Clin d’œil", love: "Amoureux", sleepy: "Endormi", determined: "Déterminé",
            surprised: "Surpris", searching: "En recherche", thinking: "Pensif", confused: "Perplexe")
        case .it: return NotchMascotStrings(
            title: "Compagno",
            hint: "Un piccolo amico che vive nell’isola. Riposa accanto alla fotocamera quando non c’è nient’altro e si fa da parte per musica, avvisi e attività.",
            visits: "Comparire ogni tanto",
            visitsHint: "Ogni pochi minuti attraversa l’isola con una breve animazione.",
            style: "Stile", minimal: "Minimale", robot: "Robot",
            shape: "Forma", ball: "Pallina", egg: "Uovo", squircle: "Quadrato arrotondato", pill: "Pillola",
            color: "Colore", pearl: "Perla", mint: "Menta", peach: "Pesca", lilac: "Lilla", lemon: "Limone", rose: "Rosa",
            commandBar: "Barra dei comandi nell’isola",
            commandBarHint: "Con la scorciatoia, la Barra dei comandi esce dall’isola con il compagno come volto. Reagisce mentre cerchi.",
            opensAs: "Si apre come", droplet: "Goccia", openIsland: "Isola aperta",
            preview: "Anteprima del compagno", previewHint: "Fai clic per vedere le sue espressioni.",
            happy: "Felice", wink: "Occhiolino", love: "Innamorato", sleepy: "Assonnato", determined: "Determinato",
            surprised: "Sorpreso", searching: "In cerca", thinking: "Pensieroso", confused: "Confuso")
        case .ru: return NotchMascotStrings(
            title: "Компаньон",
            hint: "Маленький друг, который живёт на острове. Он отдыхает рядом с камерой, когда там больше ничего нет, и уступает место музыке, уведомлениям и активностям.",
            visits: "Появляться время от времени",
            visitsHint: "Раз в несколько минут он пробегает по острову с короткой анимацией.",
            style: "Стиль", minimal: "Минимализм", robot: "Робот",
            shape: "Форма", ball: "Шарик", egg: "Яйцо", squircle: "Скруглённый квадрат", pill: "Пилюля",
            color: "Цвет", pearl: "Жемчуг", mint: "Мята", peach: "Персик", lilac: "Сирень", lemon: "Лимон", rose: "Роза",
            commandBar: "Командная панель на острове",
            commandBarHint: "По сочетанию клавиш Командная панель выходит из острова, а компаньон становится её лицом. Он реагирует, пока вы ищете.",
            opensAs: "Открывается как", droplet: "Капля", openIsland: "Открытый остров",
            preview: "Предпросмотр компаньона", previewHint: "Нажмите, чтобы увидеть его выражения.",
            happy: "Радость", wink: "Подмигивание", love: "Влюблённость", sleepy: "Сонливость", determined: "Решимость",
            surprised: "Удивление", searching: "Поиск", thinking: "Раздумье", confused: "Растерянность")
        case .tr: return NotchMascotStrings(
            title: "Arkadaş",
            hint: "Adada yaşayan küçük bir dost. Orada başka bir şey olmadığında kameranın yanında dinlenir, müzik, bildirimler ve etkinlikler için kenara çekilir.",
            visits: "Arada bir görün",
            visitsHint: "Birkaç dakikada bir kısa bir animasyonla adadan geçer.",
            style: "Stil", minimal: "Sade", robot: "Robot",
            shape: "Şekil", ball: "Top", egg: "Yumurta", squircle: "Yuvarlak kare", pill: "Hap",
            color: "Renk", pearl: "İnci", mint: "Nane", peach: "Şeftali", lilac: "Leylak", lemon: "Limon", rose: "Gül",
            commandBar: "Komut çubuğu adada",
            commandBarHint: "Kısayolla Komut çubuğu adadan çıkar ve arkadaş onun yüzü olur. Siz ararken tepki verir.",
            opensAs: "Açılış biçimi", droplet: "Damla", openIsland: "Açık ada",
            preview: "Arkadaş önizlemesi", previewHint: "Yüz ifadelerini görmek için tıklayın.",
            happy: "Mutlu", wink: "Göz kırpma", love: "Aşık", sleepy: "Uykulu", determined: "Kararlı",
            surprised: "Şaşırmış", searching: "Arıyor", thinking: "Düşünüyor", confused: "Kafası karışık")
        case .ja: return NotchMascotStrings(
            title: "コンパニオン",
            hint: "アイランドに住む小さな友だちです。ほかに何も表示されていないときはカメラの横で休み、音楽や通知、アクティビティにはその場所をゆずります。",
            visits: "ときどき現れる",
            visitsHint: "数分ごとに、短いアニメーションでアイランドを通り抜けます。",
            style: "スタイル", minimal: "ミニマル", robot: "ロボット",
            shape: "形", ball: "まる", egg: "たまご", squircle: "角丸の四角", pill: "カプセル",
            color: "色", pearl: "パール", mint: "ミント", peach: "ピーチ", lilac: "ライラック", lemon: "レモン", rose: "ローズ",
            commandBar: "アイランドのコマンドバー",
            commandBarHint: "ショートカットでコマンドバーがアイランドから現れ、コンパニオンがその顔になります。検索中は反応します。",
            opensAs: "開き方", droplet: "しずく", openIsland: "開いたアイランド",
            preview: "コンパニオンのプレビュー", previewHint: "クリックすると表情が見られます。",
            happy: "うれしい", wink: "ウインク", love: "ラブ", sleepy: "ねむい", determined: "やる気",
            surprised: "びっくり", searching: "さがし中", thinking: "考え中", confused: "こまった")
        case .ko: return NotchMascotStrings(
            title: "컴패니언",
            hint: "아일랜드에 사는 작은 친구입니다. 다른 것이 없을 때는 카메라 옆에서 쉬고, 음악, 알림, 활동에는 자리를 비켜 줍니다.",
            visits: "가끔 나타나기",
            visitsHint: "몇 분마다 짧은 애니메이션으로 아일랜드를 지나갑니다.",
            style: "스타일", minimal: "미니멀", robot: "로봇",
            shape: "모양", ball: "공", egg: "달걀", squircle: "둥근 사각형", pill: "알약",
            color: "색상", pearl: "펄", mint: "민트", peach: "피치", lilac: "라일락", lemon: "레몬", rose: "로즈",
            commandBar: "아일랜드의 명령 막대",
            commandBarHint: "단축키를 누르면 명령 막대가 아일랜드에서 나오고 컴패니언이 그 얼굴이 됩니다. 검색하는 동안 반응합니다.",
            opensAs: "열리는 방식", droplet: "물방울", openIsland: "열린 아일랜드",
            preview: "컴패니언 미리 보기", previewHint: "클릭하면 표정을 볼 수 있습니다.",
            happy: "행복", wink: "윙크", love: "사랑", sleepy: "졸림", determined: "결연",
            surprised: "놀람", searching: "찾는 중", thinking: "생각 중", confused: "혼란")
        case .zhHans: return NotchMascotStrings(
            title: "小伙伴",
            hint: "住在岛里的小朋友。岛上没有其他内容时，它会在摄像头旁休息，并为音乐、通知和活动让出位置。",
            visits: "偶尔出现",
            visitsHint: "每隔几分钟，它会以简短的动画从岛上经过。",
            style: "风格", minimal: "极简", robot: "机器人",
            shape: "形状", ball: "圆球", egg: "鸡蛋", squircle: "圆角方形", pill: "药丸",
            color: "颜色", pearl: "珍珠", mint: "薄荷", peach: "蜜桃", lilac: "丁香", lemon: "柠檬", rose: "玫瑰",
            commandBar: "在岛中使用命令栏",
            commandBarHint: "按下快捷键，命令栏会从岛中出现，小伙伴就是它的脸。你搜索时它会做出反应。",
            opensAs: "打开方式", droplet: "水滴", openIsland: "展开的岛",
            preview: "小伙伴预览", previewHint: "点击查看它的表情。",
            happy: "开心", wink: "眨眼", love: "心动", sleepy: "困倦", determined: "坚定",
            surprised: "惊讶", searching: "寻找中", thinking: "思考中", confused: "困惑")
        case .zhTW: return NotchMascotStrings(
            title: "小夥伴",
            hint: "住在動態島裡的小朋友。島上沒有其他內容時，它會在相機旁休息，並為音樂、通知和活動讓出位置。",
            visits: "偶爾出現",
            visitsHint: "每隔幾分鐘，它會以簡短的動畫從動態島經過。",
            style: "風格", minimal: "極簡", robot: "機器人",
            shape: "形狀", ball: "圓球", egg: "雞蛋", squircle: "圓角方形", pill: "藥丸",
            color: "顏色", pearl: "珍珠", mint: "薄荷", peach: "蜜桃", lilac: "丁香", lemon: "檸檬", rose: "玫瑰",
            commandBar: "在動態島中使用指令列",
            commandBarHint: "按下快速鍵，指令列會從動態島出現，小夥伴就是它的臉。你搜尋時它會做出反應。",
            opensAs: "開啟方式", droplet: "水滴", openIsland: "展開的動態島",
            preview: "小夥伴預覽", previewHint: "按一下即可查看它的表情。",
            happy: "開心", wink: "眨眼", love: "心動", sleepy: "睏倦", determined: "堅定",
            surprised: "驚訝", searching: "尋找中", thinking: "思考中", confused: "困惑")
        case .zhHK: return NotchMascotStrings(
            title: "小夥伴",
            hint: "住在動態島裡的小朋友。島上沒有其他內容時，它會在相機旁休息，並為音樂、通知和活動讓出位置。",
            visits: "間中出現",
            visitsHint: "每隔幾分鐘，它會以簡短的動畫從動態島經過。",
            style: "風格", minimal: "極簡", robot: "機械人",
            shape: "形狀", ball: "圓球", egg: "雞蛋", squircle: "圓角方形", pill: "藥丸",
            color: "顏色", pearl: "珍珠", mint: "薄荷", peach: "蜜桃", lilac: "丁香", lemon: "檸檬", rose: "玫瑰",
            commandBar: "在動態島中使用指令列",
            commandBarHint: "按下快捷鍵，指令列會從動態島出現，小夥伴就是它的臉。你搜尋時它會作出反應。",
            opensAs: "開啟方式", droplet: "水滴", openIsland: "展開的動態島",
            preview: "小夥伴預覽", previewHint: "按一下即可查看它的表情。",
            happy: "開心", wink: "眨眼", love: "心動", sleepy: "睏倦", determined: "堅定",
            surprised: "驚訝", searching: "尋找中", thinking: "思考中", confused: "困惑")
        case .uk: return NotchMascotStrings(
            title: "Компаньйон",
            hint: "Маленький друг, який живе в острівці. Він відпочиває біля камери, коли там більше нічого немає, і поступається місцем музиці, сповіщенням і активностям.",
            visits: "З’являтися час від часу",
            visitsHint: "Раз на кілька хвилин він пробігає острівцем із короткою анімацією.",
            style: "Стиль", minimal: "Мінімалізм", robot: "Робот",
            shape: "Форма", ball: "Кулька", egg: "Яйце", squircle: "Заокруглений квадрат", pill: "Пігулка",
            color: "Колір", pearl: "Перлина", mint: "М’ята", peach: "Персик", lilac: "Бузок", lemon: "Лимон", rose: "Троянда",
            commandBar: "Панель команд в острівці",
            commandBarHint: "За поєднанням клавіш Панель команд виходить з острівця, а компаньйон стає її обличчям. Він реагує, поки ви шукаєте.",
            opensAs: "Відкривається як", droplet: "Крапля", openIsland: "Відкритий острівець",
            preview: "Попередній перегляд компаньйона", previewHint: "Натисніть, щоб побачити його вирази.",
            happy: "Радість", wink: "Підморгування", love: "Закоханість", sleepy: "Сонливість", determined: "Рішучість",
            surprised: "Здивування", searching: "Пошук", thinking: "Роздуми", confused: "Розгубленість")
        }
    }
}
