//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class RealmCache: Object {
    var feed: List<RealmFeedImage> = List<RealmFeedImage>()
    @objc dynamic var timestamp: Date = Date()
    
    convenience init(feed: List<RealmFeedImage>, timestamp: Date) {
        self.init()
        self.feed = feed
        self.timestamp = timestamp
    }
}

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
    
    func toLocal() -> LocalFeedImage {
        LocalFeedImage(id: UUID(uuidString: id)!, description: desc, location: location, url: URL(string: url)!)
    }
}

class RealmFeedStore: FeedStore {
    
    let realm: Realm
    
    init() throws {
        realm = try Realm()
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
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
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            try realm.write {
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
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try realm.write {
                realm.deleteAll()
                completion(nil)
            }
        }catch {
            completion(error)
        }
    }
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
        return try! RealmFeedStore()
	}
}
