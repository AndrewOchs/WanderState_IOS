//
//  AddPhotoView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddPhotoView: View {
    let stateCode: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var themeManager = ThemeManager.shared

    // Form state
    @State private var capturedImage: UIImage?
    @State private var cityName: String = ""
    @State private var journalEntry: String = ""
    @State private var selectedDate: Date = Date()

    // Camera state
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showImageSourcePicker = false

    // Error handling
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    // Get state name from code
    private var stateName: String {
        StatePathData.stateNames[stateCode] ?? stateCode
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Photo Section
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("PHOTO", icon: "camera.fill")

                            if let image = capturedImage {
                                // Photo preview
                                VStack(spacing: 12) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)

                                    Button(action: { showImageSourcePicker = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                                .font(.system(size: 14))
                                            Text("Change Photo")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(themeManager.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(themeManager.primary, lineWidth: 1)
                                        )
                                    }
                                }
                            } else {
                                // No photo yet - show add button
                                Button(action: { showImageSourcePicker = true }) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(themeManager.primary)
                                        Text("Tap to Add Photo")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(themeManager.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.primary.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(themeManager.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Location & Date Section
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("LOCATION & DATE", icon: "mappin.and.ellipse")

                            VStack(spacing: 0) {
                                // State (read-only)
                                HStack {
                                    Text("State")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(stateName)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)

                                Divider()
                                    .padding(.leading, 14)

                                // City input
                                HStack {
                                    Text("City")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                    TextField("Optional", text: $cityName)
                                        .font(.system(size: 15))
                                        .multilineTextAlignment(.trailing)
                                        .textContentType(.addressCity)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)

                                Divider()
                                    .padding(.leading, 14)

                                // Date picker
                                HStack {
                                    Text("Date")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                        .labelsHidden()
                                        .tint(themeManager.primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                            }
                            .background(themeManager.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Journal Section
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("JOURNAL ENTRY", icon: "pencil.line")

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $journalEntry)
                                    .font(.system(size: 15))
                                    .frame(minHeight: 100)
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                    )

                                if journalEntry.isEmpty {
                                    Text("Write about your experience... (optional)")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary.opacity(0.6))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 18)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Save Button
                        Button(action: savePhoto) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Save Photo")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(capturedImage != nil ? themeManager.primary : Color.gray.opacity(0.4))
                            )
                            .shadow(color: capturedImage != nil ? themeManager.primary.opacity(0.3) : .clear, radius: 8, y: 4)
                        }
                        .disabled(capturedImage == nil)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(stateName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primary)
                }

                ToolbarItem(placement: .principal) {
                    Text(stateName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.primary)
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
            .alert("Error Saving Photo", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.primary)
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(themeManager.primary)
        }
        .padding(.leading, 4)
    }

    private func savePhoto() {
        guard let image = capturedImage else { return }

        do {
            // Save image to Documents directory
            let photoId = UUID()
            let fileName = "\(photoId.uuidString).jpg"
            let fileURL = try saveImageToDocuments(image: image, fileName: fileName)

            // Create PhotoEntity with user-selected date
            let photoEntity = PhotoEntity(
                id: photoId,
                uri: fileURL.path,
                stateCode: stateCode,
                stateName: stateName,
                cityName: cityName,
                latitude: 0.0,
                longitude: 0.0,
                capturedDate: selectedDate,
                addedDate: Date(),
                thumbnailUri: ""
            )

            // Insert into SwiftData
            modelContext.insert(photoEntity)

            // If journal entry is provided, create JournalEntryEntity
            if !journalEntry.isEmpty {
                let journal = JournalEntryEntity(
                    photoId: photoId,
                    entryText: journalEntry
                )
                journal.photo = photoEntity
                modelContext.insert(journal)
            }

            // Save context
            try modelContext.save()

            print("Photo saved successfully for \(stateCode) - \(stateName)")
            dismiss()

        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            print("Error saving photo: \(error)")
        }
    }

    private func saveImageToDocuments(image: UIImage, fileName: String) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "AddPhotoView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photosDirectory = documentsDirectory.appendingPathComponent("Photos", isDirectory: true)

        // Create Photos directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }

        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL)

        return fileURL
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
