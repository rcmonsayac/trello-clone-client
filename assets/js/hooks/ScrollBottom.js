const ScrollBottom = {
  mounted() {
    this.triggerScrollBottom()
  },
  updated() {
    this.triggerScrollBottom()
  },
  triggerScrollBottom() {
    const div = this.el
    div.scrollTop = div.scrollHeight;
  }
}

export { ScrollBottom }