var Movies = function () {
  this.respondsWith = ['html', 'json', 'xml', 'js', 'txt'];

  this.index = function (req, resp, params) {
    var self = this;

    // Limit in params?
    var limit = 100; // default limit 
    if(params.limit) {
      limit = parseInt(params.limit);
    }

    // Offset in params?
    var offset = 0; // default offset
    if(params.offset) {
      offset = parseInt(params.offset);
    }

    // TODO: Get total count
    var count = -1;

    // Query in params?
    var query = {};
    if(params.q) {
      query = { title: params.q }
    } else if (params.fts) {
      query = { fts: ["this", "is", "test"] };
    }

    // Fetch data
    geddy.model.adapter.Movie.all(query
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

