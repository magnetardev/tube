import InvidiousKit
import Observation
import SwiftData
import SwiftUI

struct FeedView: View {
    @State var search: String = ""
    @Query(sort: \FollowedChannel.name) var channels: [FollowedChannel]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if channels.isEmpty {
                    MessageBlock(
                        title: "You aren't following any channels.",
                        message: "Search for channels you'd like to follow."
                    ).padding(.horizontal)
                } else {
                    ForEach(channels) { channel in
                        FollowedChannelFeedView(channel: channel)
                    }
                }
            }.padding(.vertical)
        }
        .navigationTitle("Feed")
        .searchable(text: $search)
        .overlay {
            SearchResultsView(query: $search)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(value: NavigationDestination.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}
