class CreateAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :assets do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
