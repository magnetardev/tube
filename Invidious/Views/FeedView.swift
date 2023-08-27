import InvidiousKit
import Observation
import SwiftData
import SwiftUI

@Observable
final class FollowingViewModel {
    var videos: [VideoObject] = []
    var loading: Bool = false
    var error: Error?

    func load(channels: [FollowedChannel]) async {
        loading = true
        error = nil
        do {
            videos = try await withThrowingTaskGroup(of: Channel.VideosResponse.self, returning: [VideoObject].self) { taskGroup in
                for channel in channels {
                    taskGroup.addTask {
                        try await TubeApp.client.videos(for: channel.id, continuation: nil)
                    }
                }

                var childTaskResults = [VideoObject]()
                for try await result in taskGroup {
                    childTaskResults.append(contentsOf: result.videos)
                }
                return childTaskResults.sorted { $0.published > $1.published }
            }
        } catch {
            self.error = error
        }
        loading = false
    }
}

struct FeedView: View {
    var model = FollowingViewModel()
    @Query() var channels: [FollowedChannel]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Section {
                    if channels.isEmpty {
                        VStack {
                            Spacer()
                            Text("You aren't following any channels.").font(.headline)
                            Text("Search for channels you'd like to follow.")
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity).padding().background(.quinary).cornerRadius(8.0)
                    } else {
                        ContentGridView {
                            ForEach(model.videos, id: \.videoId) { video in
                                VideoGridItem(
                                    id: video.videoId,
                                    title: video.title,
                                    author: video.author,
                                    authorId: video.authorId,
                                    duration: video.lengthSeconds,
                                    published: video.publishedText,
                                    thumbnails: video.videoThumbnails
                                )
                            }
                        }.task {
                            await model.load(channels: channels)
                        }.refreshable {
                            await model.load(channels: channels)
                        }
                    }
                } header: {
                    Text("Following").font(.title3).fontWeight(.medium)
                }
            }.padding()
        }.navigationTitle("Feed")
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}
