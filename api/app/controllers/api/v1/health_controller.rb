module Api
  module V1
    class HealthController < ApplicationController
      def check
        render json: { 
          status: 'healthy', 
          timestamp: Time.current,
          database: database_status,
          redis: redis_status
        }
      end

      private

      def database_status
        ActiveRecord::Base.connection.execute('SELECT 1')
        'connected'
      rescue => e
        'error'
      end

      def redis_status
        Redis.new(url: ENV['REDIS_URL']).ping
        'connected'
      rescue => e
        'error'
      end
    end
  end
end
