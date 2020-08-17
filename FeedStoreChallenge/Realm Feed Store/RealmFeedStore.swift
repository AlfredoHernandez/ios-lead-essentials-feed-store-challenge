//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public final class RealmFeedStore: FeedStore {
    
    let realm: Realm
    
    public init() throws {
        realm = try Realm()
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let feedCached = realm.objects(RealmCache.self).first
        if let cache = feedCached, cache.feed.count != 0 {
            var localFeed = [LocalFeedImage]()
            cache.feed.forEach { image in
                guard let uuid = UUID(uuidString: image.id), let url = URL(string: image.url) else {
                    return completion(.failure(Error.invalidData))
                }
                localFeed.append(LocalFeedImage(id: uuid, description: image.desc, location: image.location, url: url))
            }
            completion(.found(feed: localFeed, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            try write { realm in
                realm.deleteAll()
                let realmFeed = List<RealmFeedImage>()
                feed.map { RealmFeedImage(id: $0.id.uuidString, desc: $0.description, location: $0.location, url: $0.url.absoluteString) }.forEach {
                    realmFeed.append($0)
                }
                let cache = RealmCache(feed: realmFeed, timestamp: timestamp)
                realm.add(cache)
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try write { realm in
                realm.deleteAll()
                completion(nil)
            }
        }catch {
            completion(error)
        }
    }
    
    private func write(action: (Realm) -> Void) throws {
        let realm = self.realm
        try realm.write {
            action(realm)
        }
    }
}
