window.onload = function() {
  var searchInput = findBy('#search-input');
  var postList = findBy('#posts');

  searchInput.addEventListener('keyup', function() {
    var keyword = this.value.toString().trim();
    var pattern = new RegExp(keyword, 'gi');
    var matchedCount = 0;

    toggleClass(postList, 'hidden', !keyword);

    window.collections.posts.forEach(function(post) {
      var postElement = findBy('[data-id="' + post.slug + '"]');
      var isMatched = post.title.match(pattern) || post.excerpt.match(pattern);

      matchedCount += isMatched ? 1 : 0;
      toggleClass(postElement, 'hidden', !isMatched || !keyword || matchedCount > 4);
    });

    var postCount = queryAll('#posts .post:not(.hidden)').length;
    var emptyPost = findBy('#posts .no-result-found');

    toggleClass(emptyPost, 'hidden', postCount > 0);
  });

  searchInput.focus();
}
