var Vizu = Vizu || {};

Vizu.colors = {
  "default": {background: "#CCCCCC", border: "#212121", highlight: {background: "#CCCCCC", border: "#212121"}},
  user: {background: "#80b2ff", border: "#0047b2", highlight: {background: "#80b2ff", border: "#0047b2"}},
  inetorgperson: {background: "#80b2ff", border: "#0047b2", highlight: {background: "#80b2ff", border: "#0047b2"}},
  foreignsecurityprincipal: {background: "#ffa366", border: "#8f3900", highlight: {background: "#ffa366", border: "#8f3900"}},
  computer: {background: "#d65c33", border: "#661a00", highlight: {background: "#d65c33", border: "#661a00"}},
  group: {background: "#70db70", border: "#196419", highlight: {background: "#70db70", border: "#196419"}},
  organizationalunit: {background: "#cccccc", border: "#333333", highlight: {background: "#cccccc", border: "#333333"}},
  grouppolicycontainer: {background: "#ad8533", border: "#403100", highlight: {background: "#ad8533", border: "#403100"}},
  unknown: {background: "#ffffff", border: "#a352cc", highlight: {background: "#ffffff", border: "#a352cc"}},
  site: {background: "#824c71", border: "#70163c", highlight: {background: "#824c71", border: "#70163c"}},
  subnet: {background: "#d7e798", border: "#b3c397", highlight: {background: "#d7e798", border: "#b3c397"}},
  domaincontroller: {background: "#ee7a51", border: "#d53700", highlight: {background: "#ee7a51", border: "#d53700"}},
  rodomaincontroller: {background: "#33673b", border: "#19231a", highlight: {background: "#33673b", border: "#19231a"}},
  email: {background: "#ffff00", border: "#212121", highlight: {background: "#ffff00", border: "#212121"}},
  sshkey: {background: "#e680ff", border: "#8e00b2", highlight: {background: "#e680ff", border: "#8e00b2"}},
  // unselected colors
  udefault: {background: "#E4E4E4", border: "#B1B1B1", highlight: {background: "#CCCCCC", border: "#212121"}},
  uuser: {background: "#cddcf3", border: "#a7bcdc", highlight: {background: "#80b2ff", border: "#0047b2"}},
  uinetorgperson: {background: "#cddcf3", border: "#a7bcdc", highlight: {background: "#80b2ff", border: "#0047b2"}},
  uforeignsecurityprincipal: {background: "#f3d8c6", border: "#d2b8a7", highlight: {background: "#ffa366", border: "#8f3900"}},
  ucomputer: {background: "#e7c3b6", border: "#c6afa7", highlight: {background: "#d65c33", border: "#661a00"}},
  ugroup: {background: "#c9e9c9", border: "#afc5af", highlight: {background: "#70db70", border: "#196419"}},
  uorganizationalunit: {background: "#e4e4e4", border: "#b6b6b6", highlight: {background: "#cccccc", border: "#333333"}},
  ugrouppolicycontainer: {background: "#dbcfb6", border: "#bab6a7", highlight: {background: "#ad8533", border: "#403100"}},
  uunknown: {background: "#f3f3f3", border: "#d8c0e4", highlight: {background: "#ffffff", border: "#a352cc"}},
  usite: {background: "#cebec9", border: "#c9aeb9", highlight: {background: "#824c71", border: "#70163c"}},
  usubnet: {background: "#e7ecd5", border: "#dde1d4", highlight: {background: "#d7e798", border: "#b3c397"}},
  udomaincontroller: {background: "#eeccbf", border: "#e7b8a7", highlight: {background: "#ee7a51", border: "#d53700"}},
  urodomaincontroller: {background: "#b6c6b9", border: "#afb2af", highlight: {background: "#33673b", border: "#19231a"}},
  uemail: {background: "#ffff9f", border: "#B1B1B1", highlight: {background: "#ffff9f", border: "#212121"}},
  usshkey: {background: "#ebcdf3", border: "#d1a7dc", highlight: {background: "#e680ff", border: "#8e00b2"}},
};

Vizu.edges_style = {
    // example: group_member: {color: "#ff0000", dashes: true, width: 4},
    primary_group: {color: "#00ff00"}
};

Vizu.options = {
  data: {
    properties: {
      nodes: {
        id: false,
        group: 'type',
        title: 'name',
        short: 'shortname',
        level: 'dist',
	hidden: 'hidden',
        label: false
      },
      edges: {
	hidden: 'hidden',
        from: 'source',
        to: 'target'
      }
    }
  },
  debug: false
};


Vizu.options.network = {
  groups: {
    "default": {label: "-", color: Vizu.colors['default']},
    user: {label: "u", color: Vizu.colors.user},
    inetorgperson: {label: "u", color: Vizu.colors.inetorgperson},
    foreignsecurityprincipal: {label: "w", color: Vizu.colors.foreignsecurityprincipal},
    computer: {label: "m", color: Vizu.colors.computer},
    group: {label: "g", color: Vizu.colors.group},
    organizationalunit: {label: "o", color: Vizu.colors.organizationalunit},
    grouppolicycontainer: {label: "x", color: Vizu.colors.grouppolicycontainer},
    unknown: {label: "?", color: Vizu.colors.unknown},
    site: {label: "s", color: Vizu.colors.site},
    subnet: {label: "n", color: Vizu.colors.subnet},
    domaincontroller: {label: "d", color: Vizu.colors.domaincontroller},
    rodomaincontroller: {label: "r", color: Vizu.colors.rodomaincontroller},
    email: {label: "e", color: Vizu.colors.email},
    sshkey: {label: "k", color: Vizu.colors.sshkey},
  },
  height: '100%',
  layout: {
    improvedLayout: false,
    randomSeed: 6 // fair dice roll
  },
  physics: {
    stabilization: {
      iterations: 2000 // try to stabilize the graph in 2000 times, after that show it anyway
    },
    barnesHut: {
      gravitationalConstant: -2000,
      centralGravity: 0.1,
      springLength: 95,
      springConstant: 0.04,
      damping: 0.09
    }
  },
  nodes: {
    // you can use "box", "ellipse", "circle", "text" or "database" here
    // "ellipse" is the default shape.
    shape: 'ellipse',
    size: 20,
    font: {
      size: 15,
      color: '#000000',
      face: 'arial' // maybe use a monospaced font?
    },
    borderWidth: 1,
    borderWidthSelected: 3,
    scaling: {
      label: {
        min: 15,
        max: 25
      }
    }
  },
  edges: {
    width: 2,
    smooth: {
      type: 'continuous'
    },
    hoverWidth: 2,
    selectionWidth: 2,
    arrows: {
      to: {
        enabled: true,
        scaleFactor: 0.5
      }, from: {
        enabled: false,
        scaleFactor: 0.5
      }
    },
    color: {
      //      inherit: 'from',
      color: '#666666',
      hover: '#333333',
      highlight: '#000000'
    }
  },
  interaction: {
    multiselect: true,
    hover: true,
    hideEdgesOnDrag: true
  },
  configure: {
    filter: function (option, path) {
      if (path.indexOf('global') !== -1 || option === 'global') {
        return false;
      }

      return true;
      if (path.indexOf('physics') !== -1) {
        return true;
      }
      if (path.indexOf('layout') !== -1) {
        return true;
      }
      if (path.indexOf('smooth') !== -1 || option === 'smooth') {
        return true;
      }
      if (path.indexOf('interaction') !== -1) {
        return true;
      }
      return false;
    },
    showButton: false
  }
};
/**
 * Configure here clustering options
 * Required keys:
 * - title: displayed in contextual menu
 * Optional keys:
 * - type: which type of node you can apply this clustering to
 * - clusterType: which type of node will be clustered with the node
 * - clusterRelations: array of attributes that the edge must have to be clustered
 * - clusterRelationsExclusive: whether the attributes of the edge must not contain any other value
 */
Vizu.options.clustering = [
  {
    title: 'Cluster similar nodes',
  },
  {
    title: 'Cluster connected nodes'
  },
  {
    title: "Uncluster",
    uncluster: true
  }
];
