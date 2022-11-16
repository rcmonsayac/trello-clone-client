import { createPopper } from '@popperjs/core';

const Dropdown = {
  mounted() {
    const dropdown = this.el
    const target = this.el.dataset.target
    const trigger = dropdown.querySelector(this.el.dataset.trigger)
    
    this.popper = this.addPopper()
    this.popper.update()
    
    this.windowListener = {
      handleEvent(e) {
        const content = dropdown.querySelector(target)
        if (e.target === trigger || trigger.contains(e.target)) return

        if (!content.classList.contains("hidden")) {
          content.classList.add('hidden')
        }
      },
    }

    window.addEventListener('mouseup', this.windowListener, false)

    window.addEventListener('keydown', event => {
      if (event.key == "Escape") {
        const content = dropdown.querySelector(target)
        content.classList.add('hidden')
      }
    })

    this.dropdownListener = e => {
      const content = dropdown.querySelector(target)
      if (content.classList.contains('hidden')) {
        content.classList.remove('hidden')
        this.popper.update()
      } else {
        content.classList.add('hidden')
      }
    }

    trigger.addEventListener('click', this.dropdownListener, false)
  },
  updated() {
    this.popper.update()
  },
  addPopper(){
    const dropdown = this.el
    const dropdownMenu = dropdown.querySelector(this.el.dataset.target)
    const button = dropdown.querySelector(this.el.dataset.trigger)

    return createPopper(button, dropdownMenu, {
      placement: 'bottom'
    })
  },
  destroyed() {
    if (this.windowListener)
      window.removeEventListener('mouseup', this.windowListener, false)
  },
}


export { Dropdown }