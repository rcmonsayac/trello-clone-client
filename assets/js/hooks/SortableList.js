import Sortable from 'sortablejs'
import { Decimal } from 'decimal.js'

const SortableList = {
  mounted() {
    const _this = this
    const ghostClass = _this.el.dataset.ghostClass || '_ghost'
    const group = _this.el.dataset.group || ""
    const disabled = !([true, "true"].includes(this.el.dataset.enabled))
    console.log(this.el.dataset.enabled)
    console.log(disabled)

    Sortable.create(this.el, {
      ghostClass,
      handle: '._handle',
      filter: '._ignore ',
      chosenClass: "sortable-chosen", 
      group: group,
      preventOnFilter: false,
      animation: 150,
      disabled: disabled,
      onEnd(e) {
        const el = e.item
        const resourceId = el.dataset.resourceId
        const type = el.dataset.type
        const sortableListId = e.to.dataset.sortableListId
        console.log(e.to)
        let next = null
        let prev = null
        let position = null

        if(e.to == e.from) {
          console.log("test")
          const index = e.newDraggableIndex
          const list = this.toArray()

          next = list[index + 1]
          prev = list[index - 1]
          if (index == e.oldDraggableIndex) {
            // skip if same
            return
          } else if (prev && !next) {
            // last
            prev = new Decimal(prev)
            position = prev.add(1)
          } else if (prev == null && next != null) {
            // first
            next = new Decimal(next)
            position = next.div(2)
          } else if (prev != null && next != null) {
            // in-between
            prev = new Decimal(prev)
            next = new Decimal(next)
            position = prev.add(next).div(2)
          }
        } else {
          prev = el.previousElementSibling;
          next = el.nextElementSibling;
         if (prev && !next) {
          // last
            prev = new Decimal(prev.dataset.id)
            position = prev.add(1)
          } else if (!prev&& next) {
            // first
            next = new Decimal(next.dataset.id)
            position = next.div(2)
          } else if (prev && next) {
            // in-between
            prev = new Decimal(prev.dataset.id)
            next = new Decimal(next.dataset.id)
            position = prev.add(next).div(2)
          }
          else{
            position = 1
          }
        }

        if (position != null) {
          position = position.toString()
          _this.pushEvent('reorder', { type, resourceId, position, sortableListId })
        }
      },
    })
  },
}


export { SortableList }