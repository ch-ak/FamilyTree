import SwiftUI

struct GenealogyPerson: Identifiable, Hashable {
    enum Role: String {
        case selfPerson = "You"
        case spouse = "Spouse"
        case father = "Father"
        case mother = "Mother"
        case child = "Child"
    }

    let id: UUID
    let name: String
    let birthYear: Int?
    let role: Role

    var badgeLabel: String { role.rawValue }
}

private struct TreeLayoutSnapshot {
    let canvasSize: CGSize
    let motherPosition: CGPoint
    let fatherPosition: CGPoint
    let rootPosition: CGPoint
    let spousePosition: CGPoint
    let childPositions: [UUID: CGPoint]
    let placeholderChildPosition: CGPoint?
    let parentMergeY: CGFloat
    let coupleBridgeY: CGFloat
    let childRailY: CGFloat

    var parentConnectorY: CGFloat { motherPosition.y + cardSize.height / 2 }
    var rootTopY: CGFloat { rootPosition.y - cardSize.height / 2 }
    var rootBottomY: CGFloat { rootPosition.y + cardSize.height / 2 }
    var spouseBottomY: CGFloat { spousePosition.y + cardSize.height / 2 }
    var coupleMidpointX: CGFloat { (rootPosition.x + spousePosition.x) / 2 }
    var heartCenter: CGPoint { CGPoint(x: coupleMidpointX, y: coupleBridgeY) }
}

private let cardSize = CGSize(width: 210, height: 120)

struct MiniFamilyTreeView: View {
    let root: GenealogyPerson
    let spouse: GenealogyPerson?
    let father: GenealogyPerson?
    let mother: GenealogyPerson?
    let children: [GenealogyPerson]

    @State private var baseScale: CGFloat = 1.0
    @State private var baseOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero

    private let rowSpacing: CGFloat = 150
    private let canvasPadding: CGFloat = 64

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            canvasSurface
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var header: some View {
        HStack(spacing: 8) {
            Label("Genealogy", systemImage: "tree")
                .font(.title3.weight(.semibold))
            Spacer()
            Text("Tap cards to edit • Pinch/drag canvas")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct CanvasLayer: View {
    let children: [GenealogyPerson]
    let root: GenealogyPerson
    let spouse: GenealogyPerson?
    let father: GenealogyPerson?
    let mother: GenealogyPerson?
    let rowSpacing: CGFloat
    let padding: CGFloat
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            let snapshot = buildSnapshot(size: canvasSize)
            connectors(using: snapshot)
            cards(using: snapshot)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    private func buildSnapshot(size: CGSize) -> TreeLayoutSnapshot {
        let width = size.width
        let parentY = padding / 2 + cardSize.height / 2
        let coupleY = parentY + rowSpacing
        let childY = coupleY + rowSpacing

        let parentSpread = min(width * 0.24, 240)
        let motherX = width / 2 - parentSpread
        let fatherX = width / 2 + parentSpread

        let coupleGap = max(cardSize.width * 0.6, cardSize.width * 0.75)
        let rootX = width / 2 - coupleGap / 2
        let spouseX = width / 2 + coupleGap / 2

        let actualChildren = !children.isEmpty
            ? children
            : [GenealogyPerson(id: UUID(), name: "Add child", birthYear: nil, role: .child)]
        let childSpacing = max(
            32,
            min(
                96,
                (width - padding - CGFloat(actualChildren.count) * cardSize.width)
                / CGFloat(max(actualChildren.count - 1, 1))
            )
        )
        var childPositions: [UUID: CGPoint] = [:]
        let contentWidth = CGFloat(actualChildren.count) * cardSize.width
            + CGFloat(max(actualChildren.count - 1, 0)) * childSpacing
        var currentX = (width - contentWidth) / 2 + cardSize.width / 2

        for person in actualChildren {
            childPositions[person.id] = CGPoint(x: currentX, y: childY)
            currentX += cardSize.width + childSpacing
        }

        let placeholderPoint = children.isEmpty ? childPositions.values.first : nil
        let parentMergeY = coupleY - cardSize.height / 2 - 28
        let coupleBridgeY = coupleY + cardSize.height / 2 + 18
        let childRailY = coupleBridgeY + 32

        return TreeLayoutSnapshot(
            canvasSize: size,
            motherPosition: CGPoint(x: motherX, y: parentY),
            fatherPosition: CGPoint(x: fatherX, y: parentY),
            rootPosition: CGPoint(x: rootX, y: coupleY),
            spousePosition: CGPoint(x: spouseX, y: coupleY),
            childPositions: childPositions,
            placeholderChildPosition: placeholderPoint,
            parentMergeY: parentMergeY,
            coupleBridgeY: coupleBridgeY,
            childRailY: childRailY
        )
    }

    @ViewBuilder
    private func cards(using snapshot: TreeLayoutSnapshot) -> some View {
        let actualChildren = children.isEmpty ? [] : children
        ZStack {
            parentSlot(person: mother, title: "Add mother")
                .position(snapshot.motherPosition)
            parentSlot(person: father, title: "Add father")
                .position(snapshot.fatherPosition)

            coupleSlot(person: root, isYou: true)
                .position(snapshot.rootPosition)
            coupleSlot(person: spouse, isYou: false)
                .position(snapshot.spousePosition)

            heartBadge(using: snapshot)
                .position(snapshot.heartCenter)

            if actualChildren.isEmpty {
                placeholderChild(text: "Add child")
                    .position(snapshot.placeholderChildPosition ?? snapshot.heartCenter)
            } else {
                ForEach(actualChildren) { child in
                    FamilyCard(
                        person: child,
                        accentColor: Color.purple.opacity(0.85),
                        showsActionBadge: true,
                        chip: nil
                    )
                    .position(snapshot.childPositions[child.id] ?? snapshot.heartCenter)
                }
            }
        }
    }

    @ViewBuilder
    private func parentSlot(person: GenealogyPerson?, title: String) -> some View {
        if let person {
            FamilyCard(person: person, accentColor: Color.blue.opacity(0.75), showsActionBadge: true, chip: nil)
        } else {
            PlaceholderCard(title: title)
        }
    }

    @ViewBuilder
    private func coupleSlot(person: GenealogyPerson?, isYou: Bool) -> some View {
        if let person {
            let chip: FamilyCard.Chip? = isYou
                ? FamilyCard.Chip(text: "You", symbol: "balloon.fill", tint: .blue)
                : FamilyCard.Chip(text: "Partner", symbol: "heart.fill", tint: .pink)
            FamilyCard(
                person: person,
                accentColor: isYou ? .accentColor : Color.orange.opacity(0.85),
                showsActionBadge: true,
                chip: chip
            )
        } else {
            PlaceholderCard(title: "Add spouse")
        }
    }

    @ViewBuilder
    private func placeholderChild(text: String) -> some View {
        PlaceholderCard(title: text)
    }

    private func connectors(using snapshot: TreeLayoutSnapshot) -> some View {
        Canvas { context, _ in
            var parentPath = Path()
            parentPath.move(
                to: CGPoint(x: snapshot.motherPosition.x, y: snapshot.parentConnectorY)
            )
            parentPath.addLine(
                to: CGPoint(x: snapshot.motherPosition.x, y: snapshot.parentMergeY)
            )
            parentPath.move(
                to: CGPoint(x: snapshot.fatherPosition.x, y: snapshot.parentConnectorY)
            )
            parentPath.addLine(
                to: CGPoint(x: snapshot.fatherPosition.x, y: snapshot.parentMergeY)
            )
            parentPath.addLine(
                to: CGPoint(x: snapshot.coupleMidpointX, y: snapshot.parentMergeY)
            )
            parentPath.addLine(
                to: CGPoint(x: snapshot.coupleMidpointX, y: snapshot.rootTopY - 6)
            )
            context.stroke(
                parentPath,
                with: .color(Color.gray.opacity(0.3)),
                lineWidth: 2
            )

            var coupleVerticals = Path()
            coupleVerticals.move(
                to: CGPoint(x: snapshot.rootPosition.x, y: snapshot.rootBottomY)
            )
            coupleVerticals.addLine(
                to: CGPoint(x: snapshot.rootPosition.x, y: snapshot.coupleBridgeY)
            )
            coupleVerticals.move(
                to: CGPoint(x: snapshot.spousePosition.x, y: snapshot.spouseBottomY)
            )
            coupleVerticals.addLine(
                to: CGPoint(x: snapshot.spousePosition.x, y: snapshot.coupleBridgeY)
            )
            context.stroke(
                coupleVerticals,
                with: .color(Color.gray.opacity(0.45)),
                lineWidth: 3
            )

            var coupleBridge = Path()
            coupleBridge.move(
                to: CGPoint(x: snapshot.rootPosition.x, y: snapshot.coupleBridgeY)
            )
            coupleBridge.addLine(
                to: CGPoint(x: snapshot.spousePosition.x, y: snapshot.coupleBridgeY)
            )
            context.stroke(
                coupleBridge,
                with: .color(Color.gray.opacity(0.55)),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )

            var childStem = Path()
            childStem.move(to: snapshot.heartCenter)
            childStem.addLine(
                to: CGPoint(x: snapshot.heartCenter.x, y: snapshot.childRailY)
            )
            context.stroke(
                childStem,
                with: .color(Color.gray.opacity(0.45)),
                lineWidth: 3
            )

            if let first = snapshot.childPositions.values.min(by: { $0.x < $1.x }),
               let last = snapshot.childPositions.values.max(by: { $0.x < $1.x }) {
                var childRail = Path()
                childRail.move(to: CGPoint(x: first.x, y: snapshot.childRailY))
                childRail.addLine(to: CGPoint(x: last.x, y: snapshot.childRailY))
                for point in snapshot.childPositions.values.sorted(by: { $0.x < $1.x }) {
                    childRail.move(to: CGPoint(x: point.x, y: snapshot.childRailY))
                    childRail.addLine(
                        to: CGPoint(
                            x: point.x,
                            y: point.y - cardSize.height / 2
                        )
                    )
                }
                context.stroke(
                    childRail,
                    with: .color(Color.gray.opacity(0.35)),
                    lineWidth: 2
                )
            }
        }
    }

    private func heartBadge(using snapshot: TreeLayoutSnapshot) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
            Image(systemName: "heart.fill")
                .font(.headline)
                .foregroundStyle(Color.pink)
        }
    }
}

private struct FamilyCard: View {
    struct Chip {
        let text: String
        let symbol: String?
        let tint: Color
    }

    let person: GenealogyPerson
    let accentColor: Color
    let showsActionBadge: Bool
    let chip: Chip?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            avatar
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let year = person.birthYear {
                    Label("Born \(year)", systemImage: "star.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }
            }
            if let chip {
                HStack(spacing: 6) {
                    if let symbol = chip.symbol {
                        Image(systemName: symbol)
                    }
                    Text(chip.text)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(chip.tint, in: Capsule())
            }
        }
        .padding(18)
        .frame(width: cardSize.width, height: cardSize.height, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 10, x: 0, y: 8)
        )
        .overlay(alignment: .bottomLeading) {
            if showsActionBadge {
                EmptyView()
            }
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 48, height: 48)
            Image(systemName: symbolName(for: person.role))
                .foregroundStyle(accentColor)
        }
    }

    private func symbolName(for role: GenealogyPerson.Role) -> String {
        switch role {
        case .selfPerson: return "person.crop.circle.fill.badge.checkmark"
        case .spouse: return "person.2.circle"
        case .father: return "person.fill"
        case .mother: return "person.fill.viewfinder"
        case .child: return "person.crop.square"
        }
    }
}

private struct PlaceholderCard: View {
    let title: String

    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8, 6]))
            .foregroundColor(Color(.systemGray4))
            .frame(width: cardSize.width, height: cardSize.height)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            )
    }
}

private extension MiniFamilyTreeView {
    var canvasSurface: some View {
        GeometryReader { _ in
            let magnification = MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    baseScale = clamp(baseScale * value, lower: 0.55, upper: 2.2)
                }

            let drag = DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    baseOffset.width += value.translation.width
                    baseOffset.height += value.translation.height
                }

            CanvasLayer(
                children: children,
                root: root,
                spouse: spouse,
                father: father,
                mother: mother,
                rowSpacing: rowSpacing,
                padding: canvasPadding,
                canvasSize: canvasSize
            )
            .frame(width: canvasSize.width, height: canvasSize.height)
            .scaleEffect(currentScale, anchor: .center)
            .offset(currentOffset)
            .gesture(magnification.simultaneously(with: drag))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 520)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.secondarySystemGroupedBackground))
                Canvas { context, size in
                    var grid = Path()
                    let spacing: CGFloat = 36
                    stride(from: 0, through: size.width, by: spacing).forEach { x in
                        grid.move(to: CGPoint(x: x, y: 0))
                        grid.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    stride(from: 0, through: size.height, by: spacing).forEach { y in
                        grid.move(to: CGPoint(x: 0, y: y))
                        grid.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(grid, with: .color(Color.gray.opacity(0.08)), lineWidth: 0.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    var canvasSize: CGSize {
        let childCount = max(children.count, 1)
        let width = max(780, CGFloat(childCount) * (cardSize.width + 40))
        let height = rowSpacing * 2 + cardSize.height * 2 + canvasPadding
        return CGSize(width: width, height: height)
    }

    var currentScale: CGFloat {
        clamp(baseScale * pinchScale, lower: 0.55, upper: 2.2)
    }

    var currentOffset: CGSize {
        CGSize(width: baseOffset.width + dragOffset.width, height: baseOffset.height + dragOffset.height)
    }

    func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }
}

#Preview {
    MiniFamilyTreeView(
        root: GenealogyPerson(id: UUID(), name: "Kocherlakota C.", birthYear: 1986, role: .selfPerson),
        spouse: GenealogyPerson(id: UUID(), name: "Kocherlakota A.", birthYear: 1986, role: .spouse),
        father: GenealogyPerson(id: UUID(), name: "Kocherlakota M.", birthYear: 1960, role: .father),
        mother: GenealogyPerson(id: UUID(), name: "Kocherlakota M.", birthYear: 1964, role: .mother),
        children: [
            GenealogyPerson(id: UUID(), name: "Kocherlakota R.", birthYear: 2014, role: .child)
        ]
    )
    .padding()
}
