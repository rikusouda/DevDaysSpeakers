//
//  ViewController.swift
//  RxSwiftPractice
//
//  Created by Yuki Yoshioka on 2018/02/21.
//  Copyright © 2018年 rikusouda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UITableViewController {
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    let disposeBag = DisposeBag()

    let message = BehaviorRelay<String>(value: "")
    let isBusy = BehaviorRelay<Bool>(value: false)
    let speakers = BehaviorRelay<[Speaker]>(value: [Speaker]())

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureBinding()
    }
    
    private func configureBinding() {
        self.speakers
            .asDriver()
            .drive(self.tableView.rx.items) { (tableView, i, speaker) in
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "SpeakerCell",
                                         for: IndexPath(row: i, section: 0)) as! SpeakerCell
                cell.set(speaker: speaker)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        self.isBusy
            .asDriver()
            .map { !$0 }
            .drive(syncButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.syncButton.rx.tap
            .asDriver()
            .do(onNext: { [unowned self] (_) in
                self.isBusy.accept(true)
                }, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .flatMapLatest { (_) -> Driver<[Speaker]> in
                ViewController.getSpeakers().asDriver(onErrorJustReturn: [Speaker]())
            }
            .do(onNext: { [unowned self] (_) in
                self.isBusy.accept(false)
                }, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .drive(self.speakers)
            .disposed(by: self.disposeBag)
    }

    static func getSpeakers() -> Single<[Speaker]> {
        return Single<[Speaker]>.create { observer in
            let request = URLRequest(url: URL(string: "http://demo4404797.mockable.io/speakers")!)
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard
                    error == nil,
                    let data = data
                    else {
                        return observer(.error(error!))
                }
                
                do {
                    let users: [Speaker] = try JSONDecoder().decode([Speaker].self, from: data)
                    observer(.success(users))
                }
                catch DecodingError.keyNotFound(let key, let context) {
                    let str: String? = String(data: data, encoding: .utf8)
                    print(str!)
                    
                    print("keyNotFound: \(key): \(context)")
                    observer(.error(NSError(domain: "keyNotFound: \(key): \(context)", code: 500, userInfo: nil)))
                } catch {
                    let str: String? = String(data: data, encoding: .utf8)
                    print(str!)
                    observer(.error(error))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
    
}

