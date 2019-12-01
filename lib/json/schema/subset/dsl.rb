require "json/schema/subset/dsl/version"

module Json
  module Schema
    module Subset
      class DSL
        def initialize(type: "object", schema: {}, params: {}, ref: nil, options: nil, &block)
          @type = type
          @schema = schema
          @params = params
          @ref = ref
          @options = options || {}
          @optionals = []
          set!(&block) if block_given?
        end

        def set!(&block)
          instance_eval(&block)
        end

        def compile!
          return { "$ref" => @ref } if @ref

          case
          when Array(@type).include?("array")
            ret = @schema.dup
            ret["type"] = @type
            ret["items"] = ret["items"].compile!
            ret.merge(@params.map { |k, v| [k.to_s, v] }.to_h)
          when Array(@type).include?("object")
            required = @schema.keys - @optionals
            ret = { "type" => @type, "properties" => @schema.map { |k, v| [k, v.compile!] }.to_h }
            ret["required"] = required unless required.empty?
            ret.merge(@params.map { |k, v| [k.to_s, v] }.to_h)
          else
            @schema.merge("type" => @type).merge(@params).map { |k, v| [k.to_s, v] }.to_h
          end
        end

        # toplevel

        %w[string integer number boolean null].each do |type|
          define_method(:"#{type}!") do |args = {}|
            change_type!(type)
            @schema.merge!(args)
          end
        end

        def ref!(name)
          @ref = name.to_s
        end

        def cref!(name)
          ref! components!(name)
        end

        def dref!(name)
          ref! definitions!(name)
        end

        def components!(name)
          "#/components/#{canon_name!(name)}"
        end

        def definitions!(name)
          "#/definitions/#{canon_name!(name)}"
        end

        def array!(&block)
          change_type!("array")
          @schema["items"] = DSL.new(options: @options, &block)
        end

        def respond_to_missing?(name, include_private)
          true
        end

        def method_missing(name, *args, &block)
          if name.to_s.end_with?("!")
            if block_given?
              @params[name[0...-1]] = DSL.new(options: @options, &block).compile!
            else
              @params[name[0...-1]] = args[0]
            end
            return
          end

          type = args.first
          opts = args.count > 1 && args.last.is_a?(Hash) ? args.last || {} : {}

          optional = opts.delete(:optional)
          @optionals << name.to_s if optional
          type = type.is_a?(Array) ? type.map(&:to_s) : type.to_s
          case
          when type == "ref"
            @schema[name.to_s] = DSL.new(ref: args[1], options: @options, &block)
          when type == "cref"
            @schema[name.to_s] = DSL.new(ref: components!(args[1]), options: @options, &block)
          when type == "dref"
            @schema[name.to_s] = DSL.new(ref: definitions!(args[1]), options: @options, &block)
          when Array(type).include?("array")
            @schema[name.to_s] =
              DSL.new(
                type: type, params: opts, schema: { "items" => DSL.new(options: @options, &block) }, options: @options,
              )
          when Array(type).include?("object")
            @schema[name.to_s] = DSL.new(type: type, params: opts, options: @options, &block)
          else
            @schema[name.to_s] = DSL.new(type: type, schema: opts, options: @options, &block)
          end
        end

        def change_type!(type)
          case @type
          when "object"
            if type == "null"
              @type = %w[object null]
            else
              @type = type
            end
          else
            @type = Array(@type) + [type]
          end
        end

        def canon_name!(name)
          @options[:reference_name] ? @options[:reference_name].call(name.to_s) : name.to_s
        end
      end
    end
  end
end
