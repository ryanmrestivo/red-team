var Vizu = Vizu || {};

// Simple queue with priority for Shortest path
Vizu.PriorityQueue = function() {
  this._nodes = [];

  this.enqueue = function (priority, key) {
    this._nodes.push({key: key, priority: priority});
    this.sort();
  }
  this.dequeue = function () {
    return this._nodes.shift().key;
  }
  this.sort = function () {
    this._nodes.sort(function (a, b) {
      return a.priority - b.priority;
    });
  }
  this.isEmpty = function () {
    return !this._nodes.length;
  }
};

// Shortest path algorithm based on Dijkstra
Vizu.ShortestPathFinder = function(graph) {

  var INFINITY = 1/0;

  this.shortestPath = function (startId, finishId) {
    var nodes = new Vizu.PriorityQueue(),
      distances = {},
      previous = {},
      path = [],
      smallest, nodeId, neighbor, alt;

    for (nodeId in graph.network.body.nodes) {
      if (nodeId === startId) {
        distances[nodeId] = 0;
        nodes.enqueue(0, nodeId);
      }
      else {
        distances[nodeId] = INFINITY;
        nodes.enqueue(INFINITY, nodeId);
      }

      previous[nodeId] = null;
    }

    while (!nodes.isEmpty()) {
      smallest = nodes.dequeue();

      if (smallest === finishId) {
        path;

        while (previous[smallest]) {
          path.push(smallest);
          smallest = previous[smallest];
        }

        break;
      }

      if (!smallest || distances[smallest] === INFINITY) {
        continue;
      }

      var neighbors = graph.network.getConnectedNodes(smallest);
      for (var i = 0; i < neighbors.length; i++) {
        neighbor = neighbors[i];
        alt = distances[smallest] + 1; 

        if (alt < distances[neighbor]) {
          distances[neighbor] = alt;
          previous[neighbor] = smallest;

          nodes.enqueue(alt, neighbor);
        }
      }
    }
    return path;
  }
}