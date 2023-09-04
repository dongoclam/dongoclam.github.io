window.onload = function() {
  var searchInput = findBy('#search-input');
  var tabItems = queryAll('#navbar .tab-item');

  tabItems.forEach(function(tabItem) {
    tabItem.addEventListener('click', function() {
      var target = this.dataset.target;
      var tabContents = queryAll('.home-page .tab-content');

      tabContents.forEach(function(tabContent) {
        toggleClass(tabContent, 'active', tabContent.id == target);
      });

      tabItems.forEach(function(tabItem) {
        toggleClass(tabItem, 'active', tabItem.dataset.target == target);
      });
    });
  });

  searchInput.addEventListener('keyup', function() {
    var pattern = new RegExp(this.value, 'gi');

    window.collections.posts.forEach(function(post) {
      var postElement = findBy('[data-id="' + post.slug + '"]');
      var isMatched = post.title.match(pattern) || post.excerpt.match(pattern);

      toggleClass(postElement, 'hidden', !isMatched);
    });

    window.collections.categories.forEach(function(category) {
      var categoryElement = findBy('[data-id="' + category + '"]');
      var isMatched = category.match(pattern);

      toggleClass(categoryElement, 'hidden', !isMatched);
    });

    var postCount = queryAll('#tab-posts .post:not(.hidden)').length;
    var categoryCount = queryAll('#tab-categories .category:not(.hidden)').length;

    findBy('#post-count').innerHTML = postCount;
    findBy('#category-count').innerHTML = categoryCount;

    var emptyPost = findBy('#tab-posts .no-result-found');
    var emptyCategory = findBy('#tab-categories .no-result-found');

    toggleClass(emptyPost, 'hidden', postCount > 0);
    toggleClass(emptyCategory, 'hidden', categoryCount > 0);
  });
}
