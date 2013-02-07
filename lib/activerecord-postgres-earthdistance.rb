require 'active_support'

if defined? Rails
  require "activerecord-postgres-earthdistance/railties"
else
  ActiveSupport.on_load :active_record do
    require "activerecord-postgres-earthdistance/activerecord"
  end
end
