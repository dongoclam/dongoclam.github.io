function findBy(selector) {
  return document.querySelector(selector);
}

function queryAll(selector) {
  return document.querySelectorAll(selector);
}

function toggleClass(element, className, state) {
  state ? element.classList.add(className) : element.classList.remove(className);
}
