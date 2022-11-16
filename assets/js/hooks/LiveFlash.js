import { DOM } from 'phoenix_live_view'
const PHX_RAND = 'phx-rand'

const LiveFlash = {
  mounted() {
    this.flash = document.getElementById('flash')
    const hideFlash = this.hideFlash
    const _this = this
    this.hideHandler = {
      handleEvent() {
        hideFlash.bind(_this)()
      },
    }
    this.render()
    this.attachListeners()
  },
  updated() {
    this.removeListeners()
    this.reset()
    this.render()
    this.attachListeners()
  },
  render() {
    const type = this.el.dataset.flashType
    const message = this.el.dataset.flashMessage

    if (type == null || this.flash == null) return
    switch (type) {
      case 'success':
      case 'info':
        this.flash.innerHTML = `
        <div class="alert success animated fade-in" >
          <div class="close cursor-pointer flex justify-center items-center w-full h-20 p-2 bg-green-500 rounded shadow-lg text-white" title="close">
            <span role="alert">${message}</span>
            <svg class="fill-current text-white flex justify-center items-center absolute top-5 right-5" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 18 18">
              <path d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"></path>
            </svg>
          </div>
        </div>
      `
        break
      case 'error':
        this.flash.innerHTML = `
        <div class="alert error animated fade-in" >
          <div class="close cursor-pointer flex justify-center items-center w-full h-20 p-2 bg-red-500 rounded shadow-lg text-white" title="close">
            <span role="alert">${message}</span>
            <svg class="fill-current text-white flex justify-center items-center absolute top-5 right-5" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 18 18">
              <path d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"></path>
            </svg>
          </div>
        </div>
          `
        this.flash.firstElementChild.focus()
        break
      default:
        break
    }
    if (flash.style.display === 'none') flash.style.display = 'initial'
  },
  attachListeners() {
    let successAlert = this.flash.querySelector('.alert.success')

    if (successAlert != null) {
      this.hideTimeout = setTimeout(() => this.hideFlash(), 3000)
    }

    let closeButton = this.flash.querySelector('.close')

    if (closeButton) {
      closeButton.addEventListener('click', this.hideHandler)
    }
  },
  removeListeners() {
    if (this.hideTimeout != null) {
      window.clearTimeout(this.hideTimeout)
    }

    let closeButton = this.flash.querySelector('.close')

    if (closeButton) {
      closeButton.removeEventListener('click', this.hideHandler)
    }
  },
  reset() {
    if (this.flash) this.flash.innerHTML = ''
    let flashBox = document.querySelector('.flash-box')
    if (flashBox.classList.contains('_hidden')) {
      flashBox.classList.remove('_hidden')
    }
  },
  hideFlash() {
    if (this.flash) this.flash.innerHTML = ''
    let flashBox = document.querySelector('.flash-box')
    if (!flashBox.classList.contains('_hidden')) {
      flashBox.classList.add('_hidden')
    }
  },
}

export { LiveFlash }
