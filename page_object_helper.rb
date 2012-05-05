require 'capybara'
require 'capybara/rspec'
module PageObjectHelper

  ERROR_CSS_CLASS = ".alert-error"

  def initialize(capybara_page_obj, path=nil)
    @browser = capybara_page_obj
    set_path(path) if path
  end

  def set_path(path)
    @path = path
  end

  def visit
    @browser.visit @path
  end

  def self.included(cls)
    cls.extend ClassMethods
  end

  module ClassMethods
    [:h1, :h2, :h3, :h4, :h5, :h6, :span, :label].each do |element_type|
      define_method element_type do |name, options|
        options[:element_type] = element_type
        span_element(name, options)
      end
    end
    def button(name, options={})
      selector = discover_selector(options)
      define_method("click_#{name.to_s}_button") do
        @browser.find(selector).click
      end
      define_method("#{name.to_s}_button") do
        @browser.find(selector)
      end
    end
    def link(name, options={})
      selector = discover_selector(options)
      define_method("click_#{name.to_s}_link") do
        @browser.find(selector).click
      end
      define_method("#{name.to_s}_link") do
        @browser.find(selector)
      end
      define_method("#{name.to_s}_text") do
        @browser.find(selector).text
      end
    end
    def span_element(name, options={})
      selector = discover_selector(options)
      define_method(name) do
        @browser.find(selector).text
      end
      element_type = options[:element_type] || "span"
      define_method("#{name}_#{element_type}") do
        @browser.find(selector)
      end
    end
    def text_field(name, options={})
      selector = discover_selector(options)
      define_method(name) do
        @browser.find(selector).value
      end
      define_method("#{name}=") do |value|
        @browser.find(selector).set(value)
      end
      define_method("#{name}_text_field") do
        @browser.find(selector)
      end
    end
    def select_list(name, options={})
      selector = discover_selector(options)
      define_method(name) do
        @browser.find(selector).value
      end
      define_method("#{name}_select_list") do
        @browser.find(selector)
      end
      define_method("#{name}=") do |value|
        option_text = @browser.find("#{selector} option[value='#{value}']")
        option_text ||= @browser.find("#{selector} option[text='#{value}']")
        @browser.find(selector).select option_text
      end
      define_method("select_nth_option_in_#{name}") do |value|
        option_text = @browser.find("#{selector} option:nth-child(#{value})").text
        @browser.find(selector).select option_text
      end
      define_method("#{name}_number_of_options") do
        @browser.all("#{selector} option[value!='']").length
      end
    end

    def text_area(name, options={})

    end

    def check_box(name, options={})
      selector = discover_selector(options)
      define_method("check_#{name}_checkbox") do
        @browser.check(@browser.find(selector)[:id])
      end
      define_method("uncheck_#{name}_checkbox") do
        @browser.uncheck(@browser.find(selector)[:id])
      end
      define_method("#{name}_checkbox") do
        @browser.find(selector)
      end
      define_method("#{name}_checkbox_is_checked?") do
        @browser.find(selector)['checked']
      end
    end

    def table(name, options={})
      selector = discover_selector(options)
      define_method("#{name}_table") do
        @browser.find(selector)
      end
      define_method("#{name}_table_selector") do
        selector
      end
    end

    def form(name, options={})
      selector = discover_selector(options)
      define_method("#{name}_form") do
        @browser.find(selector)
      end
      define_method("#{name}_form_has_errors?") do
        @browser.within(:css, selector) do
          @browser.has_selector? ERROR_CSS_CLASS
        end
      end
    end



    private

    def discover_selector(options)
      if options[:selector]
        options[:id] ||= get_id_from_selector(options[:selector])
        return options[:selector]
      end
      return "##{options[:id]}" if options[:id]
      return ".#{options[:class]}" if options[:class]
    end

    def get_id_from_selector(selector)
      if %r(^#[\w\d-]+$).match(selector)
        return selector[1, selector.length - 1]
      end
      nil
    end
  end

end
