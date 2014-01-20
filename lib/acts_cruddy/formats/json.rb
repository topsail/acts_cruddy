module ActsCruddy

  module Formats

    module Json

      def index
        @records = record_class.all
        render :json => @records
      end

      def show
        render :json => @record
      end

      def new
        render :json => @record
      end

      def create

        if @record.save
          render :json => @record, :status => :created, :location => url_for(:action => :show, :id => @record)
        else
          render :json => @record.errors.full_messages, :status => :unprocessable_entity
        end

      end

      def update

        if @record.update_attributes(permitted_params)
          render :json => nil, :status => :ok
        else
          render :json => @record.errors.full_messages, :status => :unprocessable_entity
        end

      end

      def destroy
        @record.destroy
        head :ok
      end

    end

  end

end
