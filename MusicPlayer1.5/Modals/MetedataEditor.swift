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






class Mp3FileReader {
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
        
        
        
        var myrange = count-20
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
