window.onload = function() {
  var scrollToTop = findBy('#scrollToTop');
  var scrollToBottom = findBy('#scrollToBottom');

  scrollToTop.addEventListener('click', function() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });

  scrollToBottom.addEventListener('click', function() {
    window.scrollTo({
      top: document.documentElement.scrollHeight,
      behavior: 'smooth'
    });
  });

  var headings = queryAll('#toc a');
  var currentActiveHeading = headings[0];
  var tocContent = findBy('.post-content-sections');

  window.addEventListener('scroll', function() {
    var scrollY = window.scrollY;
    var currentOffset = scrollY;

    var toggleScroll = scrollY > 200 ? 'add' : 'remove';
    tocContent.classList[toggleScroll]('toc-scroll');

    var pageHeight = findBy("body").clientHeight;
    var toggleBottom = scrollY + window.innerHeight + 350 > pageHeight ? 'add' : 'remove';
    tocContent.classList[toggleBottom]('toc-bottom');

    headings.forEach(function(heading) {
      var targetId = heading.getAttribute('href');
      var headingElement = findBy(targetId);
      var offset = headingElement.offsetTop - scrollY;

      if (offset >= 0 && offset <= currentOffset) {
        currentOffset = offset;
        currentActiveHeading = heading;
      }

      heading.classList.remove('active');
    });

    if (currentActiveHeading) {
      currentActiveHeading.classList.add('active');
    }
  });

  window.dispatchEvent(new CustomEvent('scroll'));
};
