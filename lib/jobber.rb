require 'rubygems'

require "mongoid"
require "mongoid-locker"
require "vidibus-uuid"
require "beaneater"

Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "jobber/**/*")).each do |file|
  require file unless File.directory?(file)
end

module Jobber
  def self.configure(&block)
    lambda = Proc.new(&block)
    @config = Config.new
    lambda.bind(@config).call
    Mongoid::Config.send(:load_configuration, @config.mongo)
  end

  def self.config
    @config ||= Config.new
  end
end
