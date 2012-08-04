var Movies = function () {
  this.respondsWith = ['html', 'json', 'xml', 'js', 'txt'];

  this.index = function (req, resp, params) {
    var self = this;

    var limit = 100; // default limit 
    if(params.limit) {
      limit = parseInt(params.limit);
    }

    var offset = 0; // default offset
    if(params.offset) {
      offset = parseInt(params.offset);
    }

    var count = -1;

    geddy.model.adapter.Movie.all({}
      , {sort: {title: 1}, limit: limit, skip: offset}
      , function(err, data) {
        self.respond({params: params
          , movies: data
          , count: count
          , limit: limit
          , offset: offset
        });
    });
  };

  this.add = function (req, resp, params) {
    this.respond({params: params});
  };

  this.create = function (req, resp, params) {
    // Save the resource, then display index page
    this.redirect({controller: this.name});
  };

  this.show = function (req, resp, params) {
    this.respond({params: params});
  };

  this.edit = function (req, resp, params) {
    this.respond({params: params});
  };

  this.update = function (req, resp, params) {
    // Save the resource, then display the item page
    this.redirect({controller: this.name, id: params.id});
  };

  this.remove = function (req, resp, params) {
    this.respond({params: params});
  };

};

exports.Movies = Movies;

