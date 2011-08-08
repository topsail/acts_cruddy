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
      
      send :include, InstanceMethods
      helper_method :record_class

      options = {
        :formats => [ :html, :json, :xml ],
        :only => ::ActsCruddy::ACTIONS,
        :except => [],
        :redirect_to_after_save => 'show'
      }.merge(options.symbolize_keys!)

      options[:redirect_to_after_create] ||= options[:redirect_to_after_save]
      options[:redirect_to_after_update] ||= options[:redirect_to_after_save]

      except = [*options[:except]].map!(&:to_sym)

      actions = [*options[:only]].map(&:to_sym)
      actions.reject! { |key, value| except.include?(key) }

      before_filter :set_record_variables, :only => actions

      options[:formats].each do |format|
        # Mix in the action methods from the format module
        path = "acts_cruddy/formats/#{format}"
        require path
        format_module = "/#{path}".camelize.constantize
        send :include, format_module
        # Now alias them to avoid name conflicts
        ::ActsCruddy::ACTIONS.each do |action|
          alias_method("#{action}_#{format}".to_sym, action) if format_module.instance_methods.include?(action)
        end
      end

      self.class_eval do
        
        @redirect_to_after_create = options[:redirect_to_after_create]
        @redirect_to_after_update = options[:redirect_to_after_update]

        class << self;
          attr_accessor :redirect_to_after_create, :redirect_to_after_update
        end

        ::ActsCruddy::ACTIONS.each do |action|

          if actions.include?(action.to_sym)

            define_method action do
              action_method = "#{action}_#{request.format.to_sym}"
              send action_method if respond_to? action_method
            end

          else
            
            define_method action do
              raise "#{action} action not supported."
            end

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

    # The scope of a translation by default is based on the location of the
    # template file.  This provides a version of translate that will look
    # for a value based on the application_controller subclass name, then fall back to the
    # application_controller scope, regardless of where the template file is.
    def hierarchical_translate(key, options={})
     
      options = {
        :scope => controller_path.gsub('/', '.') + '.' + action_name,
        :default => t("application.#{action_name}.#{key}",
                        {
                          :human_name => record_class.model_name.human,
                          :plural_human_name => record_class.model_name.human.pluralize
                        }.merge(options))
      }.merge(options)

      t(key, options)

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

