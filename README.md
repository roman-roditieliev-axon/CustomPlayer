# CustomPlayer

Custom Audio Player

Player is a simple iOS audio player written in Swift.

# Features
 - full screen player controller and mini player for used on other view controllers
 - reaction: like or dislike current audio track
 - plays local audio or streams remote audio over HTTPS
 - customizable UI and user interaction
 - no size restrictions
 - simple API

# Quick Start
You can simply copy all files into your Xcode project and install cocoapods as:
 - pod 'ReachabilitySwift'
 - pod 'Kingfisher'
 - pod 'FittedSheets'
 - pod "EFAutoScrollLabel"

# Usage 

The sample project provides an example of how to integrate Player, otherwise you can follow these steps.

Allocate and add the Player controller to your view hierarchy.

    private func openPlayer(with model: Podcast) {
        presentMainPlayer()
        player.playPodcast(with: model, completion: nil)
    }

    private func presentMainPlayer() {
        let viewModel = PlayerViewModel()
        viewModel.audioPlayer = self.player
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: PlayerViewController = storyboard.instantiateViewController(identifier: "PlayerViewController")
        viewController.viewModel = viewModel
        viewController.audioService = self.player
        self.present(viewController, animated: true, completion: nil)
    }
    
Provide the file path to the resource you would like to play locally or stream. Ensure you're including the file extension.

    let stringUrl = ""     // is your file path or remote url
    let url = URL(string: stringUrl)
    
    let podcast = Podcast(title: name, duration: TimeInterval(180), likeCount: 10, dislikeCount: 1, audioUrl: url, imageUrl: nil, podcastID: String(name), categoryID: "", createdAt: "", publishedAt: "", status: "", reactionType: .liked)
    openPlayer(with: podcast)

If you need to use mini player integrate it into your base view controller.

    lazy var miniPlayerVC: MiniPlayerViewController = {
        let view = MiniPlayerViewController()
        view.viewModel = viewModel
        view.audioPlayer = self.player
        view.delegate = self
        return view
    }()

    private lazy var miniPlayerContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private func configureView() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(miniPlayerContainerView)
        addChild(miniPlayerVC)
        miniPlayerContainerView.addSubview(miniPlayerVC.view)
        miniPlayerVC.didMove(toParent: self)
        miniPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        guard let miniPlayerView = miniPlayerVC.view else { return }
        NSLayoutConstraint.activate([
            miniPlayerContainerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            miniPlayerContainerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            miniPlayerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            miniPlayerContainerView.heightAnchor.constraint(equalToConstant: MiniPlayerViewController.playerHeight),

            miniPlayerView.leadingAnchor.constraint(equalTo: miniPlayerContainerView.leadingAnchor),
            miniPlayerView.trailingAnchor.constraint(equalTo: miniPlayerContainerView.trailingAnchor),
            miniPlayerView.topAnchor.constraint(equalTo: miniPlayerContainerView.topAnchor),
            miniPlayerView.bottomAnchor.constraint(equalTo: miniPlayerContainerView.bottomAnchor),
        ])
    }
    
 Also you need use mini-player delegate
     
     player.miniPlayerDelegate = self
     
     extension ViewController: MiniPlayerPresenterDelegate {
         func presentMiniPlayer() {
             self.configureView()
         }
     }


Community
- Found a bug? Open an issue.
- Feature idea? Open an issue.
- Want to contribute? Submit a pull request.

Resources
- Swift
- AV Foundation Programming Guide

License

Player is available under the MIT license, see the LICENSE file for more information.
