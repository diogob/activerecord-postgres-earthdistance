require "rails"
require "rails/generators"
require "rails/generators/migration"
require "active_record"
# = Earth Distance Railtie
#
# Creates a new railtie for 2 reasons:
#
# * Initialize ActiveRecord properly
# * Add earthdistance:setup generator
class EarthDistance < Rails::Railtie
  # Creates the earthdistance:setup generator. This generator creates a migration that
  # adds earthdistance support for your database. If fact, it's just the sql from the
  # contrib inside a migration. But it' s handy, isn't it?
  #
  # To use your generator, simply run it in your project:
  #
  #   rails g earthdistance:setup
  class Setup < Rails::Generators::Base
    include Rails::Generators::Migration

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), "..", "templates")
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d".format(current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      migration_template "setup_earthdistance.rb", "db/migrate/setup_earthdistance.rb", migration_version: migration_version
    end

    private

    def requires_migration_version?
      Rails::VERSION::MAJOR >= 5
    end

    def migration_version
      if requires_migration_version?
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end
  end
end
