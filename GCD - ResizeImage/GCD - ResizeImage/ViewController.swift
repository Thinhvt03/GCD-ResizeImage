//
//  ViewController.swift
//  GCD - ResizeImage
//
//  Created by Hoàng Loan on 08/03/2023.
//

import UIKit

class ViewController: UIViewController {

    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = CGRect(x: 100, y: 100, width: 200, height: 300)
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        
        downloadAndCacheImage()
    }
    
    private func downloadAndCacheImage() {
        let imageSize = CGSize(width: imageView.bounds.size.width, height: imageView.bounds.size.height)
        if let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            
            let targetURL = cacheDirectoryURL.appendingPathComponent("wallpaper.jpg")
            guard let stringURL = URL(string: "https://picsum.photos/200/300") else { return }
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.downloadWallpaper(url: stringURL, path: targetURL)
                self?.resizeImage(size: imageSize, path: targetURL)
                
                guard
                    let imageData = try? Data(contentsOf: targetURL)
                else {return}
                
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    private func downloadWallpaper(url: URL, path: URL) {
            guard
                let imageData = try? Data(contentsOf: url),
                let image = UIImage(data: imageData)
            else { return }
            do {
                try image.jpegData(compressionQuality: 1.0)?.write(to: path)
            } catch {
                print(error.localizedDescription)
            }
    }
    
    private func resizeImage(size: CGSize, path: URL) {
        
        guard let sourceImage = UIImage(contentsOfFile: path.path) else {return}
        
        let finalWidth: CGFloat, finalHeight: CGFloat
        let ratio = sourceImage.size.width / sourceImage.size.height
        
        if sourceImage.size.width >= sourceImage.size.height {
            finalWidth = size.width
            finalHeight = finalWidth / ratio
        } else {
            finalHeight = size.height
            finalWidth = finalHeight * ratio
        }
        
        let imageSize = CGSize(width: finalWidth, height: finalHeight)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let rect = CGRect(origin: .zero, size: imageSize)
        sourceImage.draw(in: rect)
        
        guard
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext(),
            let imageData = resizeImage.jpegData(compressionQuality: 1.0)
        else {
            print("Error: Resize image")
            return
        }
        do {
            try imageData.write(to: path)
        } catch {
            print("Error: Write disk")
        }
    }
}

