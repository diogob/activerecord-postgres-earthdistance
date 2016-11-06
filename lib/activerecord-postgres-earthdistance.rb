require "active_support"

ActiveSupport.on_load :active_record do
  require "activerecord-postgres-earthdistance/activerecord"
end

require "activerecord-postgres-earthdistance/railties" if defined? Rails
