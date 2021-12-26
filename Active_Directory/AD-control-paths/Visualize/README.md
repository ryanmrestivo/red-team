# Active Directory Control Path Visualization tool

This is a frontend application based on vis.js library to display extracts of Active Directory.

## 1. INSTALL

The project ships with everything included to visualize graphs.
Open the index.html file locally with your browser and then click the "Load file..." button to 
select a JSON file containing a graph.
        
## 2. USAGE

Best results are achieved using up-to-date Chromium browser. It may also work on Firefox, but has not been 
tested on other browsers. Javascript File API is required.

### Initialization

Press `Ctrl` + `o` or press the `Open file...` button to select the data you want to display.

After loading the file, a progressbar is shown. The library tries to stabilize the graph. 
This can take some time, depending on the graph size.

If the graph is not stabilized after 2000 iterations, it is shown anyway. you will be able to tweak the 
configuration by using the right toolbar which exposes all the parameters used for the physics simulation.

### Manipulation

You can select nodes and edges, drag nodes, zoom in and out using the mouse. Multiple node and edges
selection can be achieved by pressing `Ctrl` while selection is done.

Hovering a node or an edge displays its properties in a tooltip. The statusbar at the bottom of the
interface displays more detailed information, i.e. source and target nodes for an edge.

Using the right click button on a node, or in an empty area of the graph will display the context
menu. This menu offers available actions depending on the current selection:
- Remove selection: this action will remove all selected nodes and edges from the graph.
- Fix/unfix selection: this action will fix the position of the selected nodes. These won't be
  affected by the physics simulation anymore.
- Cluster/Uncluster selection: This submenu will display configured clustering actions. The clusters
  will be made using differents parameters exposed below. See advanced configuration for more info.
- Tag selection: Use it to apply a tag to your selection, or create and apply a new one.
- Untag selection: Removes the tag (if applied) from the selection.
- Select tag: Selects all nodes and edges that have a particular tag applied.
- Shortest path to root: Selects the nodes on the shortest path that goes to the root node (deph=0).
- Select same type nodes: Selectds all the node that have the same type that the currently selected
  node.

### Search

Press `Ctrl` + `f` to open the search box. It is located at the top right of the screen. Type a few 
letters to see matching results. Results are ordered using the position of the search term in the 
title.

Click a search result to select the node and center the graph around that node.

To close the search box, either use the button at the right of the search field, or use ESC while
the search field is focused.

## 3. Configuration

Using the right toolbar, by pressing the menu button, gives you access to the full graph configuration.
Here are some of the most usefull options:
- Layout:
  - hierarchical: to display nodes and relations using a hierarchical tree 
- Interaction:
  - selectConnectedEdges: Enables or disables the selection of connected edges when selecting a node
- Physics:
  - enabled: enable or disable the physical simulation of the nodes
  - solver: different algorithms are available, try them to find the one that best suits your needs
  - Depending of the solver, different parameters are shown. Use them to fine-tune the rendering.

You can find the reference documentation at [vis.js official website](http://visjs.org).

## 4. Advanced configuration

### Advanced configuration file

The default graph configuration, containing nodes style, physics default parameters and much more is 
located in the `js/config.js` file. Feel free to customize this file so that it best suits your 
needs.

### Data model

The graph is built assuming the JSON file contains the following structure:
```javascript
{
  "nodes": [
  // ...
  ],
  "links": [
  // ...
  ]
}
```

In the `config.js` file you can customize which fields are to be used in the graph rendering.

For nodes, an id is calculated in order of appearance of the node. The `from` and `to` properties
of the links must match this id property. If your model already includes an id property that is 
referenced by the links, use the id property name in the `id` data field.

By default, some groups are defined, which are used according to the `group` property name of 
your model. Feel free to add more groups to fit your needs. The label of the group will be used,
unless you specify a `label` property from your model to be used by the node.

### Network rendering configuration

For network customization options, you can find the reference documentation at 
[vis.js official website](http://visjs.org).

### Advanced clustering configuration

The clustering configuration is done in the `Vizu.options.clustering` array at the end of the
`config.js` file. 

*TODO* detail clustering configuration

## 5. CUSTOM BUILD / DEVELOPMENT

*Warning* This is not currently working

Install nodejs which ships with npm (node package manager) to make your custom build.

Run the following commands to install the dependencies:

        $ npm install
        $ sudo npm install -g browserify

To build the custom version of visjs used, type the following command:

        $ browserify build.js -t babelify -o dist/vis-custom.js -s vis

