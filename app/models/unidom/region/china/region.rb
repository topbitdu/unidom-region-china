# Region 是中国行政区划。
# 《GB/T 2260-2007 中华人民共和国行政区划代码》
# 数字码采用三层六位层次码结构，按层次分别表示我国各
#   省（自治区，直辖市，特别行政区）、
#   市（地区，自治州，盟）、
#   县（自治县、县级市、旗、自治旗、市辖区、林区、特区）。
#   第1、2位数字：所在省份编码，表示省、自治区、直辖市、特别行政区。 
#   第3、4位数字：所在省级市（县）编码，表示市、地区、自治州、盟、直辖市所辖市辖区、县汇总码、省（自治区）直辖县级行政区划汇总码。 
#     01~20、51~70表示市，直辖市则01表示市区，02以后表示直辖市辖区内的郊县；
#     21~50表示地区、自治州、盟；
#     90表示省（自治区）直辖县级行政区划汇总码。
#   第5、6位数字：所在地级县（市）编码，表示县、自治县、县级市、旗、自治旗、市辖区、林区、特区。
#     01~20表示市辖区、地区（自治州、盟）辖县级市、市辖特区以及省（自治区）直辖县级行政区划中的县级市，01通常表示辖区汇总码；
#     21~80表示县、自治县、旗、自治旗、林区、地区辖特区；
#     81~99表示省（自治区）辖县级市。
# 字母代码的编制原则和结构
#   行政区划字母代码(简称字母码)遵循科学性、统一性、实用性编码原则，参照县及县以上行政区划名称的罗马字母拼写，取相应的字母编制。
#   省、自治区、直辖市、特别行政区的字母码用两位大写字母表示。
#   市、地区、自治州、盟、县、自治县、县级市、旗、自治旗、市辖区、林区、特区的字母码用三位大写字母表示。

class Unidom::Region::China::Region < ActiveRecord::Base

  # MDUCG = MUNICIPALITY DIRECT UNDER CENTRAL GOVERNMENT
  MDUCG_CODES = [ '11', '12', '31', '50' ].freeze

  self.table_name = 'unidom_china_regions'

  validates :numeric_code,    numericality: { integer_only: true }
  validates :alphabetic_code, allow_blank: true, length: { minimum: 2 }
  validates :name,            presence: true,    length: { maximum: self.columns_hash['name'].limit }

  belongs_to :scheme,    polymorphic: true
  has_many   :locations, class_name: 'Unidom::Geo::Location', as: :region

  scope :scheme_is,      ->(scheme) { scheme.present? ? where(scheme: scheme) : scheme_id_is.scheme_type_is }
  scope :scheme_id_is,   ->(scheme_id   = ::Unidom::Common::NULL_UUID) { where scheme_id:   scheme_id   }
  scope :scheme_type_is, ->(scheme_type = ''                         ) { where scheme_type: scheme_type }

  scope :name_is,       ->(name)           { where name:    name    }
  scope :being_virtual, ->(virtual = true) { where virtual: virtual }

  include ::Unidom::Common::Concerns::ModelExtension

  def numeric_code_prefix
    numeric_code[0..1]
  end

  def numeric_code_middle
    numeric_code[2..3]
  end

  def numeric_code_suffix
    numeric_code[4..5]
  end

  def numeric_code_middle_empty?
    '00'==numeric_code_middle
  end

  def numeric_code_suffix_empty?
    '00'==numeric_code_suffix
  end

  def district?
    numeric_code_suffix.to_i<20
  end

  def under_mducg?
    self.class::MDUCG_CODES.include? numeric_code_prefix
  end

  def mducg?
    under_mducg? && numeric_code_middle_empty? && numeric_code_suffix_empty?
  end

  def super_regions
    numeric_code_suffix_empty? ? (numeric_code_middle_empty? ? self.class.none : self.class.numeric_coded_as("#{numeric_code_prefix}0000")) : self.class.numeric_coded_as("#{numeric_code_prefix}#{numeric_code_middle}00")
  end

  def sub_regions
    if numeric_code_suffix_empty?
      prefix  = numeric_code_middle_empty? ? numeric_code_prefix : "#{numeric_code_prefix}#{numeric_code_middle}"
      regions = self.class.numeric_code_starting_with(prefix).not_numeric_coded_as(numeric_code)
      regions = regions.numeric_code_ending_with('00') if numeric_code_middle_empty?
      regions
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

  def under?(region)
    return false unless region.numeric_code_prefix==numeric_code_prefix
    return false if     numeric_code_middle_empty?
    return true  if     region.numeric_code_middle_empty?
    numeric_code_suffix_empty? ? false : region.numeric_code_suffix_empty?
  end

end
