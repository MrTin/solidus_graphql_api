# frozen_string_literal: true

module SolidusGraphqlApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_graphql_api.rb'
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_graphql_api'
      end

      def mount_engine
        insert_into_file File.join('config', 'routes.rb'), after: "Rails.application.routes.draw do\n" do
          <<-HEREDOC.strip_heredoc.indent(2)
            # Solidus GraphQL API
            mount SolidusGraphqlApi::Engine, at: '/graphql'

            # Enable playground in development
            # requires gem 'graphql_playground-rails' to be installed
            # if Rails.env.development?
            #   mount GraphqlPlayground::Rails::Engine, at: '/playground', graphql_path: '/graphql'
            # end

          HEREDOC
        end
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
