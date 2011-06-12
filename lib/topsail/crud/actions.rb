module Topsail
  
  # Module that provides create, request, update and delete funtionality for basic ActiveRecords.
  # This module should be included in a subclass of ActionController::Base.
  #
  module Crud

    module Actions

      def index
        
        @record_name = record_name
        @record_class = record_class
        
        @records = find_all_records(@record_class)
        instance_variable_set("@#{@record_name.pluralize}", @records)
      
        @title = @record_name.pluralize.titleize

        respond_to do |format|
          
          format.html do
            render_template_hierarchy
          end
          
          format.xml do
            render :xml => @records.to_xml(:root => @record_name.pluralize, :dasherize => false)
          end
          
          format.json do
            render :json => @records
          end
          
          format.ext_json do
            render :json => @records.to_ext_json
          end
          
        end
        
      end

      def show

        set_record_variables

        @title = @record_name.titleize
        @title = "#{@title} - #{@record.name}" if has_name? @record_class

        respond_to do |format|
          format.html { render_template_hierarchy }
          format.xml  { render :xml => @record.to_xml(:dasherize => false) }
          format.json { render :json => @record }
          format.ext_json { render :json => @record.to_ext_json }
        end
        
      end

      def new
        
        set_record_variables
        
        @title = "New #{@record_name.titleize}"
        
        respond_to do |format|
          format.html { render_template_hierarchy }
          format.xml  { render :xml => @record.to_xml(:dasherize => false) }
          format.json { render :json => @record }
          format.ext_json { render :json => @record.to_ext_json }
        end

      end

      def edit
        set_record_variables
        @title = "#{@record_name.titleize}"
        @title = "#{@title} - #{@record.name}" if has_name? @record_class
        render_template_hierarchy
      end

      def create
        
        set_record_variables
        
        @title = "New #{@record_name.titleize}"

        respond_to do |format|
          
          if @record.save
            
            format.html do
              flash[:notice] = record_message(@record, "was successfully created.")
              redirect_to_unless_param(:action => :index)
            end
            
            format.xml do
              render :xml => @record.to_xml(:dasherize => false), :status => :created, :location => url_for(:action => :show, :id => @record)
            end
            
            format.json do
              render :json => @record, :status => :created, :location => url_for(:action => :show, :id => @record)
            end
            
            format.js do
              render_template_hierarchy
            end
            
            format.ext_json do
              render :json => @record.to_ext_json(:success => true)
            end
            
          else
            
            format.html do
              render_template_hierarchy 'new'
            end
            
            format.xml do
              render :xml => @record.errors.to_xml(:dasherize => false), :status => :unprocessable_entity
            end
            
            format.json do
              render :json => @record.errors.full_messages, :status => :unprocessable_entity
            end
            
            format.ext_json do
              render :json => @record.to_ext_json(:success => false)
            end
            
            format.js do
              if template_exists_in_hierarchy? 'create_failure'
                render_template_hierarchy 'create_failure'
              else
                render :json => @record.errors.full_messages, :status => :unprocessable_entity
              end
            end
            
          end
        
        end
        
      end

      def update
        
        set_record_variables
        
        @title = "#{@record_name.titleize}"
        @title = "#{@title} - #{@record.name}" if has_name? @record_class
        
        respond_to do |format|
          
          if @record.update_attributes(params[@record_name])
            
            format.html do
              flash[:notice] = record_message(@record, "was successfully updated.")
              redirect_to_unless_param(:action => :index)
            end
            
            format.xml do
              head :ok
            end
            
            format.json do
              head :ok
            end
            
            format.ext_json do
              render :json => @record.to_ext_json(:success => true)
            end
            
            format.js do
              render_template_hierarchy
            end
          
          else
            
            format.html do
              render_template_hierarchy 'edit'
            end
            
            format.xml do
              render :xml => @record.errors.to_xml(:dasherize => false), :status => :unprocessable_entity
            end
            
            format.json do
              render :json => @record.errors.full_messages, :status => :unprocessable_entity
            end
            
            format.ext_json do
              render :json => @record.to_ext_json(:success => false)
            end
            
            format.js do
              
              if template_exists_in_hierarchy? 'update_failure'
                render_template_hierarchy 'update_failure'
              else
                render :json => @record.errors.full_messages, :status => :unprocessable_entity
              end
        
            end
        
          end
        
        end
        
      end

      def destroy
        
        set_record_variables
        
        # records normally shouldn't be destroyed if they are associated with other
        # records, so check that

        destroyable = true

        @record_class.reflect_on_all_associations.each do | assoc |
          
          # if dependent option was set, this class has indicated how these cases should
          # be handled already, otherwise a non-empty association will be an error
          
          if assoc.options[:dependent].nil? and (assoc.macro == :has_many) and @record.send(assoc.name).size > 0
            
            error = record_message(@record, "cannot be deleted because it is currently associated with #{assoc.name.to_s.titleize.downcase}.")
            @record.errors.add_to_base(error)
            destroyable = false
            
          end
          
        end

        # go ahead and destroy it if is isn't associated with anything, else send
        # an error

        if destroyable
        
          @record.destroy

          respond_to do |format|  
            format.html do
              flash[:notice] = record_message(@record, "was successfully deleted.")
              redirect_to_unless_param :action => :index
            end
            format.xml  { head :ok }
            format.json { head :ok }
            format.js   { render_template_hierarchy }
          end
          
        else
          
          respond_to do |format|
            format.html do
              flash[:error] = @record.errors.full_messages.join("\n")
              redirect_to_unless_param :action => :index
            end
            format.xml  { render :xml => @record.errors.to_xml(:dasherize => false), :status => :unprocessable_entity }
            format.json { render :json => @record.errors, :status => :unprocessable_entity }
            format.js do
              if template_exists_in_hierarchy? 'destroy_failure'
                render_template_hierarchy 'destroy_failure'
              else
                render :json => @record.errors.full_messages, :status => :unprocessable_entity
              end
            end
            
          end
          
        end

      end

      # Determines if the ActiveRecord's table supports the "name" column
      def has_name?(record_class)
        record_class.column_names.include? 'name'
      end
      
      # Find all the records, for the index action.  Classes which include this module can override this to determine
      # the correct sorting.  If the ActiveRecord include a "name" column it will be sorted by that by default
      def find_all_records(record_class)
        if has_name? record_class
          record_class.find(:all, :order => 'lower(name)')
        else
          record_class.find(:all)
        end
      end
      
      # Sets record_name, record_class, record and the dynamic instance variable for the record.  The CRUD methods call this,
      # put it is public so that a controller can also call it as a filter if it wants.
      def set_record_variables
        
        @record_name = record_name
        @record_class = record_class
        
        if @record.nil?  # no need to do this db lookup more than once
          
          if params[:id].blank?
            @record = @record_class.new(params[@record_name])
          else
            @record = @record_class.find(params[:id])
          end
        
          instance_variable_set("@#{@record_name}", @record)
          
        end

      end
      
      def record_name
        controller_name.singularize
      end
      
      def record_class
        controller_name.classify.constantize
      end
      
      # Works like the regular redirect_to Rails method, except that if there is a
      # request parameter called "redirect_to_url" it redirects there instead
      def redirect_to_unless_param(options = {}, response_status = {})

        if params[:redirect_to_url].nil? or params[:redirect_to_url].empty?
          redirect_to(options, response_status)
        else
          redirect_to(params[:redirect_to_url])
        end

      end
      
      private

      # Returns a message with either the "name" attribute of the record or the class name of the record prepended
      def record_message(record, message)
        if has_name? record.class
          "\"#{record.name}\" #{message}"
        else
          "#{record.class.name.titleize} #{message}"
        end
      end
      
      # Renders the template for the given action.  If the template doesn't exist for this controller class,
      # this method will walk up the inheritance hierarchy and look in the template directories of each base class
      # until it gets to ActionController::Base
      def render_template_hierarchy(action=params[:action])
        render :template => template_in_hierarchy(action)
      end
      
      def template_exists_in_hierarchy?(action=params[:action])
        return !template_in_hierarchy(action).nil?
      end
      
      def template_in_hierarchy(action=params[:action])
        
        found_template_name = nil
        
        template_name = "#{controller_path}/#{action}"
        
        logger.debug("BasicCrud looking for \"#{template_name}\" template.")
        
        if template_exists?(template_name)
          found_template_name = template_name
        else
          
          parent = self.class.superclass
          
          while parent != ActionController::Base and !parent.nil?
           
            template_name = "#{parent.controller_path}/#{action}"

            logger.debug("BasicCrud looking for \"#{template_name}\" template.")

            if template_exists? template_name
              found_template_name = template_name
              break
            end
            
            parent = parent.superclass
            
          end

        end
        
        return found_template_name
        
      end
      
    end

  end
  
end
