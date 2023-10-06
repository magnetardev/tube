import SwiftUI

struct MessageBlock: View {
    var title: String
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(title).font(.headline)
            Text(message)
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity).padding().background(.quinary).cornerRadius(8.0)
    }
}

#Preview {
    LazyVStack {
        Section {
            MessageBlock(title: "Example", message: "Lorem ipsum dolor sunt")
        }
    }.padding()
}
