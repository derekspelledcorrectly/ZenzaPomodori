import SwiftUI

struct BlockTypePickerView: View {
    @Binding var blockType: BlockType

    var body: some View {
        Picker("Block Type", selection: $blockType) {
            Text("Focus").tag(BlockType.focus)
            Text("Slices").tag(BlockType.slices)
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
        .labelsHidden()
    }
}
