//
/*
 *		Created by 游宗諭 in 2021/4/11
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import SuperCodable
import XCTest

// MARK: - EncodableTests

final class EncodableTests: XCTestCase {
    func testKeyedWithKey() throws {
        let sut = KeyedWithKey(id: "1")
        XCTAssertEqual(sut.aID, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":"1"}
            """#)
    }

    func testKeyedWithoutKey() throws {
        let sut = KeyedWithoutKey(id: "1")
        XCTAssertEqual(sut.id, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":"1"}
            """#)
    }

    func testOptionalKeyedWithKey() throws {
        let sut = OptionalKeyedWithKey(id: "1")
        XCTAssertEqual(sut.aID, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":"1"}
            """#)
    }

    func testOptionalKeyedWithoutKey() throws {
        let sut = OptionalKeyedWithoutKey(id: nil)
        XCTAssertNil(sut.id, "1")

        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {}
            """#)
    }

    func testKeyedWithNestedEncodable() throws {
        let sut = KeyWithNestedEncodable()
        sut.object = KeyWithNestedEncodable.AObject(bObject: KeyWithNestedEncodable.AObject.Bobject(id: "1"))
        XCTAssertEqual(sut.object.bObject.id, "1")
        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"Aobject":{"bObject":{"id":"1"}}}
            """#)
    }

    func testTransformWithKey() throws {
        let sut = TransformWithKey()
        sut.aID = "1"
        XCTAssertEqual(sut.aID, "1")
        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":1}
            """#)
    }

    func testTransformWithKeyButFailureShouldHappenEncodeFailure() throws {
        let sut = TransformWithKey()
        sut.aID = "nan"
        XCTAssertEqual(sut.aID, "nan")
        XCTAssertThrowsError(
            try JSONEncoder().encode(sut)
        )
    }

    func testTransformWithoutKey() throws {
        let sut = TransformWithoutKey()
        sut.id = "1"
        XCTAssertEqual(sut.id, "1")
        let data = try JSONEncoder().encode(sut)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"id":1}
            """#)
    }

    func testTransformWithoutKeyButFailureShouldHappenEncodeFailure() throws {
        let sut = TransformWithoutKey()
        sut.id = "nan"
        XCTAssertEqual(sut.id, "nan")
        XCTAssertThrowsError(
            try JSONEncoder().encode(sut)
        )
    }
}

// MARK: - KeyedWithKey

private struct KeyedWithKey: SuperEncodable {
    // MARK: Lifecycle

    init(id: String) {
        self.aID = id
    }

    // MARK: Internal

    @Keyed("id")
    var aID: String
}

// MARK: - OptionalKeyedWithKey

private struct OptionalKeyedWithKey: SuperEncodable {
    // MARK: Lifecycle

    init(id: String) {
        self._aID.wrappedValue = id
    }

    // MARK: Internal

    @OptionalKeyed("id")
    var aID: String? = "1"
}

// MARK: - KeyedWithoutKey

private struct KeyedWithoutKey: SuperEncodable {
    // MARK: Lifecycle

    init(id: String) {
        self._id = .init("")
        self.id = id
    }

    // MARK: Internal

    @Keyed
    var id: String
}

// MARK: - OptionalKeyedWithoutKey

private struct OptionalKeyedWithoutKey: SuperEncodable {
    // MARK: Internal

    @OptionalKeyed
    var id: String? = nil
}

// MARK: - KeyWithNestedEncodable

private struct KeyWithNestedEncodable: SuperEncodable {
    struct AObject: Encodable {
        struct Bobject: Encodable {
            var id: String
        }

        var bObject: Bobject
    }

    @Keyed("Aobject")
    var object: AObject
}

// MARK: - TransformWithKey

private struct TransformWithKey: SuperEncodable {
    @KeyedTransform(
        "id",
        SCTransformOf<String, Int>(
            fromDecoder: { _ in
                fatalError("not a test subject, should never happen")
            },
            toEncoder: {
                str in
                guard let transformed = Int(str) else {
                    throw NSError(domain: "transform Error, str:\(str) is not a Int", code: 0)
                }
                return transformed
            }))
    var aID: String
}

// MARK: - TransformWithoutKey

private struct TransformWithoutKey: SuperEncodable {
    @KeyedTransform(
        SCTransformOf<String, Int>(
            fromDecoder: { _ in
                fatalError("not a test subject, should never happen")
            },
            toEncoder: {
                str in
                guard let transformed = Int(str) else {
                    throw NSError(domain: "transform Error, str:\(str) is not a Int", code: 0)
                }
                return transformed
            }))
    var id: String
}
