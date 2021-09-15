//
//  CachingPlayerItem.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import AVFoundation
import Foundation

fileprivate extension URL {
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}

@objc protocol CachingPlayerItemDelegate {
    /// Is called when the media file is fully downloaded.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data)
    /// Is called every time a new portion of data is received.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int)
    /// Is called after initial preBuffering is finished, means we are ready to play.
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItem)
    /// Is called when the data being downloaded did not arrive in time to continue playback.
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem)
    /// Is called on downloading error.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error)
}

open class CachingPlayerItem: AVPlayerItem {

    class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {

        var playingFromData = false
        var mimeType: String? // is required when playing from Data
        var session: URLSession?
        var mediaData: Data?
        var response: URLResponse?
        var pendingRequests = Set<AVAssetResourceLoadingRequest>()
        weak var owner: CachingPlayerItem?

        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {

            if playingFromData {
                // Nothing to load.
            } else if session == nil {
                // If we're playing from a url, we need to download the file.
                // We start loading the file on first request only.
                guard let initialUrl = owner?.url else {
                    fatalError("internal inconsistency")
                }

                startDataRequest(with: initialUrl)
            }

            pendingRequests.insert(loadingRequest)
            processPendingRequests()
            return true
        }

        func startDataRequest(with url: URL) {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            session?.dataTask(with: url).resume()
        }

        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            pendingRequests.remove(loadingRequest)
        }

        // MARK: URLSession delegates
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            mediaData?.append(data)
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didDownloadBytesSoFar: mediaData!.count, outOf: Int(dataTask.countOfBytesExpectedToReceive))
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
            mediaData = Data()
            self.response = response
            processPendingRequests()
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let errorUnwrapped = error {
                owner?.delegate?.playerItem?(owner!, downloadingFailedWith: errorUnwrapped)
                return
            }
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didFinishDownloadingData: mediaData!)
        }

        // MARK: -

        func processPendingRequests() {
            // get all fullFilled requests
            let requestsFulfilled = Set<AVAssetResourceLoadingRequest>(pendingRequests.compactMap {
                self.fillInContentInformationRequest($0.contentInformationRequest)
                if self.haveEnoughDataToFulfillRequest($0.dataRequest!) {
                    $0.finishLoading()
                    return $0
                }
                return nil
            })
            // remove fulfilled requests from pending requests
            _ = requestsFulfilled.map { self.pendingRequests.remove($0) }

        }

        func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
            // if we play from Data we make no url requests, therefore we have no responses, so we need to fill in contentInformationRequest manually
            if playingFromData {
                contentInformationRequest?.contentType = self.mimeType
                contentInformationRequest?.contentLength = Int64(mediaData!.count)
                contentInformationRequest?.isByteRangeAccessSupported = true
                return
            }

            guard let responseUnwrapped = response else {
                // have no response from the server yet
                return
            }

            contentInformationRequest?.contentType = responseUnwrapped.mimeType
            contentInformationRequest?.contentLength = responseUnwrapped.expectedContentLength
            contentInformationRequest?.isByteRangeAccessSupported = true

        }

        func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let currentOffset = Int(dataRequest.currentOffset)

            guard let songDataUnwrapped = mediaData,
                  songDataUnwrapped.count > currentOffset else {
                // Don't have any data at all for this request.
                return false
            }

            let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
            let dataToRespond = songDataUnwrapped.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
            dataRequest.respond(with: dataToRespond)

            return songDataUnwrapped.count >= requestedLength + requestedOffset

        }

        deinit {
            session?.invalidateAndCancel()
        }
    }

    let url: URL
    fileprivate let resourceLoader = ResourceLoaderDelegate()
    fileprivate let initialScheme: String?
    fileprivate var customFileExtension: String?

    weak var delegate: CachingPlayerItemDelegate?

    open func download() {
        if resourceLoader.session == nil {
            resourceLoader.startDataRequest(with: url)
        }
    }

    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"

    /// Is used for playing remote files.
    convenience init(url: URL) {
        self.init(url: url, customFileExtension: nil)
    }

    /// Override/append custom file extension to URL path.
    /// This is required for the player to work correctly with the intended file type.
    init(url: URL, customFileExtension: String?) {

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              var urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
            fatalError("Urls without a scheme are not supported")
        }

        self.url = url
        self.initialScheme = scheme

        if let ext = customFileExtension {
            urlWithCustomScheme.deletePathExtension()
            urlWithCustomScheme.appendPathExtension(ext)
            self.customFileExtension = ext
        }

        let asset = AVURLAsset(url: urlWithCustomScheme)
        asset.resourceLoader.setDelegate(resourceLoader, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)

        resourceLoader.owner = self

        addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self)

    }

    /// Is used for playing from Data.
    init(data: Data, mimeType: String, fileExtension: String) {

        guard let fakeUrl = URL(string: cachingPlayerItemScheme + "://whatever/file.\(fileExtension)") else {
            fatalError("internal inconsistency")
        }

        self.url = fakeUrl
        self.initialScheme = nil

        resourceLoader.mediaData = data
        resourceLoader.playingFromData = true
        resourceLoader.mimeType = mimeType

        let asset = AVURLAsset(url: fakeUrl)
        asset.resourceLoader.setDelegate(resourceLoader, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        resourceLoader.owner = self

        addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self)

    }

    //swiftlint:disable block_based_kvo
    //    // MARK: - KVO
        open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            #warning("https://axondevgroup.atlassian.net/browse/APDC-289")
            delegate?.playerItemReadyToPlay?(self)
        }
    //swiftlint:enable block_based_kvo

    // MARK: Notification handlers
    @objc func playbackStalledHandler() {
        delegate?.playerItemPlaybackStalled?(self)
    }

    // MARK: -
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        fatalError("not implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: "status")
        resourceLoader.session?.invalidateAndCancel()
    }

}
