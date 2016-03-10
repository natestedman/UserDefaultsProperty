// UserDefaultsProperty
// Written in 2016 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import Foundation
import ReactiveCocoa
import Result

/// A simple user-defaults-backed mutable property.
///
/// This property will read its initial value from a user defaults object, and will write future values to the same user
/// defaults object. However, it _will not_ observe changes made to the user defaults key in another manner. For
/// example:
///
///     let defaults = NSUserDefaults.standardUserDefaults()
///     let key = "example"
///     defaults.setInteger(1, forKey: key)
///
///     let property = UserDefaultsProperty<Int?>(
///         userDefaults: defaults,
///         key: key,
///         fromValue: { $0 },
///         toValue: { $0 as? Int }
///     )
///
///     // property.value == 1
///     // defaults.integerForKey(key) == 1
///
///     property.value = 2
///
///     // property.value == 1
///     // defaults.integerForKey(key) == 2
///
///     defaults.setInteger(3, forKey: key)
///
///     // property.value == 2
///     // defaults.integerForKey(key) == 3
///
/// This also means that two independent `UserDefaultsProperty` instances will not update each other's `value`. In
/// general, the intended design is to have one and only one `UserDefaultsProperty` for each key in your user defaults
/// object.
public final class UserDefaultsProperty<Value>
{
    // MARK: - Backing

    /// The backing property, in which the current value is stored.
    private let backing: MutableProperty<Value>

    // MARK: - Initialization

    /**
    Initializes a user defaults property.
    
    Two conversion functions are provided, to convert to and from the user defaults representation. It is important that
    the value returned from `fromValue` is a property-list-compatible object, so that it can be stored in the user
    defaults object.

    - parameter userDefaults: The user defaults object to use.
    - parameter key:          The user defaults key to use.
    - parameter fromValue:    A function to convert from property values to user defaults values.
    - parameter toValue:      A function to convert from user defaults values to property values.
    */
    public init(userDefaults: NSUserDefaults, key: String, fromValue: Value -> AnyObject?, toValue: AnyObject? -> Value)
    {
        self.backing = MutableProperty(toValue(userDefaults.objectForKey(key)))
        self.backing.signal.map(fromValue).observeNext({ userDefaultsValue in
            userDefaults.setObject(userDefaultsValue, forKey: key)
        })
    }
}

extension UserDefaultsProperty: MutablePropertyType
{
    // MARK: - Mutable Property Requirements

    /// A signal producer for the property's value.
    public var producer: SignalProducer<Value, NoError>
    {
        return backing.producer
    }

    /// A signal for the property's value.
    public var signal: Signal<Value, NoError>
    {
        return backing.signal
    }

    /// The property's current value.
    public var value: Value
    {
        get { return backing.value }
        set { backing.value = newValue }
    }
}
