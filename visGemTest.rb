require 'sinatra/base'
require 'chartkick'

class ChartExample < Sinatra::Base
  attr_accessor :title, :data

  get '/' do
    @title = 'Languages!'
    @data = {'Ruby' => 3, 'Javascript' => 2, 'Java' => 7, 'TeX' => 1}
    erb :test
  end
end