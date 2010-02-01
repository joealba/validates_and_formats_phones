  module ValidatesAndFormatsPhones
    DEFAULT_FORMAT = "(###) ###-####"
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods


      def validates_and_formats_phones(*args)
        formats = []
        fields = []
        args.each do |option|
          option.to_s =~ /#/ ?
            formats << option :
            fields << option.to_sym
        end
        formats << DEFAULT_FORMAT if formats.empty?
        fields  << :phone if fields.empty?

        send :include, InstanceMethods

        validates_each *fields do |record, attr, value|
          size_options = formats.collect {|a| a.count '#'}
          unless value.blank? || size_options.include?(value.scan(/\d/).size)
            if size_options.size > 1
              last = size_options.pop
              record.errors.add attr, "must have #{size_options.join(', ')} or #{last} digits."
            else
              record.errors.add attr, "must have #{size_options[0]} digits."
            end
          else
            record.format_phone_fields(fields, formats)
          end
        end
      end
    end

    module InstanceMethods

      def format_phone_fields(fields = [:phone], formats = [])
        formats << DEFAULT_FORMAT if formats.empty?
        fields.each do |field_name|
          format_phone_field(field_name, formats) unless send(field_name).blank?
        end
      end
      def format_phone_field(field_name, formats = [])
        formats << DEFAULT_FORMAT if formats.empty?
        self.send("#{field_name}=", self.send(field_name).to_s.to_phone(formats))
      end
    end
  end

  ActiveRecord::Base.send :include, ValidatesAndFormatsPhones
