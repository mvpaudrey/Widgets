//
//  WidgetDemo.swift
//  WidgetDemo
//
//  Created by Audrey SOBGOU ZEBAZE on 26/10/2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetDemoEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct WidgetDemo: Widget {
    let kind: String = "WidgetDemo"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: -8) {
                        ForEach(context.attributes.orderItems, id: \.self) { item in
                            Image(systemName: item)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .foregroundColor(.purple)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("#\(context.attributes.orderNumber)")
                        .foregroundColor(.white)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text(context.state.status.title)
                            .font(.title)

                        Text("\(context.state.status.subTitle)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ZStack(alignment: .center) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                        gradient: Gradient(stops: [
                                            Gradient.Stop(color: context.state.status == .received ? .white.opacity(0.6) : .purple, location: 0.5),
                                            Gradient.Stop(color: context.state.status == .ready ? .purple : .white.opacity(0.6), location: 0.5)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing)
                            )
                            .frame(height: 2)
                            .padding(.horizontal, 60)

                        HStack(alignment: .center, spacing: 0) {
                            ForEach(OrderStatus.allCases, id: \.self) { status in
                                Image(systemName: status.image)
                                    .font(context.state.status == status ? .title2 : .body)
                                    .foregroundColor(context.state.status == status ? .purple : Color.init(red: 0.6, green: 0.6, blue: 0.6))
                                    .frame(width: context.state.status == status ? 45 : 32, height: context.state.status == status ? 45 : 32)
                                    .background {
                                        Circle()
                                            .fill(context.state.status == status ? .white : Color.init(red: 0.4, green: 0, blue: 0.4))
                                    }

                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }

            } compactLeading: {
                HStack(spacing: -8) {
                    ForEach(context.attributes.orderItems, id: \.self) { item in
                        Image(systemName: item)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                }
            } compactTrailing: {
                Image(context.state.status.image)
                    .font(.title3)
            } minimal: {
                Image(context.state.status.image)
                    .font(.title3)
            }
            .keylineTint(.purple)
        }

    }
}

struct LockScreenLiveActivityView: View {

    let context: ActivityViewContext<OrderAttributes>

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15,
                             style: .continuous)
            .fill(Color.black.gradient)

            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("#\(context.attributes.orderNumber) \(context.state.status.title)")
                            .font(.title3)
                            .foregroundColor(.white)
                        Text(context.state.status.subTitle)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    HStack(spacing: -8) {
                        ForEach(context.attributes.orderItems, id: \.self) { item in
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .padding(-2)

                                Circle()
                                    .stroke(.purple, lineWidth: 1.5)
                                    .padding(-2)

                                Image(systemName: item)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.purple)
                            }
                            .frame(width: 40, height: 40)
                        }
                    }
                }

                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                    gradient: Gradient(stops: [
                                        Gradient.Stop(color: context.state.status == .received ? .white.opacity(0.6) : .purple, location: 0.5),
                                        Gradient.Stop(color: context.state.status == .ready ? .purple : .white.opacity(0.6), location: 0.5)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing)
                        )
                        .frame(height: 2)
                        .offset(y: 12)
                        .padding(.horizontal, 60)
                        .frame(maxHeight: .infinity, alignment: .bottom)

                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(OrderStatus.allCases, id: \.self) { status in
                            Image(systemName: status.image)
                                .font(context.state.status == status ? .title2 : .body)
                                .foregroundColor(context.state.status == status ? .purple : .white.opacity(0.6))
                                .frame(width: context.state.status == status ? 45 : 32, height: context.state.status == status ? 45 : 32)
                                .background {
                                    Circle()
                                        .fill(context.state.status == status ? .white : .purple.opacity(0.4))
                                }
                                .background(alignment: .bottom, content: {
                                    BottomArrow(status: context.state.status, type: status)
                                })
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.bottom)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }

    @ViewBuilder
    func BottomArrow(status: OrderStatus, type: OrderStatus) -> some View {
        Image(systemName: "arrowtriangle.down.fill")
            .font(.system(size: 15))
            .scaleEffect(x: 1.3)
            .offset(y: 6)
            .opacity(status == type ? 1 : 0)
            .foregroundColor(.white)
            .overlay(alignment: .bottom) {
                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .offset(y: 13)
            }
    }

}

struct WidgetDemo_Previews: PreviewProvider {
    static var previews: some View {
        WidgetDemoEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
