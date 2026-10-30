import AppKit
import SwiftUI

struct BootstrapView: View {
    @ObservedObject var viewModel: BootstrapViewModel
    let revealData: () -> Void

    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    if viewModel.state == .ready {
                        profileCard
                    } else if case .failed(let message) = viewModel.state {
                        errorCard(message: message)
                    } else {
                        loadingCard
                    }
                    Text(NSLocalizedString("foundation.privacy", comment: "Local storage description"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .frame(maxWidth: 720, alignment: .leading)
            }
        }
        .frame(minWidth: 640, minHeight: 480)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Text("FT")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlAccentColor)))
                    .accessibility(hidden: true)
                Text("FitTrack")
                    .font(.system(size: 24, weight: .semibold))
            }
            Text(NSLocalizedString("foundation.title", comment: "Welcome title"))
                .font(.system(size: 34, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(NSLocalizedString("foundation.subtitle", comment: "Welcome subtitle"))
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 7) {
                Circle().fill(Color(NSColor.systemGreen)).frame(width: 7, height: 7)
                    .accessibility(hidden: true)
                Text(NSLocalizedString("store.ready", comment: "Storage opened"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibility(identifier: "store.ready")
            }
            Text(NSLocalizedString("profile.title", comment: "Profile section"))
                .font(.headline)
            Text(NSLocalizedString("profile.name", comment: "Name label"))
                .font(.subheadline)
            TextField(
                NSLocalizedString("profile.placeholder", comment: "Name placeholder"),
                text: $viewModel.displayName
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(viewModel.isSaving)
            .accessibility(label: Text(NSLocalizedString("profile.name", comment: "Name label")))
            .accessibility(identifier: "profile.name")

            if let message = viewModel.validationMessage {
                Text(message).foregroundColor(Color(NSColor.systemRed)).font(.caption)
            }
            if let message = viewModel.saveErrorMessage {
                Text(message).foregroundColor(Color(NSColor.systemRed))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibility(identifier: "profile.error")
            }
            HStack(spacing: 12) {
                Button(action: { self.viewModel.save() }) {
                    Text(NSLocalizedString("action.save", comment: "Save profile"))
                }
                .disabled(!viewModel.canSave)
                .accessibility(identifier: "profile.save")

                if viewModel.isSaving {
                    ActivityIndicator().frame(width: 16, height: 16)
                    Text(NSLocalizedString("profile.saving", comment: "Save in progress"))
                        .font(.caption).foregroundColor(.secondary)
                } else if let message = viewModel.statusMessage {
                    Text(message).font(.caption).foregroundColor(.secondary)
                        .accessibility(identifier: "profile.saved")
                }
                Spacer()
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(NSColor.controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(NSColor.separatorColor), lineWidth: 1))
    }

    private var loadingCard: some View {
        HStack(spacing: 14) {
            ActivityIndicator().frame(width: 20, height: 20)
            Text(NSLocalizedString("store.opening", comment: "Opening local data"))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibility(identifier: "store.loading")
    }

    private func errorCard(message: String) -> some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("store.error.title", comment: "Opening error title"))
                .font(.headline)
            Text(NSLocalizedString("store.error.body", comment: "Opening error explanation"))
                .fixedSize(horizontal: false, vertical: true)
            Text(message).font(.caption).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Button(action: { self.viewModel.start() }) {
                    Text(NSLocalizedString("action.retry", comment: "Retry"))
                }
                .accessibility(identifier: "store.retry")
                Button(action: revealData) {
                    Text(NSLocalizedString("action.revealData", comment: "Open data directory"))
                }
                .disabled(!viewModel.canRevealStorageDirectory)
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(NSColor.controlBackgroundColor)))
        .accessibility(identifier: "store.error")
    }
}

/// Native activity indicator instead of the macOS 11 ProgressView.
private struct ActivityIndicator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .small
        indicator.isIndeterminate = true
        indicator.startAnimation(nil)
        return indicator
    }

    func updateNSView(_ view: NSProgressIndicator, context: Context) {}
}
