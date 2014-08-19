puts "hello world"

require 'rubygems'

#require 'bundler'
#Bundler.require

puts "gem loaded"

require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'rufus-scheduler'
require 'json'
require 'airplay'

#require File.dirname(__FILE__) + '/airplay_hotfix'

ENV['PATH'] = ENV['PATH'] + ':' + File.dirname(__FILE__) + '/bin'


class Event
    include DataMapper::Resource

    property :id, Serial, :required => true
    property :videotype, String, :required => true
    property :videourl, String, :required => true, :length=>250
    property :title, String, :required => true, :length=>250
    property :class, String, :required => true
    property :start, Integer, :required => true
    property :end, Integer, :required => true
    property :device, String, :required => true
    property :status, String, :required => true
end

module Helpers

    def self.queue
        @queue ||= Queue.new
    end

    def self.scheduler
        @scheduler ||= Rufus::Scheduler.new
    end
end

class YoutubeSchedulerApp < Sinatra::Base

    configure do

        DataMapper::Logger.new($stdout, :debug)
        DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")
        DataMapper.auto_upgrade!

        set :port, 8081
        #set :server, 'webrick'
        set :threaded, true


        Helpers.scheduler.every '1m', :first => :now do
            puts 'Starting scheduler event'
            events = Event.all(:start.lt => Time.now.to_f * 1000, :status => 'New')

            events.each do |event|
                puts 'pushing event ' + event.inspect
                Helpers.queue.push event
                event.status = 'Queued'
                event.save
            end

        end
=begin
        Thread.new do

            puts 'starting worker thread'

            while true do
                begin

                    event = Helpers.queue.pop
                    event.status = 'Playing'
                    event.class = 'event-warning'
                    event.save

                    device = Airplay[event.device]

                    if device != nil
                        player = device.play(`youtube-dl -g -f 18 #{event.videourl}`)

                        if player != nil
                            player.wait

                            puts "Event #{event.title} played"

                            event.status = 'Played'
                            event.class = 'event-success'
                            event.save

                            next

                        end
                    end

                device = nil

                puts "Event #{event.title} discarded, error"

                event.status = 'Error'
                event.class = 'event-important'
                event.save

                rescue Exception => e

                    puts 'worker thread crashed !'
                    puts e
                end
            end
        end
=end
    end

    get '/events' do
        @events = Event.all(:start => params[:from]..params[:to])
        { :success => true, :result => @events }.to_json
    end

    post '/events' do
        @event = Event.new(params)

        @event.status = 'New'

        if @event.save
            { :success => true, :id => @event.id }.to_json
        else
            { :success => false, :error_message => @event.errors.full_messages }.to_json
        end
    end

end

puts "here"

YoutubeScheduler.run!
