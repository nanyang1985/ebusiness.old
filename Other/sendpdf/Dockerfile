FROM favaserver/sendpdf:base
ENV PATH /usr/local/rvm/gems/ruby-2.2.4/bin:/usr/local/rvm/gems/ruby-2.2.4@global/bin:/usr/local/rvm/rubies/ruby-2.2.4/bin:/usr/local/rvm/bin:$PATH

RUN gem install sinatra
RUN gem install mail
RUN gem install zipruby

ENTRYPOINT cd /home/sendpdf && ruby api.rb -e production