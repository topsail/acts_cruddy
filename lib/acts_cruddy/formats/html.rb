module ActsCruddy

  module Formats

    module Html

      def index
        @records = record_class.all
        instance_variable_set("@#{plural_record_name}", @records)
      end

      def create

        if @record.save
          flash[:notice] = hierarchical_translate('record_created', :name => record_name_value(@record))
          redirect_after_create
        else
          render :action => 'new'
        end

      end

      def update

        if @record.update_attributes(permitted_params)
          flash[:notice] = hierarchical_translate('record_updated', :name => record_name_value(@record))
          redirect_after_update
        else
          render :action => 'edit', :status => :unprocessable_entity
        end

      end

      def destroy

        @record.destroy

        flash[:notice] = hierarchical_translate('record_destroyed', :name => record_name_value(@record))
        redirect_after_destroy

      end

      protected

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

      #
      # Overwrite any of the following methods in your acts_cruddy controller if you don't like the defaults
      #
      def redirect_after_save
        redirect_to url_for(:controller => controller_path, :action => :show, :id => @record)
      end

      def redirect_after_create
        redirect_after_save
      end

      def redirect_after_update
        redirect_after_save
      end

      def redirect_after_destroy
        redirect_to url_for(:controller => controller_path, :action => :index)
      end

    end

  end

end
