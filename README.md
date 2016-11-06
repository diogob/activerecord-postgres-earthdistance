# ActiveRecord + PostgreSQL Earthdistance [![Build Status](https://travis-ci.org/diogob/activerecord-postgres-earthdistance.svg?branch=master)](https://travis-ci.org/diogob/activerecord-postgres-earthdistance) [![Code Climate](https://codeclimate.com/github/diogob/activerecord-postgres-earthdistance/badges/gpa.svg)](https://codeclimate.com/github/diogob/activerecord-postgres-earthdistance)

Check distances with latitude and longitude using PostgreSQL special indexes.
This gem enables your model to query the database using the earthdistance extension. This should be much faster than using trigonometry functions over standard indexes.

## Requirements

Postgresql 9.1+ with contrib and Rails 3.1+
On Ubuntu, this is easy: `sudo apt-get install postgresql-contrib-9.1`

On Mac you have a couple of options:

* [the binary package kindly provided by EnterpriseDB](http://www.enterprisedb.com/products-services-training/pgdownload#osx)
* [Homebrew’s](https://github.com/mxcl/homebrew) Postgres installation also includes the contrib packages: `brew install postgres`
* [Postgres.app](http://postgresapp.com/)

## Install


Earthdistance is a PostgreSQL contrib module, [check it out first](http://www.postgresql.org/docs/9.2/static/earthdistance.html).

Then, just add this to your Gemfile:

`gem 'activerecord-postgres-earthdistance'`

And run your bundler:

`bundle install`

Now you need to create a migration that adds earthdistance support for your
PostgreSQL database:

`rails g earth_distance:setup`

Run it:

`rake db:migrate`

Now let's add some gist indexes to make queries ultra-fast.
For the model Place we could create an index over the lat and lng fields:

`rails g migration add_index_to_places`

Edit the created migration:

```ruby
class AddIndexToPlaces < ActiveRecord::Migration
  def up
    add_earthdistance_index :places
  end

  def down
    remove_earthdistance_index :places
  end
end
```

This will create the index with a SQL like this:
```sql
CREATE INDEX places_earthdistance_ix ON places USING GIST (ll_to_earth(lat, lng));
```

## Usage

This gem only provides a custom serialization coder.
If you want to use it just put in your Gemfile:

    gem 'activerecord-postgres-earthdistance'

Now add a line (for each earthdistance column) on the model you have your earthdistance columns.
Assuming a model called **Person**, with a **data** field on it, the
code should look like:

```ruby
class Place < ActiveRecord::Base
  acts_as_geolocated
end
```

This way, you will automatically look for columns with names such as lat/latitude and lng/longitude.
But you can use alternative names passing them as:

```ruby
class Place < ActiveRecord::Base
  acts_as_geolocated lat: 'latitude_column_name', lng: 'longitude_column_name'
end
```

You can also locale other entities through an geolocated association as in:
```ruby
class Job < ActiveRecord::Base
  belongs_to :job
  acts_as_geolocated through: :job
end
```

### Querying the database

To query for all places within a given radius of 100 meters from the origin -22.951916,-43.210487 just use:
```ruby
Place.within_radius(100, -22.951916, -43.210487).all
```

You can also order the records based on the distance from a point
```ruby
Place.within_radius(100, -22.951916,-43.210487).order_by_distance(-22.951916,-43.210487)
```

To query on associated models (the joins will be included for you):
```ruby
Job.within_radius(100, -22.951916,-43.210487)
```

The `within_radius` query performs two checks: first against the *bounding box*, followed by computing the exact distance for
all contained elements. The latter might be computationally expensive for big ranges.
So if precision is not an issue but query speed is, you might want to query against the bounding box only:
```ruby
Place.within_box(1_000_000, -22.951916,-43.210487)
```

Select the distance from a point:
```ruby
point = [-22.951916, -43.210487]
closest = Place.within_radius(100, *point).order_by_distance(*point).selecting_distance_from(*point).first
closest.distance
```

## Test Database

To have earthdistance enabled when you load your database schema (as happens in rake db:test:prepare), you
have two options.

The first option is creating a template database with earthdistance installed and set the template option
in database.yml to that database.

The second option is to uncomment or add the following line in config/application.rb

    config.active_record.schema_format = :sql

This will change your schema dumps from Ruby to SQL. If you're
unsure about the implications of this change, we suggest reading this
[Rails Guide](http://guides.rubyonrails.org/migrations.html#schema-dumping-and-you).

## Help

You can use issues in github for that. Or else you can reach us at
twitter: [@dbiazus](https://twitter.com/#!/dbiazus)

## Note on Patches/Pull Requests


* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don’t break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright © 2010 Diogo Biazus. See LICENSE for details.
