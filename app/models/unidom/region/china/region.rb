class Unidom::Region::China::Region < ActiveRecord::Base

  MUNICIPALITY_CODES_DIRECT_UNDER_CENTRAL_GOVERNMENT = [ '11', '12', '31', '50' ]

  self.table_name = 'unidom_china_regions'

  validates :name, presence: true, length: { maximum: self.columns_hash['name'].limit }
  validates :code, numericality: { integer_only: true }

  has_many :locations, class_name: 'Unidom::Geo::Location', as: :region

  scope :code_starting_with, ->(prefix)         { where 'code LIKE :prefix', prefix: prefix+'%' }
  scope :code_ending_with,   ->(suffix)         { where 'code LIKE :suffix', suffix: '%'+suffix }
  scope :being_virtual,      ->(virtual = true) { where virtual: virtual }
  scope :name_is,            ->(name)           { where name:    name    }

  include ::Unidom::Common::ModelExtension

  def code_prefix
    code[0..1]
  end

  def code_middle
    code[2..3]
  end

  def code_suffix
    code[4..5]
  end

  def code_middle_empty?
    '00'==code_middle
  end

  def code_suffix_empty?
    '00'==code_suffix
  end

  def district?
    code_suffix.to_i<20
  end

  def municipality_direct_under_central_government?
    self.class::MUNICIPALITY_CODES_DIRECT_UNDER_CENTRAL_GOVERNMENT.include?(code_prefix)&&code_middle_empty?&&code_suffix_empty?
  end

  def under_municipality_direct_under_central_government?
    self.class::MUNICIPALITY_CODES_DIRECT_UNDER_CENTRAL_GOVERNMENT.include? code_prefix
  end

  def super_regions
    code_suffix_empty? ? (code_middle_empty? ? self.class.none : self.class.coded_as("#{code_prefix}0000")) : self.class.coded_as("#{code_prefix}#{code_middle}00")
  end

  def sub_regions
    if code_suffix_empty?
      regions = self.class.not_coded_as code
      regions = code_middle_empty? ? regions.code_starting_with(code_prefix).code_ending_with('00') : regions.code_starting_with("#{code_prefix}#{code_middle}")
    else
      self.class.none
    end
  end

  def full_name(separator = ' ')
    final_name     = self.name
    current_region = self
    count          = 0
    while current_region = current_region.super_regions.first
      count += 1
      final_name = "#{current_region.name}#{separator}#{final_name}" unless current_region.virtual?
      break if count>5
    end
    final_name
  end

  def municipality_direct_under_central_government?
    self.class::MUNICIPALITY_CODES_DIRECT_UNDER_CENTRAL_GOVERNMENT.include? code
  end

  def under_municipality_direct_under_central_government?
    self.class::MUNICIPALITY_CODES_DIRECT_UNDER_CENTRAL_GOVERNMENT.include? code_prefix
  end

  def under?(region)
    region_code = region.respond_to?(:code) ? region.code : region
    self.code.start_with? region_code
  end

end
