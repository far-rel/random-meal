class CreateFavoriteMeals < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_meals do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :meal_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :favorite_meals, %i[user_id meal_id], unique: true
  end
end
