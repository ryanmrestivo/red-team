var Vizu = Vizu || {};

Vizu.SearchBox = function(graph, nodes) {
  var
    searchElem = document.getElementById('searchBox'),
    inputField = document.getElementById('searchInput'),
    closeButton = document.getElementById('searchClose'),
    results = document.getElementById('searchResults'),
    progressing = false
  ;

  var onKeyDown = function(e) {
    if (e.ctrlKey && e.keyCode == 70) {
      e.preventDefault();
      show();
    }
  };

  var show = function() {
    searchElem.style.display = 'block';
    inputField.focus();
  };

  var close = function() {
    searchElem.style.display = 'none';
  };

  var searchKeyDown = function(e) {
    if (progressing) {
      window.clearTimeout(progressing);
    }
    if (e.keyCode === 27) {
      close();
      return;
    }
    progressing = window.setTimeout(searchInGraph, 300);
  };

  var createElement = function(node, searchValue) {
    var div = document.createElement('div');
    var title = node.title,
      pos = title.indexOf(searchValue),
      htmlTitle = node.title.substring(0, pos) + '<b>' + searchValue + '</b>' + node.title.substring(pos + searchValue.length);
    div.innerHTML = htmlTitle;
    div.addEventListener('click', searchItemClick.bind(this, node));

    return div;
  };

  var searchItemClick = function(node, e) {
    e.preventDefault();
    graph.network.selectNodes([node.id]);
    graph.neighbourhoodHighlight({
      nodes: [node.id],
      edges: []
    });
    graph.network.focus(node.id, {
      scale: 1.2,
      animation: {
        duration: 500,
        easingFunction: 'easeInOutCubic'
      }
    });
  };

  var searchInGraph = function() {
    var searchValue = inputField.value,
      matchingNodes = nodes.get({
      filter: function(item) {
        return item.title.indexOf(searchValue) !== -1;
      }
    });
    results.innerHTML = '';
    if (searchValue.length < 1) {
      return;
    }
    if (0 === matchingNodes.length) {
      results.innerHTML = 'No result.';
      return;
    }
    matchingNodes.sort(function(a, b) {
      return a.title.indexOf(searchValue) - b.title.indexOf(searchValue);
    });
    for (var i = 0; i < matchingNodes.length; i++) {
      var element = createElement(matchingNodes[i], searchValue);
      results.appendChild(element);
    }
    setSelection(matchingNodes);
  };

  var setSelection = function(matchingNodes) {
    var selectNodes = matchingNodes.map(function(node) {
      return node.id;
    });
    graph.network.setSelection({
      nodes: selectNodes
    }, {
      highlightEdges: false
    });
    graph.neighbourhoodHighlight({
      nodes: selectNodes,
      edges: []
    });
  }

  inputField.addEventListener('keydown', searchKeyDown);
  window.addEventListener('keydown', onKeyDown);
  closeButton.addEventListener('click', function(e) {
    e.preventDefault();
    close();
  });

}