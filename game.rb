require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  session[:total] ||= 100
end

def random_num
    [1, 2, 3].sample
end

get '/' do
  redirect '/bet'
end

get '/bet' do
  @test = ["hi"]
  @names = ["Larry", "Curly", "Moe"]
  @total = session[:total]
  erb :betting
end

post '/bet' do
  @amount = params[:bet].to_i
  @choice = params[:guess].to_i
  @actual_num = random_num
  if (@amount < 1) || (@amount > session[:total])
    session[:message] = "Bets must be between $1 and $#{session[:total]}."
    redirect '/'
  elsif @choice == @actual_num
    session[:total] += @amount
    session[:message] = "You have guessed correctly."
  else
    session[:total] -= @amount
    session[:message] = "You have guessed #{@choice}, but the number was #{@actual_num}."
  end

  if session[:total] <= 0
    session[:message] = "You have lost all of your money." 
    redirect '/broke'
  end

  redirect '/bet'
end

get '/broke' do
  erb :broke
end

post '/broke' do
  session.delete(:total)
  redirect '/'
end