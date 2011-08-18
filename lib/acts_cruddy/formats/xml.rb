module ActsCruddy

  module Formats

    module Xml

      def index
        @records = record_class.all
        render :xml => @records.to_xml(:root => plural_record_name, :dasherize => false)
      end

      def show
        render :xml => @record.to_xml(:dasherize => false)
      end

      def new
        render :xml => @record.to_xml(:dasherize => false)
      end

      def create
        
        if @record.save
          render :xml => @record.to_xml(:dasherize => false), :status => :created, :location => url_for(:action => :show, :id => @record)
        else
          render :xml => @record.errors.to_xml(:dasherize => false), :status => :unprocessable_entity
        end
      
      end

      def update
          
        if @record.update_attributes(params[@record_name])
          head :ok
        else
          render :xml => @record.errors.to_xml(:dasherize => false), :status => :unprocessable_entity
        end
        
      end

      def destroy
        @record.destroy
        head :ok
      end

    end

  end

end
