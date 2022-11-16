const ModalClose = {
  mounted() {
    const container = this.el
    this.hideContainer = e => {
      container.style.animation = "slide-out 0.5s forwards"
      setTimeout(e => { this.pushEvent('close_modal', {})}, 400);   
    }
    this.windowListener = e => {
      if (!container.contains(e.target) 
        && !e.target.classList.contains("modal-button") 
        && !e.target.parentElement.classList.contains("modal-button")) {
          
        this.hideContainer()      
      }
      this.render()
    }

    this.windowKeyListener = e => {
      if (e.keyCode == 27) {
        this.hideContainer()  
      }
    }

    this.handleEvent("close_modal", (_payload) => {
        this.hideContainer()
    })

    this.initialize()
  },
  destroyed() {
    if (this.windowListener) {
      window.removeEventListener('mousedown', this.windowListener, false)
      window.removeEventListener('keydown', this.windowKeyListener, false)
    }
  },
  initialize() {
    if (this.windowListener) {
      window.removeEventListener('mousedown', this.windowListener)
      window.removeEventListener('keydown', this.windowKeyListener)
    }

    this.render()
  },
  render() {
    window.addEventListener('mousedown', this.windowListener)
    window.addEventListener('keydown', this.windowKeyListener)
  },
}

export { ModalClose }
