//
//  ContentView.swift
//  Fragment
//
//  Created by Tomoya Miyake on 2026/05/20.
//

import SwiftUI
import UIKit

enum ContentType: String {
    case notification
    case receipt
}

private enum ReadingFilter: String, CaseIterable, Identifiable {
    case today
    case all
    case lateNight
    case family
    case love
    case money
    case work
    case alone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "今日の謎"
        case .all:
            return "全問"
        case .lateNight:
            return "深夜"
        case .family:
            return "家族"
        case .love:
            return "恋愛"
        case .money:
            return "お金"
        case .work:
            return "仕事"
        case .alone:
            return "孤独"
        }
    }

    var systemName: String {
        switch self {
        case .today:
            return "calendar"
        case .all:
            return "rectangle.stack"
        case .lateNight:
            return "moon"
        case .family:
            return "house"
        case .love:
            return "heart"
        case .money:
            return "creditcard"
        case .work:
            return "briefcase"
        case .alone:
            return "person"
        }
    }

    func matches(_ item: FragmentItem) -> Bool {
        guard self != .all else { return true }

        let text = item.searchableText

        switch self {
        case .today:
            return false
        case .all:
            return true
        case .lateNight:
            return item.displayHour.map { $0 >= 22 || $0 <= 4 } ?? text.contains("深夜")
        case .family:
            return ["母", "父", "妻", "夫", "子", "家族", "祖母", "姉", "妹", "保育園", "学校", "実家"].contains { text.contains($0) }
        case .love:
            return ["彼", "元彼", "妻", "夫", "恋愛", "記念日", "プロポーズ", "二人", "関係", "別れ", "航", "玲奈", "結衣", "亮", "拓也", "美咲"].contains { text.contains($0) }
        case .money:
            return ["カード", "銀行", "残高", "返済", "ローン", "支出", "学費", "支払い", "限度額", "口座", "金額"].contains { text.contains($0) }
        case .work:
            return ["Slack", "会社", "上司", "面接", "転職", "仕事", "研修", "職務", "履歴書", "会議", "勤怠", "人事"].contains { text.contains($0) }
        case .alone:
            return ["一人", "孤独", "未読", "ホテル", "帰らない", "眠れない", "避難", "誰にも", "静か", "空白"].contains { text.contains($0) }
        }
    }
}

struct FragmentItem: Identifiable {
    let id = UUID()
    let type: ContentType
    let title: String
    let answer: String
    let displayTime: String
    let notifications: [NotificationLine]
    let receiptLines: [String]
}

struct NotificationLine: Identifiable {
    let id = UUID()
    let appName: String
    let sender: String
    let message: String
    let timeText: String
}

private extension FragmentItem {
    var searchableText: String {
        let notificationText = notifications.map { "\($0.appName) \($0.sender) \($0.message)" }.joined(separator: " ")
        let receiptText = receiptLines.joined(separator: " ")
        return "\(title) \(answer) \(displayTime) \(notificationText) \(receiptText)"
    }

    var displayHour: Int? {
        Int(displayTime.split(separator: ":").first ?? "")
    }

    var stableKey: String {
        let source = "\(type.rawValue)-\(displayTime)-\(title)"
        let value = source.unicodeScalars.reduce(0) { partial, scalar in
            (partial &* 31 &+ Int(scalar.value)) & 0x7fffffff
        }
        return "\(type.rawValue)-\(value)"
    }

    var typeLabel: String {
        switch type {
        case .notification:
            return "LOCK SCREEN"
        case .receipt:
            return "RECEIPT"
        }
    }

    var moodLabel: String {
        let pool = [
            "深夜",
            "未読",
            "家族",
            "恋愛",
            "疲労",
            "お金",
            "孤独",
            "社会人",
            "終電",
            "不穏"
        ]
        let seed = stableKey.unicodeScalars.reduce(title.count) { $0 + Int($1.value) }
        return pool[seed % pool.count]
    }

    var densityText: String {
        switch type {
        case .notification:
            return "\(notifications.count) NOTICES"
        case .receipt:
            return "\(receiptLines.count) ITEMS"
        }
    }

    var evidenceLines: [String] {
        switch type {
        case .notification:
            return notifications.prefix(3).map { line in
                "\(line.sender): \(line.message)"
            }
        case .receipt:
            return Array(receiptLines.prefix(3))
        }
    }

    var caseName: String {
        switch title {
        case "Locked iPhone":
            return "届いた夕食"
        case "Birthday":
            return "同時に来た通知"
        case "Hotel Lobby":
            return "家のある宿泊"
        case "Loan App":
            return "失敗した振込"
        case "Funeral Hall":
            return "写真の通知"
        case "Blocked":
            return "消したはずの人"
        case "NIGHT MINI":
            return "胃薬と酒"
        case "AIRPORT MINI":
            return "空港の香典袋"
        case "HOTEL SHOP":
            return "一泊分だけ"
        case "MACHI DELI":
            return "弁当一つ、箸二膳"
        case "Read Receipt":
            return "別アプリの証拠"
        case "Delivery Failed":
            return "再配達できないもの"
        case "Draft Saved":
            return "送信前の最後の平和"
        case "Baby Monitor":
            return "眠れない大人"
        case "Shared Calendar":
            return "消されない予定"
        case "MIDNIGHT DIY":
            return "夜中に直すもの"
        default:
            return title
        }
    }

    var truthHeadline: String {
        switch title {
        case "Locked iPhone":
            return "母の電話には出ず、先に受け取ったのは玄関前の夕食だった。"
        case "Birthday":
            return "誕生日の0時、祝福と返済通知が同じ画面に並んだ。"
        case "Hotel Lobby":
            return "旅行でも出張でもない。家に住所がある人の、帰らないための一泊。"
        case "Loan App":
            return "学費の振込に失敗し、借入結果を見る前に『正直に話す』だけをメモした。"
        case "Funeral Hall":
            return "亡くなった人の写真が、葬儀社より先にスマホから届いた。"
        case "Blocked":
            return "相手を消したのに、削除済み写真と非表示トークだけは残っている。"
        case "NIGHT MINI":
            return "胃薬で止めようとしている体に、同じ袋で酒を足している。"
        case "AIRPORT MINI":
            return "空港で買ったのは土産ではなく、香典袋だった。"
        case "HOTEL SHOP":
            return "一泊分だけの生活用品。逃げたのか、守ったのかは書かれていない。"
        case "MACHI DELI":
            return "弁当は一つなのに、箸だけ二膳。待っている相手は食卓にいない。"
        case "Read Receipt":
            return "相手の言葉より先に、別アプリが証拠を出してしまった。"
        case "Delivery Failed":
            return "受け取れなかったのは荷物ではなく、玄関まで来た相手。"
        case "Draft Saved":
            return "送ったら終わる言葉を、まだ下書きに閉じ込めている。"
        case "Baby Monitor":
            return "泣いているのは赤ちゃんだけではない。"
        case "Shared Calendar":
            return "関係は終わりかけても、予定だけはまだ二人分で残っている。"
        case "MIDNIGHT DIY":
            return "直したいのは家具ではなく、壊れた部屋の空気。"
        default:
            return revealShock
        }
    }

    var revealShock: String {
        switch title {
        case "Locked iPhone":
            return "母の着信は8分前、配達完了は1分前。人の声より先に、玄関前の袋を受け取っている。"
        case "Do Not Disturb":
            return "相手は怒っているのに、カレンダーだけは明日の仕事を平然と通知している。関係より先に朝が来る。"
        case "Low Battery":
            return "終電の通知と自宅からの不在着信が同じ画面にある。帰れないのではなく、帰った後を避けている。"
        case "Morning Alarm":
            return "アラームが鳴る前から、会社と家族の問題がもう起きている。朝は始まりではなく、夜の続き。"
        case "Unread":
            return "検査結果の連絡だけが未読のまま、写真アプリは過去を見せてくる。開けないのは通知ではなく現実。"
        case "Station Wi-Fi":
            return "決済額は小さいのに、場所だけが駅から動いていない。帰る電車ではなく、帰る決心を逃している。"
        case "NIGHT MINI":
            return "胃薬、ストロング缶、モンスターが同じ袋にある。回復と自傷が同じレシートに並んでいる。"
        case "SUN ROAD MART":
            return "子ども用歯ブラシだけが、今そこにいる誰かを説明しすぎている。生活は一人分ではない。"
        case "EKIMAE STORE":
            return "替えの靴下まで買っているのに、温かい食事がない。帰宅ではなく、どこかで夜をしのぐ準備に見える。"
        case "FAMILY GROCER":
            return "家族のための品ばかりなのに、自分をいたわるものが安いワインしかない。週末は休みではなく勤務。"
        case "24H PHARMACY":
            return "看病の買い物にも見えるが、誰宛てかが一つも書かれていない。孤独な体調不良ほど静かに見える。"
        case "CITY VALUE":
            return "紙皿と透明ごみ袋とガムテープ。食事より先に、片付けるものがある人の買い方。"
        case "Silent Mode":
            return "鍵の場所だけがメモに残っている。会話ではなく、入退室のルールだけで関係が続いている。"
        case "Office Floor":
            return "妻の『先に寝ます』の後にタクシークーポンが来る。帰る手段はあるのに、帰る理由が弱くなっている。"
        case "Shared Album":
            return "幸せな写真の通知の直後に、クリニックの予約変更がある。同じ一日でも、この人だけ別の重さを持っている。"
        case "Last Train":
            return "最終電車、内定者集合、不動産更新料。移動も仕事も生活も、全部が締切として同じ画面に並んでいる。"
        case "Unknown Number":
            return "知らない番号の後に採用担当からのメールが来ている。出なかった一本が、生活の分岐だったかもしれない。"
        case "Read Receipt":
            return "問い詰めるLINEとタグ付け通知が同時にある。証拠は相手からではなく、別のアプリから届いている。"
        case "Bank Notice":
            return "引き落とし失敗の後に面接予定がある。今日を変える予定と、昨日までの生活が同じ朝にぶつかっている。"
        case "Hospital Wi-Fi":
            return "父は『仕事戻れ』と言っているのに、病院の受付番号はまだ呼ばれていない。戻れない理由だけが増えている。"
        case "Birthday":
            return "祝福の通知が全部『今』なのに、返済予定日も同時に来ている。誕生日は、生活を免除してくれない。"
        case "Delivery Failed":
            return "配送の不在通知と『玄関の前まで行った』が重なる。受け取れなかったのは荷物だけではない。"
        case "Parent Chat":
            return "保育園、上司、夫、上履き。四方向から頼られているのに、この人を迎えに来る通知はない。"
        case "Two Homes":
            return "実家方面の乗換と、置いたままの荷物。帰る場所が二つあるほど、居場所は一つも決められない。"
        case "BLUE KIOSK":
            return "充電ケーブルまで買っている。夕食ではなく、まだどこかで起き続けるための補給。"
        case "MACHI DELI":
            return "弁当は一つ、割り箸は二膳。二人で食べる準備ではなく、来ない相手の分だけ習慣が残っている。"
        case "GREEN DRUG":
            return "薬ばかりの中にチョコレートが一つある。治す買い物ではなく、倒れないためのごまかし。"
        case "RAINY MART":
            return "傘と花束が同じレシートにある。会いに行く理由も、行けなかった言い訳も、どちらも揃っている。"
        case "PORT STORE":
            return "替えの下着とモバイルバッテリーだけが妙に現実的。旅行より、帰らない一日の準備に近い。"
        case "LOCAL BAKERY":
            return "紙袋と保冷剤まで買っているのに、品物は日常的すぎる。手土産というより、会う口実。"
        case "NORTH 24":
            return "ホットアイマスクとカフェイン錠が同じ袋にある。眠りたい体と、眠れない事情が同時にある。"
        case "VALUE PLUS":
            return "節約品だけで組まれたレシートの最後にシュークリームがある。生活の限界は、甘いものの小ささに出る。"
        case "STATION PHARM":
            return "風邪薬と口臭ケアが一緒にある。休む準備ではなく、人前で平気に見せる準備。"
        case "MOON MARKET":
            return "消臭スプレーと歯磨きシート。誰かが来る前より、誰かが帰った後の片付けに見える。"
        case "EAST SIDE CVS":
            return "深夜にコピー18枚。買い物ではなく、まだ終われない仕事の延長線。"
        case "SMALL LIFE":
            return "最低限の生活用品だけで、家具も食材もない。住み始めたというより、避難した生活。"
        case "Exam Eve":
            return "受験票の通知より、母の『まだ言わないで』が重い。試験前夜に別の秘密を背負わされている。"
        case "Care Home":
            return "薬の未記録と姉の『行けない』が同じ画面にある。責任が分担されず、この人にだけ残っている。"
        case "Wedding Group":
            return "結婚式グループの通知に、元彼と残高低下が混ざる。祝う場面ほど、自分の現在地が見えてしまう。"
        case "Funeral Hall":
            return "葬儀社の不在着信、忌引き申請、そして写真アプリの『2年前の今日』。悲しむ順番をスマホが壊している。"
        case "New Hire":
            return "初任給の話より先に、遅延と名刺入れが来ている。大人になる日は、かなり事務的に始まる。"
        case "Job Search":
            return "転職オファーと上司の進捗確認が同時にある。今の席に座りながら、別の人生を開いている。"
        case "Fan Club":
            return "唯一明るい通知の横に、カード利用と棚卸しがある。救いは趣味ではなく、持ちこたえる装置。"
        case "Class Reunion":
            return "同窓会の出欠と派遣契約の更新。昔の自分に会うには、今の自分の説明が必要になる。"
        case "Moving Day":
            return "段ボールの数より、転居先の通知の少なさが怖い。新生活ではなく、急いで消える準備かもしれない。"
        case "Night Bus":
            return "深夜バスは安い移動手段なのに、通知の並びは決心の重さを出している。戻るより離れる方を選んだ夜。"
        case "Pet Clinic":
            return "ペットの体調通知だけで生活が止まっている。小さな存在ほど、家の空気を全部変えてしまう。"
        case "After Proposal":
            return "プロポーズの後に現実的な通知が混ざる。幸せな出来事ほど、生活の細部を急に連れてくる。"
        case "Shared Calendar":
            return "共有予定だけが残っている。関係は終わりかけても、カレンダーはまだ二人分で動いている。"
        case "School Nurse":
            return "迎えに行く通知の裏で、迎えに行く側も限界に近い。子どもの不調だけの話ではない。"
        case "Loan App":
            return "学費の振込失敗、ローン審査結果、メモの『正直に話す』。まだ誰にも言っていないことだけが読める。"
        case "Hotel Lobby":
            return "ホテル予約の直前に『話し合いから逃げないで』が来ている。移動先ではなく、避難先としてのホテル。"
        case "Draft Saved":
            return "下書き保存は送信より怖い。言葉にする直前で、まだ関係を壊さずに済んでいる。"
        case "Baby Monitor":
            return "赤ちゃんの通知より、反応しない相手の静けさが目立つ。眠れないのは一人だけではない。"
        case "Blocked":
            return "通知設定の変更、削除済み写真、非表示トーク。終わらせた操作のあとに、残したものだけが並んでいる。"
        case "CEREMONY SHOP":
            return "礼服小物を今買っている。必要になることを、ぎりぎりまで認めたくなかった人のレシート。"
        case "EXAM STATION":
            return "受験の持ち物より、不安を埋める小物が多い。準備ではなく、落ち着くための儀式。"
        case "NURSING MART":
            return "介護用品と眠気覚ましが同じ袋に入っている。支える側が削られていく音がする。"
        case "AIRPORT MINI":
            return "空港で買ったものの中に香典袋がある。旅行の準備ではなく、訃報のあとに足りなかったもの。"
        case "IDOL POPUP":
            return "浪費に見える買い物ほど、逃げ場として正確なことがある。誰かには無駄でも、この人には必要。"
        case "MORNING CVS":
            return "朝のレシートなのに、夜を越えたものばかり並んでいる。出勤前ではなく徹夜明け。"
        case "WEEKEND HOME":
            return "食卓の人数は見えるのに、本人の食べたいものが見えない。家族の買い物ほど孤独が混ざる。"
        case "LAUNDRY SHOP":
            return "服を整える買い物なのに、生活全体を洗い直したい感じがある。汚れは布だけではない。"
        case "HOSPITAL CVS":
            return "誰かのためのものと自分のためのものが分かれていない。看病は生活をきれいに分けてくれない。"
        case "KIDS CORNER":
            return "小さなおもちゃは、時間の代わりに買われている。会えなかった分を物で埋める夜。"
        case "HOTEL SHOP":
            return "下着、耳栓、洗顔シート。一泊分だけ揃っているのに、楽しい予定の痕跡が一つもない。"
        case "SEA SIDE MART":
            return "海辺に来ているのに、買い物が一人分で静かすぎる。流れた予定の後か、自分で来た決心の後。"
        case "SUBURB DRUG":
            return "健康的な品ほど、切羽詰まって見えることがある。体を変えたいのではなく、生活を変えたい。"
        case "BOOKS AND MORE":
            return "前向きな本のタイトルより、買った時間の方が本音に近い。再出発は明るい顔をしていない。"
        case "MIDNIGHT DIY":
            return "工具で直せるものを買っている。でも壊れているのが家具とは限らない。"
        case "RIVER SIDE CVS":
            return "遠回りした先で買ったような物ばかり。家に近づく速度を、意図的に落としている。"
        case "AFTER PARTY":
            return "派手な夜の後に残るのは、生活感のあるものだけ。人といた時間ほど、帰り道の一人が濃くなる。"
        case "OLD TOWN SHOP":
            return "地元の店で買ったものは、今の生活より昔に近い。戻ってきたのに、帰ってきたとは言い切れない。"
        case "LAST MINUTE":
            return "贈り物なのに、準備の遅さが謝罪に見える。渡したい物より、間に合わせたい関係がある。"
        default:
            return hookLine
        }
    }

    var hookLine: String {
        switch moodLabel {
        case "深夜":
            return "まだ起きている理由だけが、画面に残っている。"
        case "未読":
            return "開かない通知ほど、生活の中心に近い。"
        case "家族":
            return "近い相手ほど、返せない夜がある。"
        case "恋愛":
            return "一通の前後に、言えなかったことがある。"
        case "疲労":
            return "ちゃんとする力が、少しだけ足りない。"
        case "お金":
            return "金額より先に、暮らしの余白が見える。"
        case "孤独":
            return "誰にも見られない時間だけが、正直になる。"
        case "社会人":
            return "仕事の通知が、生活の音を消している。"
        case "終電":
            return "間に合わなかったのは、電車だけではない。"
        default:
            return "何も起きていないようで、何かがずれている。"
        }
    }

    func shareText(includesAnswer: Bool) -> String {
        let base = """
        Fragment

        質問なし。1枚だけ見て、真相を見る。
        通知かレシートで成立する、一発もののウミガメのスープ。

        状況: \(caseName)
        \(title) / \(displayTime)

        見えている手がかり:
        \(evidenceLines.map { "- \($0)" }.joined(separator: "\n"))
        """

        guard includesAnswer else {
            return base
        }

        return """
        \(base)

        真相:
        \(truthHeadline)

        決め手:
        \(revealShock)

        補足:
        \(answer)
        """
    }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
    let text: String
}

private struct ReceiptEntry: Identifiable {
    let id = UUID()
    let index: Int
    let name: String
    let price: Int
}

private extension FragmentItem {
    var receiptEntries: [ReceiptEntry] {
        receiptLines.enumerated().map { index, line in
            let rawValue = line.unicodeScalars.reduce(index * 97 + title.count * 31) { $0 + Int($1.value) }
            let price = 120 + (rawValue % 980)
            return ReceiptEntry(index: index, name: line, price: price)
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct ContentView: View {
    @AppStorage("savedFragmentKeys") private var savedFragmentKeys = ""
    @State private var items = FragmentLibrary.makeDeck()
    @State private var currentIndex = 0
    @State private var isAnswerRevealed = false
    @State private var sharePayload: SharePayload?
    @State private var isReadingSavedOnly = false
    @State private var selectedFilter: ReadingFilter = .all
    @State private var isFilterListPresented = false

    private var activeItems: [FragmentItem] {
        let source: [FragmentItem]

        if isReadingSavedOnly {
            let keys = savedKeys
            source = FragmentLibrary.optimizedItems.filter { keys.contains($0.stableKey) }
        } else {
            source = items
        }

        if selectedFilter == .today {
            let daily = FragmentLibrary.dailyItem

            if isReadingSavedOnly {
                return savedKeys.contains(daily.stableKey) ? [daily] : source
            }

            return [daily]
        }

        let filtered = source.filter { selectedFilter.matches($0) }
        return filtered.isEmpty ? source : filtered
    }

    private var currentItem: FragmentItem {
        activeItems[safe: currentIndex] ?? items[0]
    }

    private var savedKeys: Set<String> {
        Set(savedFragmentKeys.split(separator: "|").map(String.init))
    }

    private var isCurrentItemSaved: Bool {
        savedKeys.contains(currentItem.stableKey)
    }

    private var filterSourceItems: [FragmentItem] {
        if isReadingSavedOnly {
            let keys = savedKeys
            return FragmentLibrary.optimizedItems.filter { keys.contains($0.stableKey) }
        }

        return items
    }

    private var filterCounts: [ReadingFilter: Int] {
        Dictionary(uniqueKeysWithValues: ReadingFilter.allCases.map { filter in
            if filter == .today {
                let daily = FragmentLibrary.dailyItem
                let count = isReadingSavedOnly && !savedKeys.contains(daily.stableKey) ? 0 : 1
                return (filter, count)
            }

            return (filter, filterSourceItems.filter { filter.matches($0) }.count)
        })
    }

    var body: some View {
        ZStack {
            BackgroundView()

            GeometryReader { geometry in
                let compactHeight = geometry.size.height < 740
                let cardHeight = compactHeight ? 430.0 : min(530.0, geometry.size.height * 0.62)

                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        HeaderView(
                            currentIndex: currentIndex,
                            totalCount: max(1, activeItems.count),
                            savedCount: savedKeys.count,
                            isReadingSavedOnly: isReadingSavedOnly,
                            selectedFilter: selectedFilter,
                            toggleSavedOnly: toggleSavedOnly,
                            showFilterList: showFilterList
                        )
                        .padding(.horizontal, 22)
                        .padding(.top, 18)

                        ProgressTrace(currentIndex: currentIndex, totalCount: max(1, activeItems.count))
                            .padding(.horizontal, 22)
                            .padding(.top, 14)
                            .transition(.opacity)

                        HookLineView(item: currentItem)
                            .padding(.horizontal, 22)
                            .padding(.top, 16)
                            .transition(.opacity)

                        Spacer(minLength: compactHeight ? 10 : 14)

                        FragmentDeckView(item: currentItem, cardHeight: cardHeight)
                            .id(currentItem.id)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.985)),
                                removal: .opacity.combined(with: .scale(scale: 0.995))
                            ))
                            .padding(.horizontal, 18)
                            .contentShape(Rectangle())

                        Spacer(minLength: compactHeight ? 12 : 16)

                        BottomPanelView(
                            item: currentItem,
                            isAnswerRevealed: isAnswerRevealed,
                            isSaved: isCurrentItemSaved,
                            revealAction: revealAnswer,
                            nextAction: goNext,
                            saveAction: toggleSaved,
                            shareAction: shareCurrentFragment
                        )
                        .padding(.horizontal, 22)
                        .padding(.bottom, 22)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(activityItems: [payload.image, payload.text])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isFilterListPresented) {
            ReadingFilterListView(
                selectedFilter: selectedFilter,
                counts: filterCounts
            ) { filter in
                selectFilter(filter)
                isFilterListPresented = false
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .preferredColorScheme(.dark)
        }
    }

    private func revealAnswer() {
        guard !isAnswerRevealed else { return }
        Haptics.soft()
        withAnimation(.easeOut(duration: 0.22)) {
            isAnswerRevealed = true
        }
    }

    private func selectFilter(_ filter: ReadingFilter) {
        guard selectedFilter != filter else { return }

        Haptics.selection()
        withAnimation(.easeOut(duration: 0.22)) {
            selectedFilter = filter
            currentIndex = 0
            isAnswerRevealed = false
        }
    }

    private func showFilterList() {
        Haptics.selection()
        isFilterListPresented = true
    }

    private func goNext() {
        Haptics.light()
        withAnimation(.easeInOut(duration: 0.24)) {
            if selectedFilter == .today {
                let dailyKey = currentItem.stableKey
                selectedFilter = .all
                let nextIndex = items.firstIndex { $0.stableKey == dailyKey }.map { ($0 + 1) % max(1, items.count) } ?? 0
                currentIndex = nextIndex
            } else {
                let itemCount = max(1, activeItems.count)

                if isReadingSavedOnly {
                    currentIndex = (currentIndex + 1) % itemCount
                } else if currentIndex == itemCount - 1 {
                    items = FragmentLibrary.makeDeck()
                    currentIndex = 0
                } else {
                    currentIndex += 1
                }
            }

            isAnswerRevealed = false
        }
    }

    private func toggleSaved() {
        Haptics.selection()
        var keys = savedKeys

        if keys.contains(currentItem.stableKey) {
            keys.remove(currentItem.stableKey)
        } else {
            keys.insert(currentItem.stableKey)
        }

        savedFragmentKeys = keys.sorted().joined(separator: "|")

        if isReadingSavedOnly {
            let nextCount = FragmentLibrary.optimizedItems.filter { keys.contains($0.stableKey) }.count
            if nextCount == 0 {
                isReadingSavedOnly = false
                currentIndex = 0
            } else if currentIndex >= nextCount {
                currentIndex = nextCount - 1
            }
        }
    }

    private func toggleSavedOnly() {
        guard !savedKeys.isEmpty else { return }

        Haptics.selection()
        withAnimation(.easeOut(duration: 0.18)) {
            isReadingSavedOnly.toggle()
            selectedFilter = .all
            currentIndex = 0
            isAnswerRevealed = false
        }
    }

    private func shareCurrentFragment() {
        Haptics.medium()

        let card = ShareFragmentCard(
            item: currentItem,
            includesAnswer: isAnswerRevealed
        )
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1

        guard let image = renderer.uiImage else {
            sharePayload = SharePayload(image: UIImage(), text: currentItem.shareText(includesAnswer: isAnswerRevealed))
            return
        }

        sharePayload = SharePayload(image: image, text: currentItem.shareText(includesAnswer: isAnswerRevealed))
    }
}

private struct HeaderView: View {
    let currentIndex: Int
    let totalCount: Int
    let savedCount: Int
    let isReadingSavedOnly: Bool
    let selectedFilter: ReadingFilter
    let toggleSavedOnly: () -> Void
    let showFilterList: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                AppMark(size: 28)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Fragment")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    Text("ONE-SHOT TRUTH")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.36))
                        .tracking(1.1)
                }
            }

            Spacer()

            Button(action: showFilterList) {
                Label(selectedFilter.title, systemImage: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.68))
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 9)
                    .background(.white.opacity(0.055), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("ジャンルを選ぶ")

            if savedCount > 0 {
                Button(action: toggleSavedOnly) {
                    Label("\(savedCount)", systemImage: isReadingSavedOnly ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(isReadingSavedOnly ? .black.opacity(0.82) : .white.opacity(0.64))
                        .labelStyle(.titleAndIcon)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 9)
                        .background(isReadingSavedOnly ? .white.opacity(0.82) : .white.opacity(0.05), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isReadingSavedOnly ? "すべての謎に戻る" : "お気に入りだけ読む")
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Text("\(currentIndex + 1) / \(totalCount)")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.58))
                .padding(.vertical, 7)
                .padding(.horizontal, 11)
                .background(.white.opacity(0.055), in: Capsule())
        }
    }
}

private struct ProgressTrace: View {
    let currentIndex: Int
    let totalCount: Int

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalCount)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.055))

                Capsule()
                    .fill(.white.opacity(0.34))
                    .frame(width: max(18, geometry.size.width * progress))
            }
        }
        .frame(height: 2)
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
    }
}

private struct ReadingFilterListView: View {
    let selectedFilter: ReadingFilter
    let counts: [ReadingFilter: Int]
    let selectionAction: (ReadingFilter) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.018, green: 0.019, blue: 0.023)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ジャンル")
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    Text("読みたい断片を選ぶ")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.42))
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(ReadingFilter.allCases) { filter in
                            filterRow(filter)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func filterRow(_ filter: ReadingFilter) -> some View {
        let count = counts[filter, default: 0]
        let isSelected = selectedFilter == filter

        return Button {
            selectionAction(filter)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: filter.systemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? .black.opacity(0.72) : .white.opacity(0.62))
                    .frame(width: 26, height: 26)
                    .background(isSelected ? .black.opacity(0.08) : .white.opacity(0.055), in: Circle())

                Text(filter.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? .black.opacity(0.86) : .white.opacity(0.82))

                Spacer()

                Text("\(count)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(isSelected ? .black.opacity(0.52) : .white.opacity(0.42))

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black.opacity(0.76))
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color.white.opacity(0.84) : Color.white.opacity(0.045),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(isSelected ? 0 : 0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(count == 0)
        .opacity(count == 0 ? 0.36 : 1)
    }
}

private struct ReadingFilterRail: View {
    let selectedFilter: ReadingFilter
    let counts: [ReadingFilter: Int]
    let selectionAction: (ReadingFilter) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(ReadingFilter.allCases) { filter in
                    Button {
                        selectionAction(filter)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.systemName)
                                .font(.system(size: 12, weight: .semibold))

                            Text(filter.title)
                                .font(.system(size: 12, weight: .semibold))

                            Text("\(counts[filter, default: 0])")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(isSelected(filter) ? .black.opacity(0.48) : .white.opacity(0.34))
                        }
                        .lineLimit(1)
                        .foregroundStyle(isSelected(filter) ? .black.opacity(0.84) : .white.opacity(0.58))
                        .padding(.vertical, 9)
                        .padding(.horizontal, 11)
                        .background(
                            isSelected(filter) ? Color.white.opacity(0.82) : Color.white.opacity(0.045),
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.white.opacity(isSelected(filter) ? 0 : 0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(counts[filter, default: 0] == 0)
                    .opacity(counts[filter, default: 0] == 0 ? 0.36 : 1)
                }
            }
            .padding(.horizontal, 22)
        }
        .scrollIndicators(.hidden)
    }

    private func isSelected(_ filter: ReadingFilter) -> Bool {
        selectedFilter == filter
    }
}

private struct HookLineView: View {
    let item: FragmentItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 1)
                .fill(.white.opacity(0.18))
                .frame(width: 2, height: 34)
                .padding(.top, 2)

            Text(item.hookLine)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.54))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
    }
}

private struct FragmentDeckView: View {
    let item: FragmentItem
    let cardHeight: CGFloat

    var body: some View {
        ZStack {
            DeckShadowCard(item: item, cardHeight: cardHeight, layer: 2)
                .offset(x: 25, y: 19)
                .rotationEffect(.degrees(3.2))

            DeckShadowCard(item: item, cardHeight: cardHeight, layer: 1)
                .offset(x: -20, y: 11)
                .rotationEffect(.degrees(-2.4))

            FragmentCardView(item: item, cardHeight: cardHeight)
        }
        .frame(maxWidth: 430)
        .frame(height: cardHeight + 28)
    }
}

private struct DeckShadowCard: View {
    let item: FragmentItem
    let cardHeight: CGFloat
    let layer: Int

    var body: some View {
        RoundedRectangle(cornerRadius: item.type == .notification ? 34 : 6, style: .continuous)
            .fill(fillStyle)
            .overlay(
                RoundedRectangle(cornerRadius: item.type == .notification ? 34 : 6, style: .continuous)
                    .stroke(.white.opacity(layer == 1 ? 0.07 : 0.045), lineWidth: 1)
            )
            .frame(
                width: item.type == .notification ? nil : 332,
                height: item.type == .notification ? cardHeight : min(cardHeight - 54, 450)
            )
            .frame(maxWidth: item.type == .notification ? .infinity : nil)
            .opacity(layer == 1 ? 0.42 : 0.24)
            .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
    }

    private var fillStyle: some ShapeStyle {
        switch item.type {
        case .notification:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.096, blue: 0.105),
                        Color(red: 0.025, green: 0.027, blue: 0.032)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .receipt:
            return AnyShapeStyle(Color(red: 0.88, green: 0.86, blue: 0.80))
        }
    }
}

private struct FragmentCardView: View {
    let item: FragmentItem
    let cardHeight: CGFloat

    var body: some View {
        Group {
            switch item.type {
            case .notification:
                NotificationFragmentView(item: item, cardHeight: cardHeight)
            case .receipt:
                ReceiptFragmentView(item: item)
            }
        }
        .frame(maxWidth: 430)
        .frame(maxHeight: cardHeight)
        .accessibilityElement(children: .contain)
    }
}

private struct NotificationFragmentView: View {
    let item: FragmentItem
    let cardHeight: CGFloat

    private var visibleNotifications: [NotificationLine] {
        cardHeight < 470 ? Array(item.notifications.prefix(3)) : item.notifications
    }

    private var hiddenNotificationCount: Int {
        max(0, item.notifications.count - visibleNotifications.count)
    }

    var body: some View {
        VStack(spacing: cardHeight < 450 ? 10 : 16) {
            if cardHeight >= 470 {
                LockStatusStrip()
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
            }

            VStack(spacing: 3) {
                Text(item.displayTime)
                    .font(.system(size: cardHeight < 450 ? 52 : 64, weight: .thin, design: .default))
                    .foregroundStyle(.white.opacity(0.96))
                    .monospacedDigit()

                Text(item.title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(.top, cardHeight < 470 ? 22 : 2)

            VStack(spacing: 10) {
                ForEach(visibleNotifications) { line in
                    NotificationCard(line: line)
                }

                if hiddenNotificationCount > 0 {
                    NotificationSummaryCard(count: hiddenNotificationCount)
                }
            }
            .padding(.horizontal, 13)

            Spacer(minLength: 18)

            if cardHeight >= 500 {
                HStack {
                    LockScreenShortcut(systemName: "flashlight.off.fill")
                    Spacer()
                    LockScreenShortcut(systemName: "camera.fill")
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.13, blue: 0.14),
                            Color(red: 0.04, green: 0.045, blue: 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        }
        .shadow(color: .black.opacity(0.42), radius: 24, x: 0, y: 14)
    }
}

private struct LockStatusStrip: View {
    var body: some View {
        HStack(spacing: 7) {
            Text("断片")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.46))

            Spacer()

            Image(systemName: "cellularbars")
            Image(systemName: "wifi")
            Image(systemName: "battery.25")
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white.opacity(0.42))
    }
}

private struct LockScreenShortcut: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white.opacity(0.56))
            .frame(width: 46, height: 46)
            .background(.black.opacity(0.24), in: Circle())
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct AppMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )

            Image(systemName: "eye")
                .font(.system(size: size * 0.48, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: size, height: size)
    }
}

private struct NotificationCard: View {
    let line: NotificationLine

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(line.appName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(line.timeText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.42))
                    .monospacedDigit()
            }

            Text(line.sender)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.94))
                .lineLimit(1)

            Text(line.message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.78))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct NotificationSummaryCard: View {
    let count: Int

    var body: some View {
        Text("ほか\(count)件の通知")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.42))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.06), lineWidth: 1)
            )
    }
}

private struct ReceiptFragmentView: View {
    let item: FragmentItem

    private var entries: [ReceiptEntry] {
        item.receiptEntries
    }

    private var subtotal: Int {
        entries.reduce(0) { $0 + $1.price }
    }

    private var tax: Int {
        Int((Double(subtotal) * 0.1).rounded())
    }

    private var total: Int {
        subtotal + tax
    }

    private var totalText: String {
        "\(total)円"
    }

    var body: some View {
        VStack(spacing: 0) {
            receiptHeader

            DashedDivider()
                .padding(.vertical, 12)

            VStack(alignment: .leading, spacing: 9) {
                ForEach(entries) { entry in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(String(format: "%02d", entry.index + 1))
                            .foregroundStyle(.black.opacity(0.36))
                            .frame(width: 24, alignment: .leading)

                        Text(entry.name)
                            .foregroundStyle(.black.opacity(0.82))
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        Text("\(entry.price)")
                            .foregroundStyle(.black.opacity(0.62))
                            .monospacedDigit()
                    }
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                }
            }

            DashedDivider()
                .padding(.top, 14)
                .padding(.bottom, 10)

            VStack(spacing: 6) {
                receiptAmountRow(label: "小計", value: "\(subtotal)円", emphasis: false)
                receiptAmountRow(label: "消費税", value: "\(tax)円", emphasis: false)
            }
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .foregroundStyle(.black.opacity(0.46))
            .padding(.bottom, 10)

            HStack(alignment: .firstTextBaseline) {
                Text("合計")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))

                Spacer()

                Text(totalText)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .monospacedDigit()
            }
            .foregroundStyle(.black.opacity(0.86))

            Text("ありがとうございました")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.black.opacity(0.42))
                .padding(.top, 22)
        }
        .padding(.top, 24)
        .padding(.horizontal, 22)
        .padding(.bottom, 26)
        .frame(maxWidth: 350)
        .background {
            ReceiptPaperShape()
                .fill(Color(red: 0.95, green: 0.94, blue: 0.89))
                .overlay(
                    ReceiptPaperShape()
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                )
        }
        .shadow(color: .black.opacity(0.48), radius: 22, x: 0, y: 14)
        .rotationEffect(.degrees(-0.7))
        .padding(.vertical, 8)
    }

    private var receiptHeader: some View {
        VStack(spacing: 6) {
            Text(item.title)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.88))
                .lineLimit(1)

            Text(item.displayTime)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.black.opacity(0.56))
                .monospacedDigit()

            Text("No. \(String(item.id.uuidString.prefix(8)).uppercased())")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(.black.opacity(0.36))
        }
        .frame(maxWidth: .infinity)
    }

    private func receiptAmountRow(label: String, value: String, emphasis: Bool) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(emphasis ? .semibold : .regular)
                .monospacedDigit()
        }
    }
}

private struct BottomPanelView: View {
    let item: FragmentItem
    let isAnswerRevealed: Bool
    let isSaved: Bool
    let revealAction: () -> Void
    let nextAction: () -> Void
    let saveAction: () -> Void
    let shareAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(typeText)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.42))
                    .tracking(1.2)

                Rectangle()
                    .fill(.white.opacity(0.12))
                    .frame(height: 1)
            }

            ContextTraceView(item: item)

            if !isAnswerRevealed {
                MysteryBriefView(item: item)
                    .transition(.opacity)
            }

            if isAnswerRevealed {
                RevealedReadingView(item: item)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Group {
                if !isAnswerRevealed {
                    VStack(spacing: 10) {
                        Button(action: revealAction) {
                            Label("真相を見る", systemImage: "eye")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FragmentButtonStyle(kind: .primary))
                        .transition(.opacity)

                        HStack(spacing: 10) {
                            Button(action: shareAction) {
                                Label("共有する", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FragmentButtonStyle(kind: .secondary))

                            Button(action: nextAction) {
                                Label("次の問題へ", systemImage: "arrow.right")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FragmentButtonStyle(kind: .secondary))
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Button(action: nextAction) {
                            Label("次の問題へ", systemImage: "arrow.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FragmentButtonStyle(kind: .primary))

                        HStack(spacing: 10) {
                            Button(action: shareAction) {
                                Label("共有する", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FragmentButtonStyle(kind: .secondary))
                            .transition(.opacity)

                            Button(action: saveAction) {
                                Label(isSaved ? "お気に入り済み" : "お気に入り", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FragmentButtonStyle(kind: .secondary))
                            .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.easeOut(duration: 0.2), value: isAnswerRevealed)
        }
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
    }

private var typeText: String { item.typeLabel }
}

private struct MysteryBriefView: View {
    let item: FragmentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("状況")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.36))
                    .tracking(0.8)

                Text(item.caseName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Text("質問はできない。少ない情報から真相を見抜け。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.50))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}

private struct RevealedReadingView: View {
    let item: FragmentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("真相")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.54))

                Text(item.truthHeadline)
                    .font(.system(size: 18, weight: .semibold))
                    .lineSpacing(5)
                    .foregroundStyle(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("決め手")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.46))

                Text(item.revealShock)
                    .font(.system(size: 16, weight: .medium))
                    .lineSpacing(5)
                    .foregroundStyle(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("見えていた手がかり")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.42))

                ForEach(item.evidenceLines, id: \.self) { evidence in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle()
                            .fill(.white.opacity(0.32))
                            .frame(width: 4, height: 4)

                        Text(evidence)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(2)
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("補足")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.46))

                Text(item.answer)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(5)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.leading, 12)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(.white.opacity(0.18))
                .frame(width: 2)
        }
    }
}

private struct ContextTraceView: View {
    let item: FragmentItem

    var body: some View {
        HStack(spacing: 8) {
            tracePill(item.displayTime, systemName: "clock")
            tracePill(item.moodLabel, systemName: "waveform.path")
            tracePill(item.densityText, systemName: item.type == .notification ? "bell.badge" : "list.bullet.rectangle")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tracePill(_ text: String, systemName: String) -> some View {
        Label(text, systemImage: systemName)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.52))
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.vertical, 7)
            .padding(.horizontal, 9)
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.white.opacity(0.07), lineWidth: 1)
            )
    }
}

private struct ShareFragmentCard: View {
    let item: FragmentItem
    let includesAnswer: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.015, green: 0.016, blue: 0.018),
                    Color(red: 0.05, green: 0.052, blue: 0.058),
                    Color(red: 0.012, green: 0.013, blue: 0.016)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 42) {
                HStack(spacing: 22) {
                    AppMark(size: 58)

                    Text("Fragment")
                        .font(.system(size: 54, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    Spacer()

                    Text(item.typeLabel)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.52))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(.white.opacity(0.06), in: Capsule())
                }

                Text("状況: \(item.caseName)")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.96))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(item.title) / \(item.displayTime)")
                    .font(.system(size: 30, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.52))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 18) {
                    shareTracePill(item.displayTime)
                    shareTracePill(item.moodLabel)
                    shareTracePill(item.densityText)
                }

                Group {
                    switch item.type {
                    case .notification:
                        ShareNotificationSnapshot(item: item)
                    case .receipt:
                        ShareReceiptSnapshot(item: item)
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(includesAnswer ? "見えていた手がかり" : "見えている手がかり")
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.42))

                        ForEach(item.evidenceLines.prefix(2), id: \.self) { evidence in
                            Text("- \(evidence)")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundStyle(.white.opacity(0.58))
                                .lineLimit(2)
                        }
                    }

                    if includesAnswer {
                        Text("真相")
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.50))

                        Text(item.truthHeadline)
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.90))
                            .lineSpacing(9)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("決め手")
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.46))

                        Text(item.revealShock)
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(.white.opacity(0.84))
                            .lineSpacing(9)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("補足")
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.46))

                        Text(item.answer)
                            .font(.system(size: 30, weight: .regular))
                            .foregroundStyle(.white.opacity(0.66))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("質問はできない。少ない情報から真相を見抜け。")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.leading, 28)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.18))
                        .frame(width: 4)
                }

                Spacer()

                Text(includesAnswer ? "質問なしのウミガメのスープ。" : "真相はアプリで。")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(.horizontal, 82)
            .padding(.top, 94)
            .padding(.bottom, 78)
        }
    }

    private func shareTracePill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.58))
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ShareNotificationSnapshot: View {
    let item: FragmentItem

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(item.displayTime)
                    .font(.system(size: 112, weight: .thin))
                    .foregroundStyle(.white.opacity(0.96))
                    .monospacedDigit()

                Text(item.title)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(.white.opacity(0.42))
            }

            VStack(spacing: 18) {
                ForEach(item.notifications.prefix(4)) { line in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(line.appName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.56))

                            Spacer()

                            Text(line.timeText)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white.opacity(0.38))
                        }

                        Text(line.sender)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.94))
                            .lineLimit(1)

                        Text(line.message)
                            .font(.system(size: 26, weight: .regular))
                            .foregroundStyle(.white.opacity(0.74))
                            .lineLimit(2)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 26)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 2)
                    )
                }
            }
        }
        .padding(34)
        .background(
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.13, blue: 0.14),
                            Color(red: 0.035, green: 0.038, blue: 0.044)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 2)
        )
    }
}

private struct ShareReceiptSnapshot: View {
    let item: FragmentItem

    private var entries: [ReceiptEntry] { item.receiptEntries }
    private var subtotal: Int { entries.reduce(0) { $0 + $1.price } }
    private var tax: Int { Int((Double(subtotal) * 0.1).rounded()) }
    private var total: Int { subtotal + tax }

    var body: some View {
        VStack(spacing: 0) {
            Text(item.title)
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.88))

            Text(item.displayTime)
                .font(.system(size: 28, weight: .regular, design: .monospaced))
                .foregroundStyle(.black.opacity(0.54))
                .monospacedDigit()
                .padding(.top, 10)

            DashedDivider()
                .padding(.vertical, 32)

            VStack(spacing: 18) {
                ForEach(entries) { entry in
                    HStack(spacing: 18) {
                        Text(String(format: "%02d", entry.index + 1))
                            .foregroundStyle(.black.opacity(0.34))
                            .frame(width: 52, alignment: .leading)

                        Text(entry.name)
                            .foregroundStyle(.black.opacity(0.82))
                            .lineLimit(1)

                        Spacer()

                        Text("\(entry.price)")
                            .foregroundStyle(.black.opacity(0.62))
                            .monospacedDigit()
                    }
                }
            }
            .font(.system(size: 30, weight: .regular, design: .monospaced))

            DashedDivider()
                .padding(.vertical, 32)

            VStack(spacing: 14) {
                receiptRow(label: "小計", value: "\(subtotal)円", size: 24, weight: .regular)
                receiptRow(label: "消費税", value: "\(tax)円", size: 24, weight: .regular)
                receiptRow(label: "合計", value: "\(total)円", size: 38, weight: .bold)
                    .padding(.top, 6)
            }
        }
        .padding(.top, 58)
        .padding(.horizontal, 54)
        .padding(.bottom, 62)
        .frame(maxWidth: 780)
        .background {
            ReceiptPaperShape()
                .fill(Color(red: 0.95, green: 0.94, blue: 0.89))
        }
        .rotationEffect(.degrees(-0.6))
    }

    private func receiptRow(label: String, value: String, size: CGFloat, weight: Font.Weight) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
        .font(.system(size: size, weight: weight, design: .monospaced))
        .foregroundStyle(.black.opacity(0.86))
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.015, green: 0.016, blue: 0.018),
                Color(red: 0.055, green: 0.058, blue: 0.062),
                Color(red: 0.025, green: 0.027, blue: 0.03)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay {
            VStack {
                Rectangle()
                    .fill(.white.opacity(0.035))
                    .frame(height: 1)
                    .padding(.top, 96)

                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

private struct DashedDivider: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: 1)
            .overlay {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0.5))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 0.5))
                    }
                    .stroke(
                        .black.opacity(0.26),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                }
            }
    }
}

private struct ReceiptPaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchWidth: CGFloat = 11
        let notchHeight: CGFloat = 6
        let notchCount = max(8, Int(rect.width / notchWidth))
        let step = rect.width / CGFloat(notchCount)

        path.move(to: CGPoint(x: 0, y: 0))

        for index in 0..<notchCount {
            let startX = CGFloat(index) * step
            path.addLine(to: CGPoint(x: startX + step * 0.5, y: notchHeight))
            path.addLine(to: CGPoint(x: startX + step, y: 0))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height - notchHeight))

        for index in stride(from: notchCount, through: 0, by: -1) {
            let x = CGFloat(index) * step
            path.addLine(to: CGPoint(x: max(0, x - step * 0.5), y: rect.height))
            path.addLine(to: CGPoint(x: max(0, x - step), y: rect.height - notchHeight))
        }

        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

private struct FragmentButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case secondary
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(kind == .primary ? .black.opacity(0.88) : .white.opacity(0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.vertical, 14)
            .labelStyle(.titleAndIcon)
            .background(background(for: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(kind == .primary ? 0 : 0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func background(for isPressed: Bool) -> Color {
        switch kind {
        case .primary:
            return Color.white.opacity(isPressed ? 0.72 : 0.86)
        case .secondary:
            return Color.white.opacity(isPressed ? 0.10 : 0.055)
        }
    }
}

private enum Haptics {
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.7)
    }

    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.55)
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 0.62)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

private enum FragmentLibrary {
    static let optimizedItems: [FragmentItem] = {
        let notifications = items.filter { $0.type == .notification }
        let receipts = items.filter { $0.type == .receipt }
        let count = max(notifications.count, receipts.count)

        return (0..<count).flatMap { index -> [FragmentItem] in
            var result: [FragmentItem] = []
            if index < notifications.count {
                result.append(notifications[index])
            }
            if index < receipts.count {
                result.append(receipts[index])
            }
            return result
        }
    }()

    static var dailyItem: FragmentItem {
        let openingItems = openingTitles.compactMap { title in
            items.first { $0.title == title }
        }
        let pool = openingItems.isEmpty ? optimizedItems : openingItems
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return pool[day % max(1, pool.count)]
    }

    private static let openingTitles = [
        "AIRPORT MINI",
        "MACHI DELI",
        "Loan App",
        "Blocked",
        "Funeral Hall",
        "Hotel Lobby",
        "Locked iPhone",
        "Birthday",
        "NIGHT MINI",
        "HOTEL SHOP",
        "Read Receipt",
        "Delivery Failed",
        "Draft Saved",
        "Shared Calendar",
        "MIDNIGHT DIY"
    ]

    static func makeDeck() -> [FragmentItem] {
        let notifications = items.filter { $0.type == .notification }.shuffled()
        let receipts = items.filter { $0.type == .receipt }.shuffled()
        let count = max(notifications.count, receipts.count)
        let startsWithNotification = Bool.random()

        let shuffledDeck = (0..<count).flatMap { index -> [FragmentItem] in
            let first = startsWithNotification ? notifications[safe: index] : receipts[safe: index]
            let second = startsWithNotification ? receipts[safe: index] : notifications[safe: index]
            return [first, second].compactMap { $0 }
        }

        let opening = openingTitles.compactMap { title in
            items.first { $0.title == title }
        }
        let openingKeys = Set(opening.map(\.stableKey))
        return opening + shuffledDeck.filter { !openingKeys.contains($0.stableKey) }
    }

    static let items: [FragmentItem] = [
        FragmentItem(
            type: .notification,
            title: "Locked iPhone",
            answer: "終電後、誰にも連絡を返せないまま帰宅した夜。お金も人間関係も、少しずつ未処理のまま積もっている。",
            displayTime: "02:14",
            notifications: [
                NotificationLine(appName: "Uber Eats", sender: "配達完了", message: "ご注文が配達されました", timeText: "1分前"),
                NotificationLine(appName: "電話", sender: "母", message: "電話出て", timeText: "8分前"),
                NotificationLine(appName: "楽天カード", sender: "お支払いに関するご案内", message: "ご登録口座からのお引き落としについて", timeText: "22分前"),
                NotificationLine(appName: "LINE", sender: "未読メッセージ", message: "17件のメッセージがあります", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Do Not Disturb",
            answer: "謝るタイミングを逃したまま深夜になった。相手も自分も起きていて、でも誰も最後の一通を送れない。",
            displayTime: "01:47",
            notifications: [
                NotificationLine(appName: "LINE", sender: "美咲", message: "さっきの、そういう意味じゃないから", timeText: "34分前"),
                NotificationLine(appName: "LINE", sender: "美咲", message: "既読だけつけるのやめて", timeText: "21分前"),
                NotificationLine(appName: "カレンダー", sender: "明日の予定", message: "9:30 週次定例", timeText: "10分前"),
                NotificationLine(appName: "ヘルスケア", sender: "睡眠", message: "就寝時刻を過ぎています", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Low Battery",
            answer: "帰る場所はあるのに、帰った後の会話が重い。バッテリー残量より先に、話す気力が切れている。",
            displayTime: "23:58",
            notifications: [
                NotificationLine(appName: "メッセージ", sender: "父", message: "今日は帰ってくるのか", timeText: "2時間前"),
                NotificationLine(appName: "乗換案内", sender: "終電接近", message: "自宅方面の最終電車まであと9分", timeText: "12分前"),
                NotificationLine(appName: "電話", sender: "不在着信", message: "自宅 3件", timeText: "7分前"),
                NotificationLine(appName: "バッテリー", sender: "残り10%", message: "低電力モードをオンにしますか？", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Morning Alarm",
            answer: "寝たというより気絶に近い。仕事には行くつもりだけど、何かを持ち直す余白はほとんど残っていない。",
            displayTime: "06:31",
            notifications: [
                NotificationLine(appName: "アラーム", sender: "平日", message: "6:30", timeText: "今"),
                NotificationLine(appName: "Slack", sender: "佐伯", message: "昨日の件、朝イチで少し話せますか", timeText: "5:42"),
                NotificationLine(appName: "メール", sender: "人事部", message: "面談日程のご確認", timeText: "1:18"),
                NotificationLine(appName: "LINE", sender: "妹", message: "お母さんにはまだ言ってない", timeText: "0:43")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Unread",
            answer: "大事な連絡ほど開けない夜がある。読んだら返事をしなければならないし、返事をしたら現実が進んでしまう。",
            displayTime: "00:26",
            notifications: [
                NotificationLine(appName: "LINE", sender: "母", message: "検査結果、明日わかるって", timeText: "3時間前"),
                NotificationLine(appName: "LINE", sender: "兄", message: "お前からも一回連絡して", timeText: "2時間前"),
                NotificationLine(appName: "銀行", sender: "入出金通知", message: "残高が指定金額を下回りました", timeText: "41分前"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "3年前の今日", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Station Wi-Fi",
            answer: "駅のベンチか、改札の外。帰れないほど遠いわけではないのに、帰る決断だけが遅れている。",
            displayTime: "00:09",
            notifications: [
                NotificationLine(appName: "乗換案内", sender: "遅延情報", message: "山手線 内回りに遅れが出ています", timeText: "18分前"),
                NotificationLine(appName: "LINE", sender: "店長", message: "明日、少し早く来れる？", timeText: "11分前"),
                NotificationLine(appName: "電話", sender: "不在着信", message: "非通知設定", timeText: "6分前"),
                NotificationLine(appName: "PayPay", sender: "決済完了", message: "320円を支払いました", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .receipt,
            title: "NIGHT MINI",
            answer: "飲み会帰りなのか、仕事帰りなのか。少なくともこの人は、明日をあまり大事にできていない。",
            displayTime: "02:13",
            notifications: [],
            receiptLines: [
                "氷",
                "ストロング缶 500ml",
                "胃薬",
                "モンスター",
                "からあげ棒"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "SUN ROAD MART",
            answer: "自分の分だけなら買わないものが混ざっている。家に誰かがいる、あるいは誰かがいた頃の癖が残っている。",
            displayTime: "21:42",
            notifications: [],
            receiptLines: [
                "牛乳",
                "小さなプリン 2個",
                "冷凍うどん",
                "子ども用歯ブラシ",
                "缶ビール"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "EKIMAE STORE",
            answer: "帰宅前の最低限を買ったようで、どこか時間稼ぎにも見える。温かいものを選べないくらい疲れている。",
            displayTime: "00:31",
            notifications: [],
            receiptLines: [
                "ビニール傘",
                "のど飴",
                "カップ味噌汁",
                "替えの靴下",
                "単三電池"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "FAMILY GROCER",
            answer: "家族の予定に合わせているようで、自分のものがほとんどない。休む日ではなく、整える日になりそうな週末。",
            displayTime: "18:06",
            notifications: [],
            receiptLines: [
                "卵 10個",
                "食パン 6枚",
                "洗濯洗剤",
                "絆創膏",
                "安い赤ワイン"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "24H PHARMACY",
            answer: "誰かを待っている買い物にも、自分を雑に保つ買い物にも見える。眠れない理由だけは、レシートに直接書かれていない。",
            displayTime: "03:22",
            notifications: [],
            receiptLines: [
                "解熱鎮痛薬",
                "冷却シート",
                "ゼリー飲料",
                "水 2L",
                "使い捨てマスク"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "CITY VALUE",
            answer: "引っ越し、別れ話、退職届。どれでも成立してしまう買い方。生活を一度リセットした人の軽さと雑さがある。",
            displayTime: "20:58",
            notifications: [],
            receiptLines: [
                "紙皿",
                "透明ごみ袋",
                "ガムテープ",
                "カップ麺",
                "発泡酒 6缶"
            ]
        ),
        FragmentItem(
            type: .notification,
            title: "Silent Mode",
            answer: "待っているのは返信なのか、謝罪なのか、帰宅連絡なのか。通知が鳴らない時間だけが、状況を重くしている。",
            displayTime: "02:03",
            notifications: [
                NotificationLine(appName: "LINE", sender: "航", message: "今どこ", timeText: "1時間前"),
                NotificationLine(appName: "LINE", sender: "航", message: "もういい", timeText: "46分前"),
                NotificationLine(appName: "電話", sender: "不在着信", message: "航 5件", timeText: "31分前"),
                NotificationLine(appName: "メモ", sender: "固定メモ", message: "鍵はポストの中", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Office Floor",
            answer: "仕事が終わらないというより、終わった後に戻る生活のほうが怖い。明るいオフィスが避難場所になっている。",
            displayTime: "23:41",
            notifications: [
                NotificationLine(appName: "Slack", sender: "経理", message: "申請、今日中にお願いします", timeText: "2時間前"),
                NotificationLine(appName: "カレンダー", sender: "明日", message: "8:45 役員レビュー", timeText: "54分前"),
                NotificationLine(appName: "LINE", sender: "妻", message: "先に寝ます", timeText: "28分前"),
                NotificationLine(appName: "タクシー", sender: "クーポン", message: "深夜料金でも使えます", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Shared Album",
            answer: "祝い事の輪に入っているのに、自分だけ別のニュースを抱えている。幸せな通知ほど、今夜は開きづらい。",
            displayTime: "22:17",
            notifications: [
                NotificationLine(appName: "写真", sender: "共有アルバム", message: "新しい写真が28枚追加されました", timeText: "12分前"),
                NotificationLine(appName: "LINE", sender: "高校グループ", message: "次はいつ集まる？", timeText: "9分前"),
                NotificationLine(appName: "メール", sender: "クリニック", message: "検査予約変更のお知らせ", timeText: "6分前"),
                NotificationLine(appName: "リマインダー", sender: "明日", message: "保険証", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Last Train",
            answer: "予定も返事も、少しずつ間に合わなくなっている。まだ取り返せる距離なのに、動き出す力が足りない。",
            displayTime: "00:18",
            notifications: [
                NotificationLine(appName: "乗換案内", sender: "最終案内", message: "次の電車が本日最終です", timeText: "13分前"),
                NotificationLine(appName: "LINE", sender: "内定者グループ", message: "明日の集合、8:50で大丈夫です", timeText: "9分前"),
                NotificationLine(appName: "メール", sender: "不動産管理会社", message: "更新料のお支払いについて", timeText: "5分前"),
                NotificationLine(appName: "天気", sender: "現在地", message: "まもなく雨が降ります", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Unknown Number",
            answer: "知らない番号に出る余裕がない夜。大事な連絡かもしれないとわかっていても、これ以上何かが始まるのを避けている。",
            displayTime: "19:53",
            notifications: [
                NotificationLine(appName: "電話", sender: "不在着信", message: "03-6848-****", timeText: "32分前"),
                NotificationLine(appName: "留守番電話", sender: "新規メッセージ", message: "1件の留守番電話があります", timeText: "29分前"),
                NotificationLine(appName: "メール", sender: "採用担当", message: "選考結果のご連絡", timeText: "18分前"),
                NotificationLine(appName: "LINE", sender: "母", message: "今日だけでも帰れない？", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Read Receipt",
            answer: "読んだ瞬間に、知らなかったことにはできなくなった。返事をしてもしなくても、関係はもう少し変わってしまっている。",
            displayTime: "01:12",
            notifications: [
                NotificationLine(appName: "LINE", sender: "玲奈", message: "昨日、一緒にいた人だれ？", timeText: "44分前"),
                NotificationLine(appName: "Instagram", sender: "タグ付け", message: "あなたが写真にタグ付けされました", timeText: "39分前"),
                NotificationLine(appName: "LINE", sender: "玲奈", message: "既読ついてるよ", timeText: "18分前"),
                NotificationLine(appName: "写真", sender: "共有提案", message: "この写真を共有しますか？", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Bank Notice",
            answer: "払うべきものと向き合う順番を、毎日少しずつ後ろにずらしている。生活は続いているが、余白はかなり薄い。",
            displayTime: "08:04",
            notifications: [
                NotificationLine(appName: "銀行", sender: "口座振替", message: "引き落としができませんでした", timeText: "7:12"),
                NotificationLine(appName: "カード", sender: "ご利用可能額", message: "限度額に近づいています", timeText: "7:35"),
                NotificationLine(appName: "LINE", sender: "店長", message: "シフト代われる人いない？", timeText: "7:58"),
                NotificationLine(appName: "カレンダー", sender: "今日", message: "10:00 面接", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Hospital Wi-Fi",
            answer: "自分のことではないようで、自分の生活も止まっている。誰かを待つ時間が、仕事の通知を妙に遠く見せている。",
            displayTime: "15:36",
            notifications: [
                NotificationLine(appName: "病院", sender: "受付番号", message: "まもなくお呼びします", timeText: "14分前"),
                NotificationLine(appName: "Slack", sender: "チーム", message: "今日のMTG、参加できそうですか？", timeText: "11分前"),
                NotificationLine(appName: "LINE", sender: "父", message: "大丈夫だから仕事戻れ", timeText: "8分前"),
                NotificationLine(appName: "天気", sender: "警報", message: "強い雨に注意してください", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Birthday",
            answer: "祝われているのに、心がそこへ追いついていない。年齢だけが進んで、整理できていないものが残っている。",
            displayTime: "00:02",
            notifications: [
                NotificationLine(appName: "LINE", sender: "友だち", message: "誕生日おめでとう！", timeText: "今"),
                NotificationLine(appName: "LINE", sender: "母", message: "生まれてきてくれてありがとう", timeText: "今"),
                NotificationLine(appName: "カレンダー", sender: "今日", message: "誕生日", timeText: "今"),
                NotificationLine(appName: "メール", sender: "消費者金融", message: "ご返済予定日のご案内", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Delivery Failed",
            answer: "荷物だけなら再配達できる。けれど、同じ日に届くはずだった気持ちや連絡は、再配達の時間指定ができない。",
            displayTime: "21:05",
            notifications: [
                NotificationLine(appName: "配送", sender: "不在通知", message: "お荷物を持ち戻りました", timeText: "2時間前"),
                NotificationLine(appName: "LINE", sender: "蒼太", message: "玄関の前まで行った", timeText: "1時間前"),
                NotificationLine(appName: "LINE", sender: "蒼太", message: "もう置いて帰る", timeText: "54分前"),
                NotificationLine(appName: "メモ", sender: "買うもの", message: "ゴミ袋、電球、謝る", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Parent Chat",
            answer: "ちゃんとしている人のふりを、家庭でも職場でも続けている。誰にも責められていないのに、全部に遅れている感覚がある。",
            displayTime: "07:48",
            notifications: [
                NotificationLine(appName: "保育園", sender: "連絡帳", message: "本日の持ち物をご確認ください", timeText: "7:02"),
                NotificationLine(appName: "Slack", sender: "上司", message: "資料、9時までに見られますか", timeText: "7:15"),
                NotificationLine(appName: "LINE", sender: "夫", message: "ごめん今日も迎え無理", timeText: "7:31"),
                NotificationLine(appName: "リマインダー", sender: "今日", message: "上履き", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Two Homes",
            answer: "住所は一つでも、戻る場所が一つとは限らない。どちらに帰っても、説明しなければならないことがある。",
            displayTime: "22:44",
            notifications: [
                NotificationLine(appName: "LINE", sender: "母", message: "今夜こっち来る？", timeText: "1時間前"),
                NotificationLine(appName: "LINE", sender: "亮", message: "荷物、まだ置いたままだよ", timeText: "37分前"),
                NotificationLine(appName: "乗換案内", sender: "候補", message: "実家方面 23:02発", timeText: "18分前"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "去年の引っ越し", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .receipt,
            title: "BLUE KIOSK",
            answer: "家でちゃんと食べることか、誰かと食べることか。駅の売店で済ませた夕食には、急いでいる以上の感じがある。",
            displayTime: "23:06",
            notifications: [],
            receiptLines: [
                "おにぎり 鮭",
                "栄養ドリンク",
                "ミントタブレット",
                "携帯充電ケーブル",
                "ブラックコーヒー"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "MACHI DELI",
            answer: "二人分に見えるのに、温度差がある。待っているのか、待たせているのか、もう帰ってこない人の分なのか。",
            displayTime: "20:19",
            notifications: [],
            receiptLines: [
                "幕の内弁当",
                "小さなサラダ",
                "カップ味噌汁",
                "プリン",
                "割り箸 2膳"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "GREEN DRUG",
            answer: "誰かに心配されたくない買い物。大丈夫と言う準備だけが整っていて、本当に大丈夫かは別の話。",
            displayTime: "22:33",
            notifications: [],
            receiptLines: [
                "胃腸薬",
                "目薬",
                "湿布",
                "ビタミン剤",
                "チョコレート"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "RAINY MART",
            answer: "雨を理由に遅れているのか、雨を口実に行かないつもりなのか。傘と甘いものだけが妙に正直に見える。",
            displayTime: "18:52",
            notifications: [],
            receiptLines: [
                "透明傘",
                "ホットカフェラテ",
                "ミルクキャンディ",
                "ハンドタオル",
                "小さな花束"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "PORT STORE",
            answer: "旅の準備にも、勢いだけの移動にも見える。行き先より、ここに残りたくなかった理由のほうが濃い。",
            displayTime: "05:18",
            notifications: [],
            receiptLines: [
                "歯ブラシ",
                "替えの下着",
                "モバイルバッテリー",
                "酔い止め",
                "水 500ml"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "LOCAL BAKERY",
            answer: "謝罪に持っていくには軽く、手土産には少し急ごしらえ。会う理由より、会わないといけない理由がありそうだ。",
            displayTime: "10:07",
            notifications: [],
            receiptLines: [
                "食パン",
                "あんぱん",
                "カレーパン",
                "紙袋",
                "保冷剤"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "NORTH 24",
            answer: "眠るための買い物に見えて、眠らないためのものも混ざっている。体と頭が別々の方向を向いている。",
            displayTime: "01:58",
            notifications: [],
            receiptLines: [
                "ホットアイマスク",
                "カフェイン錠",
                "ミネラルウォーター",
                "カップスープ",
                "コピー用紙"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "VALUE PLUS",
            answer: "節約の買い物なのに、最後に少しだけ逃げ道がある。ちゃんとしようとしている人ほど、ひとつだけ甘いものを入れる。",
            displayTime: "19:14",
            notifications: [],
            receiptLines: [
                "もやし",
                "納豆 3個",
                "卵",
                "袋ラーメン",
                "シュークリーム"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "STATION PHARM",
            answer: "体調が悪いまま、人前に出る予定がある。自分を休ませる選択肢が、最初から棚に並んでいない。",
            displayTime: "07:21",
            notifications: [],
            receiptLines: [
                "風邪薬",
                "のどスプレー",
                "マスク",
                "栄養ドリンク",
                "口臭ケア"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "MOON MARKET",
            answer: "整えるための買い物にも、痕跡を消すための買い物にも見える。部屋だけでなく、気持ちも急いで片付けている。",
            displayTime: "23:27",
            notifications: [],
            receiptLines: [
                "消臭スプレー",
                "紙コップ",
                "歯磨きシート",
                "缶チューハイ",
                "アイス 2個"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "EAST SIDE CVS",
            answer: "帰宅ではなく復帰に近い。家に戻っても、まだ終わっていない画面が待っている。",
            displayTime: "02:46",
            notifications: [],
            receiptLines: [
                "コピー 18枚",
                "赤ペン",
                "眠気覚ましガム",
                "お茶 1L",
                "チョコバー"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "SMALL LIFE",
            answer: "最低限だけを買い直している。始まりにも見えるし、何かが終わった後の仮住まいにも見える。",
            displayTime: "16:39",
            notifications: [],
            receiptLines: [
                "タオル",
                "歯磨き粉",
                "紙皿",
                "洗濯ネット",
                "ミネラルウォーター"
            ]
        ),
        FragmentItem(
            type: .notification,
            title: "Exam Eve",
            answer: "明日の試験より、家の空気のほうが気になっている。机に向かっていても、頭の半分は別の部屋にある。",
            displayTime: "01:06",
            notifications: [
                NotificationLine(appName: "スタディ", sender: "模試結果", message: "志望校判定が更新されました", timeText: "2時間前"),
                NotificationLine(appName: "LINE", sender: "母", message: "お父さんにはまだ言わないで", timeText: "48分前"),
                NotificationLine(appName: "LINE", sender: "塾", message: "明日は受験票を忘れずに", timeText: "22分前"),
                NotificationLine(appName: "アラーム", sender: "明日", message: "5:40", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Care Home",
            answer: "自分の予定が、誰かの体調でいつも書き換わる。疲れているのに、頼られることを手放せない。",
            displayTime: "14:18",
            notifications: [
                NotificationLine(appName: "介護メモ", sender: "服薬", message: "昼の薬が未記録です", timeText: "36分前"),
                NotificationLine(appName: "LINE", sender: "姉", message: "今週末は行けない、ごめん", timeText: "21分前"),
                NotificationLine(appName: "電話", sender: "ケアマネージャー", message: "不在着信", timeText: "13分前"),
                NotificationLine(appName: "カレンダー", sender: "明日", message: "通院付き添い 9:00", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Wedding Group",
            answer: "おめでとうと言える相手ほど、自分の現在地を思い知らされる。悪意ではなく、置いていかれる感じがある。",
            displayTime: "22:52",
            notifications: [
                NotificationLine(appName: "LINE", sender: "結婚式グループ", message: "余興の動画、今日中にください！", timeText: "1時間前"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "5年前の旅行", timeText: "42分前"),
                NotificationLine(appName: "LINE", sender: "元彼", message: "招待状届いた？", timeText: "18分前"),
                NotificationLine(appName: "銀行", sender: "入出金通知", message: "残高が指定額を下回りました", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Funeral Hall",
            answer: "事務的な連絡だけが進んで、気持ちはどこにも追いついていない。悲しむ前に、決めることが多すぎる。",
            displayTime: "06:12",
            notifications: [
                NotificationLine(appName: "電話", sender: "葬儀社", message: "不在着信", timeText: "5:48"),
                NotificationLine(appName: "LINE", sender: "叔父", message: "香典の件、あとで話そう", timeText: "5:55"),
                NotificationLine(appName: "メール", sender: "会社", message: "忌引き申請について", timeText: "6:01"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "2年前の今日", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "New Hire",
            answer: "大人として扱われることに、まだ体が追いついていない。予定だけが社会人で、中身はずっと緊張している。",
            displayTime: "07:06",
            notifications: [
                NotificationLine(appName: "Slack", sender: "人事", message: "本日の研修資料を確認してください", timeText: "6:12"),
                NotificationLine(appName: "LINE", sender: "母", message: "初任給出たらご飯行こうね", timeText: "6:38"),
                NotificationLine(appName: "乗換案内", sender: "遅延", message: "東西線に遅れが出ています", timeText: "6:51"),
                NotificationLine(appName: "リマインダー", sender: "今日", message: "名刺入れ", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Job Search",
            answer: "毎日出勤しているふりをしながら、別の未来を探している。まだ辞めていないのに、心だけ先に退職している。",
            displayTime: "11:27",
            notifications: [
                NotificationLine(appName: "転職", sender: "スカウト", message: "新しいオファーが届きました", timeText: "1時間前"),
                NotificationLine(appName: "Slack", sender: "上司", message: "今日の進捗どうですか", timeText: "36分前"),
                NotificationLine(appName: "メール", sender: "面接日程", message: "一次面接のご案内", timeText: "19分前"),
                NotificationLine(appName: "LINE", sender: "妻", message: "今月も残業多い？", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Fan Club",
            answer: "現実の通知は重いのに、ひとつだけ逃げ場のような通知がある。救いは大げさなものではなく、数分の配信かもしれない。",
            displayTime: "20:44",
            notifications: [
                NotificationLine(appName: "ファンクラブ", sender: "生配信開始", message: "まもなく限定配信が始まります", timeText: "今"),
                NotificationLine(appName: "LINE", sender: "店長", message: "明日、早番入れる？", timeText: "17分前"),
                NotificationLine(appName: "カード", sender: "ご利用速報", message: "12,800円", timeText: "24分前"),
                NotificationLine(appName: "カレンダー", sender: "明日", message: "棚卸し", timeText: "1時間前")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Class Reunion",
            answer: "昔の自分を知っている人に、今の自分を説明するのが怖い。懐かしさより先に、比較が来てしまう。",
            displayTime: "18:29",
            notifications: [
                NotificationLine(appName: "LINE", sender: "中学同窓会", message: "出欠、今日までです！", timeText: "3時間前"),
                NotificationLine(appName: "Instagram", sender: "フォローリクエスト", message: "同級生からリクエストがあります", timeText: "1時間前"),
                NotificationLine(appName: "メール", sender: "派遣会社", message: "契約更新について", timeText: "42分前"),
                NotificationLine(appName: "LINE", sender: "母", message: "同窓会行くの？", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Moving Day",
            answer: "段ボールの数だけでは、出ていく理由はわからない。新しい場所へ行くというより、ここから離れる必要があった。",
            displayTime: "08:58",
            notifications: [
                NotificationLine(appName: "引越し業者", sender: "到着予定", message: "9:15頃に到着します", timeText: "12分前"),
                NotificationLine(appName: "LINE", sender: "大家", message: "鍵はポストにお願いします", timeText: "31分前"),
                NotificationLine(appName: "LINE", sender: "拓也", message: "最後に少しだけ話せない？", timeText: "44分前"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "この部屋での1年前", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Night Bus",
            answer: "旅行の高揚ではなく、戻らなければならない移動。深夜バスの通知には、節約と決心が同じくらい乗っている。",
            displayTime: "22:08",
            notifications: [
                NotificationLine(appName: "高速バス", sender: "乗車案内", message: "22:40 新宿西口発", timeText: "25分前"),
                NotificationLine(appName: "LINE", sender: "祖母", message: "無理して帰ってこなくていいよ", timeText: "1時間前"),
                NotificationLine(appName: "メール", sender: "会社", message: "明日の欠勤連絡を受け付けました", timeText: "2時間前"),
                NotificationLine(appName: "天気", sender: "目的地", message: "明朝は雪の予報です", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Pet Clinic",
            answer: "小さな存在の体調が、生活全体を止めている。誰にも責められていないのに、自分のせいだと思っている。",
            displayTime: "04:51",
            notifications: [
                NotificationLine(appName: "動物病院", sender: "予約確認", message: "本日 9:00", timeText: "3:12"),
                NotificationLine(appName: "検索", sender: "最近の検索", message: "猫 食べない 朝まで", timeText: "2:48"),
                NotificationLine(appName: "LINE", sender: "母", message: "寝られてる？", timeText: "1:27"),
                NotificationLine(appName: "カメラ", sender: "通知", message: "リビングで動きがありました", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "After Proposal",
            answer: "うれしいはずの出来事ほど、生活の細部が急に現実になる。好きだけでは決められない何かがある。",
            displayTime: "00:37",
            notifications: [
                NotificationLine(appName: "写真", sender: "新しい共有", message: "指輪の写真が共有されました", timeText: "1時間前"),
                NotificationLine(appName: "LINE", sender: "親友", message: "で、返事したの？", timeText: "33分前"),
                NotificationLine(appName: "家計簿", sender: "今月の支出", message: "予算を超過しています", timeText: "19分前"),
                NotificationLine(appName: "LINE", sender: "彼", message: "急がなくていいから", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Shared Calendar",
            answer: "予定は共有されたままなのに、気持ちはもう別々になっている。消すほどではない関係が、一番扱いづらい。",
            displayTime: "12:03",
            notifications: [
                NotificationLine(appName: "カレンダー", sender: "共有予定", message: "記念日 ディナー", timeText: "今"),
                NotificationLine(appName: "LINE", sender: "予約店", message: "本日のご予約を確認します", timeText: "8分前"),
                NotificationLine(appName: "LINE", sender: "結衣", message: "今日はやめておこう", timeText: "19分前"),
                NotificationLine(appName: "写真", sender: "メモリー", message: "4年前の今日", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "School Nurse",
            answer: "子どもの体調不良に見えて、大人の限界も滲んでいる。迎えに行く人もまた、誰かに迎えに来てほしい。",
            displayTime: "13:41",
            notifications: [
                NotificationLine(appName: "学校", sender: "保健室", message: "お子さんが体調不良です", timeText: "7分前"),
                NotificationLine(appName: "Slack", sender: "上司", message: "15時の会議、資料ありますか", timeText: "12分前"),
                NotificationLine(appName: "LINE", sender: "夫", message: "今出られない", timeText: "4分前"),
                NotificationLine(appName: "乗換案内", sender: "検索結果", message: "最短 38分", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Loan App",
            answer: "生活が破綻しているわけではなく、破綻しないために少しずつ無理をしている。数字だけが先に本音を出す。",
            displayTime: "03:09",
            notifications: [
                NotificationLine(appName: "ローン", sender: "審査結果", message: "お申し込み結果をご確認ください", timeText: "2分前"),
                NotificationLine(appName: "LINE", sender: "妻", message: "学費の振込、今日までだよね", timeText: "1時間前"),
                NotificationLine(appName: "銀行", sender: "振込予約", message: "予約処理が失敗しました", timeText: "38分前"),
                NotificationLine(appName: "メモ", sender: "下書き", message: "正直に話す", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Hotel Lobby",
            answer: "旅行でも出張でもなく、家に帰らないための一泊かもしれない。住所のある人が、今夜だけ居場所を借りている。",
            displayTime: "23:16",
            notifications: [
                NotificationLine(appName: "ホテル", sender: "チェックイン", message: "予約番号をフロントで提示してください", timeText: "14分前"),
                NotificationLine(appName: "LINE", sender: "自宅", message: "話し合いから逃げないで", timeText: "51分前"),
                NotificationLine(appName: "カード", sender: "ご利用速報", message: "8,900円", timeText: "12分前"),
                NotificationLine(appName: "天気", sender: "現在地", message: "明朝は晴れ", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Draft Saved",
            answer: "言葉にした時点で、関係が終わることも始まることもある。下書きに残っているのは、送信前の最後の平和。",
            displayTime: "02:32",
            notifications: [
                NotificationLine(appName: "メール", sender: "下書き保存", message: "件名なし", timeText: "今"),
                NotificationLine(appName: "LINE", sender: "上司", message: "明日、出社したら話そう", timeText: "1時間前"),
                NotificationLine(appName: "勤怠", sender: "有休残日数", message: "残り 0.5日", timeText: "23分前"),
                NotificationLine(appName: "メモ", sender: "固定", message: "退職理由", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Baby Monitor",
            answer: "泣いているのは子どもだけではない。通知の静けさと細切れの睡眠が、生活を少しずつ別の形にしている。",
            displayTime: "03:44",
            notifications: [
                NotificationLine(appName: "ベビーモニター", sender: "音声検知", message: "寝室で音を検知しました", timeText: "今"),
                NotificationLine(appName: "育児記録", sender: "授乳", message: "前回から2時間52分", timeText: "3分前"),
                NotificationLine(appName: "LINE", sender: "母", message: "昼間少し寝なさいね", timeText: "2時間前"),
                NotificationLine(appName: "Slack", sender: "会社", message: "復帰時期の確認です", timeText: "昨日")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .notification,
            title: "Blocked",
            answer: "言い合いの最後は、言葉ではなく設定で終わることがある。ブロックした側も、少しだけ画面を見続けている。",
            displayTime: "01:55",
            notifications: [
                NotificationLine(appName: "LINE", sender: "システム", message: "通知設定が変更されました", timeText: "今"),
                NotificationLine(appName: "写真", sender: "削除済み項目", message: "12枚の写真が追加されました", timeText: "9分前"),
                NotificationLine(appName: "Uber", sender: "配車完了", message: "ドライバーが到着しました", timeText: "17分前"),
                NotificationLine(appName: "LINE", sender: "非表示のトーク", message: "1件の未読メッセージ", timeText: "今")
            ],
            receiptLines: []
        ),
        FragmentItem(
            type: .receipt,
            title: "CEREMONY SHOP",
            answer: "急に必要になった礼服まわりの小物。準備のなさは怠慢ではなく、受け入れたくなかった時間の長さかもしれない。",
            displayTime: "07:32",
            notifications: [],
            receiptLines: [
                "黒ネクタイ",
                "白封筒",
                "筆ペン",
                "ストッキング",
                "ポケットティッシュ"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "EXAM STATION",
            answer: "必要なものを買い足すほど、忘れ物より不安を埋めている。大丈夫と言うための小さな儀式。",
            displayTime: "06:48",
            notifications: [],
            receiptLines: [
                "鉛筆 3本",
                "消しゴム",
                "チョコバー",
                "ホットレモン",
                "カイロ"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "NURSING MART",
            answer: "介護用品と自分用の眠気覚ましが同じ袋に入っている。支える側の生活が、静かに削られている。",
            displayTime: "21:36",
            notifications: [],
            receiptLines: [
                "大人用おむつ",
                "やわらかごはん",
                "使い捨て手袋",
                "栄養ドリンク",
                "無糖コーヒー"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "AIRPORT MINI",
            answer: "楽しみな出発なら買わないものが混ざっている。急な移動には、生活を置いてきた感じが出る。",
            displayTime: "05:57",
            notifications: [],
            receiptLines: [
                "充電アダプタ",
                "替えの靴下",
                "のど飴",
                "アイマスク",
                "香典袋"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "IDOL POPUP",
            answer: "浪費にも見えるし、生存戦略にも見える。誰にも理解されなくても、今日を越えるための理由が必要な日がある。",
            displayTime: "18:23",
            notifications: [],
            receiptLines: [
                "ランダム缶バッジ",
                "アクリルスタンド",
                "トレカケース",
                "ミネラルウォーター",
                "レジ袋"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "MORNING CVS",
            answer: "朝の買い物なのに、夜の続きが残っている。出勤前ではなく、徹夜明けの一時停止に見える。",
            displayTime: "06:11",
            notifications: [],
            receiptLines: [
                "眠眠打破",
                "サンドイッチ",
                "目薬",
                "替えマスク",
                "ミントガム"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "WEEKEND HOME",
            answer: "食卓の人数は見えるのに、会話の温度は見えない。家族のための買い物ほど、本人の孤独が混ざることがある。",
            displayTime: "16:22",
            notifications: [],
            receiptLines: [
                "カレー粉",
                "じゃがいも",
                "豚こま肉",
                "子ども用ジュース",
                "缶ハイボール"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "LAUNDRY SHOP",
            answer: "服を整えるための買い物なのに、生活全体を立て直したい感じがある。洗剤だけでは落ちない日もある。",
            displayTime: "23:04",
            notifications: [],
            receiptLines: [
                "洗濯洗剤",
                "柔軟剤",
                "シミ抜き",
                "45Lごみ袋",
                "安い白ワイン"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "HOSPITAL CVS",
            answer: "誰かのためのものと自分のためのものが、雑に同じ袋に入っている。看病の時間は生活を分けてくれない。",
            displayTime: "19:49",
            notifications: [],
            receiptLines: [
                "テレビカード",
                "ゼリー飲料",
                "歯磨きセット",
                "週刊誌",
                "ブラックコーヒー"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "KIDS CORNER",
            answer: "小さなおもちゃは、時間の代わりにはならない。それでも何かを持って帰らないといけない夜がある。",
            displayTime: "20:12",
            notifications: [],
            receiptLines: [
                "ミニカー",
                "シールブック",
                "グミ",
                "小さなプリン",
                "缶ビール"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "HOTEL SHOP",
            answer: "一泊分だけの生活用品は、理由を説明しない。逃げたのか、守ったのか、ただ静かな場所が必要だったのか。",
            displayTime: "23:38",
            notifications: [],
            receiptLines: [
                "下着",
                "洗顔シート",
                "ミネラルウォーター",
                "カップ味噌汁",
                "耳栓"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "SEA SIDE MART",
            answer: "海辺で食べるには寂しい組み合わせ。待ち合わせが流れた後か、一人で来ると決めた後かもしれない。",
            displayTime: "17:55",
            notifications: [],
            receiptLines: [
                "ホットコーヒー",
                "肉まん",
                "使い捨てカイロ",
                "ポケット灰皿",
                "ミントタブレット"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "SUBURB DRUG",
            answer: "健康的な買い物に見えるけれど、どこか切羽詰まっている。体を変えたいのか、生活を変えたいのか。",
            displayTime: "09:34",
            notifications: [],
            receiptLines: [
                "プロテインバー",
                "サプリメント",
                "体重計用電池",
                "無糖ヨーグルト",
                "炭酸水"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "BOOKS AND MORE",
            answer: "本のタイトルだけでは前向きに見える。でもレシートの時間には、焦りと再出発が同居している。",
            displayTime: "21:28",
            notifications: [],
            receiptLines: [
                "履歴書",
                "職務経歴書",
                "ボールペン",
                "面接マナー本",
                "ブラックコーヒー"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "MIDNIGHT DIY",
            answer: "家具かもしれないし、壊れた空気かもしれない。工具を買えば解決するものばかりではない。",
            displayTime: "00:47",
            notifications: [],
            receiptLines: [
                "六角レンチ",
                "養生テープ",
                "軍手",
                "電球",
                "缶チューハイ"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "RIVER SIDE CVS",
            answer: "遠回りして買ったようなものばかり。家に近づく速度を、少しだけ落としたかったのかもしれない。",
            displayTime: "22:21",
            notifications: [],
            receiptLines: [
                "ホットミルクティー",
                "文庫本",
                "小さなチョコ",
                "絆創膏",
                "ビニール傘"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "AFTER PARTY",
            answer: "人と会った後ほど、一人になる瞬間が濃くなる。派手な夜の終わりに、生活感だけが戻ってくる。",
            displayTime: "01:24",
            notifications: [],
            receiptLines: [
                "メイク落とし",
                "水 1L",
                "カップ麺",
                "頭痛薬",
                "ヘアゴム"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "OLD TOWN SHOP",
            answer: "地元の店で買うものは、今の生活より昔の記憶に近い。戻ってきたのに、帰ってきたとは言い切れない。",
            displayTime: "15:03",
            notifications: [],
            receiptLines: [
                "仏花",
                "緑茶",
                "線香",
                "どら焼き",
                "新聞"
            ]
        ),
        FragmentItem(
            type: .receipt,
            title: "LAST MINUTE",
            answer: "間に合わせの買い物には、準備できなかった事情が出る。贈り物なのに、どこか謝罪に近い。",
            displayTime: "19:57",
            notifications: [],
            receiptLines: [
                "ギフト袋",
                "ハンドクリーム",
                "小さなカード",
                "ボールペン",
                "ミント"
            ]
        )
    ]
}

#Preview {
    ContentView()
}
