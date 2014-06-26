require "rubygems"
require "sinatra"
require "aws/s3"

before do
  AWS::S3::Base.establish_connection!(
    :access_key_id     => 'AKIAJ6AECJ44RP4N2ICA',
    :secret_access_key => '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'
  )
end

get "/" do
  # List all buckets here
  @buckets = AWS::S3::Service.buckets
  erb :index
end

get "/buckets/:name" do
  # Find bucket with :name, and list all files
  @bucket = AWS::S3::Bucket.find(params[:name])
  	 
  erb :buckets_index
end

post "/buckets/:name" do
  # Upload file to bucket with :name
  filename = params[:file][:filename] + ".htm"
  system "abiword --verbose=0 --to=" << filename << " " << params[:file][:tempfile].path
  file =File.open(filename,"r")
  AWS::S3::S3Object.store( filename,  file, params[:name] )	
  system "rm "<<filename
  system "rm -r "<< filename << "_files"
  redirect "/buckets/#{params[:name]}"
end

get "/buckets/:name/new" do
  # Find bucket with :name, and render a form (form provided in sample)
  @bucket = AWS::S3::Bucket.find(params[:name])
  erb :buckets_new
end

post '/edit/save/:name' do
   AWS::S3::S3Object.store( params[:name], params[:content], 'waynelin_hw3')
  redirect "/edit/#{params[:name]}"
end

get "/edit/:name" do
  @filename = params[:name]  
  @file = AWS::S3::S3Object.value params[:name],'waynelin_hw3'

  erb :edit	
end
