set :rails_env, "production"
set :branch, "master"

#############################################################
#	Servers
#############################################################

role :app, "107.20.134.170"
role :web, "107.20.134.170"
role :db,  "107.20.134.170", :primary => true


