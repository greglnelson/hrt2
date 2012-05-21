require 'app/reports/base'
require 'app/charts/base'
class Reports::DistrictSplit < Reports::Base
  include CurrencyNumberHelper
  include ActionView::Helpers::NumberHelper

  attr_accessor :request, :locations

  def initialize(request)
    @request = request
    @locations = Location.find(:all, :order => 'short_display ASC')
  end

  def unit
    "%"
  end

  def collection
    percentage_by_districts
  end

  def format(value)
    number_to_percentage(value,  :precision => 2)
  end

  private
  def percentage_by_districts
    national  = locations.detect{|l| l.short_display == 'National Level' }
    districts = locations.select{|l| l != national}

    percentages = []

    percentages << district_percentages(national) if national

    districts.each do |district|
      percentages << district_percentages(district)
    end

    percentages
  end

  def total_budget
    @total_budget ||= amount_by_district.inject(0) do |acc, district|
      acc += district[1][:budget]
    end
  end

  def total_spend
    @total_spend ||= amount_by_district.inject(0) do |acc, district|
      acc += district[1][:spend]
    end
  end

  def amount_by_district
    @amount_by_district ||= map_data(code_assignments)
  end

  def code_assignments
    CodeAssignment.find :all,
      :select => 'code_assignments.type AS klass, codes.short_display AS district,
        SUM("code_assignments".cached_amount) AS amount,
        COALESCE(projects.currency, organizations.currency) AS amount_currency',
      :joins => 'INNER JOIN "codes" ON "codes".id = "code_assignments".code_id
                 INNER JOIN "activities" ON "activities".id = "code_assignments".activity_id
                 LEFT OUTER JOIN "projects" ON "projects".id = "activities".project_id
                 INNER JOIN "data_responses" ON "data_responses".id = "activities".data_response_id
                 INNER JOIN "organizations" ON "organizations".id = "data_responses".organization_id',
      :conditions => ["data_responses.data_request_id = ? AND
                  code_assignments.type IN
                  ('CodingBudgetDistrict', 'CodingSpendDistrict')", request.id],
      :group => 'klass, district, amount_currency'

  end

  def district_percentages(district)
    spend  = amount_by_district[district.short_display][:spend] * 100 / total_spend
    budget = amount_by_district[district.short_display][:budget] * 100 / total_budget
    Reports::Row.new(district.short_display, spend.to_f.round_with_precision(2),
                     budget.to_f.round_with_precision(2))
  end

  def map_data(collection)
    result = {}
    locations.each { |location| result[location.short_display] ||= Hash.new(0) }

    collection.each do |e|
      result[e.district][method_from_class(e.klass.to_s)] +=
        universal_currency_converter(e.amount.to_f, e.amount_currency, 'RWF')
    end
    result
  end
end
