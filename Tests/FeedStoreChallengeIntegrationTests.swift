//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import RealmSwift
import FeedStoreChallenge

class FeedStoreChallengeIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    func test_retrieve_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let cache = expectedCache()
        insert(feed: cache.feed, timestamp: cache.timestamp, on: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: cache.feed, timestamp: cache.timestamp)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> RealmFeedStore {
        try! RealmFeedStore()
    }
    
    private func insert(feed: [LocalFeedImage], timestamp: Date, on sut: RealmFeedStore) {
        let exp = expectation(description: "Wait for insertion.")
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error, "Expected insert images. Got \(String(describing: error)) instead.")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: RealmFeedStore, toLoad expectedFeed: [LocalFeedImage], timestamp expectedTimestamp: Date) {
        let exp = expectation(description: "Wait to retrieve")
        sut.retrieve { result in
            switch result {
            case let .found(retrievedFeed, retrievedTimestamp):
                XCTAssertEqual(retrievedFeed, expectedFeed)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp)
            default:
                XCTFail("Expected to found feed. Got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectedCache() -> (feed: [LocalFeedImage], timestamp: Date) {
        return (uniqueLocalImageFeed(), Date())
    }
    
    private func uniqueLocalImageFeed() -> [LocalFeedImage] {
        return [uniqueLocalImage(), uniqueLocalImage()]
    }
    
    private func uniqueLocalImage(description: String? = nil, location: String? = nil) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: description, location: location, url: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}
