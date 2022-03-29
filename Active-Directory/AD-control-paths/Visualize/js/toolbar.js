var Vizu = Vizu || {};

Vizu.Toolbar = function (graph) {
  var container = document.getElementById('toolbar'),
    titles = container.getElementsByClassName('container-title');


  document.getElementById('toggleToolbar').addEventListener('click', function (e) {
      e.preventDefault();
      container.classList.toggle('open');
    }, false);

  document.getElementById('saveConfig').addEventListener('click', function(e) {
    e.preventDefault();
    window.localStorage.setItem('adcpVizuOptions', JSON.stringify(graph.network.configurator.getOptions()));
  });;


  document.getElementById('resetConfig').addEventListener('click', function(e) {
    e.preventDefault();
    window.localStorage.removeItem('adcpVizuOptions');
  });;

  document.getElementById('exportPng').addEventListener('click', function(e) {
    this.href = graph.network.canvas.frame.canvas.toDataURL('image/png');
  });

  document.getElementById('loadFile').addEventListener('click', Vizu.triggerLoad);

  container.addEventListener('mousedown', function (e) {
    e.stopPropagation();
  }, false);

  for (var i = 0; i < titles.length; i++) {
    titles[i].addEventListener('click', function(e) {
      // toggle open/close on head
      var titlesToClose = container.getElementsByClassName('container-title open');
      for (var k = 0; k < titlesToClose.length; k++ ) {
        var el = titlesToClose[k];
        el.classList.remove('open');
        el.classList.add('closed');
      }
      this.classList.remove('closed');
      this.classList.add('open');
      // close open containers
      var toClose = container.getElementsByClassName('container open');
      for (var j = 0; j < toClose.length; j++) {
        var el = toClose[j];
        el.classList.remove('open');
        el.classList.add('closed');
      }
      // find next container and open it
      var elem = this;
      do {
        elem = elem.nextSibling;
      } while(elem && elem.tagName !== 'DIV');
      elem.classList.remove('closed');
      elem.classList.add('open');
    });
  }
  // this is a much simpler configurator
  var secConf = new vis.Configurator(graph.network, graph.network.body.container, graph.network.configurator.configureOptions, graph.network.canvas.pixelRatio),
    customContainer = document.getElementById('customConfigurator');
  secConf.setOptions({
    filter: function(option, path) {
      return ('hierarchical' === option) ||
        (path.indexOf('physics') === 0) ||
        ("selectConnectedEdges" === option && path.indexOf('interaction') === 0)
      ;
    },
    showButton: false,
    container: customContainer
  });
  secConf.setModuleOptions(graph.network.configurator.moduleOptions);
};