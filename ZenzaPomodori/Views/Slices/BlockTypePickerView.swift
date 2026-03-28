import SwiftUI

struct BlockTypePickerView: View {
    @Binding var blockType: BlockType

    var body: some View {
        Picker("Block Type", selection: $blockType) {
            Text("Regular").tag(BlockType.regular)
            Text("Slices").tag(BlockType.slices)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}
