const otherNumberButton = document.querySelector('#number-replace-button')

function doSubmit () {
  const otherNumberForm = document.querySelector('#number-replace-form')
}

function showField (ev) {
  ev.preventDefault()

  const toShow = document.querySelector('#number-replacement-field')
  toShow.style.display = 'block'

  otherNumberButton.innerText = 'Change my number'

  otherNumberButton.removeEventListener('click', showField)
  otherNumberButton.addEventListener('click', doSubmit)
}

otherNumberButton.addEventListener('click', showField)
