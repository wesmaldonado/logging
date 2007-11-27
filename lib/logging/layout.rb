# $Id$
 
require 'yaml'
require 'logging'

module Logging

  # The +Layout+ class provides methods for formatting log events into a
  # string representation. Layouts are used by Appenders to format log
  # events before writing them to the logging destination.
  #
  # All other Layouts inherit from this class which provides stub methods.
  # Each subclass should provide a +format+ method. A layout can be used by
  # more than one +Appender+ so all the methods need to be thread safe.
  #
  class Layout

    # call-seq:
    #    Layout.new( :format_as => :string )
    #
    # Creates a new layout that will format objecs as strings using the
    # given <tt>:format_as</tt> style. This can be one of <tt>:string</tt>,
    # <tt>:inspect</tt>, or <tt>:yaml</tt>. These formatting commands map to
    # the following object methods:
    #
    # * :string  => to_s
    # * :inspect => inspect
    # * :yaml    => to_yaml
    #
    # If the format is not specified then the global object format is used
    # (see Logging#format_as). If the global object format is not specified
    # then <tt>:string</tt> is used.
    #
    def initialize( opts = {} )
      f = opts[:format_as] || opts['format_as']
      f ||= ::Logging::OBJ_FORMAT if ::Logging.const_defined? 'OBJ_FORMAT'
      f = f.intern if f.instance_of? String

      @obj_format = case f
                    when :inspect, :yaml; f
                    else :string end
    end

    # call-seq:
    #    format( event )
    #
    # Returns a string representation of the given loggging _event_. It is
    # up to subclasses to implement this method.
    #
    def format( event ) nil end

    # call-seq:
    #    header
    #
    # Returns a header string to be used at the beginning of a logging
    # appender.
    #
    def header( ) '' end

    # call-seq:
    #    footer
    #
    # Returns a footer string to be used at the end of a logging appender.
    #
    def footer( ) '' end 


    protected

    # call-seq:
    #    format_obj( obj )
    #
    # Return a string representation of the given object. Depending upon
    # the configuration of the logger system the format will be an +inspect+
    # based represenation or a +yaml+ based representation.
    #
    def format_obj( obj )
      case obj
      when String; obj
      when Exception 
        str = "<#{obj.class.name}> #{obj.message}"
        unless obj.backtrace.nil?
          str << "\n\t" << obj.backtrace.join("\n\t")
        end
        str
      when nil; "<#{obj.class.name}> nil"
      else
        str = "<#{obj.class.name}> "
        str << case @obj_format
               when :inspect; obj.inspect
               when :yaml; "\n#{obj.to_yaml}"
               else obj.to_s end
        str
      end
    end

  end  # class Layout
end  # module Logging

# EOF
