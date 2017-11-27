# coding: utf-8
require 'sinatra'
require 'mail'
require 'zipruby'
require 'net/smtp'
require 'securerandom'

options = { :address              => "smtp.e-business.co.jp",
            :port                 => 587,
            :domain               => 'e-business.co.jp',
            :user_name            => 'ebprint@e-business.co.jp',
            :password             => 'eb123456',
            :authentication       => 'plain',
            :openssl_verify_mode  => 'none',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

def sendbody(from, to, subject, body, zip)
  Mail.deliver do
       to to
       from from
       subject subject
       body body
       add_file zip
  end
end

def sendpass(from, to, subject, body , password)
  Mail.deliver do
       to to
       from from
       subject subject
       body body.gsub('PASSWORD', password)
  end
end
    
def convert_file(newName, file)
  tmpName = file.path.split("/").last
  system( "/usr/bin/libreoffice --invisible --convert-to pdf #{file.path} --outdir /home/sendpdf" )
end

get '/' do
  content_type :html, :charset => 'utf-8'
  File.read(File.join('public', 'index.html'))
end

post '/send' do
  content_type :html, :charset => 'utf-8'
  newName1 = nil
  if params[:file1]
    newName1 = params[:file1][:tempfile].path.split("/").last.gsub('xlsx', 'pdf')
    system("/usr/bin/libreoffice --invisible --convert-to pdf #{params[:file1][:tempfile].path} --outdir /home/sendpdf" )
  end
  newName2 = nil
  if params[:file2]
    newName2 = params[:file2][:tempfile].path.split("/").last.gsub('xlsx', 'pdf')
    system("/usr/bin/libreoffice --invisible --convert-to pdf #{params[:file2][:tempfile].path} --outdir /home/sendpdf" )
  end
  
  zipName = params[:file1][:filename].split("_").first.encode('cp932')
  zipPath = "/home/sendpdf/#{zipName}.zip"
  File.delete(zipPath) if File.exist?(zipPath)
  Zip::Archive.open(zipPath, Zip::CREATE) do |arc|
    arc.add_file("#{params[:file1][:filename].gsub('xlsx', 'pdf').encode('cp932')}", "/home/sendpdf/#{newName1}")
    arc.add_file("#{params[:file2][:filename].gsub('xlsx', 'pdf').encode('cp932')}", "/home/sendpdf/#{newName2}")
  end
  
  password = 4.times.map { SecureRandom.random_number(10) }.join
  Zip::Archive.encrypt(zipPath, password)
  File.delete("/home/sendpdf/#{newName1}") if File.exist?("/home/sendpdf/#{newName1}")
  File.delete("/home/sendpdf/#{newName2}") if File.exist?("/home/sendpdf/#{newName2}")
  
  sendbody(params[:from], params[:to], params[:title], params[:content1], zipPath)
  sendpass(params[:from], params[:to], params[:title], params[:content2], password)
end
