import InvidiousKit
import SwiftUI

@Observable
class SearchResultsViewModel {
    var results: [Search.Result] = []
    var done: Bool = false
    var page: Int32 = 0
    var task: Task<Void, Never>?

    func handleUpdate(query: String, appending: Bool = false) {
        task?.cancel()
        task = Task {
            do {
                let response = try await TubeApp.client.search(query: query, page: page)
                await MainActor.run {
                    done = response.count == 0
                    if appending {
                        results.append(contentsOf: response)
                    } else {
                        results = response
                    }
                }
            } catch {
                print(error)
            }
            task = nil
        }
    }

    func nextPage(query: String) {
        page += 1
        handleUpdate(query: query, appending: true)
    }
}

struct SearchResultsView: View {
    @Binding var query: String
    var model = SearchResultsViewModel()

    var body: some View {
        if !query.isEmpty {
            ScrollView {
                LazyVStack {
                    if model.results.isEmpty {
                        ProgressView()
                    } else {
                        ContentGridView {
                            ForEach(model.results) { result in
                                switch result {
                                case .video(let video):
                                    VideoGridItem(
                                        id: video.videoId,
                                        title: video.title,
                                        author: video.author,
                                        authorId: video.authorId,
                                        duration: video.lengthSeconds,
                                        published: video.publishedText,
                                        thumbnails: video.videoThumbnails
                                    )
                                case .channel(let channel):
                                    NavigationLink(value: NavigationDestination.channel(channel.authorId)) {
                                        ImageView(width: 64, height: 64, images: channel.authorThumbnails)
                                        VStack(alignment: .leading) {
                                            Text(channel.author)
                                            Text("\(channel.subCount.formatted()) subscribers").font(.callout)
                                                .foregroundStyle(.secondary)
                                            FollowButton(channelId: channel.authorId, channelName: channel.author)
                                        }
                                    }.buttonStyle(.plain)
                                case .playlist(let playlist):
                                    PlaylistItemView(id: playlist.playlistId, title: playlist.title, author: playlist.author, videoCount: playlist.videoCount)
                                }
                            }
                        }
                    }
                }.padding()
            }
            .background(.windowBackground)
            .onChange(of: query) { _, _ in
                model.handleUpdate(query: query)
            }
        }
    }
}

// #Preview {
//    SearchResultsView()
// }
