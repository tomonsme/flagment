import AppKit
import CoreGraphics

let designSize = CGSize(width: 1320, height: 2868)
let canvasSize = CGSize(width: 1284, height: 2778)
let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("marketing/appstore")
let iconURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Fragment/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: y, width: w, height: h)
}

func roundedRect(_ frame: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: frame, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

func drawText(
    _ text: String,
    in frame: CGRect,
    size: CGFloat,
    weight: NSFont.Weight = .regular,
    color: NSColor = .white,
    alignment: NSTextAlignment = .left,
    lineSpacing: CGFloat = 0
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineSpacing = lineSpacing
    paragraph.lineBreakMode = .byWordWrapping
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: 0
    ]
    NSAttributedString(string: text, attributes: attributes).draw(in: frame)
}

func drawMono(_ text: String, in frame: CGRect, size: CGFloat, weight: NSFont.Weight = .regular, color: NSColor = .white, alignment: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byTruncatingTail
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: 0
    ]
    NSAttributedString(string: text, attributes: attributes).draw(in: frame)
}

func drawLine(from: CGPoint, to: CGPoint, color: NSColor, width: CGFloat) {
    let path = NSBezierPath()
    path.move(to: from)
    path.line(to: to)
    color.setStroke()
    path.lineWidth = width
    path.stroke()
}

func drawCircle(center: CGPoint, radius: CGFloat, fill: NSColor) {
    let path = NSBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    fill.setFill()
    path.fill()
}

func drawBackground() {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [color(0x050506).cgColor, color(0x0b0c0e).cgColor, color(0x15100f).cgColor] as CFArray,
        locations: [0, 0.62, 1]
    )!
    context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: designSize.width, y: designSize.height), options: [])
    for index in 0..<18 {
        let x = CGFloat((index * 137) % 1200) + 48
        let y = CGFloat((index * 211) % 2500) + 170
        drawCircle(center: CGPoint(x: x, y: y), radius: CGFloat(2 + (index % 3)), fill: color(0xffffff, 0.045))
    }
}

func drawBrand() {
    roundedRect(rect(78, 88, 88, 88), radius: 24, fill: color(0xffffff, 0.06), stroke: color(0xffffff, 0.12))
    if let icon = NSImage(contentsOf: iconURL) {
        icon.draw(in: rect(78, 88, 88, 88), from: .zero, operation: .sourceOver, fraction: 1)
    }
    drawText("Fragment", in: rect(188, 92, 520, 54), size: 48, weight: .semibold, color: color(0xffffff, 0.94))
    drawText("ONE-SHOT TRUTH", in: rect(190, 148, 380, 26), size: 19, weight: .semibold, color: color(0xffffff, 0.40))
}

func drawHero(_ title: String, subtitle: String, top: CGFloat = 304, titleHeight: CGFloat = 300, subtitleOffset: CGFloat = 318) {
    drawText(title, in: rect(78, top, 1164, titleHeight), size: 82, weight: .bold, color: color(0xffffff, 0.95), lineSpacing: 10)
    drawText(subtitle, in: rect(82, top + subtitleOffset, 1080, 122), size: 34, weight: .regular, color: color(0xffffff, 0.58), lineSpacing: 9)
}

func drawPhoneFrame(y: CGFloat = 882, height: CGFloat = 1646) -> CGRect {
    let phone = rect(132, y, 1056, height)
    roundedRect(phone, radius: 96, fill: color(0x0b0d10), stroke: color(0xffffff, 0.18), lineWidth: 3)
    roundedRect(rect(phone.minX + 24, phone.minY + 24, phone.width - 48, phone.height - 48), radius: 76, fill: color(0x08090b), stroke: color(0xffffff, 0.06))
    let screen = rect(phone.minX + 48, phone.minY + 52, phone.width - 96, phone.height - 104)
    roundedRect(screen, radius: 58, fill: color(0x0d0f12), stroke: color(0xffffff, 0.05))
    return screen
}

func drawNotificationCard(x: CGFloat, y: CGFloat, w: CGFloat, app: String, sender: String, message: String, time: String) {
    roundedRect(rect(x, y, w, 142), radius: 32, fill: color(0xffffff, 0.135), stroke: color(0xffffff, 0.12))
    drawText(app, in: rect(x + 32, y + 24, w - 150, 26), size: 22, weight: .medium, color: color(0xffffff, 0.50))
    drawText(time, in: rect(x + w - 116, y + 24, 84, 26), size: 22, color: color(0xffffff, 0.42), alignment: .right)
    drawText(sender, in: rect(x + 32, y + 58, w - 64, 34), size: 28, weight: .semibold, color: color(0xffffff, 0.92))
    drawText(message, in: rect(x + 32, y + 94, w - 64, 36), size: 26, color: color(0xffffff, 0.70))
}

func drawReceiptCard(in frame: CGRect, store: String, time: String, lines: [(String, String)], total: String) {
    roundedRect(frame, radius: 34, fill: color(0xffffff, 0.92), stroke: color(0xffffff, 0.20))
    drawMono(store, in: rect(frame.minX + 42, frame.minY + 40, frame.width - 84, 34), size: 30, weight: .medium, color: color(0x151515, 0.88), alignment: .center)
    drawMono(time, in: rect(frame.minX + 42, frame.minY + 78, frame.width - 84, 28), size: 22, color: color(0x151515, 0.52), alignment: .center)
    drawLine(from: CGPoint(x: frame.minX + 42, y: frame.minY + 126), to: CGPoint(x: frame.maxX - 42, y: frame.minY + 126), color: color(0x151515, 0.16), width: 1)
    for (index, line) in lines.enumerated() {
        let y = frame.minY + 152 + CGFloat(index * 44)
        drawMono(line.0, in: rect(frame.minX + 42, y, frame.width - 170, 32), size: 27, color: color(0x161616, 0.82))
        drawMono(line.1, in: rect(frame.maxX - 150, y, 108, 32), size: 27, color: color(0x161616, 0.82), alignment: .right)
    }
    drawLine(from: CGPoint(x: frame.minX + 42, y: frame.maxY - 88), to: CGPoint(x: frame.maxX - 42, y: frame.maxY - 88), color: color(0x151515, 0.16), width: 1)
    drawMono("合計", in: rect(frame.minX + 42, frame.maxY - 60, 140, 34), size: 28, weight: .medium, color: color(0x151515, 0.82))
    drawMono(total, in: rect(frame.maxX - 230, frame.maxY - 60, 188, 34), size: 28, weight: .medium, color: color(0x151515, 0.82), alignment: .right)
}

func drawRevealPanel(in frame: CGRect, title: String, body: String) {
    roundedRect(frame, radius: 38, fill: color(0xffffff, 0.08), stroke: color(0xffffff, 0.14))
    drawText("真相", in: rect(frame.minX + 42, frame.minY + 40, frame.width - 84, 34), size: 24, weight: .semibold, color: color(0xffffff, 0.44))
    drawText(title, in: rect(frame.minX + 42, frame.minY + 86, frame.width - 84, 130), size: 42, weight: .semibold, color: color(0xffffff, 0.92), lineSpacing: 8)
    drawText(body, in: rect(frame.minX + 42, frame.minY + 236, frame.width - 84, frame.height - 276), size: 29, color: color(0xffffff, 0.66), lineSpacing: 8)
}

func drawButton(_ title: String, in frame: CGRect) {
    roundedRect(frame, radius: frame.height / 2, fill: color(0xffffff, 0.92), stroke: color(0xffffff, 0.10))
    drawText(title, in: rect(frame.minX, frame.minY + 18, frame.width, frame.height - 24), size: 36, weight: .semibold, color: color(0x090909), alignment: .center)
}

func drawFooter(_ text: String) {
    drawText(text, in: rect(82, 2636, 1156, 96), size: 32, weight: .medium, color: color(0xffffff, 0.64), alignment: .center, lineSpacing: 9)
}

func scene01() {
    drawBackground()
    drawBrand()
    drawHero("質問はできない。\n少ない情報から\n真相を見抜け。", subtitle: "通知欄、レシート、深夜の購入履歴。\n一枚の断片だけで、何が起きたのかを読む。", titleHeight: 390, subtitleOffset: 420)
    let screen = drawPhoneFrame()
    drawText("02:14", in: rect(screen.minX, screen.minY + 82, screen.width, 112), size: 86, weight: .thin, color: color(0xffffff, 0.88), alignment: .center)
    drawText("土曜日, 5月23日", in: rect(screen.minX, screen.minY + 190, screen.width, 34), size: 27, color: color(0xffffff, 0.46), alignment: .center)
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 308, w: screen.width - 108, app: "Uber Eats", sender: "配達完了", message: "ご注文が配達されました", time: "2分前")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 478, w: screen.width - 108, app: "メッセージ", sender: "母", message: "電話出て", time: "02:11")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 648, w: screen.width - 108, app: "カード", sender: "楽天カード", message: "お支払いに関するご案内", time: "02:08")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 818, w: screen.width - 108, app: "LINE", sender: "未読メッセージ 17件", message: "通知を確認してください", time: "01:59")
    drawReceiptCard(in: rect(screen.minX + 80, screen.minY + 1058, screen.width - 160, 380), store: "NIGHT MINI", time: "02:13", lines: [("氷", "198"), ("ストロング缶", "428"), ("胃薬", "598")], total: "1,842円")
    drawButton("真相を見る", in: rect(222, 2396, 876, 84))
    drawFooter("スコアも、勝敗もない。\nぞっとするほど腑に落ちる、一発読み切りミステリー。")
}

func scene02() {
    drawBackground()
    drawBrand()
    drawHero("通知だけで、\nその夜が見える。", subtitle: "誰かのスマホに残った数行。\n未読、家族、決済通知。順番まで手がかりになる。")
    let screen = drawPhoneFrame(y: 830, height: 1540)
    drawText("03:27", in: rect(screen.minX, screen.minY + 82, screen.width, 112), size: 86, weight: .thin, color: color(0xffffff, 0.88), alignment: .center)
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 300, w: screen.width - 108, app: "カレンダー", sender: "9:00 面談", message: "15分前に通知", time: "明日")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 470, w: screen.width - 108, app: "LINE", sender: "上司", message: "既読つけなくていいから見て", time: "03:14")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 640, w: screen.width - 108, app: "メッセージ", sender: "父", message: "母にはまだ言わないで", time: "02:58")
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 810, w: screen.width - 108, app: "タクシー", sender: "乗車履歴", message: "目的地を変更しました", time: "02:41")
    drawButton("真相を見る", in: rect(screen.minX + 80, screen.maxY - 156, screen.width - 160, 84))
    drawFooter("眺めるだけでは終わらない。\n数秒後、自分の読みがひっくり返る。")
}

func scene03() {
    drawBackground()
    drawBrand()
    drawHero("レシートは、\nかなり喋る。", subtitle: "買った物、時刻、合計金額。\n生活感の中に、説明されない違和感が残る。")
    let screen = drawPhoneFrame(y: 830, height: 1540)
    drawReceiptCard(in: rect(screen.minX + 86, screen.minY + 118, screen.width - 172, 486), store: "STATION MART", time: "00:46", lines: [("のど飴", "238"), ("水 2L", "128"), ("子ども用歯ブラシ", "198"), ("充電ケーブル", "1,280"), ("封筒", "110")], total: "1,954円")
    drawReceiptCard(in: rect(screen.minX + 86, screen.minY + 682, screen.width - 172, 486), store: "PHARMACY K", time: "22:18", lines: [("湿布", "698"), ("冷却シート", "498"), ("栄養ドリンク", "298"), ("小さいハサミ", "220"), ("絆創膏", "330")], total: "2,044円")
    drawButton("真相を見る", in: rect(screen.minX + 80, screen.maxY - 156, screen.width - 160, 84))
    drawFooter("これは買い物記録ではない。\n誰かがその日を乗り切った証拠。")
}

func scene04() {
    drawBackground()
    drawBrand()
    drawHero("答え合わせではなく、\n真相を読む。", subtitle: "正解率もスコアもない。\nただ、少ない情報が急に意味を持つ瞬間がある。")
    let screen = drawPhoneFrame(y: 830, height: 1540)
    drawNotificationCard(x: screen.minX + 54, y: screen.minY + 116, w: screen.width - 108, app: "メッセージ", sender: "母", message: "電話出て", time: "02:11")
    drawReceiptCard(in: rect(screen.minX + 80, screen.minY + 310, screen.width - 160, 380), store: "NIGHT MINI", time: "02:13", lines: [("氷", "198"), ("ストロング缶", "428"), ("胃薬", "598")], total: "1,842円")
    drawRevealPanel(in: rect(screen.minX + 70, screen.minY + 760, screen.width - 140, 406), title: "帰る場所はある。\nでも、戻りたくない夜だった。", body: "終電後、連絡を返せないままコンビニに寄った。母の電話も、カード通知も、明日の仕事も全部見えている。それでもこの人は、もう一缶だけ買った。")
    drawButton("次の問題へ", in: rect(screen.minX + 80, screen.maxY - 156, screen.width - 160, 84))
    drawFooter("見たあとに、もう一度断片を見る。\n同じ一枚が別の意味に変わる。")
}

func scene05() {
    drawBackground()
    drawBrand()
    drawHero("好きな断片から、\nすぐ読める。", subtitle: "深夜、家族、恋愛、お金、仕事、孤独。\nジャンル別に選んで、お気に入りにも戻れる。")
    let screen = drawPhoneFrame(y: 830, height: 1540)
    let tags = ["今日の謎", "深夜", "家族", "恋愛", "お金", "仕事", "孤独", "お気に入り"]
    for (index, tag) in tags.enumerated() {
        let row = CGFloat(index / 2)
        let column = CGFloat(index % 2)
        let x = screen.minX + 70 + column * ((screen.width - 170) / 2 + 30)
        let y = screen.minY + 120 + row * 132
        roundedRect(rect(x, y, (screen.width - 170) / 2, 92), radius: 26, fill: color(0xffffff, index == 0 ? 0.18 : 0.09), stroke: color(0xffffff, 0.12))
        drawText(tag, in: rect(x + 24, y + 26, (screen.width - 170) / 2 - 48, 36), size: 28, weight: .semibold, color: color(0xffffff, 0.86), alignment: .center)
    }
    drawRevealPanel(in: rect(screen.minX + 70, screen.minY + 720, screen.width - 140, 430), title: "1分で読めて、\n少し残る。", body: "ログインなし。通信なし。広告なし。開いた瞬間に一問、真相を見たら次へ。短い空き時間に、静かな違和感だけを読む。")
    drawButton("Fragmentを開く", in: rect(screen.minX + 80, screen.maxY - 156, screen.width - 160, 84))
    drawFooter("余計な説明を削った、\n一発読み切りの考察エンタメ。")
}

func render(_ scene: @escaping () -> Void, filename: String) throws {
    let view = PromoView(frame: CGRect(origin: .zero, size: canvasSize), renderer: scene)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Unable to create bitmap")
    }
    bitmap.size = view.bounds.size
    view.cacheDisplay(in: view.bounds, to: bitmap)
    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Unable to create PNG")
    }
    let url = outputDirectory.appendingPathComponent(filename)
    try png.write(to: url)
    print(url.path)
}

final class PromoView: NSView {
    let renderer: () -> Void

    init(frame: CGRect, renderer: @escaping () -> Void) {
        self.renderer = renderer
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        context.saveGState()
        context.scaleBy(x: bounds.width / designSize.width, y: bounds.height / designSize.height)
        renderer()
        context.restoreGState()
    }
}

try render(scene01, filename: "01-hook.png")
try render(scene02, filename: "02-notifications.png")
try render(scene03, filename: "03-receipts.png")
try render(scene04, filename: "04-truth.png")
try render(scene05, filename: "05-library.png")
