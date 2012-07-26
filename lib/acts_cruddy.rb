require "acts_cruddy/version"

module ActsCruddy
 
  ACTIONS = [ :index, :show, :new, :create, :edit, :update, :destroy ]

  def self.included(base)
    base.send :extend, ClassMethods
  end
 
  module ClassMethods

    # Adds a basic implementation of CRUD actions to this controller.
    # To control which actions get implemented, use the +only+ and
    # +except+ options.
    #
    def acts_cruddy(options={})
      
      options = {
        :formats => [ :html, :json, :xml ],
        :only => ::ActsCruddy::ACTIONS,
        :except => [],
        :redirect_to_after_save => 'show'
      }.merge(options.symbolize_keys!)

      # define redirect_to_after_create and redirect_to_after_update as methods so that subclasses inherit them
			class_eval %(class << self; def redirect_to_after_create; "#{ options[:redirect_to_after_create] || options[:redirect_to_after_save] }" end; end)
			class_eval %(class << self; def redirect_to_after_update; "#{ options[:redirect_to_after_update] || options[:redirect_to_after_save] }" end; end)

      # Figure out which actions to create based on the only and except options
      except = [*options[:except]].map!(&:to_sym)
      actions = [*options[:only]].map(&:to_sym)
      actions.reject! { |key, value| except.include?(key) }

      # Add in the instance methods for working with records without knowing their type
      send :include, InstanceMethods
      helper_method :record_class, :record_name, :plural_record_name
      before_filter :set_record_variables, :only => actions, :except => :index

      # Remember the instance_methods we had before we started
      # mixing things in, so we can leave them unchanged
      original_instance_methods = instance_methods.dup

      # Mix in the action methods for each format
      options[:formats].each do |format|

        # Include the format module
        path = "acts_cruddy/formats/#{format}"
        require path
        format_module = "/#{path}".camelize.constantize
        send :include, format_module

        # Alias the actions to avoid name conflicts between modules
        ::ActsCruddy::ACTIONS.each do |action|
          if format_module.instance_methods.include?(action) && !original_instance_methods.include?(action)
            alias_method("#{action}_#{format}".to_sym, action)
          end
        end

      end

      # Add action methods that delegate to the format specific methods based on the request format
      ::ActsCruddy::ACTIONS.each do |action|

        unless original_instance_methods.include?(action) # Don't change methods that existed before the mixins

          if actions.include?(action.to_sym)

            define_method action do
              action_method = "#{action}_#{request.format.to_sym}"
              action_method += 'html' if action_method[-1] == '_'  # IE sends an ACCEPT header of '*/*' when hitting RELOAD and the url doersn't have a format extension; trying to accomodate...
              send action_method if respond_to? action_method
            end

          else
            # Clean up any mixed in actions that were not wanted.
            undef_method(action) if self.instance_methods.include?(action)
          end

        end

      end

    end

  end
 
  module InstanceMethods
    
    def record_name
      @record_name ||= controller_name.singularize
    end
   
    def plural_record_name
      @plural_record_name ||= record_name.pluralize
    end

    def record_class
      @record_class ||= controller_name.classify.constantize
    end

    def record_name_attribute
      @name_attribute ||= 'name'
    end

    def record_name_value(record)
      record.respond_to?(record_name_attribute) ? record.send(record_name_attribute) : nil
    end

    def set_record_variables
    
      if params[:id].present?
        @record = record_class.find(params[:id])
      else
        @record = record_class.new(params[record_name])
      end
      
      instance_variable_set("@#{record_name}", @record)
    
    end

  end

end

ActionController::Base.send :include, ActsCruddy

