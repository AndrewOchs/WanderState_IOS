//
//  AddPhotoView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import PhotosUI

struct AddPhotoView: View {
    let stateCode: String
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var capturedImage: UIImage?
    @State private var cityName: String = ""
    @State private var journalEntry: String = ""

    // Camera state
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showImageSourcePicker = false

    // Get state name from code
    private var stateName: String {
        StatePathData.stateNames[stateCode] ?? stateCode
    }

    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section {
                    if let image = capturedImage {
                        // Photo preview
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)

                            Button(action: { showImageSourcePicker = true }) {
                                Label("Change Photo", systemImage: "arrow.triangle.2.circlepath.camera")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                    } else {
                        // No photo yet - show add button
                        Button(action: { showImageSourcePicker = true }) {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Add Photo")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Photo")
                }

                // Location Section
                Section {
                    TextField("City name (optional)", text: $cityName)
                        .textContentType(.addressCity)
                } header: {
                    Text("Location")
                } footer: {
                    Text("Adding to: \(stateName)")
                }

                // Journal Section
                Section {
                    TextEditor(text: $journalEntry)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if journalEntry.isEmpty {
                                    Text("Write about your experience...")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                } header: {
                    Text("Journal Entry (Optional)")
                }
            }
            .navigationTitle(stateName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePhoto()
                    }
                    .disabled(capturedImage == nil)
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog("Add Photo", isPresented: $showImageSourcePicker) {
                Button("Take Photo") {
                    showCamera = true
                }
                Button("Choose from Library") {
                    showPhotoLibrary = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoLibraryPicker(image: $capturedImage)
            }
        }
    }

    private func savePhoto() {
        // TODO: Save to SwiftData
        print("Photo saved for \(stateCode) - \(stateName)")
        if !cityName.isEmpty {
            print("  City: \(cityName)")
        }
        if !journalEntry.isEmpty {
            print("  Journal: \(journalEntry.prefix(50))...")
        }
        dismiss()
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Library Picker (PHPickerViewController wrapper)

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker

        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddPhotoView(stateCode: "PA")
}
