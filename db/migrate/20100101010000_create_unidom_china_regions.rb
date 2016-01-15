class CreateUnidomChinaRegions < ActiveRecord::Migration

  def change

    create_table :unidom_china_regions, id: :uuid do |t|

      t.column :code, 'char(6)', null: false, default: '0'*6
      t.string :name,            null: false, default: '', limit: 200

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

    add_index :unidom_china_regions, :code, unique: true

  end

end
