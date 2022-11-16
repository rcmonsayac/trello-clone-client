onmount('#flash', () => {
  let flashBox = document.querySelector('#flash')
  let successAlert = document.querySelector('.success.alert')

  let closeButton = flashBox.querySelector('.close')

  if (successAlert != null) {
    setTimeout(() => hideFlash(flashBox), 3000)
  }

  if (closeButton != null) {
    closeButton.addEventListener('click', e => {
      hideFlash(flashBox)
    });
  }

})


const hideFlash = flashBox => {
  if (flashBox.style.display !== 'none') flashBox.style.display = 'none'
}
