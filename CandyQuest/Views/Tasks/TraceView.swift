import SwiftUI

struct TraceView: View {
    let task: TraceTask
    var onComplete: (Int) -> Void

    @State private var touchedGuideIndices: Set<Int> = []
    @State private var userPath = Path()
    @State private var attempts = 0
    @State private var finished = false
    @State private var hintMessage: String? = nil

    private let canvasSize: CGFloat = 260
    // Generous radius + lower threshold: these are discrete sample points along
    // the letter's stroke, not a full outline, so a young child's finger doesn't
    // need to be precise to reasonably be considered "traced."
    private let hitRadius: CGFloat = 40
    private let completionThreshold: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            Text("Trace the letter \(task.character)!")
                .font(.candyTitle(24))
                .foregroundColor(.black.opacity(0.75))

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: canvasSize, height: canvasSize)
                    .shadow(color: .black.opacity(0.1), radius: 6)

                // Guide letter, faint
                Text(task.character)
                    .font(.system(size: canvasSize * 0.75, weight: .bold, design: .rounded))
                    .foregroundColor(CandyTheme.lemon.opacity(0.6))

                // User's drawn stroke (drawn first so guide dots stay visible on top)
                userPath
                    .stroke(CandyTheme.hotPink, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))

                // Guide dots (for coverage checking + visual hint)
                ForEach(Array(task.guidePoints.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(touchedGuideIndices.contains(index) ? Color.green : CandyTheme.purple.opacity(0.45))
                        .frame(width: 16, height: 16)
                        .position(scaled(point))
                }
            }
            .frame(width: canvasSize, height: canvasSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        guard !finished else { return }
                        addPoint(value.location)
                    }
                    .onEnded { _ in
                        guard !finished else { return }
                        checkCompletion()
                    }
            )

            // Live progress, so it's obvious tracing is being tracked.
            progressBar

            if let hintMessage {
                Text(hintMessage)
                    .font(.candyBody(15))
                    .foregroundColor(CandyTheme.purple)
                    .transition(.opacity)
            }

            HStack(spacing: 16) {
                Button("Clear") {
                    userPath = Path()
                    touchedGuideIndices = []
                    hintMessage = nil
                }
                .buttonStyle(CandyButtonStyle(color: .gray))

                Button("Done") {
                    checkCompletion()
                }
                .buttonStyle(CandyButtonStyle(color: CandyTheme.hotPink))
            }
        }
    }

    private var progressBar: some View {
        let progress = Double(touchedGuideIndices.count) / Double(task.guidePoints.count)
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.2))
                Capsule()
                    .fill(progress >= completionThreshold ? Color.green : CandyTheme.hotPink)
                    .frame(width: geo.size.width * min(progress, 1.0))
                    .animation(.easeOut(duration: 0.2), value: progress)
            }
        }
        .frame(width: canvasSize, height: 14)
    }

    private func scaled(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * canvasSize, y: point.y * canvasSize)
    }

    private func addPoint(_ location: CGPoint) {
        if userPath.isEmpty {
            userPath.move(to: location)
        } else {
            userPath.addLine(to: location)
        }
        for (index, guidePoint) in task.guidePoints.enumerated() {
            let p = scaled(guidePoint)
            if hypot(p.x - location.x, p.y - location.y) < hitRadius {
                touchedGuideIndices.insert(index)
            }
        }
    }

    private func checkCompletion() {
        attempts += 1
        let coverage = Double(touchedGuideIndices.count) / Double(task.guidePoints.count)
        if coverage >= completionThreshold {
            finished = true
            hintMessage = nil
            let stars = attempts == 1 ? 3 : (attempts <= 2 ? 2 : 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onComplete(stars)
            }
        } else {
            withAnimation { hintMessage = "So close! Trace a bit more of the letter, then tap Done again." }
        }
    }
}
