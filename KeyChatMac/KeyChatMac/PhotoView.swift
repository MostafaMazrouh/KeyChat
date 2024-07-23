//
//  PhotoView.swift
//  KeyChatMac
//
//  Created by Mostafa Mazrouh on 2024-07-16.
//

import SwiftUI

struct PhotoView: View {
    
    @State private var selectedImage: NSImage? = nil
    @State private var showingFileImporter = false
    @StateObject private var filterVM = FilterVM()
    
    var body: some View {
        
        VStack {
            
            HStack {
                Button(action: {
                    showingFileImporter = true
                }) {
                    Text("Select from Files")
                }
                .fileImporter(
                    isPresented: $showingFileImporter,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    loadSelectedImage(from: result)
                }
                
                Button(action: {
                    if let image = selectedImage {
                        filterVM.applyBlur(to: image)
                        selectedImage = filterVM.filteredImage
                    }
                }) {
                    Text("Filter")
                }
                .disabled(selectedImage == nil)
                
                Button(action: {
                    selectedImage = nil
                    filterVM.filteredImage = nil
                }) {
                    Text("Remove avatar")
                }
                .disabled(selectedImage == nil && filterVM.filteredImage == nil)
            }
            
            if let image = filterVM.filteredImage ?? selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
//                    .frame(maxWidth: 700, maxHeight: 700)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
//                    .frame(maxWidth: 700, maxHeight: 700)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func loadSelectedImage(from result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                
                do {
                    let imageData = try Data(contentsOf: url)
                    if let image = NSImage(data: imageData) {
                        DispatchQueue.main.async {
                            selectedImage = image
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    print("----------------------------")
                }
            }
        case .failure(let error):
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PhotoView()
}
