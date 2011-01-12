# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, additional_text = nil, show_title = true)
    raw_title t("views.titles.#{page_title.to_s}"), additional_text, show_title
  end

  def raw_title(page_title, additional_text = nil, show_title = true)
    page_title = "#{page_title} - #{additional_text}" if additional_text 
    app_title = t('app.name')
    @content_for_title = "#{page_title} - #{app_title}"
    @show_title = show_title
    @content_for_page_title = content_tag(:h1, page_title) if show_title
  end



  def body_css(*args)
    content_for(:body_css) { args.join(" ") }
  end

  def app_version
    version = IO.readlines(Rails.root.join('VERSION')).first
    version_label = "#{I18n.t('application_version')} #{version}"
    version_label << " env: #{Rails.env}" unless Rails.env.production?
    content_tag :div, version_label, :class => 'app_version'
  end

  def support_mail_contact
    content_tag(:a, t('request_a_feature'), {:href => "mailto:support@vanilladesk.com?subject=#{t('new_feature_request')}"}) <<
    content_tag(:a, t('contact_support'), {:href => "mailto:support@vanilladesk.com?subject=#{t('vanilladesk_support')}"})
  end

  
  def codelist_js
    codelist = {
      :path => collection_path,
      :dash_type => model_class.to_s.underscore,
      :type => model_class.to_s,
      :count => model_class.count
    }
    content_for(:page_entity_js) { "var Page = Page || {};Page.codelist = #{codelist.to_json};" }
  end

  def collection_path
    params[:controller].split('/').last
  end

  # current model name (TicketSource, Impact, ....)
  def model_name
    collection_path.singularize
  end

  # current model class (TicketSource, Impact, ....)
  def model_class
    model_name.classify.constantize
  end





  def page_js(page_js)
    "pages/#{page_js}" 
  end

  def entity_js(item)
    entity = {
      :id => item.id.to_s,
      :type => item.class.to_s
    }
    content_for(:page_entity_js) { "var Page = Page || {};Page.entity = #{entity.to_json};" }
  end



  def show_title?
    @show_title
  end

  def theme(theme)
    stylesheet_link_tag "lib/jquery-ui/#{theme}/jquery-ui-1.7.2.custom"
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
end

