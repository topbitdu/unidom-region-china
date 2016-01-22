# Unidom Region China

Unidom (UNIfied Domain Object Model) is a series of domain model engines. The China Region domain model engine includes the Region model and its migration.
Unidom (统一领域对象模型)是一系列的领域模型引擎。中国行政区划领域模型引擎包括中国大陆的行政区划模型及其数据迁移脚本。

## Usage in Gemfile:
```ruby
gem 'unidom-region-china'
```

## Run the Database Migration:
```shell
rake db:migrate
```

## Import Data:
```shell
bundle exec rake unidom:region:china:import file=/china-region-data/NBS-county/20141031.csv from_date=2014-10-31 scheme_id= scheme_type=
```

## Call the Model:
```ruby
Unidom::Region::China::Region.numeric_coded_as('120000').valid_at.alive.first # Tianjing (天津)
```
