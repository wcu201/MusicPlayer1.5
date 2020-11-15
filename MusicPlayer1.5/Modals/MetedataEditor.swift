//
//  MetedataEditor.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 8/4/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import Foundation

enum MetadataError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

enum ID3v1FieldRange: Int {
    case header
    case title
    case artist
    
    var range: Range<Data.Index> {
        switch self {
        case .header: return 0 ..< 3 // "TAG" header field in first 3 bytes
        case .title: return 3 ..< 33 // 
        case .artist: return 33 ..< 63
        }
    }
}

//ID3
/*
 How to read and write data from an mp3 file
 ===========================================
 
 1. As a safety check take the url of your file as input and check its path extension to make sure its "mp3" else throw an error
 2. Convert the file's type URL to the type Data (let mp3 = try Data(contentsOf: your_url_name)
 3. Read the mp3 data convert bytes into characters so the data is readable ( String(Character(Unicode.Scalar(data_byte))) )
 4. To look for pertinent metadata you have to find specfic tags
    ------------------------------------------------------------
    TPE1 -> Artist
    TPE2 -> Album Artist
    TIT2 -> Title
    TALB -> Album
    APIC -> Attached Pictures
    TCON -> Genre
    TRCK -> Track Position
    (This is determinate on tag version, still researching) 
 
 ===========================================
*/






public class Mp3FileReader: NSObject {
    
    func getTitle(url: URL) throws -> String {
//        guard url.pathExtension.caseInsensitiveCompare("mp3") == ComparisonResult.orderedSame else {
//            throw NSError.init(domain: "Error - Not an mp3 file", code: 400, userInfo: nil)
//        }
        
        var title = String()
        let mp3 = try Data(contentsOf: url)
        
        // ID3Tag which is the last 128 bytes of an mp3 file
        let tag = last128bytes(data: mp3)
        // Grab the title from the tag given the ID3v1 format to know in which byte range it's stored
        title = String(data: tag[ID3v1FieldRange.title.range], encoding: .utf8) ?? ""
        // Remove null characters "\0"
        title = title.replacingOccurrences(of: "\0", with: "")
        return title
    }
    
    //For ID3v1 should return the ID3 tag which is the last 128 bytes of an mp3 file
    func last128bytes(data: Data) -> Data {
        //OR data[data.count-128...data.count-1]
        return data.subdata(in: data.count-128..<data.count)
    }
    
//    //For ID3v1 should return the header field which contains the string "TAG". In unicode that's 84 -> T, 65 -> A, 71 -> G
//    func headerRange(data: Data) -> Data {
//        //OR data[data.count-128...data.count-126]
//        return data.subdata(in: 0..<3)
//    }
//
//    func titleRange(data: Data) -> Data {
//        //OR data[data.count-125...data.count-96]
//        return data.subdata(in: 3..<32)
//    }
//
//    func artistRange(data: Data) -> Data {
//        //OR data[data.count-95...data.count-66]
//        return data.subdata(in: data.count-95..<data.count-65)
//    }
    
    func readFrom(path: URL/*String*/) throws -> Data {
        //let validPath = URL(fileURLWithPath: path)
        let validPath = path
        print(path)
        guard validPath.pathExtension.caseInsensitiveCompare("mp3") == ComparisonResult.orderedSame else {
            throw MetadataError.outOfStock
        }
        let mp3 = try Data(contentsOf: validPath)
        
        var count = 0
        for ind in mp3{
            /*if count<10{
                print(ind, Character(Unicode.Scalar(ind)))
                
            }*/
            let ch = String(Character(Unicode.Scalar(ind)))
            if ch=="A" {
                let c = String(Character(Unicode.Scalar(mp3[count+1])))
                if c=="c"{
                    let h = String(Character(Unicode.Scalar(mp3[count+2])))
                    if h=="t"{
                        print("Fount It! ", count)
                        break
                    }
                }
            }
            count+=1
        }
        print("count: ", count)
        let testContent = [UInt8]("Action Bronson".utf8)
        print(testContent)
        
        
        
        var myrange = count
        var counter = 0
        var myData = ""
        while(counter < 50){
            let cha = String(Character(Unicode.Scalar(mp3[myrange])))
            myData.append(cha)
            myrange+=1
            counter+=1
        }
        
        print("Did it work: ", myData)
        //print(mp3.base64EncodedString(options: .lineLength64Characters))
        //var testData = Data(base64Encoded: testContent)
        //mp3.contains(testContent[0])
        //let encoded = mp3.base64EncodedString()[1...2]
        //print("Action"[0..>])
        //mp3.contains(testContent)
        //print(testData?.base64EncodedData())
        //print(mp3.)
        return mp3
    }
}
