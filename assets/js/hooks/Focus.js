const Focus = {
  mounted() {
    this.triggerFocus()

  },
  updated() {
    this.triggerFocus()
  },
  triggerFocus() {
    const input = this.el
    const focus = input.dataset.focus
    
    if (input != null && focus) {
      const value = input.value
      input.value = ''
      input.focus()
      input.value = value
    }
  },
}

export { Focus }