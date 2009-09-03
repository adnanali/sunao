class CreateAdminContentTypes < ActiveRecord::Migration
  def self.up
    create_table :admin_content_types do |t|
      t.text :title

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_content_types
  end
end
