# Unidom Region China 中国行政区划领域模型引擎

[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/unidom-region-china.svg)](https://badge.fury.io/rb/unidom-region-china)

Unidom (UNIfied Domain Object Model) is a series of domain model engines. The China Region domain model engine includes the Region model and its migration.
Unidom (统一领域对象模型)是一系列的领域模型引擎。中国行政区划领域模型引擎包括中国大陆的行政区划模型及其数据迁移脚本。



## Recent Update
Check out the [Road Map](ROADMAP.md) to find out what's the next.
Check out the [Change Log](CHANGELOG.md) to find out what's new.
This gem is deprecated, please use [unidom-geo-china](https://github.com/topbitdu/unidom-geo-china) instead.



## Usage in Gemfile
```ruby
gem 'unidom-region-china'
```



## Run the Database Migration
```shell
rake db:migrate
```



## Import Data
```shell
bundle exec rake unidom:region:china:import file=/china-region-data/NBS-county/20141031.csv from_date=2014-10-31 scheme_id= scheme_type=
```



## Call the Model
```ruby
Unidom::Region::China::Region.root_level # All the 31 province-level regions including Beijing, Tianjin, etc.
Unidom::Region::China::Region.numeric_coded_as('120000').valid_at.alive.first # Tianjin (天津)
```
