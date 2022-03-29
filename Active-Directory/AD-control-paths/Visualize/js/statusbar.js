var Vizu = Vizu || {};

Vizu.Statusbar = function(graph, nodes, edges) {
  var
   container = document.getElementById('statusbar'),
   link = document.getElementById('toggleStatusbar'),
   visibleStatus = document.getElementById('visible-status'),
   selectionContainer = document.getElementById('selection-status'),
   selectionDetailsContainer = document.getElementById('selectionDetails'),
   visibleStatusHTML = visibleStatus.innerHTML,
   // this var avoids updating the selection panel when we are displaying a path
   showPath = false
  ;

  var linkClick = function (e) {
    e.preventDefault();
    container.classList.toggle('open');
  };

  container.addEventListener('mousedown', function (e) {
    e.stopPropagation();
  }, false);
  link.addEventListener('click', linkClick.bind(this), false);

  var createElementFromNode = function(node) {
    var el = document.createElement('span');
    el.classList.add('status');
    el.classList.add(node.baseGroup);
    el.textContent = node.title;

    return el;
  };
  
  var createElementFromCluster = function(node) {
	var containedNodes = graph.network.body.nodes[node.id].containedNodes;
	var elCluster = document.createElement('div');
	for (var containedNodeId in containedNodes) {
		var el = document.createElement('span');
        el.classList.add('status');
        el.classList.add(node.baseGroup);
		var containedNode = graph.network.body.data.nodes.get(containedNodeId);
		el.textContent = containedNode["title"];
		elCluster.appendChild(el);
	}

    return elCluster;
  };
  this.update = function(object) {
    visibleStatus.innerHTML = '';
    var el;
    if (object.node) {
      if (graph.network.isCluster(object.node)) {

        el = createElementFromCluster(graph.network.body.nodes[object.node].options);

      } else {
        var node = nodes.get(object.node);
        el = createElementFromNode(node);
      }
      visibleStatus.appendChild(el);
    }
    if (object.edge) {
      var nodeIds = graph.network.getConnectedNodes(object.edge),
        edge = edges.get(object.edge);
      // if source or target node is a cluster, look for the original link & objects
      if (graph.network.isCluster(nodeIds[0]) || graph.network.isCluster(nodeIds[1])) {
        var originalId = graph.network.body.edges[object.edge].clusteringEdgeReplacingId;
        edge = edges.get(originalId);
      }
      var
        sourceEl = createElementFromNode({baseGroup: edge.data.fromBaseGroup, title: edge.data.fromShortName}),
        targetEl = createElementFromNode({baseGroup: edge.data.toBaseGroup, title: edge.data.toShortName}),
        propsEl = document.createElement('span');
      var firstArrow = '&#8594;';
      if ("double" === edge.data.type) {
        firstArrow = '&#8592;';
      }
      propsEl.innerHTML = ' ' + firstArrow + ' [ ' + edge.data.rels.join(', ') + ' ] &#8594; ';

      visibleStatus.appendChild(sourceEl);
      visibleStatus.appendChild(propsEl);
      visibleStatus.appendChild(targetEl);
    }
  };

  this.deselectObject = function() {
    showPath = false;
  };

  this.selectObject = function(o) {
    showPath = false;
    visibleStatusHTML = visibleStatus.innerHTML;
  };

  this.reset = function(resetSelection) {
    if (true === resetSelection) {
      visibleStatusHTML = '';
    }
    visibleStatus.innerHTML = visibleStatusHTML;
    this.updateSelectionDetails();
  };

  this.updateSelectionDetails = function() {
    if (showPath) {
      return;
    }
    selectionContainer.innerHTML = '';
    selectionDetailsContainer.innerHTML = '';
    var selectedEdges = graph.network.getSelectedEdges(),
      selectedNodes = graph.network.getSelectedNodes(),
      text = 'Selection:';

    if (selectedNodes.length > 0) {
      text += ' ' + selectedNodes.length + ' node' + (selectedNodes.length > 1 ? 's' : '');
    }
    if (selectedEdges.length > 0) {
      text += ' ' + selectedEdges.length + ' edge' + (selectedEdges.length > 1 ? 's' : '');
    }
    if (selectedNodes.length > 0 || selectedEdges.length > 0) {
      selectionContainer.textContent = text;
    }

    for (var i = 0; i < selectedNodes.length; i++) {
      var nodeId = selectedNodes[i];
      if (graph.network.isCluster(nodeId)) {
        // TODO find all nodes inside
      } else {
        var node = nodes.get(nodeId),
          el = createElementFromNode(node);
        selectionDetailsContainer.appendChild(el);
      }
    }
  };

  this.setPath = function(pathNodes, pathEdges) {
    showPath = true;
    selectionDetailsContainer.innerHTML = '';
    pathNodes.reverse();
    pathEdges.reverse();
    for (var i = 0; i < pathNodes.length; i++) {
      var node = nodes.get(pathNodes[i]),
        edge = i == pathEdges.length ? null : edges.get(pathEdges[i]),
        nodeEl = createElementFromNode(node);

      selectionDetailsContainer.appendChild(nodeEl);
      if (edge) {
        var edgeEl = document.createElement('span'),
          firstArrow = '&#8594;';
          if ("double" === edge.data.type) {
            firstArrow = '&#8592;';
          }
        edgeEl.innerHTML = ' ' + firstArrow + ' [ ' + edge.data.rels.join(', ') + ' ] &#8594; ';
        selectionDetailsContainer.appendChild(edgeEl);
      }

    }
  };

};
