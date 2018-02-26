//
//  SpeakerCell.swift
//  RxSwiftPractice
//
//  Created by Yuki Yoshioka on 2018/02/23.
//  Copyright © 2018年 rikusouda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SpeakerCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let disposeBag = DisposeBag()
    let speaker = PublishRelay<Speaker>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let speakerDriver = speaker.asDriver(onErrorDriveWith: Driver.empty())
        
        speakerDriver
            .map { $0.name }
            .drive(self.nameLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        speakerDriver
            .map { $0.description }
            .drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        speakerDriver
            .map { (speaker) -> URL? in
                speaker.avatar != nil ? URL(string: speaker.avatar!) : nil
            }
            .flatMap { (avatarURLString) -> Driver<UIImage?> in
                if let url = avatarURLString {
                    return SpeakerCell.loadAvaterImage(url: url)
                        .map { UIImage?.some($0) }
                        .asDriver(onErrorDriveWith: Driver<UIImage?>.just(nil))
                } else {
                    return Driver<UIImage?>.just(nil)
                }
            }
            .drive(self.iconImage.rx.image)
            .disposed(by: self.disposeBag)
    }
    
    func set(speaker: Speaker) {
        self.speaker.accept(speaker)
    }
    
    private static func loadAvaterImage(url: URL) -> Single<UIImage> {
        return Single<UIImage>.create { observer in
            let request = URLRequest(url: url,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 20)
            let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
                if let responseData = responseData,
                    let image = UIImage(data: responseData) {
                    observer(.success(image))
                    return
                } else {
                    observer(.error(NSError(domain: "Avater don't loaded", code: 500, userInfo: nil)))
                }
            }
            task.resume()
            
            return Disposables.create()
        }
    }
}
