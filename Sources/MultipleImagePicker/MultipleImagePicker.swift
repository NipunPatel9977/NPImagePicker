// The Swift Programming Language
// https://docs.swift.org/swift-book

import PhotosUI
import UIKit
import AVKit

public enum MediaType {
    case image
    case video
    case imageVideo
}

public struct PickedMedia {
    let name: String
    let type: String // "Image" or "Video"
    let img: UIImage?
    let videoURL: URL?
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "type": type,
            "img": img ?? "",
            "video": videoURL?.lastPathComponent ?? ""
        ]
    }
}


public final class NPPickerManager: NSObject  {
    
    //MARK: - Private variables
    
    private var mediaType: MediaType
    private var maxSelection: Int
    private var completion: (([PickedMedia]) -> Void)?
    
    //------------------------------------------------------
    
    //MARK: - Initializer
    
    public init(mediaType: MediaType = .image, maxSelection: Int = 1) {
        self.mediaType = mediaType
        self.maxSelection = maxSelection
    }
    
    //------------------------------------------------------
    
    //MARK: - Private methods
    
    //To generate video thumb image
    private func generateThumbnailImage(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    //------------------------------------------------------
    
    //MARK: - Public methods
    
    @MainActor public func presentPicker(from viewController: UIViewController, completion: @escaping ([PickedMedia]) -> Void) {
        self.completion = completion
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = self.maxSelection
        
        switch mediaType {
        case .image:
            config.filter = .images
        case .video:
            config.filter = .videos
        case .imageVideo:
            config.filter = .any(of: [.images, .videos])
        }
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
    
    //------------------------------------------------------
}

//MARK: - PHPickerViewControllerDelegate methods

extension NPPickerManager: PHPickerViewControllerDelegate {
    
    @MainActor func pickerDidCancel(_ picker: PHPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        DispatchQueue.main.async {
            
            picker.dismiss(animated: true)
            
            var mediaResults: [PickedMedia] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                let provider = result.itemProvider
                
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadObject(ofClass: UIImage.self) { image, error in
                        defer { group.leave() }
                        if let img = image as? UIImage {
                            let item = PickedMedia(name: provider.suggestedName ?? "Image",
                                                   type: "Image",
                                                   img: img,
                                                   videoURL: nil)
                            mediaResults.append(item)
                        }
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                        defer { group.leave() }
                        
                        guard let sourceURL = url else { return }
                        
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                        try? FileManager.default.copyItem(at: sourceURL, to: tempURL)
                        
                        let thumbnail = self.generateThumbnailImage(for: tempURL)
                        let item = PickedMedia(
                            name: provider.suggestedName ?? "video.mp4",
                            type: "Video",
                            img: thumbnail,
                            videoURL: tempURL
                        )
                        mediaResults.append(item)
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.completion?(mediaResults)
            }
        }
    }
}

//------------------------------------------------------
