import AppKit
import CoreGraphics

let width: CGFloat = 1320
let height: CGFloat = 2868
let scale: CGFloat = 1
let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("marketing/fragment-appstore-promo-6-9.png")
let iconURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Fragment/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")

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
    lineSpacing: CGFloat = 0,
    fontName: String? = nil
) {
    let font: NSFont
    if let fontName, let namedFont = NSFont(name: fontName, size: size) {
        font = namedFont
    } else {
        font = NSFont.systemFont(ofSize: size, weight: weight)
    }
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineSpacing = lineSpacing
    paragraph.lineBreakMode = .byWordWrapping
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: 0
    ]
    NSAttributedString(string: text, attributes: attributes).draw(in: frame)
}

func drawMonospaceText(_ text: String, in frame: CGRect, size: CGFloat, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byTruncatingTail
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
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
    let frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    let path = NSBezierPath(ovalIn: frame)
    fill.setFill()
    path.fill()
}

func drawNotificationCard(x: CGFloat, y: CGFloat, w: CGFloat, app: String, sender: String, message: String, time: String) {
    roundedRect(rect(x, y, w, 142), radius: 32, fill: color(0xffffff, 0.135), stroke: color(0xffffff, 0.12), lineWidth: 1)
    drawText(app, in: rect(x + 32, y + 24, w - 150, 26), size: 22, weight: .medium, color: color(0xffffff, 0.50))
    drawText(time, in: rect(x + w - 116, y + 24, 84, 26), size: 22, weight: .regular, color: color(0xffffff, 0.42), alignment: .right)
    drawText(sender, in: rect(x + 32, y + 58, w - 64, 34), size: 28, weight: .semibold, color: color(0xffffff, 0.92))
    drawText(message, in: rect(x + 32, y + 94, w - 64, 36), size: 26, weight: .regular, color: color(0xffffff, 0.70))
}

func drawReceiptLine(_ name: String, _ price: String, y: CGFloat, x: CGFloat, w: CGFloat) {
    drawMonospaceText(name, in: rect(x, y, w - 110, 30), size: 27, color: color(0x161616, 0.82))
    drawMonospaceText(price, in: rect(x + w - 118, y, 118, 30), size: 27, color: color(0x161616, 0.82), alignment: .right)
}

func renderPromo() {
guard let context = NSGraphicsContext.current?.cgContext else {
    fatalError("Unable to create drawing context")
}

context.saveGState()

let background = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        color(0x050506).cgColor,
        color(0x0b0c0e).cgColor,
        color(0x14100f).cgColor
    ] as CFArray,
    locations: [0, 0.56, 1]
)!
context.drawLinearGradient(
    background,
    start: CGPoint(x: 0, y: 0),
    end: CGPoint(x: width, y: height),
    options: []
)

for index in 0..<18 {
    let x = CGFloat((index * 137) % 1200) + 48
    let y = CGFloat((index * 211) % 2500) + 170
    drawCircle(center: CGPoint(x: x, y: y), radius: CGFloat(2 + (index % 3)), fill: color(0xffffff, 0.045))
}

roundedRect(rect(78, 88, 88, 88), radius: 24, fill: color(0xffffff, 0.06), stroke: color(0xffffff, 0.12), lineWidth: 1)
if let icon = NSImage(contentsOf: iconURL) {
    icon.draw(in: rect(78, 88, 88, 88), from: .zero, operation: .sourceOver, fraction: 1)
}
drawText("Fragment", in: rect(188, 92, 520, 54), size: 48, weight: .semibold, color: color(0xffffff, 0.94))
drawText("ONE-SHOT TRUTH", in: rect(190, 148, 380, 26), size: 19, weight: .semibold, color: color(0xffffff, 0.40))

drawText(
    "質問はできない。",
    in: rect(78, 304, 1164, 106),
    size: 86,
    weight: .bold,
    color: color(0xffffff, 0.95)
)
drawText(
    "少ない情報から\n真相を見抜け。",
    in: rect(78, 420, 1164, 226),
    size: 86,
    weight: .bold,
    color: color(0xffffff, 0.95),
    lineSpacing: 10
)
drawText(
    "通知欄、レシート、深夜の購入履歴。\n一枚の断片だけで、何が起きたのかを読む。",
    in: rect(82, 690, 1060, 116),
    size: 34,
    weight: .regular,
    color: color(0xffffff, 0.58),
    lineSpacing: 9
)

let phoneFrame = rect(132, 882, 1056, 1646)
roundedRect(phoneFrame, radius: 96, fill: color(0x0b0d10), stroke: color(0xffffff, 0.18), lineWidth: 3)
roundedRect(rect(phoneFrame.minX + 24, phoneFrame.minY + 24, phoneFrame.width - 48, phoneFrame.height - 48), radius: 76, fill: color(0x08090b), stroke: color(0xffffff, 0.06), lineWidth: 1)

let screen = rect(phoneFrame.minX + 48, phoneFrame.minY + 52, phoneFrame.width - 96, phoneFrame.height - 104)
roundedRect(screen, radius: 58, fill: color(0x0d0f12), stroke: color(0xffffff, 0.05), lineWidth: 1)

drawText("02:14", in: rect(screen.minX, screen.minY + 82, screen.width, 112), size: 86, weight: .thin, color: color(0xffffff, 0.88), alignment: .center)
drawText("土曜日, 5月23日", in: rect(screen.minX, screen.minY + 190, screen.width, 34), size: 27, weight: .regular, color: color(0xffffff, 0.46), alignment: .center)

drawNotificationCard(x: screen.minX + 54, y: screen.minY + 308, w: screen.width - 108, app: "Uber Eats", sender: "配達完了", message: "ご注文が配達されました", time: "2分前")
drawNotificationCard(x: screen.minX + 54, y: screen.minY + 478, w: screen.width - 108, app: "メッセージ", sender: "母", message: "電話出て", time: "02:11")
drawNotificationCard(x: screen.minX + 54, y: screen.minY + 648, w: screen.width - 108, app: "カード", sender: "楽天カード", message: "お支払いに関するご案内", time: "02:08")
drawNotificationCard(x: screen.minX + 54, y: screen.minY + 818, w: screen.width - 108, app: "LINE", sender: "未読メッセージ 17件", message: "通知を確認してください", time: "01:59")

roundedRect(rect(screen.minX + 80, screen.minY + 1058, screen.width - 160, 262), radius: 34, fill: color(0xffffff, 0.92), stroke: color(0xffffff, 0.20), lineWidth: 1)
drawMonospaceText("NIGHT MINI", in: rect(screen.minX + 122, screen.minY + 1098, screen.width - 244, 34), size: 30, color: color(0x151515, 0.88), alignment: .center)
drawMonospaceText("02:13", in: rect(screen.minX + 122, screen.minY + 1136, screen.width - 244, 28), size: 22, color: color(0x151515, 0.52), alignment: .center)
drawLine(from: CGPoint(x: screen.minX + 124, y: screen.minY + 1184), to: CGPoint(x: screen.maxX - 124, y: screen.minY + 1184), color: color(0x151515, 0.16), width: 1)
drawReceiptLine("氷", "198", y: screen.minY + 1208, x: screen.minX + 124, w: screen.width - 248)
drawReceiptLine("ストロング缶", "428", y: screen.minY + 1248, x: screen.minX + 124, w: screen.width - 248)
drawReceiptLine("胃薬", "598", y: screen.minY + 1288, x: screen.minX + 124, w: screen.width - 248)
drawLine(from: CGPoint(x: screen.minX + 124, y: screen.minY + 1334), to: CGPoint(x: screen.maxX - 124, y: screen.minY + 1334), color: color(0x151515, 0.16), width: 1)
drawMonospaceText("合計", in: rect(screen.minX + 124, screen.minY + 1356, 140, 34), size: 28, color: color(0x151515, 0.82))
drawMonospaceText("1,842円", in: rect(screen.maxX - 330, screen.minY + 1356, 206, 34), size: 28, color: color(0x151515, 0.82), alignment: .right)

roundedRect(rect(222, 2396, 876, 84), radius: 42, fill: color(0xffffff, 0.92), stroke: color(0xffffff, 0.12), lineWidth: 1)
drawText("真相を見る", in: rect(222, 2414, 876, 44), size: 36, weight: .semibold, color: color(0x090909), alignment: .center)

drawText(
    "スコアも、勝敗もない。\nぞっとするほど腑に落ちる、一発読み切りミステリー。",
    in: rect(82, 2612, 1156, 100),
    size: 32,
    weight: .medium,
    color: color(0xffffff, 0.64),
    alignment: .center,
    lineSpacing: 9
)
drawText("完全オフライン  /  広告なし  /  画像アセット不要", in: rect(82, 2742, 1156, 34), size: 24, weight: .regular, color: color(0xffffff, 0.34), alignment: .center)

context.restoreGState()
}

final class PromoView: NSView {
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        renderPromo()
    }
}

let view = PromoView(frame: rect(0, 0, width, height))
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(width),
    pixelsHigh: Int(height),
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

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to create PNG")
}

try pngData.write(to: outputURL)
print(outputURL.path)
