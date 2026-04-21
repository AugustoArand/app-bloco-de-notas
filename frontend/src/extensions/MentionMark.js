import { Mark, mergeAttributes, markInputRule } from '@tiptap/core'

// Converts @word (followed by a space) into a mention mark.
// The trailing space that triggers the rule is consumed; type a space
// after the mention to continue writing normally.
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

  // Typing "@word " applies the mention mark to "@word"
  addInputRules() {
    return [
      markInputRule({
        find: /(@[\wÀ-ſ]+)\s$/,
        type: this.type,
        getAttributes: match => ({
          label: (match[match.length - 1] || '').slice(1),
        }),
      }),
    ]
  },
})
