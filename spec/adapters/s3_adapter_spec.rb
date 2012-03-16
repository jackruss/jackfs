require 'spec_helper'
require File.dirname(__FILE__) + '/../spec_helper'


describe "JackFS S3 Adapter" do
  before(:each) do
    root = File.dirname(__FILE__) + '/..'
    YAML.should_receive(:load_file).and_return("test" => {
      "adapter" => "s3",
      "bucket" => 'jackhq',
      "access_key" => ENV['AMAZON_ACCESS_KEY_ID'],
      "secret_key" => ENV['AMAZON_SECRET_ACCESS_KEY']
    })
    
    @s3a = Jackfs::S3Adapter.new(root, :test)
  
  end
  
  it "should save a file to a configured access key" do
    @s3a.access_key.should == ENV['AMAZON_ACCESS_KEY_ID']
  end
  
  it "should save a file to a configured secret key" do
    @s3a.secret_key.should == ENV['AMAZON_SECRET_ACCESS_KEY']
  end

  it "should save a file to a configured secret key" do
    @s3a.bucket.should == "jackhq"
  end

  it "should establish a connection to s3" do
    AWS::S3::Base.stub!(:establish_connection!).and_return(true)
    @s3a.establish_connection.should == true
  end

  it "should create a bucket if a bucket does not exist" do
    AWS::S3::Bucket.should_receive(:find).and_return(false)
    AWS::S3::Bucket.should_receive(:create).and_return(true)
    @s3a.find_or_create_bucket.should be_true
    
  end

  it "should find a bucket if a bucket does exist" do
    AWS::S3::Bucket.should_receive(:find).and_return(true)
    @s3a.find_or_create_bucket.should be_true
  end

  it "should save the file in s3 using the given name" do
    @s3a.should_receive(:find_or_create_bucket).and_return(true)
    AWS::S3::S3Object.should_receive(:store).and_return(true)
    @s3a.store(File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r'),"COOLBEANS").should == true
  end

  it "should get a file from a configured from s3" do
    f = File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r')
    #AWS::S3::S3Object.should_receive(:stream).and_return(f)
    @s3a.store(File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r'),"COOLBEANS").should == true
    @s3a.get("COOLBEANS").read.length.should == f.read.length
  end
  
end
