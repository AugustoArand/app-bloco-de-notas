import { Extension, InputRule } from '@tiptap/core'

// Replaces "->" with "→" as you type in the Tiptap editor.
export default Extension.create({
  name: 'arrowShortcut',

  addInputRules() {
    return [
      new InputRule({
        find: /->$/,
        handler: ({ state, range }) => {
          state.tr.replaceWith(range.from, range.to, state.schema.text('→'))
        },
      }),
    ]
  },
})
