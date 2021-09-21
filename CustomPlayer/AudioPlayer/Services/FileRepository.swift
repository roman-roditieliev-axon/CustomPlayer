//
//  FileRepository.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import Foundation

protocol FileRepositoryProtocol {
    func saveFile(data: Data, name: String, completion: @escaping (Result<Data, Error>) -> Void)
    func retrieveFile(name: String, completion: @escaping (Result<(dataObject: Data, localURL: URL), Error>) -> Void)
}

class FileRepository: FileRepositoryProtocol {
    static let shared = FileRepository()
    private var manager = FileManager.default

    func saveFile(data: Data, name: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let path = self.getDocumentDirectory().appendingPathComponent(name + ".mp3")
        DispatchQueue.global().async {
            do {
                try data.write(to: path)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func retrieveFile(name: String, completion: @escaping (Result<(dataObject: Data, localURL: URL), Error>) -> Void) {
        let directory = self.getDocumentDirectory().appendingPathComponent(name + ".mp3")
        if manager.fileExists(atPath: directory.path) {
            DispatchQueue.main.async {
                do {
                    let audioData: Data = try Data(contentsOf: directory)
                    completion(.success((audioData, directory)))
                } catch {
                    completion(.failure(error))
                }
            }
        } else {
            let errorTemp = NSError(domain: "", code: 401, userInfo: nil)
            completion(.failure(errorTemp))
        }
    }

    func deleteFile(name: String, completion: () -> Void) {
        let directory = self.getDocumentDirectory().appendingPathComponent(name + "mp3")
        if manager.fileExists(atPath: directory.path) {
            try? manager.removeItem(at: directory)
            completion()
        }
    }

    private init() { }
}

// MARK: - Get Documents Directory path
private extension FileRepository {
    func getDocumentDirectory() -> URL {
        manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

