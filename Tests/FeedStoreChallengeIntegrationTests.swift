//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeIntegrationTests: XCTestCase {
    func test_retrieve_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = try! RealmFeedStore()
        let sutToPerformLoad = try! RealmFeedStore()
        
        let exp = expectation(description: "Wait for insertion.")
        let localFeed = uniqueLocalImageFeed()
        let timestamp = Date()
        sutToPerformSave.insert(localFeed, timestamp: timestamp) { error in
            XCTAssertNil(error, "Expected insert images. Got \(String(describing: error)) instead.")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: "Wait to retrieve")
        sutToPerformLoad.retrieve { result in
            switch result {
            case let .found(retrievedFeed, retrievedTimestamp):
                XCTAssertEqual(retrievedFeed, localFeed)
                XCTAssertEqual(retrievedTimestamp, timestamp)
            default:
                XCTFail("Expected to found feed. Got \(result) instead.")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    func uniqueLocalImageFeed() -> [LocalFeedImage] {
        [uniqueLocalImage(), uniqueLocalImage()]
    }
    
    func uniqueLocalImage(description: String? = nil, location: String? = nil) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: description, location: location, url: anyURL())
    }
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}
