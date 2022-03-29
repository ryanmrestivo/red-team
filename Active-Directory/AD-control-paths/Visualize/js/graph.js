var Vizu = Vizu || {};

Vizu.Graph = function (containerId, options) {
  this.container = document.getElementById(containerId);
  this.options = options;
}

Vizu.Graph.prototype = (function () {

  var nodes, edges;

  var getGroup = function (node, options) {
    // return default group when no configuration was defined
    return options.network.groups[node[options.data.properties.nodes.group]] ? node[options.data.properties.nodes.group] : 'default';
  };

  var setData = function(data) {
    // setting template in body
    document.body.innerHTML = "";
    var t = document.querySelector('#bodyContent');
    var clone = document.importNode(t.content, true);
    document.body.appendChild(clone);

    nodes = new vis.DataSet(); edges = new vis.DataSet();

    for (var i = 0; i < data.nodes.length; i++) {
      var n = data.nodes[i],
        group = getGroup(n, this.options),
        node;
      if (0 === n.dist) {
        this.rootId = this.options.data.properties.id ? n[this.options.data.properties.id] : i
      }
      node = {
        // we use the count of the loop as an id if the id property setting is false
        // this is in case the edges properties "from" and "to" are referencing
        // the order of the node, not the real id.
        id: this.options.data.properties.id ? n[this.options.data.properties.id] : i,
        group: group,
        baseGroup: group,
        title: n[this.options.data.properties.nodes.title],
        shortName: n[this.options.data.properties.nodes.short],
        level: n[this.options.data.properties.nodes.level],
	hidden: n[this.options.data.properties.nodes.hidden] ? n[this.options.data.properties.nodes.hidden] : false,
        tags: new Vizu.TagList(),
        value: 0 === n.dist ? 10 : 1
      };
      if (this.options.data.properties.nodes.label) {
        node['label'] = n[this.options.data.properties.nodes.label];
      }
      nodes.add(node);
    }
    for (var j = 0; j < data.links.length; j++) {
      var l = data.links[j];
      edge = {
        from: l.source,
        to: l.target,
        hidden: l[this.options.data.properties.edges.hidden] ? l[this.options.data.properties.edges.hidden] : false,
        data: {
          rels: l.rels,
          fromShortName: nodes.get(l.source).shortName,
          fromBaseGroup: nodes.get(l.source).baseGroup,
          toShortName: nodes.get(l.target).shortName,
          toBaseGroup: nodes.get(l.target).baseGroup,
          tags: new Vizu.TagList(),
          type: l.type
        },
        arrows: l.type === 'double' ? 'to, from' : 'to',
        title: l.rels.join('<br>')
      };
      for (var k = 0; k < l.rels.length; ++k) {
          Object.assign(edge, Vizu.edges_style[l.rels[k]]);
      }

      edges.add(edge);
    }

    // create a network
    var container = document.getElementById('mynetwork');
    var networkData = {
      nodes: nodes,
      edges: edges
    };

    var networkOptions = Vizu.options.network;
    if (window.localStorage.getItem('adcpVizuOptions')) {
      networkOptions = JSON.parse(window.localStorage.getItem('adcpVizuOptions'));
      networkOptions.groups = Vizu.options.network.groups;
      networkOptions.configure = Vizu.options.network.configure;
    }
    Vizu.options.network.configure.container = document.getElementById('config');

    this.network = new vis.Network(container, networkData, networkOptions);
    // put the colorpicker in the root page so it's not limited to our fixed toolbar
    var colPicker = document.getElementsByClassName('vis-color-picker')[0];
    colPicker.parentNode.removeChild(colPicker);
    document.body.appendChild(colPicker);

    var searchBox = new Vizu.SearchBox(this, nodes);

    this.contextMenu = new Vizu.ContextMenu('contextMenu', this);

    this.network.on('oncontext', onContext.bind(this));

    this.network.on('click', function() {
      this.contextMenu.hide();
    }.bind(this));

    this.network.on('select', neighbourhoodHighlight.bind(this));

    this.network.on("stabilizationProgress", stabilizationProgressFunction);
    this.network.once("stabilizationIterationsDone", stabilizationDoneFunction);

    this.toolbar = new Vizu.Toolbar(this);
    this.statusbar = new Vizu.Statusbar(this, nodes, edges);

    this.network.on('hoverNode', this.statusbar.update);
    this.network.on('hoverEdge', this.statusbar.update);
    this.network.on('blurNode', this.statusbar.reset.bind(this.statusbar));
    this.network.on('blurEdge', this.statusbar.reset.bind(this.statusbar));

    this.network.on('selectNode', this.statusbar.selectObject);
    this.network.on('selectEdge', this.statusbar.selectObject);

    this.network.on('deselectNode', this.statusbar.deselectObject);
    this.network.on('deselectEdge', this.statusbar.deselectObject);
  };

  var onContext = function(params) {
    var node,
      edge,
      selectionNodes = [],
      selectionEdges = [];
    params.event.preventDefault();
    if (node = this.network.getNodeAt(params.pointer.DOM)) {
      if (params.event.ctrlKey) {
        selectionNodes = this.network.getSelectedNodes();
      }
      selectionNodes.push(node);
      this.network.selectNodes(selectionNodes, this.network.selectionHandler.options.selectConnectedEdges);
    } else if (edge = this.network.getEdgeAt(params.pointer.DOM)) {
      if (params.event.ctrlKey) {
        selectionEdges = this.network.getSelectedEdges();
      }
      selectionEdges.push(edge);
      this.network.selectEdges(selectionEdges);
    }
    neighbourhoodHighlight.call(this, {nodes: this.network.getSelectedNodes(), edges: this.network.getSelectedEdges()});
    this.contextMenu.show(params.pointer.DOM.x, params.pointer.DOM.y);
  };

  var  neighbourhoodHighlight = function(params) {
    this.contextMenu.hide();
    this.statusbar.updateSelectionDetails();
    // get a JSON object
    var allNodes = this.network.body.nodes;
    // if something is selected:
    if (params.nodes.length > 0 || params.edges.length > 0) {
        // mark all nodes as hard to read.
        for (var nodeId in allNodes) {
          if (allNodes.hasOwnProperty(nodeId) && allNodes[nodeId].options.baseGroup) {
            allNodes[nodeId].options.color.background = Vizu.colors['u' + allNodes[nodeId].options.baseGroup].background;
            allNodes[nodeId].options.color.border = Vizu.colors['u' + allNodes[nodeId].options.baseGroup].border;
          }
        }

        for (var i = 0; i < params.nodes.length; i++) {
          var node;
          if (this.network.isCluster(params.nodes[i])) {
            node = this.network.body.nodes[params.nodes[i]];
          } else {
            node = allNodes[params.nodes[i]];
          }
          if (node.options.baseGroup) {
            node.options.color.background = Vizu.colors['u' + node.options.baseGroup].background;
            node.options.color.border = Vizu.colors['u' + node.options.baseGroup].border;
          }
        }
//        this.network.redraw();
    }
    else {
        // reset all nodes
        resetNodeStyle(allNodes, this.network);
        this.statusbar.reset(true);
    }
  }

  var resetNodeStyle = function (allNodes) {
    for (var nodeId in allNodes) {
      if (allNodes.hasOwnProperty(nodeId)) {
        if(allNodes[nodeId].options.baseGroup) {
          allNodes[nodeId].options.color.background = Vizu.colors[allNodes[nodeId].options.baseGroup].background;
          allNodes[nodeId].options.color.border = Vizu.colors[allNodes[nodeId].options.baseGroup].border;
        }
      }
    }
  };

  // Increment loading bar length on progress event
  var stabilizationProgressFunction = function(params) {
    var maxWidth = 496;
    var minWidth = 20;
    document.getElementById('loadingBar').style.display = 'block';
    var widthFactor = params.iterations / params.total;
    var width = Math.max(minWidth, maxWidth * widthFactor);

    document.getElementById('bar').style.width = width + 'px';
    document.getElementById('text').innerHTML = Math.round(widthFactor * 100) + '%';
  };

  // stabilization is done, remove loading bar
  var stabilizationDoneFunction = function() {
    var loadingBar = document.getElementById('loadingBar');
    document.getElementById('text').innerHTML = '100%';
    document.getElementById('bar').style.width = '496px';
    loadingBar.style.opacity = 0;
    // really clean the dom element
    setTimeout(function () {
      loadingBar.parentNode.removeChild(loadingBar);
    }, 200);
  };

  return {
    resetNodeStyle: resetNodeStyle,
    neighbourhoodHighlight: neighbourhoodHighlight,
    setData: setData
  };
})();
