import { Mark, mergeAttributes, markInputRule, InputRule } from '@tiptap/core'

// Two trigger patterns:
//   @palavra     → space-terminated, single word (space is consumed)
//   @[palavras compostas] → bracket-terminated, any text (brackets are consumed,
//                           displayed as "@palavras compostas")
export default Mark.create({
  name: 'mention',

  priority: 1000,

  addAttributes() {
    return {
      label: {
        default: null,
        parseHTML: el => el.getAttribute('data-mention'),
        renderHTML: attrs => ({ 'data-mention': attrs.label }),
      },
    }
  },

  parseHTML() {
    return [{ tag: 'span[data-mention]' }]
  },

  renderHTML({ HTMLAttributes }) {
    return ['span', mergeAttributes(HTMLAttributes, { class: 'mention' }), 0]
  },

  addInputRules() {
    return [
      // @word<space> — single word, trailing space consumed
      markInputRule({
        find: /(@[\wÀ-ſ]+)\s$/,
        type: this.type,
        getAttributes: match => ({
          label: (match[match.length - 1] || '').slice(1),
        }),
      }),

      // @[compound mention] — brackets consumed, displayed as "@compound mention"
      new InputRule({
        find: /@\[([^\]]+)\]$/,
        handler: ({ state, range, match }) => {
          const label = match[1]
          const { tr, schema } = state
          tr.replaceWith(
            range.from,
            range.to,
            schema.text(`@${label}`, [this.type.create({ label })])
          )
          tr.removeStoredMark(this.type)
        },
      }),
    ]
  },
})
