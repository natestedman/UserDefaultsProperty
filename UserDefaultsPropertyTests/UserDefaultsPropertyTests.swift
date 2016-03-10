// UserDefaultsProperty
// Written in 2016 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import UserDefaultsProperty
import XCTest

class UserDefaultsPropertyTests: XCTestCase
{
    func testUserDefaultsProperty()
    {
        let defaults = NSUserDefaults()
        let key = "test"
        defaults.setObject(nil, forKey: key)

        let property = UserDefaultsProperty<Int?>(
            userDefaults: defaults,
            key: key,
            fromValue: { $0 },
            toValue: { $0 as? Int }
        )

        XCTAssertNil(property.value)
        XCTAssertNil(defaults.objectForKey(key))

        property.value = 1

        XCTAssertEqual(property.value, 1)
        XCTAssertEqual(defaults.integerForKey(key), 1)

        defaults.setInteger(2, forKey: key)

        XCTAssertEqual(property.value, 1)
        XCTAssertEqual(defaults.integerForKey(key), 2)
    }
}
