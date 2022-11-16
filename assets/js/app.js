// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import topbar from "topbar"
import { LiveSocket } from "phoenix_live_view"
import { LiveFlash } from './hooks/LiveFlash'
import { ModalClose } from './hooks/ModalClose'
import { Dropdown } from './hooks/Dropdown'
import { Focus } from './hooks/Focus'
import { SortableList } from './hooks/SortableList'
import { ScrollBottom } from './hooks/ScrollBottom'


window.onmount = require('onmount')
function requireAll(r) {
  r.keys().forEach(r)
}
requireAll(require.context('./behaviours/', true, /\.js$/))
onmount()

let hooks = {}
hooks.LiveFlash = LiveFlash
hooks.ModalClose = ModalClose
hooks.Dropdown = Dropdown
hooks.Focus = Focus
hooks.SortableList = SortableList
hooks.ScrollBottom = ScrollBottom

hooks.ConfirmDialog = {
  mounted() {
    const button = this.el
    const message = button.dataset.message
    button.addEventListener('click', event => {
      if (!confirm(message)) {
        event.preventDefault()
        event.stopImmediatePropagation()
      }
    })
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket