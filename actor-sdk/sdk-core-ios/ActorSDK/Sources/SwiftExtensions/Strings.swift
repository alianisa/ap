//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import j2objc

public extension String {
    
    //public var isEmpty: Bool { return self.characters.isEmpty }
    
    public var length: Int { return self.characters.count }
    
    public func indexOf(_ str: String) -> Int? {
        if let range = range(of: str) {
            return characters.distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces);
    }
    
    public subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public func first(_ count: Int) -> String {
        let realCount = min(count, length);
        return substring(to: characters.index(startIndex, offsetBy: realCount));
    }
    
    public func skip(_ count: Int) -> String {
        let realCount = min(count, length);
        return substring(from: characters.index(startIndex, offsetBy: realCount))
    }
    
    
    public func strip(_ set: CharacterSet) -> String {
        return components(separatedBy: set).joined(separator: "")
    }
    
    public func replace(_ src: String, dest:String) -> String {
        return replacingOccurrences(of: src, with: dest, options: NSString.CompareOptions(), range: nil)
    }
    
    public func toLong() -> Int64? {
        return NumberFormatter().number(from: self)?.int64Value
    }
    
    public func toJLong() -> jlong {
        return jlong(toLong()!)
    }
    
    public func smallValue() -> String {
        let trimmed = trim();
        if (trimmed.isEmpty){
            return "#";
        }
        let letters = CharacterSet.letters
        let res: String = self[0];
        if (res.rangeOfCharacter(from: letters) != nil) {
            return res.uppercased();
        } else {
            return "#";
        }
    }
    
    public func hasPrefixInWords(_ prefix: String) -> Bool {
        var components = self.components(separatedBy: " ")
        for i in 0..<components.count {
            if components[i].lowercased().hasPrefix(prefix.lowercased()) {
                return true
            }
        }
        return false
    }
    
    /*public func contains(_ text: String) -> Bool {
        return self.range(of: text, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil
    }*/
    
    public func startsWith(_ text: String) -> Bool {
        let range = self.range(of: text)
        if range != nil {
            return range!.lowerBound == startIndex
        }
        return false
    }
    
    public func rangesOfString(_ text: String) -> [Range<String.Index>] {
        var res = [Range<String.Index>]()
        
        var searchRange = (self.startIndex ..< self.endIndex)
        while true {
            let found = self.range(of: text, options: String.CompareOptions.caseInsensitive, range: searchRange, locale: nil)
            if found != nil {
                res.append(found!)
                searchRange = (found!.upperBound ..< self.endIndex)
            } else {
                break
            }
        }
        
        return res
    }
    
    public func repeatString(_ count: Int) -> String {
        var res = ""
        for _ in 0..<count {
            res += self
        }
        return res
    }
        
    public func isValidUrl () -> Bool {
            if let url = URL(string: self) {
                return UIApplication.shared.canOpenURL(url)
            }
        return false
    }

    public var ns: NSString {
        return self as NSString
    }
    public var pathExtension: String? {
        return ns.pathExtension
    }
    public var lastPathComponent: String? {
        return ns.lastPathComponent
    }
    
    public var asNS: NSString { return (self as NSString) }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
           // print(scalar.value)
            switch scalar.value {
            case
            0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F910...0x1F933, // New Emoticons
            0x1F1E6...0x1F1FF, // Flags
            0x1F980...0x1F984,
            0x1F191...0x1F19A,
            0x1F201...0x1F202,
            0x1F232...0x1F23A,
            0x1F250...0x1F251,
            0x23E9...0x23F3,
            0x23F8...0x23FA,
            0x1F170...0x1F171,
            0x1F17E,
            0xA9,
            0xAE,
            0x2122,
            0x2328,
            0x3030,
            0x1F0CF,
            0x1F18E,
            0x1F9C0:
                return true
            default:
                continue
            }
        }
        return false
    }
}

public extension NSAttributedString {
    
    public func appendMutate(_ text: NSAttributedString) -> NSAttributedString {
        let res = NSMutableAttributedString()
        res.append(self)
        res.append(text)
        return res
    }
    
    public func appendMutate(_ text: String, font: UIFont) -> NSAttributedString {
        return self.appendMutate(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font]))
    }
    
    public convenience init(string: String, font: UIFont) {
        self.init(string: string, attributes: [NSAttributedStringKey.font: font])
    }
}

public extension NSMutableAttributedString {
    
    public func appendFont(_ font: UIFont) {
        self.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, self.length))
    }
    
    public func appendColor(_ color: UIColor) {
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color.cgColor, range: NSMakeRange(0, self.length))
    }
}


