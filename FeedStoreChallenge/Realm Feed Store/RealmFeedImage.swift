//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFeedImage: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var desc: String?
    @objc dynamic var location: String?
    @objc dynamic var url: String = ""
    
    convenience init(id: String, desc: String?, location: String?, url: String) {
        self.init()
        self.id = id
        self.desc = desc
        self.location = location
        self.url = url
    }
}
