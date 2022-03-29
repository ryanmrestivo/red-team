var Vizu = Vizu || {};

Vizu.ContextMenu = function (container, graph) {
  this.container = document.getElementById(container);
  // some subcontexts...
  this.subContextCluster = document.getElementById('subContextCluster');
  this.subContextTag = document.getElementById('subContextTag');
  this.subContextUntag = document.getElementById('subContextUntag');
  this.subContextSelectTag = document.getElementById('subContextSelectTag');

  this.links = this.container.getElementsByTagName('li');

  this.graph = graph;
  this.height = 0;
  this.width = 0;

  var tagList = new Vizu.TagList();

  this.show(0, 0);
  this.height = this.container.offsetHeight;
  this.width = this.container.offsetWidth;
  this.hide();

  var linkListener = function (e) {
    e.preventDefault();
    this.hide();
    graph.resetNodeStyle(graph.network.body.nodes);
    graph.statusbar.reset();
  };
  
   /**
   * Generate Cypher relation deletion command to clipboard
   */
  var cypherDelListener = function () {
    var selectedNodes = graph.network.getSelectedNodes(),
      selectedEdges = graph.network.getSelectedEdges(),
      nodes = graph.network.body.data.nodes["_data"],
      edges = graph.network.body.data.edges["_data"];
    var output = "MATCH ";
	if(selectedNodes.length > 0) {
		output = output.concat("(n)-[r]-(m) WHERE n.name = \"",nodes[selectedNodes[0]]["title"],"\" DELETE r,n;");
	}
	else {
      for (var j = 0; j < selectedEdges.length; j++) {
        var edge = edges[selectedEdges[j]];
        var from = nodes[edge["from"]]["title"];
        var to = nodes[edge["to"]]["title"];
        var title = edge["title"];
	    title = title.replace(/<br>/g,"|");
        output = output.concat("p=({name:\"", from, "\"})-[rel:", title, "]-({name:\"", to, "\"}) DELETE rel;\n");
      }
	}

    cText = output.replace(/\n\r?/g, "<br>");

    var editableDiv = document.getElementById("cb");

    with (editableDiv) {
        contentEditable = true;
    }
    editableDiv.innerHTML = cText;

    // select the editable content and copy it to the clipboard
    var range = document.createRange();
    var selection = window.getSelection();
    range.selectNodeContents(editableDiv);
    selection.removeAllRanges();
    selection.addRange(range);
    document.execCommand("Copy");
    selection.removeAllRanges();
  };

  /**
   * Copy selection to clipboard
   */
  var clipboardListener = function () {
    var selectedNodes = graph.network.getSelectedNodes(),
      selectedEdges = graph.network.getSelectedEdges(),
      nodes = graph.network.body.data.nodes["_data"],
      edges = graph.network.body.data.edges["_data"];
    var output = "Nodes:\n";
	if(graph.network.isCluster(selectedNodes)) {
		var containedNodes = graph.network.body.nodes[selectedNodes].containedNodes;
		for (var containedNodeId in containedNodes) {
		  var containedNode = graph.network.body.data.nodes.get(containedNodeId);
		  output = output.concat(containedNode["title"],"\n");
		}
	}
	else {
    for (var i = 0; i < selectedNodes.length; i++) {
      output = output.concat(nodes[selectedNodes[i]]["title"],"\n");
    }	
    output = output.concat("\nRelationships:\n");
    for (var j = 0; j < selectedEdges.length; j++) {
      var edge = edges[selectedEdges[j]];
      var from = nodes[edge["from"]]["title"];
      var to = nodes[edge["to"]]["title"];
      var title = edge["title"];
      output = output.concat("(", from, ")-[", title, "]-(", to, ")\n");
    }
	}

    cText = output.replace(/\n\r?/g, "<br>");

    var editableDiv = document.getElementById("cb");

    with (editableDiv) {
        contentEditable = true;
    }
    editableDiv.innerHTML = cText;

    // select the editable content and copy it to the clipboard
    var range = document.createRange();
    var selection = window.getSelection();
    range.selectNodeContents(editableDiv);
    selection.removeAllRanges();
    selection.addRange(range);
    document.execCommand("Copy");
    selection.removeAllRanges();
  };

  /**
   * Delete selection (nodes & edges)
   */
  var delListener = function () {
    var selectedNodes = graph.network.getSelectedNodes(),
      selectedEdges = graph.network.getSelectedEdges(),
      nodes = graph.network.body.data.nodes,
      edges = graph.network.body.data.edges;

    var removeNodes = [];
    for (var i = 0; i < selectedNodes.length; i++) {
      removeNodes.push({id: selectedNodes[i]});
    }
    var removeEdges = [];
    for (var j = 0; j < selectedEdges.length; j++) {
      removeEdges.push({id: selectedEdges[j]});
    }
    // we will need to log that!
    nodes.remove(removeNodes);
    edges.remove(removeEdges);
  };

  /**
   * Fix selection position on the canvas
   */
  var fixListener = function () {
    var selectedNodes = graph.network.getSelectedNodes(),
      nodes = graph.network.body.data.nodes,
      updateNodes = [];
    for (var i = 0; i < selectedNodes.length; i++) {
      var selected = nodes.get(selectedNodes[i]);
      if (selected.physics !== undefined) {
        updateNodes.push({id: selected.id, physics: !selected.physics});
      } else {
        updateNodes.push({id: selected.id, physics: false});
      }
    }
    nodes.update(updateNodes);
  };

  /**
   * Clusterize a node
   * @param object config the cluster type configuration
   * @param Event e original event
   */
  var clusterLinkClick = function (config, e) {
    var selection = graph.network.getSelectedNodes();
    for (var i = 0; i < selection.length; i++) {
      var nodeId = selection[i],
        node = graph.network.body.data.nodes.get(nodeId);
      if (config.uncluster && graph.network.isCluster(nodeId)) {
        graph.network.openCluster(nodeId);
        continue;
      }
      if (graph.network.isCluster(nodeId)) {
        continue;
      }
      if (config.type && config.type !== node.baseGroup) {
        continue; // we wont treat non matching node
      }
      graph.network.clusterByConnection(nodeId, {
//      graph.network.cluster({
        clusterNodeProperties: {
          group: node.baseGroup,
          baseGroup: node.baseGroup,
          label: node.label || '    ' + Vizu.options.network.groups[node.baseGroup].label + '    ', //'    ' + (node.label ? node.label : Vizu.options.groups[node.baseGroup].label) + '    ',
          shape: 'box',
          shapeProperties: {
            borderRadius: 3
          },
          title: node.title,
          level: node.level
        },
        joinCondition: function (n1, n2) {
          if (config.clusterType && n2.baseGroup !== config.clusterType) {
            return false; // return early if type is not good
          }
          // return early, if we don't need to check relations on the node then it's ok i guess
          if (!config.clusterRelations) {
            return true;
          }
          // search for the edge and check his properties
          var edges = graph.network.getConnectedEdges(n1.id);
          for (var i = 0; i < edges.length; i++) {
            if (graph.network.getConnectedNodes(edges[i]).indexOf(parseInt(n2.id)) !== -1) {
              var edge = graph.network.body.data.edges.get(edges[i]);
              for (var j = 0; j < config.clusterRelations.length; j++) {
                if (edge.data.rels.indexOf(config.clusterRelations[j]) === -1) {
                  return false;
                }
                // if exclusive, length must match when the loop is over
                // otherwise, it's good, all relations were checked
                return config.clusterRelationsExclusive ? edge.data.rels.length === config.clusterRelations.length : true;
              }
              break;
            }
          }
          return false;
        }
      });
    }
    graph.network.unselectAll();
    linkListener.call(this, e);
  };

  /**
   * Clusterize similar nodes
   * @param object config the cluster type configuration
   * @param Event e original event
   */
  var clusterSimilarClick = function (config, e) {
    var selection = graph.network.getSelectedNodes();
	// select only 1 node
	if(selection.length !== 1) {
		return false;
	}
    var nodeId = selection[0],
      node = graph.network.body.data.nodes.get(nodeId),
	  edges = graph.network.getConnectedEdges(nodeId),
	  nodeRelations = [];
	for (var i = 0; i < edges.length; i++) {
		var edge = graph.network.body.data.edges.get(edges[i]);
		var direction = "";
		if(edge["to"] === parseInt(nodeId)) {
		  direction = "from";
		}
		else {
		  direction = "to";
		}
		var target = edge[direction];
		nodeRelations.push([direction, target, edge["title"]]);
	}
	nodeRelations.sort();

	graph.network.cluster(
	  {
        clusterNodeProperties: {
          group: node.baseGroup,
          baseGroup: node.baseGroup,
          label: node.baseGroup + 's cluster',  //node.label || '    ' + Vizu.options.network.groups[node.baseGroup].label + '    ', //'    ' + (node.label ? node.label : Vizu.options.groups[node.baseGroup].label) + '    ',
          shape: 'box',
          shapeProperties: {
            borderRadius: 3
          },
          title: node.baseGroup + 's cluster',
          level: node.level
	    },
	    joinCondition: function (n1) {
		  if(n1.baseGroup !== node.baseGroup) {
		    return false;
		  }
		  var n1Edges = graph.network.getConnectedEdges(n1.id);
		  if(n1Edges.length !== nodeRelations.length) {
		    return false;
		  }
		  var n1Relations = [];
		  for (var i = 0; i < n1Edges.length; i++) {
		    var n1Edge = graph.network.body.data.edges.get(n1Edges[i]);
			var direction = "";
		    if(n1Edge["to"] === parseInt(n1.id)) {
		      direction = "from";
		    }
		    else {
		      direction = "to";
		    }
		    var target = n1Edge[direction];			
			n1Relations.push([direction, target, n1Edge["title"]])			
		  }
		  n1Relations.sort();
		  if(JSON.stringify(n1Relations) === JSON.stringify(nodeRelations)) {
		    return true;
		  }
		  else {
			return false;
		  }
		}
      },
      true
	);
     
    graph.network.unselectAll();
    linkListener.call(this, e);
  };

  /**
   * Open selected cluster
   * @param object config the cluster type configuration
   * @param Event e original event
   */
  var clusterOpenClick = function (config, e) {
    var selection = graph.network.getSelectedNodes();
	// select only 1 node
	if(selection.length !== 1) {
		return false;
	}
    var nodeId = selection[0];
	graph.network.openCluster(nodeId);
     
    graph.network.unselectAll();
    linkListener.call(this, e);
  };

  var clusterLinkHover = function (e) {
    // cancel event if item is not available
    if (e.currentTarget.classList.contains('disabled')) {
      return;
    }
    this.subContextCluster.innerHTML = '';
    for (var i = 0; i < Vizu.options.clustering.length; i++) {
      var elem = Vizu.options.clustering[i],
        li = document.createElement('li');
      li.classList.add('context-item');
      li.textContent = elem.title;
      this.subContextCluster.appendChild(li);

	  if(elem.title === 'Cluster similar nodes') {
        li.addEventListener('click', clusterSimilarClick.bind(this, elem));
	  }
	  if(elem.title === 'Cluster connected nodes') {
	    li.addEventListener('click', clusterLinkClick.bind(this, elem));
	  }
	  if(elem.title === 'Uncluster') {
	    li.addEventListener('click', clusterOpenClick.bind(this, elem));
	  }
    }
    // display it
    displaySubContext(e, this.subContextCluster);
  };

  var displaySubContext = function (e, element) {
    var elemRect = e.currentTarget.getBoundingClientRect(),
      contextRect = e.currentTarget.parentNode.getBoundingClientRect();

    element.style.display = 'block';
    var rect = element.getBoundingClientRect(),
      left = (elemRect.width - 1);
    if (contextRect.left + contextRect.width + rect.width > document.body.clientWidth) {
      left = -rect.width - 1;
    }
    element.style.left = left + "px";
  };

  /**
   * Add a tag to current selection
   * @param string tagName
   * @param Event e
   */
  var addTagLinkClick = function (tagName, e) {
    var selectedNodes = graph.network.getSelectedNodes(),
      selectedEdges = graph.network.getSelectedEdges();
    for (var i = 0; i < selectedNodes.length; i++) {
      if (graph.network.isCluster(selectedNodes[i])) {
        continue;
      }
      var node = graph.network.body.data.nodes.get(selectedNodes[i]);
      node.tags.add(tagName);
    }
    for (var j = 0; j < selectedEdges.length; j++) {
      var edge = graph.network.body.data.edges.get(selectedEdges[j]);
      edge.data.tags.add(tagName);
    }
    this.hide();
  };

  /**
   * Add a tag to the taglist
   * Tag current selection with it after
   * @param Event e
   */
  var addTagToListClick = function (e) {
    var tag = prompt('Enter new tag');
    if (tag) {
      tagList.add(tag);
    }
    // then we add it, keeping the current context
    addTagLinkClick.call(this, tag, e);
  };


  var tagLinkHover = function (e) {
    if (e.currentTarget.classList.contains('disabled')) {
      return;
    }
    this.subContextTag.innerHTML = ''; // empty
    addTagElements(this.subContextTag, addTagLinkClick, this);
    var addEl = document.createElement('li');
    addEl.classList.add('context-item');
    addEl.textContent = 'Add new tag';
    this.subContextTag.appendChild(addEl);
    addEl.addEventListener('click', addTagToListClick.bind(this));

    displaySubContext(e, this.subContextTag);
  };

  // helper to add tag elements to all tag related submenus
  var addTagElements = function (element, handler, thisArg, showEmptyEl) {
    tagList.each(function (item) {
      var li = document.createElement('li');
      li.classList.add('context-item');
      li.textContent = item;
      element.appendChild(li);
      li.addEventListener('click', handler.bind(thisArg, item));
    }.bind(this));
    if (showEmptyEl && tagList.getSize() < 1) {
      var li = document.createElement('li');
      li.textContent = 'No tag yet.';
      li.classList.add('disabled');
      element.appendChild(li);
    }
  };

  /**
   * Remove tag from selection
   * @param string tagName
   * @param Event e
   */
  var untagLinkClick = function (tagName, e) {
    var selectedNodes = graph.network.getSelectedNodes(),
      selectedEdges = graph.network.getSelectedEdges();
    for (var i = 0; i < selectedNodes.length; i++) {
      if (graph.network.isCluster(selectedNodes[i])) {
        continue;
      }
      var node = graph.network.body.data.nodes.get(selectedNodes[i]);
      node.tags.remove(tagName);
    }
    for (var j = 0; j < selectedEdges.length; j++) {
      var edge = graph.network.body.data.edges.get(selectedEdges[j]);
      edge.data.tags.remove(tagName);
    }
    this.hide();
  };

  var untagLinkHover = function (e) {
    if (e.currentTarget.classList.contains('disabled')) {
      return;
    }
    this.subContextUntag.innerHTML = '';
    addTagElements(this.subContextUntag, untagLinkClick, this, true);
    displaySubContext(e, this.subContextUntag);
  };

  /**
   * Set the network selection with tagged nodes
   * @param string tagName
   * @param Event e
   */
  var selectTagLinkClick = function (tagName, e) {
    var nodes = graph.network.body.data.nodes.getIds({
      filter: function (node) {
        return node.tags && node.tags.contains(tagName);
      }
    });

    var edges = graph.network.body.data.edges.getIds({
      filter: function (edge) {
        return edge.data.tags && edge.data.tags.contains(tagName);
      }
    });
    graph.network.setSelection({
      nodes: nodes,
      edges: edges
    }, {
      highlightEdges: false
    });

    this.hide();
    graph.neighbourhoodHighlight({
      nodes: nodes,
      edges: edges
    });
  };

  var selectTagLinkHover = function (e) {
    this.subContextSelectTag.innerHTML = '';
    addTagElements(this.subContextSelectTag, selectTagLinkClick, this, true);
    displaySubContext(e, this.subContextSelectTag);
  };

  // perform shortest path to root calculation
  var pathListener = function () {
    var selectedNodes = graph.network.getSelectedNodes();
    if (1 !== selectedNodes.length) {
      return;
    }
    var pathFinder = new Vizu.ShortestPathFinder(graph),
      shortestPath = pathFinder.shortestPath(selectedNodes[0], graph.rootId);
    graph.network.unselectAll();
    shortestPath.push(selectedNodes[0]); // path doesn't include first node
    if (shortestPath.length < 2) {
      alert('No path found!');
      return;
    }
    // calculate edges 'cause we only have nodes in our path calculation
    var shortestPathEdges = [];
    getPath:
      for (var i = 0; i < shortestPath.length - 1; i++) {
      var nodesA = graph.network.getConnectedEdges(shortestPath[i]),
        nodesB = graph.network.getConnectedEdges(shortestPath[i + 1]);
      for (var j = 0; j < nodesA.length; j++) {
        if (nodesB.indexOf(nodesA[j]) !== -1) {
          shortestPathEdges.push(nodesA[j]);
          continue getPath;
        }
      }
    }
    graph.network.setSelection({
      nodes: shortestPath,
      edges: shortestPathEdges
    }, {
      highlightEdges: false
    });
    graph.neighbourhoodHighlight({nodes: graph.network.getSelectedNodes(), edges: graph.network.getSelectedEdges()});
    graph.statusbar.setPath(shortestPath, shortestPathEdges);
  };

  var selectSameListener = function () {
    var selectedNodes = graph.network.getSelectedNodes();
    if (1 !== selectedNodes.length) {
      return;
    }
    var nodeGroup = graph.network.body.data.nodes.get(selectedNodes[0]).baseGroup;
    graph.network.selectNodes(graph.network.body.data.nodes.getIds({
      filter: function (item) {
        return item.baseGroup === nodeGroup;
      }
    }), graph.network.selectionHandler.options.selectConnectedEdges);
    graph.neighbourhoodHighlight({nodes: graph.network.getSelectedNodes()});
  };

  var links = this.container.getElementsByClassName('context-item');
  for (var i = 0; i < links.length; i++) {
    var link = links[i];
    if (!link.classList.contains('context-item-submenu')) {
      link.addEventListener('click', linkListener.bind(this), false);
    }
	if (link.id === 'cypherDeleteToClipboard') {
      link.addEventListener('click', cypherDelListener.bind(this), false);
    }
    if (link.id === 'copyToClipboard') {
      link.addEventListener('click', clipboardListener.bind(this), false);
    }
    if (link.id === 'delLink') {
      link.addEventListener('click', delListener.bind(this), false);
    }
    if (link.id === 'fixLink') {
      link.addEventListener('click', fixListener.bind(this), false);
    }
    if (link.id === 'clusterLink') {
      link.addEventListener('mouseenter', clusterLinkHover.bind(this));
      link.addEventListener('mouseleave', function () {
        this.subContextCluster.style.display = 'none';
      }.bind(this));
    }
    if (link.id === 'tagLink') {
      link.addEventListener('mouseenter', tagLinkHover.bind(this));
      link.addEventListener('mouseleave', function () {
        this.subContextTag.style.display = 'none';
      }.bind(this));
    }
    if (link.id === 'untagLink') {
      link.addEventListener('mouseenter', untagLinkHover.bind(this));
      link.addEventListener('mouseleave', function () {
        this.subContextUntag.style.display = 'none';
      }.bind(this));
    }
    if (link.id === 'selectTagLink') {
      link.addEventListener('mouseenter', selectTagLinkHover.bind(this));
      link.addEventListener('mouseleave', function () {
        this.subContextSelectTag.style.display = 'none';
      }.bind(this));
    }
    if (link.id === 'pathLink') {
      link.addEventListener('click', pathListener.bind(this), false);
    }

    if (link.id === 'selectSameLink') {
      link.addEventListener('click', selectSameListener.bind(this), false);
    }
  }
};

Vizu.ContextMenu.prototype = {
  show: function (x, y) {
    if (y + this.height > document.body.clientHeight) {
      y = y - this.height;
    }
    if (x + this.width > document.body.clientWidth) {
      x = x - this.width;
    }
    this.container.style.display = 'block';
    this.container.style.top = y + 'px';
    this.container.style.left = x + 'px';
    var selectedNodesCount = this.graph.network.getSelectedNodes().length,
      selectedEdgesCount = this.graph.network.getSelectedEdges().length;

    // manage enabled / disabled class
    for (var i = 0; i < this.links.length; i++) {
      var link = this.links[i];
      link.classList.remove('disabled');
      if (link.dataset['minSelection'] && link.dataset['minSelection'] > selectedNodesCount) {
        link.classList.add('disabled');
      }
      if (link.dataset['maxSelection'] && link.dataset['maxSelection'] < selectedNodesCount) {
        link.classList.add('disabled'); // redundant, i know
      }
      if (link.dataset['minNodeOrEdge'] && link.dataset['minNodeOrEdge'] > selectedNodesCount && link.dataset['minNodeOrEdge'] > selectedEdgesCount) {
        link.classList.add('disabled');
      }
    }
  },
  hide: function () {
    this.container.style.display = 'none';
    this.subContextCluster.style.display = 'none';
  }
};
