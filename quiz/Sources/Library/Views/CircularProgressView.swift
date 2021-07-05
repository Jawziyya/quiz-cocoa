//
//
//  quiz
//  
//  Created on 04.07.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI

struct CircularProgressView: View {

    // MARK: Properties

    /// The progress view style.

    let style: CircularProgressView.Style

    let fillColor: Color
    let backgroundColor: Color

    /// The current progress shown by the progress view.
    ///
    /// The current progress is represented by a `Double` value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. Values less than 0.0 and greater than 1.0 are pinned to those limits.

    @Binding var progress: Double

    private var adjustedProgress: Double {
        min(max(0, self.progress), 1)
    }

    // MARK: Initializers

    /// Creates an instance that displays the progress of a task over time.
    ///
    /// - Parameter style: The progress view style.
    /// - Parameter progress: A binding indicating the progress of a task.
    ///
    /// - Returns: A progress view that displays the progress of a task over time.

    init(style: CircularProgressView.Style, fillColor: Color, backgroundColor: Color, progress: Binding<Double>) {
        self.style = style
        self.fillColor = fillColor
        self.backgroundColor = backgroundColor
        self._progress = progress
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            if style == .bar {
                GCProgressBar(progress: adjustedProgress)
                    .stroke(style: barStrokeStyle(geometry))
                    .foregroundColor(fillColor)
                    .background(
                        GCProgressBar(progress: 1)
                            .stroke(style: barStrokeStyle(geometry))
                            .foregroundColor(backgroundColor)
                    )
                    .padding(.horizontal, barPadding(geometry))
            } else if style == .circle {
                GCProgressCircle(progress: adjustedProgress)
                    .fill(fillColor)
                    .background(
                        GCProgressCircle(progress: 1)
                            .fill(backgroundColor)
                    )
            } else if style == .ring {
                GCProgressRing(progress: adjustedProgress)
                    .stroke(style: ringStrokeStyle(geometry))
                    .foregroundColor(fillColor)
                    .background(
                        GCProgressRing(progress: 1)
                            .stroke(style: ringStrokeStyle(geometry))
                            .foregroundColor(backgroundColor)
                    )
                    .padding(ringPadding(geometry))
            }
        }
        .animation(.linear)
    }
}

extension CircularProgressView {

    /// The styles permitted for the progress view.

    enum Style: String, CaseIterable {

        /// A horizontal bar that animates from left to right.
        case bar

        /// A circle that animates clockwise.
        case circle

        /// A ring that animates clockwise.
        case ring

    }
}

// MARK: - Padding, Line Width, & Stroke Style

extension CircularProgressView {

    // MARK: Bar

    private func barPadding(_ geometry: GeometryProxy) -> CGFloat {
        self.barLineWidth(geometry) / 2
    }

    private func barLineWidth(_ geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width / 8, geometry.size.height)
    }

    private func barStrokeStyle(_ geometry: GeometryProxy) -> StrokeStyle {
        StrokeStyle(lineWidth: self.barLineWidth(geometry), lineCap: .round)
    }

    // MARK: Ring

    private func ringPadding(_ geometry: GeometryProxy) -> CGFloat {
        self.ringLineWidth(geometry) / 2
    }

    private func ringLineWidth(_ geometry: GeometryProxy) -> CGFloat {
        let smallestDimension = min(geometry.size.width, geometry.size.height)

        return max(smallestDimension / 8, 1)
    }

    private func ringStrokeStyle(_ geometry: GeometryProxy) -> StrokeStyle {
        StrokeStyle(lineWidth: self.ringLineWidth(geometry), lineCap: .round)
    }
}

struct GCProgressBar: Shape {

    // MARK: Properties

    var progress: Double

    var animatableData: Double {
        get { self.progress }
        set { self.progress = newValue }
    }

    // MARK: Path

    func path(in rect: CGRect) -> Path {
        guard self.progress > .zero else {
            return Path()
        }

        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        let endPoint = CGPoint(x: rect.size.width * CGFloat(self.progress), y: rect.midY)

        var path = Path()

        path.move(to: startPoint)
        path.addLine(to: endPoint)

        return path
    }
}

struct GCProgressRing: Shape {

    // MARK: Properties

    var progress: Double

    var animatableData: Double {
        get { self.progress }
        set { self.progress = newValue }
    }

    // MARK: Path

    func path(in rect: CGRect) -> Path {
        guard self.progress > .zero else {
            return Path()
        }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.size.width, rect.size.height) / 2
        let startAngle = Angle.degrees(-90)
        let endAngle = startAngle + .degrees(360 * self.progress)

        var path = Path()

        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)

        return path
    }
}

struct GCProgressCircle: Shape {

    // MARK: Properties

    var progress: Double

    var animatableData: Double {
        get { self.progress }
        set { self.progress = newValue }
    }

    // MARK: Path

    func path(in rect: CGRect) -> Path {
        guard self.progress > .zero else {
            return Path()
        }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.size.width, rect.size.height) / 2
        let startAngle = Angle.degrees(-90)
        let endAngle = startAngle + .degrees(360 * self.progress)

        var path = Path()

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        return path
    }
}

struct Circular_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(
            style: .ring,
            fillColor: Color.accentColor,
            backgroundColor: Color.purple,
            progress: .constant(0.25)
        )
        .previewLayout(PreviewLayout.fixed(width: 70, height: 50))
    }
}
