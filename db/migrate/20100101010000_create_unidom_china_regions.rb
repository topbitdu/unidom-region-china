class CreateUnidomChinaRegions < ActiveRecord::Migration

  def change

    create_table :unidom_china_regions, id: :uuid do |t|

      t.references :schema, type: :uuid, null: false,
        polymorphic: { null: false, default: '', limit: 200 }

      t.column :numeric_code, 'char(6)', null: false, default: '0'*6
      t.string :alphabetic_code,         null: true,  default: nil, limit: 3

      t.string  :name,    null: false, default: '', limit: 200
      t.boolean :virtual, null: false, default: false

      t.text :instruction
      t.text :description

      t.column   :state, 'char(1)', null: false, default: 'C'
      t.datetime :opened_at,        null: false, default: ::Time.utc(1970)
      t.datetime :closed_at,        null: false, default: ::Time.utc(3000)
      t.boolean  :defunct,          null: false, default: false
      t.jsonb    :notation,         null: false, default: {}

      t.timestamps null: false

    end

    add_index :unidom_china_regions, :schema_id
    add_index :unidom_china_regions, [ :numeric_code,    :schema_id, :schema_type ], unique: true, name: 'index_unidom_china_regions_on_numeric_code_and_schema'
    add_index :unidom_china_regions, [ :alphabetic_code, :schema_id, :schema_type ], unique: true, name: 'index_unidom_china_regions_on_alphabetic_code_and_schema'

  end

end
