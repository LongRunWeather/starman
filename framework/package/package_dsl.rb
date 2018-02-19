module PackageDSL
  def self.included base
    base.extend self
  end

  def spec
    package_class = self.name.split('::').last
    return self.class_variable_get "@@#{package_class}_spec"  if self.class_variable_defined? "@@#{package_class}_spec"
    self.class_variable_set "@@#{package_class}_spec", PackageSpec.new 
  end

  [:url, :mirror, :sha256, :version, :file_name].each do |keyword|
    self.define_method(keyword) do |val|
      spec.send "#{keyword}=", val
    end
  end

  [:label, :depends_on].each do |keyword|
    self.define_method(keyword) do |val, options = {}|
      spec.send keyword, val, options
    end
  end

  def option name, desc, options = {}
    name = name.gsub('-', '_').to_sym
    options[:desc] = desc
    options[:type] = :boolean if not options[:type]
    spec.option name, options
    # Create a helper for querying option.
    case options[:type]
    when :boolean
      define_method(:"#{name}?") do
        @spec.options[name][:value]
      end
      self.class.define_method(:"#{name}?") do
        self.class.class_variable_get("@@#{self}_spec").options[name][:value]
      end
    end
  end

  def skip_test?
    CommandParser.args[:skip_test]
  end
end
