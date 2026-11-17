import SwiftUI

struct IslandPicker: View {
  let selected: Island
  let onSelect: (Island) -> Void

  @Environment(\.dismiss) private var dismiss
  @StateObject private var locator = Locator()
  @State private var search = ""
  @State private var expanded: Set<String> = []
  @State private var locationError: String?

  private var atolls: [(atoll: String, islands: [Island])] {
    let query = search.trimmingCharacters(in: .whitespaces)
    let matches = Timetable.shared.islands.filter {
      query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
        || $0.atoll.localizedCaseInsensitiveContains(query)
    }

    var order: [String] = []
    var groups: [String: [Island]] = [:]
    for island in matches {
      if groups[island.atoll] == nil { order.append(island.atoll) }
      groups[island.atoll, default: []].append(island)
    }
    return order.map { ($0, groups[$0]!) }
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(atolls, id: \.atoll) { group in
          DisclosureGroup(isExpanded: binding(for: group.atoll)) {
            ForEach(group.islands) { island in
              row(island)
            }
          } label: {
            HStack {
              Text(group.atoll).font(.headline)
              Spacer()
              Text("\(group.islands.count)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      .listStyle(.insetGrouped)      .overlay {
        if atolls.isEmpty {
          ContentUnavailableView.search(text: search)
        }
      }
      .navigationTitle("Islands")
      .navigationBarTitleDisplayMode(.inline)
      .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always))
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .bottomBar) {
          Button(action: useLocation) {
            if locator.isLocating {
              ProgressView()
            } else {
              Label("Use My Location", systemImage: "location.fill")
                .labelStyle(.titleAndIcon)
            }
          }
          .disabled(locator.isLocating)
        }
      }
      .alert(
        "Location",
        isPresented: Binding(get: { locationError != nil }, set: { if !$0 { locationError = nil } })
      ) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(locationError ?? "")
      }
      .onAppear {
        expanded = [selected.atoll]
      }
    }
  }

  private func row(_ island: Island) -> some View {
    Button {
      choose(island)
    } label: {
      HStack {
        Text(island.name).foregroundStyle(.primary)
        Spacer()
        if island.id == selected.id {
          Image(systemName: "checkmark")
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.accentColor)
        }
      }
    }
  }

  private func binding(for atoll: String) -> Binding<Bool> {
    Binding(
      get: { !search.isEmpty || expanded.contains(atoll) },
      set: { isOpen in
        if isOpen { expanded.insert(atoll) } else { expanded.remove(atoll) }
      }
    )
  }

  private func choose(_ island: Island) {
    onSelect(island)
    dismiss()
  }

  private func useLocation() {
    Task {
      do {
        choose(try await locator.nearestIsland())
      } catch is CancellationError {
      } catch {
        locationError = error.localizedDescription
      }
    }
  }
}
