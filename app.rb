
require 'sinatra'
require 'sequel'
require 'json'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/bikeway')

DB.create_table? :trips do
  primary_key :id

  String :user_id
  String :bike_id

  Float :start_longitude
  Float :end_longitude

  Float :start_latitude
  Float :end_latitude

  DateTime :start_timestamp
  DateTime :end_timestamp
end

trips = DB[:trips]

def valid_credentials(params)
  #  if is_valid(params[:access_key]) then
  #    return true
  #  else
  #    return false
  #  end

  puts "Valid Authentication"
  return false
end

before do
  if !valid_credentials(params) then
    halt "Invalid credentials"
  end
end

post '/unlock' do
  trip = {
    :user_id => params[:user_id],
    :bike_id => params[:bike_id],
    :start_longitude => params[:start_longitude].to_f,
    :start_latitude => params[:start_latitude].to_f,
    :start_timestamp => DateTime.now
  }

  trip[:id] = trips.insert(trip)
  return trip.to_json
end

post '/lock/:id' do

  trip = trips.where(:id => params[:id].to_i).update(
    :end_longitude => params[:end_longitude],
    :end_latitude => params[:end_latitude],
    :end_timestamp => DateTime.now
  )

  return trip.to_json
end

