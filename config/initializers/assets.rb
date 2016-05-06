# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
Rails.application.config.assets.precompile += %w( gorae.css )
Rails.application.config.assets.precompile += %w( crawl.css )
Rails.application.config.assets.precompile += %w( admin.css )
Rails.application.config.assets.precompile += %w( song.css )

Rails.application.config.assets.precompile += %w( 4d_info/team0.css )
Rails.application.config.assets.precompile += %w( 4d_info/team1.css )
Rails.application.config.assets.precompile += %w( 4d_info/team2.css )

Rails.application.config.assets.precompile += %w( gorae/home.css )
Rails.application.config.assets.precompile += %w( gorae/search.css )
Rails.application.config.assets.precompile += %w( gorae/rank.css )
Rails.application.config.assets.precompile += %w( gorae/recommendation.css )
Rails.application.config.assets.precompile += %w( gorae/users.css )
Rails.application.config.assets.precompile += %w( tutorial/tutorial.css )
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
