var Vizu = Vizu || {};

Vizu.TagList = function () {
  var tags = [];

  this.add = function (tagName) {
    if (tags.indexOf(tagName) === -1) {
      tags.push(tagName);
    }
  };

  this.remove = function (tagName) {
    var index = tags.indexOf(tagName);
    if (index !== -1) {
      tags.splice(index, 1);
    }
  };

  this.contains = function (tagName) {
    return tags.indexOf(tagName) !== -1;
  };

  this.each = function (callable) {
    for (var i = 0; i < tags.length; i++) {
      callable.call(this, tags[i]);
    }
  };

  this.getSize = function() {
    return tags.length;
  }
};
