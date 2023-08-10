//
//  VisualWidget.swift
//  Speaks AI
//
//  Created by IAL VECTOR on 8/24/23.
import Foundation
import WidgetKit
import SwiftUI

@main
struct VisualAssist: Widget {
    let kind: String = "Visual Assist"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView()
        }
        .configurationDisplayName("Speaks AI Widget")
        .description("A widget that displays the words 'Speaks AI'.")
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetView: View {
    var body: some View {
        Text("Speaks AI")
            .font(.title)
    }
}
