module OrganizationsHelper
  def organization_response(organization, data_request)
    organization.data_responses.detect { |dr| dr.data_request == data_request }
  end

  def input_options(label = nil, hint = nil, required = false, label_class = 'indented', wrapper_class = 'input-wrapper')
    return  {label: label, hint: hint,
            label_html: { class: label_class, required: required },
            wrapper_html: { class: wrapper_class }}
  end

  def input_date(value, label = nil, hint = nil, required = true, label_class = 'indented', wrapper_class = 'input-wrapper')
    return {value: formatted_date(value), class: "date_picker",
      label: label, required: required,
      hint: hint, label_html: { class: label_class },
      wrapper_html: { class: wrapper_class }}
  end

  def select_options(label = nil, hint = nil, required = true, label_class = 'indented', wrapper_class = 'input-wrapper', input_class = 'string required')
    return {label: label, hint: hint,
      label_html: { class: label_class, required: required},
      wrapper_html: { class: wrapper_class },
      input_html: { class: input_class }}
  end

  def name_hint
    "What is the name of the organization?"
  end

  def raw_type_hint
    "Raw type of organization"
  end

  def funder_type_hint
    "Funder type of organization"
  end

  def implementer_type_hint
    "Implementer type of organization"
  end

  def fosaid_hint
    "Fosaid of organization"
  end

  def currency_hint
    "You can override the currency for individual projects
    should you deem it necessary."
  end

  def contact_name_hint
    "The primary contact at your organization that will help the Health
    Resource Tracker team if there are any questions throughout the process."
  end

  def contact_position_hint
    "The position of the contact at your organization."
  end

  def phone_number_hint
    "A telephone number that can be used to contact the contact person."
  end

  def contact_main_office_phone_number_hint
    "The telephone number of the organizations main office."
  end

  def office_location_hint
    "The geographic location of the office."
  end

  def start_month_hint
    "The month in which your organization's fiscal year starts."
  end
end
