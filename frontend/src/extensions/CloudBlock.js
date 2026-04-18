import { Node, mergeAttributes } from '@tiptap/core'
import { Plugin, PluginKey } from '@tiptap/pm/state'
import { Decoration, DecorationSet } from '@tiptap/pm/view'

const cloudPluginKey = new PluginKey('cloudBlock')

const CloudBlock = Node.create({
  name: 'cloudBlock',
  group: 'block',
  content: 'block+',
  defining: true,

  parseHTML() {
    return [
      { tag: 'div[data-type="cloud-block"]' },
      { tag: 'div.cloud-wrap', contentElement: '.cloud-body' },
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return [
      'div',
      mergeAttributes(HTMLAttributes, {
        'data-type': 'cloud-block',
        class: 'cloud-block',
      }),
      0,
    ]
  },

  addCommands() {
    return {
      toggleCloudBlock:
        () =>
        ({ commands }) => {
          return commands.toggleWrap('cloudBlock')
        },
    }
  },

  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: cloudPluginKey,
        props: {
          decorations(state) {
            const decorations = []
            const { from, to } = state.selection
            state.doc.descendants((node, pos) => {
              if (node.type.name === 'cloudBlock') {
                const nodeEnd = pos + node.nodeSize
                if (from >= pos && to <= nodeEnd) {
                  decorations.push(
                    Decoration.node(pos, nodeEnd, { class: 'cloud-active' })
                  )
                }
              }
            })
            return DecorationSet.create(state.doc, decorations)
          },
        },
      }),
    ]
  },
})

export default CloudBlock
