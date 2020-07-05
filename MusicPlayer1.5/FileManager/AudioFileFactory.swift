//
//  Mp3Factory.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 6/25/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import Foundation

class AudioFileFactory {
    //static let shared = ARFileManager()
    let fileManager = FileManager.default

    var documentDirectoryURL: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    
//    func createMp3File(using rawData: Data) throws -> URL {
//
//    }
    
//    private func createMp3Header(data: Data) -> NSData {
//        let header = NSMutableData()
//
//    }

//    func createWavFile(using rawData: Data) throws -> URL {
//         //Prepare Wav file header
//         let waveHeaderFormat = createWaveHeader(data: rawData) as Data
//
//         //Prepare Final Wav File Data
//         let waveFileData = waveHeaderFormat + rawData
//
//         //Store Wav file in document directory.
//         return try storeMusicFile(data: waveFileData)
//     }

     private func createWaveHeader(data: Data) -> NSData {

          let sampleRate:Int32 = 2000
          let chunkSize:Int32 = 36 + Int32(data.count)
          let subChunkSize:Int32 = 16
          let format:Int16 = 1
          let channels:Int16 = 1
          let bitsPerSample:Int16 = 8
          let byteRate:Int32 = sampleRate * Int32(channels * bitsPerSample / 8)
          let blockAlign: Int16 = channels * bitsPerSample / 8
          let dataSize:Int32 = Int32(data.count)

          let header = NSMutableData()

          header.append([UInt8]("RIFF".utf8), length: 4) //Chunk ID
          header.append(intToByteArray(chunkSize), length: 4) //Chunk Size

          //WAVE
          header.append([UInt8]("WAVE".utf8), length: 4) //Format

          //FMT
          header.append([UInt8]("fmt ".utf8), length: 4) //Subchunk1 ID

          header.append(intToByteArray(subChunkSize), length: 4) //Subchunk1 ID Size
          header.append(shortToByteArray(format), length: 2) //Audio Format
          header.append(shortToByteArray(channels), length: 2) //Number of Channels
          header.append(intToByteArray(sampleRate), length: 4) //Sample Rate
          header.append(intToByteArray(byteRate), length: 4) //Byte Rate
          header.append(shortToByteArray(blockAlign), length: 2) //Block Align
          header.append(shortToByteArray(bitsPerSample), length: 2) //Bits per Sample

          header.append([UInt8]("data".utf8), length: 4) //Subchunk2 ID
          header.append(intToByteArray(dataSize), length: 4) //Subchunk2 Size

          return header //Header will be in front of data
     }

    private func intToByteArray(_ i: Int32) -> [UInt8] {
          return [
            //little endian
            UInt8(truncatingIfNeeded: (i      ) & 0xff),
            UInt8(truncatingIfNeeded: (i >>  8) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 16) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 24) & 0xff)
           ]
     }

     private func shortToByteArray(_ i: Int16) -> [UInt8] {
            return [
                //little endian
                UInt8(truncatingIfNeeded: (i      ) & 0xff),
                UInt8(truncatingIfNeeded: (i >>  8) & 0xff)
            ]
      }

//     func storeMusicFile(data: Data) throws -> URL {
//
//           let fileName = "Record \(Date().dateFileName)"
//
//           guard mediaDirectoryURL != nil else {
//              debugPrint("Error: Failed to fetch mediaDirectoryURL")
//              throw ARError(localizedDescription:             AlertMessage.medioDirectoryPathNotAvaiable)
//            }
//
//           let filePath = mediaDirectoryURL!.appendingPathComponent("\(fileName).wav")
//            debugPrint("File Path: \(filePath.path)")
//            try data.write(to: filePath)
//
//           return filePath //Save file's path respected to document directory.
//      }
    public static func DataToMP3(data: Data) {
        
    }
}
