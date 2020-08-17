//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmCache: Object {
    var feed: List<RealmFeedImage> = List<RealmFeedImage>()
    @objc dynamic var timestamp: Date = Date()
    
    convenience init(feed: List<RealmFeedImage>, timestamp: Date) {
        self.init()
        self.feed = feed
        self.timestamp = timestamp
    }
}
