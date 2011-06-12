# Copyright (c) 2008 martin.rehfeld@glnetworks.de
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Mime::Type.register_alias "text/javascript", :ext_json

class ActiveRecord::Base
  
  def to_ext_json(options = {})
    
    success = options.delete(:success)
    methods = Array(options.delete(:methods))
    underscored_class_name = self.class.to_s.demodulize.underscore

    if success || (success.nil? && valid?)
      # return success/data hash to form loader, i.e.:
      #  {"data": { "post[id]": 1, "post[title]": "First Post",
      #             "post[body]": "This is my first post.",
      #             "post[published]": true, ...},
      #   "success": true}
      data =  attributes.map{|name,value| ["#{underscored_class_name}[#{name}]", value] }
      methods.each do |method|
        data << ["#{underscored_class_name}[#{method}]", self.send(method)] if self.respond_to? method
      end
      { :success => true, :data => Hash[*data.flatten], underscored_class_name => self }.to_json(options)
    else
      # return no-success/errors hash to form submitter, i.e.:
      #  {"errors":  { "post[title]": "Title can't be blank", ... },
      #   "success": false }
      error_hash = errors.inject({}) do |result, error| # error is [attribute, message]
        field_key = "#{underscored_class_name}[#{error.first}]"
        result[field_key] ||= 'Field ' + Array(errors[error.first]).join(' and ')
        result
      end
      { :success => false, :errors => error_hash, :error_messages => errors.full_messages }.to_json(options)
    end
    
  end
  
end

class Array

  # return Ext compatible JSON form of an Array, i.e.:
  #  {"results": n, 
  #   "posts": [ {"id": 1, "title": "First Post",
  #               "body": "This is my first post.",
  #               "published": true, ... },
  #               ...
  #            ]
  #  }
  def to_ext_json(options = {})
    if given_class = options.delete(:class)
      element_class = (given_class.is_a?(Class) ? given_class : given_class.to_s.classify.constantize)
    else
      element_class = first.class
    end
    element_count = options.delete(:count) || self.length

    { :results => element_count, element_class.to_s.tableize.tr('/','_') => self }.to_json(options)
  end

end